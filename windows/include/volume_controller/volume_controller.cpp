#include "volume_controller.h"

#include <iostream>

namespace volume_controller
{
    namespace
    {
        constexpr UINT kRebindMessage = WM_APP + 1;
        constexpr wchar_t kRebindWindowClass[] =
            L"com.kurenai7968.volume_controller.DeviceRebind";
    }

    class DeviceNotificationClient : public IMMNotificationClient
    {
    public:
        explicit DeviceNotificationClient(VolumeController *owner) : owner_(owner) {}

        ULONG STDMETHODCALLTYPE AddRef() override
        {
            return InterlockedIncrement(&ref_count_);
        }

        ULONG STDMETHODCALLTYPE Release() override
        {
            ULONG ref = InterlockedDecrement(&ref_count_);
            if (ref == 0)
            {
                delete this;
            }
            return ref;
        }

        HRESULT STDMETHODCALLTYPE QueryInterface(REFIID riid, VOID **ppvInterface) override
        {
            if (ppvInterface == nullptr)
            {
                return E_POINTER;
            }

            if (riid == IID_IUnknown || riid == __uuidof(IMMNotificationClient))
            {
                AddRef();
                *ppvInterface = static_cast<IMMNotificationClient *>(this);
                return S_OK;
            }

            *ppvInterface = nullptr;
            return E_NOINTERFACE;
        }

        HRESULT STDMETHODCALLTYPE OnDeviceStateChanged(LPCWSTR, DWORD) override
        {
            return S_OK;
        }

        HRESULT STDMETHODCALLTYPE OnDeviceAdded(LPCWSTR) override
        {
            return S_OK;
        }

        HRESULT STDMETHODCALLTYPE OnDeviceRemoved(LPCWSTR) override
        {
            return S_OK;
        }

        HRESULT STDMETHODCALLTYPE OnDefaultDeviceChanged(EDataFlow flow, ERole role, LPCWSTR) override
        {
            if (owner_ && flow == eRender && (role == eMultimedia || role == eConsole))
            {
                owner_->OnDefaultDeviceChanged();
            }
            return S_OK;
        }

        HRESULT STDMETHODCALLTYPE OnPropertyValueChanged(LPCWSTR, const PROPERTYKEY) override
        {
            return S_OK;
        }

    private:
        VolumeController *owner_;
        LONG ref_count_ = 1;
    };

    VolumeController &VolumeController::GetInstance()
    {
        static VolumeController instance;
        return instance;
    }

    bool VolumeController::Initialize()
    {
        std::lock_guard<std::recursive_mutex> lock(mutex_);
        if (init_count_ > 0)
        {
            ++init_count_;
            return pVolume_ != nullptr;
        }

        if (!InitializeLocked())
        {
            return false;
        }

        init_count_ = 1;
        return true;
    }

    void VolumeController::Dispose()
    {
        std::lock_guard<std::recursive_mutex> lock(mutex_);
        if (init_count_ == 0)
        {
            return;
        }

        --init_count_;
        if (init_count_ == 0)
        {
            DisposeLocked();
        }
    }

    bool VolumeController::InitializeLocked()
    {
        HRESULT hr = CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);
        if (SUCCEEDED(hr))
        {
            com_needs_uninit_ = true;
        }
        else if (hr == RPC_E_CHANGED_MODE)
        {
            com_needs_uninit_ = false;
        }
        else
        {
            std::cerr << "Failed to initialize COM library: " << hr << std::endl;
            return false;
        }

        hr = CoCreateInstance(
            __uuidof(MMDeviceEnumerator), nullptr, CLSCTX_ALL,
            __uuidof(IMMDeviceEnumerator), (void **)&pEnumerator_);
        if (FAILED(hr))
        {
            std::cerr << "Failed to create device enumerator: " << hr << std::endl;
            DisposeLocked();
            return false;
        }

        EnsureRebindWindowLocked();

        pDeviceClient_ = new DeviceNotificationClient(this);
        hr = pEnumerator_->RegisterEndpointNotificationCallback(pDeviceClient_);
        if (FAILED(hr))
        {
            std::cerr << "Failed to register endpoint notification callback: " << hr << std::endl;
            pDeviceClient_->Release();
            pDeviceClient_ = nullptr;
        }

        if (!BindDefaultEndpointLocked())
        {
            DisposeLocked();
            return false;
        }

        return true;
    }

    void VolumeController::DisposeLocked()
    {
        if (pEnumerator_ && pDeviceClient_)
        {
            pEnumerator_->UnregisterEndpointNotificationCallback(pDeviceClient_);
        }
        if (pDeviceClient_)
        {
            pDeviceClient_->Release();
            pDeviceClient_ = nullptr;
        }

        DestroyRebindWindowLocked();
        DisposeVolumeNotification();
        ReleaseEndpointLocked();

        if (pEnumerator_)
        {
            pEnumerator_->Release();
            pEnumerator_ = nullptr;
        }
        if (com_needs_uninit_)
        {
            CoUninitialize();
            com_needs_uninit_ = false;
        }
    }

    bool VolumeController::BindDefaultEndpointLocked()
    {
        if (!pEnumerator_)
        {
            return false;
        }

        IMMDevice *pDevice = nullptr;
        HRESULT hr = pEnumerator_->GetDefaultAudioEndpoint(eRender, eMultimedia, &pDevice);
        if (FAILED(hr))
        {
            std::cerr << "Failed to get default audio endpoint: " << hr << std::endl;
            return false;
        }

        IAudioEndpointVolume *pVolume = nullptr;
        hr = pDevice->Activate(__uuidof(IAudioEndpointVolume), CLSCTX_ALL, nullptr, (void **)&pVolume);
        pDevice->Release();
        if (FAILED(hr))
        {
            std::cerr << "Failed to activate audio endpoint volume: " << hr << std::endl;
            return false;
        }

        ReleaseEndpointLocked();
        pVolume_ = pVolume;

        if (pCallback_)
        {
            hr = pVolume_->RegisterControlChangeNotify(pCallback_);
            if (FAILED(hr))
            {
                std::cerr << "Failed to register volume notification: " << hr << std::endl;
                // Keep pCallback_. It belongs to the Dart EventChannel
                // subscription, not this endpoint. Releasing it here would
                // leave the Dart listener silent until it is torn down and
                // attached again. A later rebind can register it.
            }
        }

        return true;
    }

    void VolumeController::ReleaseEndpointLocked()
    {
        if (pVolume_ && pCallback_)
        {
            pVolume_->UnregisterControlChangeNotify(pCallback_);
        }
        if (pVolume_)
        {
            pVolume_->Release();
            pVolume_ = nullptr;
        }
    }

    void VolumeController::OnDefaultDeviceChanged()
    {
        // IMMNotificationClient must not wait on a lock or call enumerator
        // methods. Post the rebind onto the thread that owns the COM objects.
        HWND hwnd = hwnd_.load(std::memory_order_acquire);
        if (hwnd)
        {
            PostMessageW(hwnd, kRebindMessage, 0, 0);
        }
    }

    void VolumeController::RebindDefaultEndpoint()
    {
        std::lock_guard<std::recursive_mutex> lock(mutex_);
        if (init_count_ == 0)
        {
            return;
        }
        BindDefaultEndpointLocked();
    }

    void VolumeController::EnsureRebindWindowLocked()
    {
        if (hwnd_.load(std::memory_order_relaxed))
        {
            return;
        }

        HMODULE instance = GetPluginModule();
        WNDCLASSW window_class = {};
        window_class.lpfnWndProc = WndProc;
        window_class.hInstance = instance;
        window_class.lpszClassName = kRebindWindowClass;
        if (!RegisterClassW(&window_class))
        {
            const DWORD error = GetLastError();
            if (error != ERROR_CLASS_ALREADY_EXISTS)
            {
                std::cerr << "Failed to register device-rebind window class: " << error << std::endl;
                return;
            }
        }

        HWND hwnd = CreateWindowExW(0, kRebindWindowClass, L"", 0, 0, 0, 0, 0,
                                    HWND_MESSAGE, nullptr, instance, nullptr);
        if (!hwnd)
        {
            std::cerr << "Failed to create device-rebind window: " << GetLastError() << std::endl;
            return;
        }

        SetWindowLongPtrW(hwnd, GWLP_USERDATA, reinterpret_cast<LONG_PTR>(this));
        hwnd_.store(hwnd, std::memory_order_release);
    }

    void VolumeController::DestroyRebindWindowLocked()
    {
        HWND hwnd = hwnd_.exchange(nullptr, std::memory_order_acq_rel);
        if (!hwnd)
        {
            return;
        }

        MSG message;
        while (PeekMessageW(&message, hwnd, kRebindMessage, kRebindMessage, PM_REMOVE))
        {
        }

        DestroyWindow(hwnd);
    }

    HMODULE VolumeController::GetPluginModule()
    {
        HMODULE module = nullptr;
        GetModuleHandleExW(GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS |
                               GET_MODULE_HANDLE_EX_FLAG_UNCHANGED_REFCOUNT,
                           reinterpret_cast<LPCWSTR>(&GetPluginModule), &module);
        return module;
    }

    LRESULT CALLBACK VolumeController::WndProc(HWND hwnd, UINT message, WPARAM wparam, LPARAM lparam)
    {
        if (message == kRebindMessage)
        {
            auto *self = reinterpret_cast<VolumeController *>(GetWindowLongPtrW(hwnd, GWLP_USERDATA));
            if (self)
            {
                self->RebindDefaultEndpoint();
            }
            return 0;
        }

        return DefWindowProcW(hwnd, message, wparam, lparam);
    }

    float VolumeController::GetVolume()
    {
        std::lock_guard<std::recursive_mutex> lock(mutex_);
        if (!pVolume_)
        {
            return 0;
        }

        float currentVolume = 0.0;
        HRESULT hr = pVolume_->GetMasterVolumeLevelScalar(&currentVolume);
        if (FAILED(hr))
        {
            std::cerr << "Failed to get master volume level: " << hr << std::endl;
            return 0;
        }

        return currentVolume;
    }

    bool VolumeController::SetVolume(float volume)
    {
        std::lock_guard<std::recursive_mutex> lock(mutex_);
        if (!pVolume_)
        {
            return false;
        }

        HRESULT hr = pVolume_->SetMasterVolumeLevelScalar(volume, nullptr);
        if (FAILED(hr))
        {
            std::cerr << "Failed to set master volume level: " << hr << std::endl;
            return false;
        }

        return true;
    }

    bool VolumeController::IsMuted()
    {
        std::lock_guard<std::recursive_mutex> lock(mutex_);
        if (!pVolume_)
        {
            return false;
        }

        BOOL isMuted = FALSE;
        HRESULT hr = pVolume_->GetMute(&isMuted);
        if (FAILED(hr))
        {
            std::cerr << "Failed to get mute status: " << hr << std::endl;
            return false;
        }

        return isMuted == TRUE;
    }

    bool VolumeController::SetMute(bool isMute)
    {
        std::lock_guard<std::recursive_mutex> lock(mutex_);
        if (!pVolume_)
        {
            return false;
        }

        HRESULT hr = pVolume_->SetMute(isMute, nullptr);
        if (FAILED(hr))
        {
            std::cerr << "Failed to set mute status: " << hr << std::endl;
            return false;
        }

        return true;
    }

    bool VolumeController::RegisterVolumeNotification(volume_callback::VolumeCallback *callback)
    {
        std::lock_guard<std::recursive_mutex> lock(mutex_);
        DisposeVolumeNotification();

        if (!pVolume_ || !callback)
        {
            if (callback)
            {
                callback->Release();
            }
            return false;
        }

        HRESULT hr = pVolume_->RegisterControlChangeNotify(callback);
        if (FAILED(hr))
        {
            std::cerr << "Failed to register volume notification: " << hr << std::endl;
            callback->Release();
            return false;
        }

        pCallback_ = callback;
        return true;
    }

    void VolumeController::DisposeVolumeNotification()
    {
        std::lock_guard<std::recursive_mutex> lock(mutex_);
        if (pVolume_ && pCallback_)
        {
            pVolume_->UnregisterControlChangeNotify(pCallback_);
            pCallback_->Release();
            pCallback_ = nullptr;
        }
        else if (pCallback_)
        {
            pCallback_->Release();
            pCallback_ = nullptr;
        }
    }
}

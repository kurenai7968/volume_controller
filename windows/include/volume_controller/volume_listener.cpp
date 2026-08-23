#include "volume_listener.h"

namespace volume_listener
{
    VolumeListener &VolumeListener::GetInstance()
    {
        static VolumeListener instance;
        return instance;
    }

    bool VolumeListener::Initialize()
    {
        IMMDeviceEnumerator *pEnumerator = nullptr;
        IMMDevice *pDevice = nullptr;

        HRESULT hr = CoInitialize(nullptr);
        if (FAILED(hr))
        {
            std::cerr << "Failed to initialize COM library: " << hr << std::endl;
            return false;
        }

        hr = CoCreateInstance(
            __uuidof(MMDeviceEnumerator), nullptr, CLSCTX_ALL,
            __uuidof(IMMDeviceEnumerator), (void **)&pEnumerator);

        if (FAILED(hr))
        {
            std::cerr << "Failed to create device enumerator: " << hr << std::endl;
            CoUninitialize();
            return false;
        }

        hr = pEnumerator->GetDefaultAudioEndpoint(eRender, eMultimedia, &pDevice);
        if (FAILED(hr))
        {
            std::cerr << "Failed to get default audio endpoint: " << hr << std::endl;
            pEnumerator->Release();
            CoUninitialize();
            return false;
        }

        hr = pDevice->Activate(__uuidof(IAudioEndpointVolume), CLSCTX_ALL, nullptr, (void **)&pVolume_);
        if (FAILED(hr))
        {
            std::cerr << "Failed to activate audio endpoint volume: " << hr << std::endl;
            pDevice->Release();
            pEnumerator->Release();
            CoUninitialize();
            return false;
        }

        pDevice->Release();
        pEnumerator->Release();

        return true;
    }

    void VolumeListener::Dispose()
    {
        DisposeVolumeNotification();
        if (pVolume_)
        {
            pVolume_->Release();
            pVolume_ = nullptr;
        }
        CoUninitialize();
    }

    bool VolumeListener::RegisterVolumeNotification(volume_callback::VolumeCallback *callback)
    {
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

    void VolumeListener::DisposeVolumeNotification()
    {
        if (pVolume_ && pCallback_)
        {
            pVolume_->UnregisterControlChangeNotify(pCallback_);
            pCallback_->Release();
            pCallback_ = nullptr;
        }
    }
}
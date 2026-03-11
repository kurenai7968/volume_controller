#include "volume_listener.h"
#include <wrl/client.h>

namespace volume_controller
{
    VolumeListener::~VolumeListener()
    {
        Dispose();
    }

    VolumeListener &VolumeListener::GetInstance()
    {
        static VolumeListener instance;
        return instance;
    }

    bool VolumeListener::Initialize()
    {
        if (endpoint_volume_)
            return true;

        HRESULT hr = CoInitialize(nullptr);
        if (FAILED(hr) && hr != RPC_E_CHANGED_MODE)
        {
            std::cerr << "Failed to initialize COM library: " << std::hex << hr << std::endl;
            return false;
        }

        Microsoft::WRL::ComPtr<IMMDeviceEnumerator> enumerator;
        hr = CoCreateInstance(
            __uuidof(MMDeviceEnumerator), nullptr, CLSCTX_ALL,
            IID_PPV_ARGS(&enumerator));

        if (FAILED(hr))
        {
            std::cerr << "Failed to create device enumerator: " << std::hex << hr << std::endl;
            return false;
        }

        Microsoft::WRL::ComPtr<IMMDevice> device;
        hr = enumerator->GetDefaultAudioEndpoint(eRender, eMultimedia, &device);
        if (FAILED(hr))
        {
            std::cerr << "Failed to get default audio endpoint: " << std::hex << hr << std::endl;
            return false;
        }

        hr = device->Activate(__uuidof(IAudioEndpointVolume), CLSCTX_ALL, nullptr, &endpoint_volume_);
        if (FAILED(hr))
        {
            std::cerr << "Failed to activate audio endpoint volume: " << std::hex << hr << std::endl;
            return false;
        }

        return true;
    }

    void VolumeListener::Dispose()
    {
        DisposeVolumeNotification();
        endpoint_volume_.Reset();
    }

    bool VolumeListener::RegisterVolumeNotification(Microsoft::WRL::ComPtr<IAudioEndpointVolumeCallback> callback)
    {
        if (!endpoint_volume_)
        {
            return false;
        }

        callback_ = callback;
        HRESULT hr = endpoint_volume_->RegisterControlChangeNotify(callback_.Get());

        if (FAILED(hr))
        {
            std::cerr << "Failed to register volume notification: " << std::hex << hr << std::endl;
            return false;
        }

        return true;
    }

    void VolumeListener::DisposeVolumeNotification()
    {
        if (endpoint_volume_ && callback_)
        {
            endpoint_volume_->UnregisterControlChangeNotify(callback_.Get());
            callback_.Reset();
        }
    }
}
#include "volume_controller.h"

namespace volume_controller
{

    VolumeController::VolumeController() = default;

    VolumeController::~VolumeController()
    {
        Dispose();
    }

    VolumeController &VolumeController::GetInstance()
    {
        static VolumeController instance;
        return instance;
    }

    bool VolumeController::Initialize()
    {
        HRESULT hr = CoInitialize(nullptr);
        if (FAILED(hr))
        {
            std::cerr << "Failed to initialize COM library: " << std::hex << hr << std::endl;
            return false;
        }

        Microsoft::WRL::ComPtr<IMMDeviceEnumerator> enumerator;
        hr = CoCreateInstance(__uuidof(MMDeviceEnumerator), nullptr, CLSCTX_ALL, __uuidof(IMMDeviceEnumerator), &enumerator);

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

    void VolumeController::Dispose()
    {
        endpoint_volume_.Reset();
        CoUninitialize();
    }

    float VolumeController::GetVolume()
    {
        if (!endpoint_volume_)
        {
            return 0.0f;
        }

        float currentVolume = 0.0f;
        HRESULT hr = endpoint_volume_->GetMasterVolumeLevelScalar(&currentVolume);
        if (FAILED(hr))
        {
            std::cerr << "Failed to get master volume level: " << std::hex << hr << std::endl;
            return 0.0f;
        }

        return currentVolume;
    }

    bool VolumeController::SetVolume(float volume)
    {
        if (!endpoint_volume_)
        {
            return false;
        }

        if (volume < 0.0f)
        {
            volume = 0.0f;
        }
        if (volume > 1.0f)
        {
            volume = 1.0f;
        }

        HRESULT hr = endpoint_volume_->SetMasterVolumeLevelScalar(volume, nullptr);
        if (FAILED(hr))
        {
            std::cerr << "Failed to set master volume level: " << std::hex << hr << std::endl;
            return false;
        }

        return true;
    }

    bool VolumeController::IsMuted()
    {
        if (!endpoint_volume_)
        {
            return false;
        }

        BOOL isMuted = FALSE;
        HRESULT hr = endpoint_volume_->GetMute(&isMuted);
        if (FAILED(hr))
        {
            std::cerr << "Failed to get mute status: " << std::hex << hr << std::endl;
            return false;
        }

        return isMuted == TRUE;
    }

    bool VolumeController::SetMute(bool isMute)
    {
        if (!endpoint_volume_)
        {
            return false;
        }

        HRESULT hr = endpoint_volume_->SetMute(isMute ? TRUE : FALSE, nullptr);
        if (FAILED(hr))
        {
            std::cerr << "Failed to set mute status: " << std::hex << hr << std::endl;
            return false;
        }

        return true;
    }

} // namespace volume_controller
#ifndef VOLUME_CONTROLLER_H_
#define VOLUME_CONTROLLER_H_

#include <windows.h>
#include <mmdeviceapi.h>
#include <endpointvolume.h>
#include <wrl/client.h>
#include <iostream>

namespace volume_controller
{
    class VolumeController
    {
    public:
        static VolumeController &GetInstance();

        bool Initialize();

        void Dispose();

        float GetVolume();

        bool SetVolume(float volume);

        bool IsMuted();

        bool SetMute(bool isMute);

    private:
        VolumeController();
        ~VolumeController();

        VolumeController(const VolumeController &) = delete;
        VolumeController &operator=(const VolumeController &) = delete;

        Microsoft::WRL::ComPtr<IAudioEndpointVolume> endpoint_volume_;
    };
}

#endif // VOLUME_CONTROLLER_H_
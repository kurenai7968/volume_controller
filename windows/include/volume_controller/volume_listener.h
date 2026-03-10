#ifndef VOLUME_LISTENER_H_
#define VOLUME_LISTENER_H_

#include <windows.h>
#include <mmdeviceapi.h>
#include <endpointvolume.h>
#include <iostream>
#include <wrl/client.h>
#include <wrl/implements.h>

#include "volume_callback.h"

namespace volume_controller
{
    class VolumeListener
    {
    public:
        static VolumeListener &GetInstance();

        bool Initialize();

        void Dispose();

        bool RegisterVolumeNotification(Microsoft::WRL::ComPtr<IAudioEndpointVolumeCallback> callback);

        void DisposeVolumeNotification();

    private:
        VolumeListener() = default;
        ~VolumeListener();

        VolumeListener(const VolumeListener &) = delete;
        VolumeListener &operator=(const VolumeListener &) = delete;

        Microsoft::WRL::ComPtr<IAudioEndpointVolume> endpoint_volume_;
        Microsoft::WRL::ComPtr<IAudioEndpointVolumeCallback> callback_;
    };
} // namespace volume_controller

#endif // VOLUME_LISTENER_H_
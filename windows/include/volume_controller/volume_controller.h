#ifndef VOLUME_CONTROLLER_H_
#define VOLUME_CONTROLLER_H_

#include <windows.h>
#include <mmdeviceapi.h>
#include <endpointvolume.h>
#include <atomic>
#include <mutex>

#include "volume_callback.h"

namespace volume_controller
{
    class DeviceNotificationClient;

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

        bool RegisterVolumeNotification(volume_callback::VolumeCallback *callback);

        void DisposeVolumeNotification();

    private:
        VolumeController() = default;
        ~VolumeController() = default;

        VolumeController(const VolumeController &) = delete;
        VolumeController &operator=(const VolumeController &) = delete;

        bool InitializeLocked();
        void DisposeLocked();
        bool BindDefaultEndpointLocked();
        void ReleaseEndpointLocked();
        void OnDefaultDeviceChanged();
        void RebindDefaultEndpoint();
        void EnsureRebindWindowLocked();
        void DestroyRebindWindowLocked();

        static LRESULT CALLBACK WndProc(HWND hwnd, UINT message, WPARAM wparam, LPARAM lparam);
        static HMODULE GetPluginModule();

        friend class DeviceNotificationClient;

        std::recursive_mutex mutex_;
        int init_count_ = 0;
        bool com_needs_uninit_ = false;
        IMMDeviceEnumerator *pEnumerator_ = nullptr;
        IAudioEndpointVolume *pVolume_ = nullptr;
        volume_callback::VolumeCallback *pCallback_ = nullptr;
        DeviceNotificationClient *pDeviceClient_ = nullptr;
        std::atomic<HWND> hwnd_{nullptr};
    };
}

#endif

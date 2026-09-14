#include "volume_listener.h"

#include "volume_controller.h"

namespace volume_listener
{
    VolumeListener &VolumeListener::GetInstance()
    {
        static VolumeListener instance;
        return instance;
    }

    bool VolumeListener::Initialize()
    {
        return volume_controller::VolumeController::GetInstance().Initialize();
    }

    void VolumeListener::Dispose()
    {
        volume_controller::VolumeController::GetInstance().Dispose();
    }

    bool VolumeListener::RegisterVolumeNotification(volume_callback::VolumeCallback *callback)
    {
        return volume_controller::VolumeController::GetInstance().RegisterVolumeNotification(callback);
    }

    void VolumeListener::DisposeVolumeNotification()
    {
        volume_controller::VolumeController::GetInstance().DisposeVolumeNotification();
    }
}

#ifndef VOLUME_LISTENER_H_
#define VOLUME_LISTENER_H_

#include "volume_callback.h"

namespace volume_listener
{
    class VolumeListener
    {
    public:
        static VolumeListener &GetInstance();

        bool Initialize();

        void Dispose();

        bool RegisterVolumeNotification(volume_callback::VolumeCallback *callback);

        void DisposeVolumeNotification();
    };
} // namespace volume_listener

#endif // VOLUME_LISTENER_H_

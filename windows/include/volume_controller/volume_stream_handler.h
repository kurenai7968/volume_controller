#ifndef VOLUME_STREAM_HANDLER_H_
#define VOLUME_STREAM_HANDLER_H_

#include <windows.h>
#include <flutter/event_channel.h>
#include <flutter/encodable_value.h>
#include <flutter/plugin_registrar_windows.h>
#include <memory>
#include <mutex>

#include "constants.h"
#include "volume_listener.h"
#include "volume_controller.h"
#include "helper.h"

namespace volume_controller
{
    class VolumeStreamHandler : public flutter::StreamHandler<flutter::EncodableValue>
    {
    public:
        VolumeStreamHandler(flutter::PluginRegistrarWindows *registrar);
        ~VolumeStreamHandler();

        void SendVolumeChangeEvent(float volume);

    protected:
        std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>> OnListenInternal(
            const flutter::EncodableValue *arguments,
            std::unique_ptr<flutter::EventSink<flutter::EncodableValue>> &&events) override;

        std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>> OnCancelInternal(
            const flutter::EncodableValue *arguments) override;

    private:
        flutter::PluginRegistrarWindows *registrar_;
        std::unique_ptr<flutter::EventSink<flutter::EncodableValue>> event_sink_;
        VolumeListener &volume_listener_;

        // Window procedure delegate ID for callback deregistration.
        int window_proc_id_ = -1;
    };
}

#endif // VOLUME_STREAM_HANDLER_H_
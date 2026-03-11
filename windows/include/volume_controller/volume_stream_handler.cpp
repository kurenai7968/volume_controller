#include <wrl/client.h>
#include <wrl/implements.h>
#include <iostream>
#include <windows.h>
#include <flutter/encodable_value.h>
#include <flutter/encodable_value.h>

#include "volume_stream_handler.h"

namespace volume_controller
{
    // Define a custom message ID for volume changes.
    const UINT kVolumeChangeMessage = WM_APP + 9991;

    VolumeStreamHandler::VolumeStreamHandler(flutter::PluginRegistrarWindows *registrar)
        : volume_listener_(VolumeListener::GetInstance()), registrar_(registrar)
    {
        volume_listener_.Initialize();

        // Register a window procedure delegate.
        window_proc_id_ = registrar->RegisterTopLevelWindowProcDelegate(
            [this](HWND hwnd, UINT message, WPARAM wparam, LPARAM lparam) -> std::optional<LRESULT>
            {
                if (message == kVolumeChangeMessage)
                {
                    float *volume_ptr = reinterpret_cast<float *>(lparam);
                    if (volume_ptr)
                    {
                        float volume = *volume_ptr;
                        if (event_sink_)
                        {
                            event_sink_->Success(flutter::EncodableValue(volume));
                        }
                        delete volume_ptr;
                        return 0;
                    }
                }
                return std::nullopt;
            });
    }

    VolumeStreamHandler::~VolumeStreamHandler()
    {
        if (window_proc_id_ != -1)
        {
            registrar_->UnregisterTopLevelWindowProcDelegate(window_proc_id_);
        }
        volume_listener_.Dispose();
    }

    std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>> VolumeStreamHandler::OnListenInternal(
        const flutter::EncodableValue *arguments,
        std::unique_ptr<flutter::EventSink<flutter::EncodableValue>> &&events)
    {
        const flutter::EncodableMap *args_map = std::get_if<flutter::EncodableMap>(arguments);
        const bool *fetchInitialVolume = std::get_if<bool>(GetArgValue(*args_map, constants::EventArgument::fetchInitialVolume));

        event_sink_ = std::move(events);

        auto callback = Microsoft::WRL::Make<VolumeCallback>([this](float volume)
                                                             { SendVolumeChangeEvent(volume); });

        volume_listener_.RegisterVolumeNotification(callback);

        if (fetchInitialVolume && *fetchInitialVolume)
        {
            float volume = VolumeController::GetInstance().GetVolume();

            // Send the initial volume
            event_sink_->Success(flutter::EncodableValue(volume));
        }

        return nullptr;
    }

    std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>> VolumeStreamHandler::OnCancelInternal(
        const flutter::EncodableValue *arguments)
    {
        event_sink_ = nullptr;
        return nullptr;
    }

    void VolumeStreamHandler::SendVolumeChangeEvent(float volume)
    {
        // Must use the window handle associated with the plugin registrar.
        // We need the root window to ensure the message loop processes it if it's a top level delegate.
        HWND hwnd = GetAncestor(registrar_->GetView()->GetNativeWindow(), GA_ROOT);
        if (!hwnd)
        {
            hwnd = registrar_->GetView()->GetNativeWindow();
        }

        float *volume_ptr = new float(volume);
        if (!PostMessage(hwnd, kVolumeChangeMessage, 0, reinterpret_cast<LPARAM>(volume_ptr)))
        {
            delete volume_ptr;
            std::cerr << "Failed to post volume change message." << std::endl;
        }
    }
}
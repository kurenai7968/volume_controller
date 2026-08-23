#include "volume_stream_handler.h"

namespace volume_stream_handler
{
    namespace
    {
        constexpr UINT kPostTaskMessage = WM_APP + 1;
        constexpr wchar_t kPlatformWindowClass[] =
            L"com.kurenai7968.volume_controller.PlatformThread";
    }

    VolumeStreamHandler::VolumeStreamHandler()
        : volume_listener_(volume_listener::VolumeListener::GetInstance())
    {
        volume_listener_.Initialize();
    }

    VolumeStreamHandler::~VolumeStreamHandler()
    {
        volume_listener_.DisposeVolumeNotification();
        event_sink_ = nullptr;
        DestroyPlatformWindow();
        volume_listener_.Dispose();
    }

    std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>> VolumeStreamHandler::OnListenInternal(
        const flutter::EncodableValue *arguments,
        std::unique_ptr<flutter::EventSink<flutter::EncodableValue>> &&events)
    {
        const flutter::EncodableMap *args_map = std::get_if<flutter::EncodableMap>(arguments);
        const bool *fetchInitialVolume = std::get_if<bool>(GetArgValue(*args_map, constants::EventArgument::fetchInitialVolume));

        // EventChannel handlers run on the Flutter platform thread. Create the
        // message-only window here so its WndProc also runs on that thread.
        EnsurePlatformWindow();

        event_sink_ = std::move(events);

        auto callback = new volume_callback::VolumeCallback([this](float volume)
                                                            { SendVolumeChangeEvent(volume); });

        volume_listener_.RegisterVolumeNotification(callback);

        if (fetchInitialVolume && *fetchInitialVolume)
        {
            float volume = volume_controller::VolumeController::GetInstance().GetVolume();
            event_sink_->Success(flutter::EncodableValue(volume));
        }

        return nullptr;
    }

    std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>> VolumeStreamHandler::OnCancelInternal(
        const flutter::EncodableValue *arguments)
    {
        volume_listener_.DisposeVolumeNotification();
        DrainPendingTasks();
        event_sink_ = nullptr;
        return nullptr;
    }

    void VolumeStreamHandler::SendVolumeChangeEvent(float volume)
    {
        PostToPlatformThread([this, volume]()
                             {
                                 if (event_sink_)
                                 {
                                     event_sink_->Success(flutter::EncodableValue(volume));
                                 }
                             });
    }

    void VolumeStreamHandler::EnsurePlatformWindow()
    {
        if (hwnd_)
        {
            return;
        }

        platform_thread_id_ = GetCurrentThreadId();

        HMODULE instance = GetPluginModule();
        WNDCLASSW window_class = {};
        window_class.lpfnWndProc = WndProc;
        window_class.hInstance = instance;
        window_class.lpszClassName = kPlatformWindowClass;
        RegisterClassW(&window_class);

        hwnd_ = CreateWindowExW(0, kPlatformWindowClass, L"", 0, 0, 0, 0, 0,
                                HWND_MESSAGE, nullptr, instance, nullptr);
        if (hwnd_)
        {
            SetWindowLongPtrW(hwnd_, GWLP_USERDATA, reinterpret_cast<LONG_PTR>(this));
        }
    }

    void VolumeStreamHandler::DestroyPlatformWindow()
    {
        DrainPendingTasks();
        if (hwnd_)
        {
            DestroyWindow(hwnd_);
            hwnd_ = nullptr;
        }
    }

    void VolumeStreamHandler::PostToPlatformThread(std::function<void()> task)
    {
        if (!hwnd_)
        {
            return;
        }

        if (platform_thread_id_ != 0 && GetCurrentThreadId() == platform_thread_id_)
        {
            task();
            return;
        }

        auto *posted_task = new std::function<void()>(std::move(task));
        if (!PostMessageW(hwnd_, kPostTaskMessage, reinterpret_cast<WPARAM>(posted_task), 0))
        {
            delete posted_task;
        }
    }

    void VolumeStreamHandler::DrainPendingTasks()
    {
        if (!hwnd_)
        {
            return;
        }

        MSG message;
        while (PeekMessageW(&message, hwnd_, kPostTaskMessage, kPostTaskMessage, PM_REMOVE))
        {
            delete reinterpret_cast<std::function<void()> *>(message.wParam);
        }
    }

    HMODULE VolumeStreamHandler::GetPluginModule()
    {
        HMODULE module = nullptr;
        GetModuleHandleExW(GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS |
                               GET_MODULE_HANDLE_EX_FLAG_UNCHANGED_REFCOUNT,
                           reinterpret_cast<LPCWSTR>(&GetPluginModule), &module);
        return module;
    }

    LRESULT CALLBACK VolumeStreamHandler::WndProc(HWND hwnd, UINT message, WPARAM wparam, LPARAM lparam)
    {
        auto *self = reinterpret_cast<VolumeStreamHandler *>(GetWindowLongPtrW(hwnd, GWLP_USERDATA));
        if (self && message == kPostTaskMessage)
        {
            auto *task = reinterpret_cast<std::function<void()> *>(wparam);
            (*task)();
            delete task;
            return 0;
        }

        return DefWindowProcW(hwnd, message, wparam, lparam);
    }
}

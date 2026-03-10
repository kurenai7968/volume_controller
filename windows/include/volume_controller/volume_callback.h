#ifndef VOLUME_CALLBACK_H_
#define VOLUME_CALLBACK_H_

#include <windows.h>
#include <mmdeviceapi.h>
#include <endpointvolume.h>
#include <wrl/implements.h>
#include <functional>

namespace volume_controller
{
    class VolumeCallback : public Microsoft::WRL::RuntimeClass<Microsoft::WRL::RuntimeClassFlags<Microsoft::WRL::ClassicCom>, IAudioEndpointVolumeCallback>
    {
    public:
        VolumeCallback(std::function<void(float)> callback) : callback_(callback) {}

        ~VolumeCallback() override = default;

        HRESULT STDMETHODCALLTYPE OnNotify(PAUDIO_VOLUME_NOTIFICATION_DATA pNotify) override
        {
            if (pNotify && callback_)
            {
                callback_(pNotify->fMasterVolume);
            }
            return S_OK;
        }

    private:
        std::function<void(float)> callback_;
    };
} // namespace volume_controller

#endif // VOLUME_CALLBACK_H_
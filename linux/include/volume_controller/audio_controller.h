#ifndef AUDIO_CONTROLLER_H
#define AUDIO_CONTROLLER_H

#include <string>
#include <functional>
#include <atomic>
#include <glib.h>
#include <alsa/asoundlib.h>

class AudioController
{
public:
    AudioController();
    AudioController(std::string cardName);

    AudioController(const AudioController &) = delete;
    AudioController &operator=(const AudioController &) = delete;

    ~AudioController();

    using VolumeChangeCallback = std::function<void(double volume, gpointer user_data)>;

    double get_volume();
    void set_volume(double volume);
    bool is_muted();
    void set_mute(bool mute);

    bool start_listening_for_volume_changes(VolumeChangeCallback callback, gpointer user_data);
    void stop_listening_for_volume_changes();

    bool fetch_initial_volume = false;

private:
    std::string cardName_;
    snd_mixer_t *mixerHandle_ = nullptr;

    VolumeChangeCallback volume_change_callback_ = nullptr;
    gpointer callback_user_data_ = nullptr;
    double last_known_volume_ = 0.0;
    GThread *volume_listener_thread_ = nullptr;
    snd_mixer_elem_t *master_element_ = nullptr;
    std::atomic<bool> listening_for_volume_changes_{false};
    double temp_mute_volume_ = -1.0;

    void open_mixer();
    snd_mixer_elem_t *find_playback_element();
    snd_mixer_elem_t *get_mixer_element(const std::string &channel) const;

    void volume_listener_loop();
    static gpointer volume_listener_thread_func_static(gpointer data);
    void check_volume_and_notify();
};

#endif // AUDIO_CONTROLLER_H

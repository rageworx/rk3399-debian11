#!/bin/bash

echo "Update device.description for pulseaudio 14.2"
sleep 5
sudo -u linaro PULSE_RUNTIME_PATH=/run/user/1000/pulse pacmd update-sink-proplist alsa_output.platform-hdmi-sound.stereo-fallback device.description="HDMI-Sound-Output"
sudo -u linaro PULSE_RUNTIME_PATH=/run/user/1000/pulse pacmd update-sink-proplist alsa_output.platform-spdif-sound.stereo-fallback device.description="SPDIF-Sound-Output"
sound_ext_card_name=`sudo -u linaro PULSE_RUNTIME_PATH=/run/user/1000/pulse pacmd list-cards | grep -A 10 alsa_card.platform-sound-ext-card | grep alsa.card_name`
sound_ext_alsa_card_name=$(echo $sound_ext_card_name | cut -d" " -f 3)
sudo -u linaro PULSE_RUNTIME_PATH=/run/user/1000/pulse pacmd update-sink-proplist alsa_output.platform-sound-ext-card.stereo-fallback device.description=$sound_ext_alsa_card_name

# set default sink output
sudo -u linaro PULSE_RUNTIME_PATH=/run/user/1000/pulse pacmd set-default-sink "alsa_output.platform-hdmi-sound.stereo-fallback"

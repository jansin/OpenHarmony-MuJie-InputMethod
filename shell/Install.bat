set keyboard_replace_folder=entry/build/default/outputs/default/entry-default-signed.hap
cd ..
copy %keyboard_replace_folder% mujieinput.hap
set hdc=hdc.exe
%hdc% shell "mount -o rw,remount /vendor/soc_platform"
%hdc% shell "rm -rf /vendor/soc_platform/app/com.mujie.mujieinput/*"
%hdc% file send %keyboard_replace_folder% /vendor/soc_platform/app/com.mujie.mujieinput/mujieinput.hap
%hdc% shell "rm -rf /data/*"
%hdc% shell "reboot"
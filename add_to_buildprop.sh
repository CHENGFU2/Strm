#!/sbin/sh
# By Jeeko
busybox echo " " >> /system/build.prop
busybox echo "# Ultimate Performance Mod Tweaks" >> /system/build.prop
busybox echo "persist.sys.use_dithering=1" >> /system/build.prop
busybox echo "# System Tweaks" >> /system/build.prop
busybox echo "ro.config.hw_fast_dormancy=1" >> /system/build.prop
busybox echo "ro.config.hw_quickpoweron=true" >> /system/build.prop
busybox echo "persist.sys.shutdown.mode=hibernate" >> /system/build.prop
busybox echo "ro.config.hw_power_saving=true" >> /system/build.prop
busybox echo "# Miscellaneous Tweaks" >> /system/build.prop
busybox echo "ro.telephony.sms_segment_size=160" >> /system/build.prop
busybox echo "persist.telephony.support.ipv6=1" >> /system/build.prop
busybox echo "persist.telephony.support.ipv4=1" >> /system/build.prop
busybox echo "# Signal Tweaks" >> /system/build.prop
busybox echo "ro.ril.hsxpa=2" >> /system/build.prop
busybox echo "ro.ril.gprsclass=12" >> /system/build.prop
busybox echo "ro.ril.hsdpa.category=8" >> /system/build.prop
busybox echo "ro.ril.hsupa.category=6" >> /system/build.prop
busybox echo "persist.cust.tel.eons=1" >> /system/build.prop
busybox echo "ro.ril.set.mtu1472=1" >> /system/build.prop
busybox echo "# Wireless Speed Tweaks" >> /system/build.prop
busybox echo "net.tcp.buffersize.default=4096,87380,256960,4096,16384,256960" >> /system/build.prop
busybox echo "net.tcp.buffersize.wifi=4096,87380,256960,4096,16384,256960" >> /system/build.prop
busybox echo "net.tcp.buffersize.umts=4096,87380,256960,4096,16384,256960" >> /system/build.prop
busybox echo "net.tcp.buffersize.gprs=4096,87380,256960,4096,16384,256960" >> /system/build.prop
busybox echo "net.tcp.buffersize.edge=4096,87380,256960,4096,16384,256960" >> /system/build.prop
busybox echo "net.ipv4.tcp_ecn=0" >> /system/build.prop
busybox echo "net.ipv4.route.flush=1" >> /system/build.prop
busybox echo "net.ipv4.tcp_rfc1337=1" >> /system/build.prop
busybox echo "net.ipv4.ip_no_pmtu_disc=0" >> /system/build.prop
busybox echo "net.ipv4.tcp_sack=1" >> /system/build.prop
busybox echo "net.ipv4.tcp_fack=1" >> /system/build.prop
busybox echo "net.ipv4.tcp_window_scaling=1" >> /system/build.prop
busybox echo "net.ipv4.tcp_timestamps=1" >> /system/build.prop
busybox echo "net.ipv4.tcp_rmem=4096 39000 187000" >> /system/build.prop
busybox echo "net.ipv4.tcp_wmem=4096 39000 187000" >> /system/build.prop
busybox echo "net.ipv4.tcp_mem=187000 187000 187000" >> /system/build.prop
busybox echo "net.ipv4.tcp_no_metrics_save=1" >> /system/build.prop
busybox echo "net.ipv4.tcp_moderate_rcvbuf=1" >> /system/build.prop
busybox echo "# Makes streaming videos stream faster" >> /system/build.prop
busybox echo "media.stagefright.enable-player=true" >> /system/build.prop
busybox echo "media.stagefright.enable-meta=true" >> /system/build.prop
busybox echo "media.stagefright.enable-scan=true" >> /system/build.prop
busybox echo "media.stagefright.enable-http=true" >> /system/build.prop
busybox echo "media.stagefright.enable-record=true" >> /system/build.prop
busybox echo "# Website Bypass" >> /system/build.prop
busybox echo "net.rmnet0.dns1=8.8.8.8" >> /system/build.prop
busybox echo "net.rmnet0.dns2=8.8.4.4" >> /system/build.prop
busybox echo "net.dns1=8.8.8.8" >> /system/build.prop
busybox echo "net.dns2=8.8.4.4" >> /system/build.prop
busybox echo "# Graphics Enhancement" >> /system/build.prop
busybox echo "video.accelerate.hw=1" >> /system/build.prop
busybox echo "ro.media.dec.jpeg.memcap=20000000" >> /system/build.prop
busybox echo "ro.media.enc.hprof.vid.bps=8000000" >> /system/build.prop
busybox echo "ro.media.enc.jpeg.quality=100" >> /system/build.prop
busybox echo "# Disables data sent and logging" >> /system/build.prop
busybox echo "ro.config.nocheckin=1" >> /system/build.prop
busybox echo "profiler.force_disable_err_rpt=1" >> /system/build.prop
busybox echo "profiler.force_disable_ulog=1" >> /system/build.prop
busybox echo "# Power Saving Tweaks" >> /system/build.prop
busybox echo "ro.ril.disable.power.collapse=1" >> /system/build.prop
busybox echo "pm.sleep_mode=1" >> /system/build.prop
busybox echo "wifi.supplicant_scan_interval=180" >> /system/build.prop
busybox echo "# Dialing Tweaks" >> /system/build.prop
busybox echo "ro.telephony.call_ring.delay=0" >> /system/build.prop
busybox echo "ro.lge.proximity.delay=25" >> /system/build.prop
busybox echo "mot.proximity.delay=25" >> /system/build.prop
busybox echo "ro.ril.enable.amr.wideband=1" >> /system/build.prop
busybox echo "# DalvikVM" >> /system/build.prop
busybox echo "dalvik.vm.verify-bytecode=false" >> /system/build.prop
busybox echo "dalvik.vm.execution-mode=int:jit" >> /system/build.prop
busybox echo "dalvik.vm.checkjni=false" >> /system/build.prop
busybox echo "dalvik.vm.dexopt-data-only=1" >> /system/build.prop
busybox echo "dalvik.vm.lockprof.threshold=250" >> /system/build.prop
busybox echo "dalvik.vm.dexopt-flags=m=v,o=y" >> /system/build.prop
busybox echo "dalvik.vm.jmiopts=forcecopy" >> /system/build.prop
busybox echo "# Performance" >> /system/build.prop
busybox echo "ro.max.fling_velocity=20000" >> /system/build.prop
busybox echo "ro.min.fling_velocity=18000" >> /system/build.prop
busybox echo "debug.performance.tuning=1" >> /system/build.prop
busybox echo "debug.kill_allocating_task=0" >> /system/build.prop
busybox echo "debug.overlayui.enable=1" >> /system/build.prop
busybox echo "hw3d.force=1" >> /system/build.prop
busybox echo "hw2d.force=1" >> /system/build.prop
busybox echo "persist.sys.ui.hw=1" >> /system/build.prop
busybox echo "ro.debuggable=1" >> /system/build.prop
busybox echo "ro.config.disable.hw_accel=false" >> /system/build.prop
busybox echo "# End of UPM Tweaks" >> /system/build.prop  
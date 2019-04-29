#!/system/bin/sh
# Please don't hardcode /magisk/modname/... ; instead, please use $MODDIR/...
# This will make your scripts compatible even if Magisk change its mount point in the future
MODDIR=${0%/*}
setenforce 0
echo 0 > /sys/block/mmcblk0/queue/nomerges
echo 0 > /sys/block/mmcblk0/queue/add_random
echo 0 > /sys/module/lowmemorykiller/parameters/debug_level
echo 0 > /sys/module/subsystem_restart/parameters/enable_ramdumps
echo 0 > /sys/module/subsystem_restart/parameters/enable_mini_ramdumps
swapoff /dev/block/zram0 > /dev/null 2>&1
echo 150 >/sys/class/power_supply/bms/temp_cool
echo 480 >/sys/class/power_supply/bms/temp_warm
sysctl -w net.ipv4.tcp_congestion_control=reno
echo 1 > /sys/module/snd_soc_wcd9xxx/parameters/impedance_detect_en
echo 1 > /sys/module/snd_soc_wcd9330/parameters/high_perf_mode
sleep 30
$MODDIR/./tweak
./tweak
echo '30' > /proc/sys/vm/swappiness
echo '0' > /sys/module/lowmemorykiller/parameters/enable_adaptive_lmk
echo '80' > /proc/sys/vm/overcommit_ratio
echo '400' > /proc/sys/vm/vfs_cache_pressure
echo '24300' > /proc/sys/vm/extra_free_kbytes
echo '128' > /proc/sys/kernel/random/read_wakeup_threshold
echo '256' > /proc/sys/kernel/random/write_wakeup_threshold
echo '1024' > /sys/block/mmcblk0/queue/read_ahead_kb
echo '0' > /sys/block/mmcblk0/queue/iostats
echo '1' > /sys/block/mmcblk0/queue/add_random
echo '1024' > /sys/block/mmcblk1/queue/read_ahead_kb
echo '0' > /sys/block/mmcblk1/queue/iostats
echo '1' > /sys/block/mmcblk1/queue/add_random
echo '4096' > /proc/sys/vm/min_free_kbytes
echo '0' > /proc/sys/vm/oom_kill_allocating_task
echo '90' > /proc/sys/vm/dirty_ratio
echo '70' > /proc/sys/vm/dirty_background_ratio
chmod 666 /sys/module/lowmemorykiller/parameters/minfree
chown root /sys/module/lowmemorykiller/parameters/minfree
echo '21816,29088,36360,43632,50904,65448' > /sys/module/lowmemorykiller/parameters/minfree
#SWAPT#
TL=60
Step=3
k=0

while [ `SWAPT` -eq 0  ]
do
    k=$(( $k + $Step ))
    if [ $k -gt $TL  ] ; then
        exit 0
    fi
    sleep $Step
done

SR="\/dev\/"
PS="/proc/swap*"

if [ -f /system/bin/swapoff ] ; then
    SO="/system/bin/swapoff"
else
    SO="swapoff"
fi

# You would think that there's only ever zram0
# And you would be wrong
# Samsung had a different method at least once (vmswap) 
# HTC used four zram swap partitions at least once
# They can't even all agree if it's swap or swaps in /proc
# Find all swapregions and target each one for swapoff
# Don't assume it's in the first field of swaps, find it

DIE=`awk -v SBD="$SR" ' $0 ~ SBD {
      for ( i=1;i<=NF;i++ )
        {
          if ( $i ~ ( "^" SBD ) )
           {
              printf "%s;", $i
              break
           }
        }
      }' $PS`

saveifs=$IFS
IFS=';'

# I could have put all this in awk and just eval'd it 
# But where's the fun in that

for i in $DIE
do
    case $i in
        *zram*)
              j=`echo $i | sed 's/.*zram//'`
              ( ( 
                 echo $j > /sys/class/zram-control/hot_remove
                 echo 1 > /sys/block/zram${j}/reset
                 $SO $i
              ) & )
              ;;
        *)
              if [ -n $i ]; then
                  ( ( $SO $i ) & ) 
              fi
              ;;
    esac
done

IFS=$saveifs
fi
esac
case ${SOC} in msm8996* | apq8096*) #sd820
	update_clock_speed 280000 little min
	update_clock_speed 280000 big min
	# avoid permission problem, do not set 0444
	write "/dev/cpuset/background/cpus" 1
	write "/dev/cpuset/system-background/cpus" "0-1"
	write "/dev/cpuset/foreground/cpus" "0-1,2-3"
	write "/dev/cpuset/top-app/cpus" "0-1,2-3"
	set_value 25 /proc/sys/kernel/sched_downmigrate
	set_value 45 /proc/sys/kernel/sched_upmigrate
	set_param cpu0 use_sched_load 1
	set_param cpu${bcores} use_sched_load 1
	# shared interactive parameters
	set_param cpu0 timer_rate 20000
	set_param cpu0 timer_slack 180000
	set_param cpu0 boost 0
	set_param cpu0 boostpulse_duration 0
	set_param cpu${bcores} timer_rate 20000
	set_param cpu${bcores} timer_slack 180000
	set_param cpu${bcores} boost 0
	set_param cpu${bcores} boostpulse_duration 0
	if [ ${PROFILE} -eq 0 ];then
	set_boost_freq "0:380000 2:380000"
	set_param cpu0 above_hispeed_delay "18000 1180000:78000 1280000:98000"
	set_param cpu0 hispeed_freq 1080000
	set_param cpu0 go_hispeed_load 97
	set_param cpu0 target_loads "80 380000:5 580000:42 680000:60 780000:70 880000:83 980000:92 1180000:97"
	set_param cpu0 min_sample_time 18000
	set_param cpu${bcores} above_hispeed_delay "18000 1280000:98000 1380000:58000 1480000:98000 1880000:138000"
	set_param cpu${bcores} hispeed_freq 1180000
	set_param cpu${bcores} go_hispeed_load 98
	set_param cpu${bcores} target_loads "80 380000:53 480000:38 580000:63 780000:69 880000:85 1080000:93 1380000:72 1480000:98"
	set_param cpu${bcores} min_sample_time 18000
	set_param cpu2 min_sample_time 18000
	elif [ ${PROFILE} -eq 1 ];then
	set_boost_freq "0:380000 2:380000"
	set_param cpu0 above_hispeed_delay "58000 1280000:98000 1580000:58000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 98
	set_param cpu0 target_loads "80 380000:9 580000:36 780000:62 880000:71 980000:87 1080000:75 1180000:98"
	set_param cpu0 min_sample_time 18000
	set_param cpu${bcores} above_hispeed_delay "38000 1480000:98000 1880000:138000"
	set_param cpu${bcores} hispeed_freq 1380000
	set_param cpu${bcores} go_hispeed_load 98
	set_param cpu${bcores} target_loads "80 380000:39 480000:35 680000:29 780000:63 880000:71 1180000:91 1380000:83 1480000:98"
	set_param cpu${bcores} min_sample_time 18000
	elif [ ${PROFILE} -eq 2 ];then
	set_boost_freq "0:380000 2:380000"
	set_param cpu0 above_hispeed_delay "18000 1280000:98000 1480000:38000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 97
	set_param cpu0 target_loads "80 380000:7 480000:31 580000:13 680000:58 780000:63 980000:73 1180000:98"
	set_param cpu0 min_sample_time 38000
	set_param cpu${bcores} above_hispeed_delay "18000 1580000:98000 1880000:38000"
	set_param cpu${bcores} hispeed_freq 1480000
	set_param cpu${bcores} go_hispeed_load 98
	set_param cpu${bcores} target_loads "80 380000:34 680000:40 780000:63 880000:57 1080000:72 1380000:78 1480000:98"
	set_param cpu${bcores} min_sample_time 18000
	set_param cpu2 min_sample_time 18000
   	elif [ ${PROFILE} -eq 3 ];then
	update_clock_speed 1080000 little min
	set_param cpu0 above_hispeed_delay "18000 1480000:198000"
	set_param cpu0 hispeed_freq 1080000
	set_param cpu0 target_loads "80 1580000:90"
	set_param cpu0 min_sample_time 38000
	update_clock_speed 1380000 big min
	set_param cpu${bcores} above_hispeed_delay "18000 1880000:198000"
	set_param cpu${bcores} hispeed_freq 1380000
	set_param cpu${bcores} target_loads "80 1980000:90"
	set_p


# =========
# Google Services Drain fix by @Alcolawl @Oreganoian
# =========
LOGDATA "#  [INFO] Fixing SystemUpdateService BATTERY DRAIN"
su -c pm enable com.google.android.gms/.update.SystemUpdateActivity 
su -c pm enable com.google.android.gms/.update.SystemUpdateService
su -c pm enable com.google.android.gms/.update.SystemUpdateService$ActiveReceiver 
su -c pm enable com.google.android.gms/.update.SystemUpdateService$Receiver 
su -c pm enable com.google.android.gms/.update.SystemUpdateService$SecretCodeReceiver 
su -c pm enable com.google.android.gsf/.update.SystemUpdateActivity 
su -c pm enable com.google.android.gsf/.update.SystemUpdatePanoActivity 
su -c pm enable com.google.android.gsf/.update.SystemUpdateService 
su -c pm enable com.google.android.gsf/.update.SystemUpdateService$Receiver 
su -c pm enable com.google.android.gsf/.update.SystemUpdateService$SecretCodeReceiver
# FS-TRIM
fstrim -v /cache
fstrim -v /data
fstrim -v /system
LOGDATA "#  [INFO] EXECUTING FS-TRIM "
# =========
# Battery Check
# =========
LOGDATA "# =================================" 
LOGDATA "#  BATTERY LEVEL: $BATT_LEV % "
LOGDATA "#  BATTERY TECHNOLOGY: $BATT_TECH"
LOGDATA "#  BATTERY HEALTH: $BATT_HLTH"
LOGDATA "#  BATTERY TEMP: $BATT_TEMP ��C"
LOGDATA "#  BATTERY VOLTAGE: $BATT_VOLT VOLTS "
LOGDATA "# =================================" 
LOGDATA "#  FINISHED : $(date +"%d-%m-%Y %r")"

# This script will be executed in late_start service mode
sleep 35
chmod 755 /sys/class/*/*/*
chmod 755 /sys/module/*/*/*
while true; do
echo '1' > /sys/kernel/fast_charge/force_fast_charge
echo '1' > /sys/class/power_supply/battery/allow_hvdcp3
echo '0' > /sys/class/power_supply/battery/input_current_limited
echo '1' >/sys/class/power_supply/battery/subsystem/usb/pd_allowed
echo '1' > /sys/class/power_supply/battery/input_current_settled
echo '150' >/sys/class/power_supply/bms/temp_cool
echo '500' >/sys/class/power_supply/bms/temp_warm
echo '3000' > /sys/module/qpnp_smbcharger/parameters/default_hvdcp_icl_ma
echo '3000' > /sys/module/qpnp_smbcharger/parameters/default_dcp_icl_ma
echo '3000' > /sys/module/qpnp_smbcharger/parameters/default_hvdcp3_icl_ma
echo '3000' > /sys/module/dwc3_msm/parameters/dcp_max_current
echo '3000' > /sys/module/dwc3_msm/parameters/hvdcp_max_current
echo '3000' > /sys/module/phy_msm_usb/parameters/dcp_max_current
echo '3000' > /sys/module/phy_msm_usb/parameters/hvdcp_max_current
echo '3000' > /sys/module/phy_msm_usb/parameters/lpm_disconnect_thresh
echo '3000000' > /sys/class/power_supply/dc/current_max
echo '3000000' > /sys/class/power_supply/main/current_max
echo '3000000' > /sys/class/power_supply/parallel/current_max
echo '3000000' > /sys/class/power_supply/pc_port/current_max
echo '3000000' > /sys/class/power_supply/qpnp-dc/current_max
echo '3000000' > /sys/class/power_supply/battery/current_max
echo '3000000' > /sys/class/power_supply/battery/input_current_max
echo '3000000' > /sys/class/power_supply/usb/current_max
echo '3000000' > /sys/class/power_supply/usb/hw_current_max
echo '3500000' > /sys/class/power_supply/usb/pd_current_max
echo '3500000' > /sys/class/power_supply/usb/ctm_current_max
echo '3500000' > /sys/class/power_supply/usb/sdp_current_max
echo '3300000' > /sys/class/power_supply/main/constant_charge_current_max
echo '3500000' > /sys/class/power_supply/parallel/constant_charge_current_max
echo '3500000' > /sys/class/power_supply/battery/constant_charge_current_max
sleep 1






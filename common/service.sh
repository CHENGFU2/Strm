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

# Enjoy a better Android experience, and be kind to someone

exit 0





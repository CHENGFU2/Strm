#!/system/bin/sh
MODDIR=${0%/*}

/system/etc/Strm/r.sh > /dev/null 2>&1 &

#This imitation part of the code comes from LKT
write() {
    echo -n $2 > $1
}
copy() {
    if [ "$4" == "" ];then
	if [ -e "$1" ]; then
    cat $1 > $2
	fi
	else
	src1=$(cat $1 | tr -d '\n')
	src2=$(cat $2 | tr -d '\n')
	if [ -e "$1" ] && [ -e "$2" ]; then
	write "$3" "${src1} $4 ${src2}"
	fi
	fi
}
round() {
  printf "%.$2f" "$1"
}
min()
{
    local m="$1"
    for n in "$@"
    do
        [ "$n" -lt "$m" ] && m="$n"
    done
    echo "$m"
}
max()
{
    local m="$1"
    for n in "$@"
    do
        [ "$n" -gt "$m" ] && m="$n"
    done
    echo "$m"
}
set_value() {
	if [ -f $2 ]; then
		# chown 0.0 $2
		chmod 0644 $2
		echo $1 > $2
		chmod 0444 $2
	fi
}
is_int() { return $(test "$@" -eq "$@" > /dev/null 2>&1); }
    cores=`grep -c ^processor /proc/cpuinfo` 2>/dev/null
    coresmax=$(cat /sys/devices/system/cpu/kernel_max) 2>/dev/null
	if [[ $((cores % 2)) -ne 0 ]];then
    #echo "$cores is odd"
	cores=$(( ${cores} + 1 ))
	fi
	if [[ $((coresmax % 2)) -eq 0 ]];then
    #echo "$coresmax is even"
	coresmax=$(( ${coresmax} - 1 ))
	fi
	if [ -z ${cores} ];then
	cores=$(( ${coresmax} + 1 ))
	fi	
    if [ ${cores} -eq 4 ];then
    bcores="2"
    else
    bcores="4"
    fi
set_boost() {
	#Tune Input Boost
	if [ -e "/sys/module/cpu_boost/parameters/input_boost_ms" ]; then
	set_value $1 /sys/module/cpu_boost/parameters/input_boost_ms
	fi
	if [ -e "/sys/module/cpu_boost/parameters/input_boost_ms_s2" ]; then
	set_value 0 /sys/module/cpu_boost/parameters/input_boost_ms_s2
	fi
	if [ -e /sys/module/cpu_boost/parameters/input_boost_enabled ]; then
	set_value 1 /sys/module/cpu_boost/parameters/input_boost_enabled
	fi
	if [ -e /sys/module/cpu_boost/parameters/sched_boost_on_input ]; then
	set_value "N" /sys/module/cpu_boost/parameters/sched_boost_on_input
	fi
	if [ -e "/sys/kernel/cpu_input_boost/enabled" ]; then
	set_value 1 /sys/kernel/cpu_input_boost/enabled
	set_value $1 /sys/kernel/cpu_input_boost/ib_duration_ms
	fi
	#Disable Touch Boost
	if [ -e "/sys/module/msm_performance/parameters/touchboost" ]; then
	set_value 0 /sys/module/msm_performance/parameters/touchboost
	fi
	if [ -e /sys/power/pnpmgr/touch_boost ]; then
	set_value 0 /sys/power/pnpmgr/touch_boost
	fi
	#Disable CPU Boost
	if [ -e "/sys/module/cpu_boost/parameters/boost_ms" ]; then
	set_value 0 /sys/module/cpu_boost/parameters/boost_ms
	fi

}
set_boost_freq() {
    cpu_l=$(echo $1 | awk '{split($0,a); print a[1]}') 2>/dev/null
    cpu_b=$(echo $1 | awk '{split($0,a); print a[2]}') 2>/dev/null
    cpu_l_f=$(echo $cpu_l | awk -F: '{ print($NF) }') 2>/dev/null
	cpu_b_f=$(echo $cpu_b | awk -F: '{ print($NF) }') 2>/dev/null
	if [ -e "/sys/module/cpu_boost/parameters/input_boost_freq" ]; then
	freq="0:$cpu_l_f"
	i=1
	while [ $i -lt $bcores ]
	do
	freq="$i:$cpu_l_f $freq"
	i=$(( $i + 1 ))
	done
	i=$bcores
	while [ $i -lt $cores ]
	do
	freq="$i:$cpu_b_f $freq"
	i=$(( $i + 1 ))
	done	
	freq=$(echo $freq | awk '{for(i=NF;i>0;--i)printf "%s%s",$i,(i>1?OFS:ORS)}')
	set_value "$freq" /sys/module/cpu_boost/parameters/input_boost_freq
	if [ -e "/sys/kernel/cpu_input_boost/ib_freqs" ]; then
	set_value "0" /sys/kernel/cpu_input_boost/ib_freqs
	fi
	if [ -e "/sys/module/cpu_boost/parameters/input_boost_freq_s2" ]; then
	freq="0:0"
	i=1
	while [ $i -lt $cores ]
	do
	freq="$i:0 $freq"
	i=$(( $i + 1 ))
	done
	freq=$(echo $freq | awk '{for(i=NF;i>0;--i)printf "%s%s",$i,(i>1?OFS:ORS)}')
	set_value "$freq" /sys/module/cpu_boost/parameters/input_boost_freq_s2
	fi
	else
	if [ -e "/sys/kernel/cpu_input_boost/ib_freqs" ]; then
	freq="$cpu_l_f $cpu_b_f"
	set_value "$freq" /sys/kernel/cpu_input_boost/ib_freqs
	fi
	if [ -e "/sys/module/cpu_boost/parameters/input_boost_freq_s2" ]; then
	freq="0:$cpu_l_f"
	i=1
	while [ $i -lt $cores ]
	do
	freq="$i:$cpu_b_f $freq"
	i=$(( $i + 1 ))
	done
	freq=$(echo $freq | awk '{for(i=NF;i>0;--i)printf "%s%s",$i,(i>1?OFS:ORS)}')
	set_value "$freq" /sys/module/cpu_boost/parameters/input_boost_freq_s2
	fi
	fi
	if [ -e "/sys/module/cpu_boost/parameters/sync_threshold" ]; then
	set_value 0 /sys/module/cpu_boost/parameters/sync_threshold
	set_value 0 /sys/devices/system/cpu/cpufreq/interactive/sync_freq
	set_value 0 /sys/devices/system/cpu*/cpufreq/interactive/sync_freq
	fi
}
backup_boost() {
copy "/sys/module/cpu_boost/parameters/input_boost_freq" "/sys/module/cpu_boost/parameters/input_boost_ms" "/data/adb/boost1.txt" "#"
copy "/sys/kernel/cpu_input_boost/ib_freqs" "/sys/kernel/cpu_input_boost/ib_duration_m" "/data/adb/boost2.txt" "#"
copy "/sys/module/cpu_boost/parameters/input_boost_freq_s2" "/sys/module/cpu_boost/parameters/input_boost_ms_s2" "/data/adb/boost3.txt" "#"
copy "/sys/devices/system/cpu/cpufreq/interactive/go_hispeed_load" "/data/adb/go_hispeed.txt"
copy "/sys/devices/system/cpu/cpu0/cpufreq/interactive/go_hispeed_load" "/data/adb/go_hispeed_l.txt"
copy "/sys/devices/system/cpu/cpu$bcores/cpufreq/interactive/go_hispeed_load" "/data/adb/go_hispeed_b.txt"
}
restore_boost() {
	if [ -e "/data/adb/boost1.txt" ]; then
	FREQ_FILE="/data/adb/boost1.txt"
	FREQ=$(awk -F# '{ print tolower($1) }' $FREQ_FILE)
	BOOSTMS=$(awk -F# '{ print tolower($2) }' $FREQ_FILE)
	set_value "$FREQ" /sys/module/cpu_boost/parameters/input_boost_freq
	set_value $BOOSTMS /sys/module/cpu_boost/parameters/input_boost_ms
	fi
	if [ -e "/data/adb/boost2.txt" ]; then
	FREQ_FILE="/data/adb/boost2.txt"
	FREQ=$(awk -F# '{ print tolower($1) }' $FREQ_FILE)
	BOOSTMS=$(awk -F# '{ print tolower($2) }' $FREQ_FILE)
	set_value "$FREQ" /sys/kernel/cpu_input_boost/ib_freqs
	set_value $BOOSTMS /sys/kernel/cpu_input_boost/ib_duration_ms
	fi
	if [ -e "/data/adb/boost3.txt" ]; then
	FREQ_FILE="/data/adb/boost3.txt"
	FREQ=$(awk -F# '{ print tolower($1) }' $FREQ_FILE)
	BOOSTMS=$(awk -F# '{ print tolower($2) }' $FREQ_FILE)
	set_value "$FREQ" /sys/module/cpu_boost/parameters/input_boost_freq_s2
	set_value $BOOSTMS /sys/module/cpu_boost/parameters/input_boost_ms_s2
	fi
	if [ -e "/data/adb/go_hispeed" ]; then
	$GO_HIS=$(cat /data/adb/go_hispeed.txt)
	set_value $GO_HIS /sys/devices/system/cpu/cpufreq/interactive/go_hispeed
	fi
	if [ -e "/data/adb/go_hispeed_l" ]; then
	$GO_HIS=$(cat /data/adb/go_hispeed_l.txt)
	set_value $GO_HIS /sys/devices/system/cpu/cpu0/cpufreq/interactive/go_hispeed
	fi
	if [ -e "/data/adb/go_hispeed_b" ]; then
	$GO_HIS=$(cat /data/adb/go_hispeed_b.txt)
	set_value $GO_HIS /sys/devices/system/cpu/cpu$bcores/cpufreq/interactive/go_hispeed
	fi
}
backup_eas() {
copy "/dev/stune/top-app/schedtune.boost" "/data/adb/top-app.txt"
copy "/dev/stune/foreground/schedtune.boost" "/data/adb/foreground.txt"
copy "/dev/stune/background/schedtune.boost" "/data/adb/background.txt"
copy "/sys/module/cpu_boost/parameters/dynamic_stune_boost" "/data/adb/dynamic_stune_boost.txt"
}
backup_gpu() {
if [ -d "/sys/class/kgsl/kgsl-3d0" ]; then
GPU_DIR="/sys/class/kgsl/kgsl-3d0"
else
GPU_DIR="/sys/devices/soc/*.qcom,kgsl-3d0/kgsl/kgsl-3d0"
fi

for i in ${GPU_DIR}/*
do
chmod 0666 $i
done

copy "$GPU_DIR/deep_nap_timer" "/data/adb/deep_nap_timer.txt"
copy "$GPU_DIR/idle_timer" "/data/adb/idle_timer.txt"
}

LOG="/data/Strm.prop"
RETRY_INTERVAL=10 #in seconds
MAX_RETRY=30
retry=${MAX_RETRY}
#wait for boot completed
while (("$retry" > "0")) && [ "$(getprop sys.boot_completed)" != "1" ]; do
  sleep ${RETRY_INTERVAL}
  ((retry--))
done
if [ -e $LOG ]; then
  rm $LOG;
fi;
if [ "$1" == "" ];then
if [ -e "/data/adb/boost1.txt" ]; then
rm "/data/adb/boost1.txt"
fi;
if [ -e "/data/adb/boost2.txt" ]; then
rm "/data/adb/boost2.txt"
fi;
if [ -e "/data/adb/boost3.txt" ]; then
rm "/data/adb/boost3.txt"
fi;
if [ -e "/data/adb/background.txt" ]; then
rm "/data/adb/background.txt"
fi;
if [ -e "/data/adb/foreground.txt" ]; then
rm "/data/adb/foreground.txt"
fi;
if [ -e "/data/adb/top-app.txt" ]; then
rm "/data/adb/top-app.txt"
fi;
if [ -e "/data/adb/dynamic_stune_boost.txt" ]; then
rm "/data/adb/dynamic_stune_boost.txt"
fi;
if [ -e "/data/adb/go_hispeed.txt" ]; then
rm "/data/adb/go_hispeed.txt"
fi;
if [ -e "/data/adb/go_hispeed_l.txt" ]; then
rm "/data/adb/go_hispeed_l.txt"
fi;
if [ -e "/data/adb/go_hispeed_b.txt" ]; then
rm "/data/adb/go_hispeed_b.txt"
fi;
if [ -e "/data/adb/idle_timer.txt" ]; then
rm "/data/adb/idle_timer.txt"
fi;
if [ -e "/data/adb/deep_nap_timer.txt" ]; then
rm "/data/adb/deep_nap_timer.txt"
fi;
backup_boost
backup_eas
backup_gpu
fi;
    if [ "$1" == "" ];then
    PROFILE="<PROFILE_MODE>"
    if [ -e "/data/adb/Strmprofile.txt" ]; then
	PROFILE=$(cat /data/adb/Strmprofile.txt | tr -d '\n')
	else
	echo $PROFILE > /data/adb/Strmprofile.txt
	fi
	else
    PROFILE=$1
	rm /data/adb/Strmprofile.txt
	if [ ! -f /data/adb/Strmprofile.txt ]; then
	echo $1 > /data/adb/Strmprofile.txt
    fi
	fi
    if [ "$2" == "" ];then
    bootdelay=90
    else
    bootdelay=$2
    fi
    sleep ${bootdelay}
    export TZ=$(getprop persist.sys.timezone);
    #MOD Variable
    V="<VER>"
    dt=$(date '+%d/%m/%Y %H:%M:%S');
    sbusybox=`busybox | awk 'NR==1{print $2}'` 2>/dev/null
    # RAM variables
    TOTAL_RAM=$(awk '/^MemTotal:/{print $2}' /proc/meminfo) 2>/dev/null
    if [ $TOTAL_RAM -ge 1000000 ] && [ $TOTAL_RAM -lt 1500000 ]; then
    memg=$(awk -v x=$TOTAL_RAM 'BEGIN{print x/1000000}')
    memg=$(round ${memg} 1)
	else
    memg=$(awk -v x=$TOTAL_RAM 'BEGIN{printf("%.f\n", (x/1000000)+0.5)}')
    memg=$(round ${memg} 0)
    fi
    if [ ${memg} -gt 32 ];then
    memg=$(awk -v x=$memg 'BEGIN{printf("%.f\n", (x/1000)+0.5)}')
    fi
    # CPU variables
    arch_type=`uname -m` 2>/dev/null
    # Device infos
    BATT_LEV=`cat /sys/class/power_supply/battery/capacity | tr -d '\n'` 2>/dev/null
    BATT_TECH=`cat /sys/class/power_supply/battery/technology | tr -d '\n'` 2>/dev/null
    BATT_HLTH=`cat /sys/class/power_supply/battery/health | tr -d '\n'` 2>/dev/null
    BATT_TEMP=`cat /sys/class/power_supply/battery/temp | tr -d '\n'` 2>/dev/null
    BATT_VOLT=`cat /sys/class/power_supply/battery/batt_vol | tr -d '\n'` 2>/dev/null
    if [ "$BATT_LEV" == "" ];then
    BATT_LEV=`dumpsys battery | grep level | awk '{print $2}'` 2>/dev/null
    elif [ "$BATT_LEV" == "" ];then
    BATT_LEV=$(awk -F ': |;' '$1=="Percentage(%)" {print $2}' /sys/class/power_supply/battery/batt_attr_text) 2>/dev/null
    fi
    if [ "$BATT_TECH" == "" ];then
    BATT_TECH=`dumpsys battery | grep technology | awk '{print $2}'` 2>/dev/null
    fi
    if [ "$BATT_VOLT" == "" ];then
    BATT_VOLT=`dumpsys battery | awk '/^ +voltage:/ && $NF!=0{print $NF}'` 2>/dev/null
    elif [ "$BATT_VOLT" == "" ];then
    BATT_VOLT=$(awk -F ': |;' '$1=="VBAT(mV)" {print $2}' /sys/class/power_supply/battery/batt_attr_text) 2>/dev/null
    fi
    if [ "$BATT_TEMP" == "" ];then
    BATT_TEMP=`dumpsys battery | grep temperature | awk '{print $2}'` 2>/dev/null
    elif [ "$BATT_TEMP" == "" ];then
    BATT_TEMP=$(awk -F ': |;' '$1=="BATT_TEMP" {print $2}' /sys/class/power_supply/battery/batt_attr_text) 2>/dev/null
    fi
    if [ "$BATT_HLTH" == "" ];then
    BATT_HLTH=`dumpsys battery | grep health | awk '{print $2}'` 2>/dev/null
    if [ $BATT_HLTH -eq "2" ];then
    BATT_HLTH="Very Good"
    elif [ $BATT_HLTH -eq "3" ];then
    BATT_HLTH="Good"
    elif [ $BATT_HLTH -eq "4" ];then
    BATT_HLTH="Poor"
    elif [ $BATT_HLTH -eq "5" ];then
    BATT_HLTH="Sh*t"
    else
    BATT_HLTH="Unknown"
    fi
    elif [ "$BATT_HLTH" == "" ];then
    BATT_HLTH=$(awk -F ': |;' '$1=="HEALTH" {print $2}' /sys/class/power_supply/battery/batt_attr_text) 2>/dev/null
    if [ $BATT_HLTH -eq "1" ];then
    BATT_HLTH="Very Good"
    else
    BATT_HLTH="Unknown"
    fi
    fi
    BATT_TEMP=$(awk -v x=$BATT_TEMP 'BEGIN{print x/10}')
    BATT_VOLT=$(awk -v x=$BATT_VOLT 'BEGIN{print x/1000}')
    BATT_VOLT=$(round ${BATT_VOLT} 1) 
    VENDOR=`getprop ro.product.brand | tr '[:lower:]' '[:upper:]'`
    KERNEL="$(uname -r)"
    OS=`getprop ro.build.version.release`
    APP=`getprop ro.product.model`
    SOC=$(awk '/^Hardware/{print tolower($NF)}' /proc/cpuinfo | tr -d '\n') 2>/dev/null
    SOC0=`cat /sys/devices/soc0/machine  | tr -d '\n' | tr '[:upper:]' '[:lower:]'` 2>/dev/null
    SOC1=`cat /sys/devices/soc0/soc_id  | tr -d '\n' | tr '[:upper:]' '[:lower:]'` 2>/dev/null
    SOC2=`getprop ro.product.board | tr '[:upper:]' '[:lower:]'` 2>/dev/null
    SOC3=`getprop ro.product.platform | tr '[:upper:]' '[:lower:]'` 2>/dev/null
    SOC4=`getprop ro.board.platform | tr '[:upper:]' '[:lower:]'` 2>/dev/null
    SOC5=`getprop ro.chipname | tr '[:upper:]' '[:lower:]'` 2>/dev/null
    SOC6=`getprop ro.hardware | tr '[:upper:]' '[:lower:]'` 2>/dev/null
	soc_id=$(cat /sys/devices/soc0/id) 2>/dev/null
	soc_revision=$(cat /sys/devices/soc0/revision) 2>/dev/null
	adreno=0
	if [ -d "/sys/class/kgsl/kgsl-3d0" ]; then
	GPU_DIR="/sys/class/kgsl/kgsl-3d0"
	adreno=1
	elif [ -d "/sys/devices/platform/kgsl-3d0.0/kgsl/kgsl-3d0" ]; then
	GPU_DIR="/sys/devices/platform/kgsl-3d0.0/kgsl/kgsl-3d0"
	adreno=1
	elif [ -d "/sys/devices/soc/*.qcom,kgsl-3d0/kgsl/kgsl-3d0" ]; then
	GPU_DIR="/sys/devices/soc/*.qcom,kgsl-3d0/kgsl/kgsl-3d0"
	adreno=1
	elif [ -d "/sys/devices/soc.0/*.qcom,kgsl-3d0/kgsl/kgsl-3d0" ]; then
	GPU_DIR="/sys/devices/soc.0/*.qcom,kgsl-3d0/kgsl/kgsl-3d0"
	adreno=1
	elif [ -d "/sys/devices/platform/*.gpu/devfreq/*.gpu" ]; then
	GPU_DIR="/sys/devices/platform/*.gpu/devfreq/*.gpu"	
	adreno=0
	elif [ -d "/sys/devices/platform/gpusysfs" ]; then
	GPU_DIR="/sys/devices/platform/gpusysfs"
	adreno=0
	elif [ -d "/sys/devices/*.mali" ]; then
	GPU_DIR="/sys/devices/*.mali"
	adreno=0
	elif [ -d "/sys/devices/*.gpu" ]; then
	GPU_DIR="/sys/devices/*.gpu"
	adreno=0
	elif [ -d "/sys/devices/platform/mali.0" ]; then
	GPU_DIR="/sys/devices/platform/mali.0"
	adreno=0
	elif [ -d "/sys/devices/platform/mali-*.0" ]; then
	GPU_DIR="/sys/devices/platform/mali-*.0"
	adreno=0
	elif [ -d "/sys/module/mali/parameters" ]; then
	GPU_DIR="/sys/module/mali/parameters"
	adreno=0
	elif [ -d "/sys/class/misc/mali0" ]; then
	GPU_DIR="/sys/class/misc/mali0"
	adreno=0
	elif [ -d "/sys/kernel/gpu" ]; then
	GPU_DIR="/sys/kernel/gpu"
	adreno=0
	fi
	if [ -e "$GPU_DIR/devfreq/available_frequencies" ]; then
	GPU_FREQS=$(cat $GPU_DIR/devfreq/available_frequencies) 2>/dev/null
	elif [ -d "$GPU_DIR/devfreq/*.mali/available_frequencies" ]; then
	GPU_FREQS=$(cat $GPU_DIR/devfreq/*.mali/available_frequencies) 2>/dev/null
	elif [ -d "$GPU_DIR/device/devfreq/*.gpu/available_frequencies" ]; then
	GPU_FREQS=$(cat $GPU_DIR/device/devfreq/*.gpu/available_frequencies) 2>/dev/null
	elif [ -d "$GPU_DIR/device/available_frequencies" ]; then
	GPU_FREQS=$(cat $GPU_DIR/device/available_frequencies) 2>/dev/null
	fi

	if [ -e "$GPU_DIR/devfreq/available_governors" ]; then
	GPU_GOV=$(cat $GPU_DIR/devfreq/available_governors) 2>/dev/null
	elif [ -d "$GPU_DIR/devfreq/*.mali/available_governors" ]; then
	GPU_GOV=$(cat $GPU_DIR/devfreq/*.mali/available_governors) 2>/dev/null
	elif [ -d "$GPU_DIR/device/devfreq/*.gpu/available_governors" ]; then
	GPU_GOV=$(cat $GPU_DIR/device/devfreq/*.gpu/available_governors) 2>/dev/null
	elif [ -d "$GPU_DIR/device/available_governors" ]; then
	GPU_GOV=$(cat $GPU_DIR/device/available_governors) 2>/dev/null
	fi

	if [ -e "$GPU_DIR/gpu_model" ]; then
	GPU_MODEL=$(cat $GPU_DIR/gpu_model) 2>/dev/null
	elif [ -d "$GPU_DIR/*.mali/gpu_model" ]; then
	GPU_MODEL=$(cat $GPU_DIR/*.mali/gpu_model) 2>/dev/null
	elif [ -d "$GPU_DIR/device/*.gpu/gpu_model" ]; then
	GPU_MODEL=$(cat $GPU_DIR/device/*.gpu/gpu_model) 2>/dev/null
	elif [ -d "$GPU_DIR/device/gpu_model" ]; then
	GPU_MODEL=$(cat $GPU_DIR/device/gpu_model) 2>/dev/null
	fi

    CPU_FILE="/data/soc.txt"
    error=0
    support=0
    snapdragon=0
    chip=0
	EAS=0
	HMP=0
	shared=1
	MSG=0
    LOGDATA() {
        echo $1 |  tee -a $LOG;
    }
    if [ -e /sys/devices/system/cpu/cpu0/cpufreq ]; then
    GOV_PATH_L=/sys/devices/system/cpu/cpu0/cpufreq
    fi
    if [ -e "/sys/devices/system/cpu/cpu${bcores}/cpufreq" ]; then
    GOV_PATH_B="/sys/devices/system/cpu/cpu${bcores}/cpufreq"
    fi
	available_governors=$(cat ${GOV_PATH_L}/scaling_available_governors)
    is_big_little=true
    if [ -z ${SOC} ];then
	error=1
    SOC=${SOC0}
	else
    #LOGDATA "#  [WARNING] SOC DETECTION FAILED. TRYING ALTERNATIVES"
	case ${SOC} in msm* | sm* | apq* | sdm* | sda* | exynos* | universal* | kirin* | hi* | moorefield* | mt*)
	error=0
    if [[ ! -n ${SOC//[a-z]} ]] && [ "$SOC" != "moorefield" ]; then
	error=2
    SOC=${SOC0}
    fi
    ;;
	*)
	error=2
    SOC=${SOC0}
    ;;
	esac
    fi
    if [ -z ${SOC} ];then
	error=1
	SOC=${SOC1}
	else
    if [ $error -ne 0 ]; then
    #LOGDATA "#  [WARNING] SOC DETECTION METHOD(0) FAILED. TRYING ALTERNATIVES"
    case ${SOC} in msm* | sm* | "8cx" | apq* | sdm* | sda* | exynos* | universal* | kirin* | hi* | moorefield* | mt*)
	error=0
    if [[ ! -n ${SOC//[a-z]} ]] && [ "$SOC" != "moorefield" ]; then
	error=2
    SOC=${SOC1}
    fi
    ;;
	*)
	error=2
	SOC=${SOC1}
    ;;
	esac
    fi
    fi
    if [ -z ${SOC} ];then
	error=1
	SOC=${SOC2}
	else
    if [ $error -ne 0 ]; then
    #LOGDATA "#  [WARNING] SOC DETECTION METHOD(1) FAILED. TRYING ALTERNATIVES"
    case ${SOC} in msm* | sm* | "8cx" | apq* | sdm* | sda* | exynos* | universal* | kirin* | hi* | moorefield* | mt*)
	error=0
    if [[ ! -n ${SOC//[a-z]} ]] && [ "$SOC" != "moorefield" ]; then
	error=2
    SOC=${SOC2}
    fi
    ;;
	*)
	error=2
	SOC=${SOC2}
    ;;
	esac
    fi
    fi
    if [ -z ${SOC} ];then
	error=1
	SOC=${SOC3}
	else
    if [ $error -ne 0 ]; then
    #LOGDATA "#  [WARNING] SOC DETECTION METHOD(2) FAILED. TRYING ALTERNATIVES"
    case ${SOC} in msm* | sm* | "8cx" | apq* | sdm* | sda* | exynos* | universal* | kirin* | hi* | moorefield* | mt*)
	error=0
    if [[ ! -n ${SOC//[a-z]} ]] && [ "$SOC" != "moorefield" ]; then
	error=2
    SOC=${SOC3}
    fi
    ;;
	*)
	error=2
 	SOC=${SOC3}
    ;;
	esac
    fi
    fi
    if [ -z ${SOC} ];then
	error=1
	SOC=${SOC4}
	else
    if [ $error -ne 0 ]; then
    #LOGDATA "#  [WARNING] SOC DETECTION METHOD(3) FAILED. TRYING ALTERNATIVES"
    case ${SOC} in msm* | sm* | "8cx" | apq* | sdm* | sda* | exynos* | universal* | kirin* | hi* | moorefield* | mt*)
	error=0
    if [[ ! -n ${SOC//[a-z]} ]] && [ "$SOC" != "moorefield" ]; then
	error=2
    SOC=${SOC4}
    fi
     ;;
	*)
	error=2
    SOC=${SOC4}
    ;;
	esac
    fi
    fi
    if [ -z ${SOC} ];then
	error=1
	SOC=${SOC5}
	else
    if [ $error -ne 0 ]; then
    #LOGDATA "#  [WARNING] SOC DETECTION METHOD(3) FAILED. TRYING ALTERNATIVES"
    case ${SOC} in msm* | sm* | "8cx" | apq* | sdm* | sda* | exynos* | universal* | kirin* | hi* | moorefield* | mt*)
	error=0
    if [[ ! -n ${SOC//[a-z]} ]] && [ "$SOC" != "moorefield" ]; then
	error=2
    SOC=${SOC5}
    fi
     ;;
	*)
	error=2
    SOC=${SOC5}
    ;;
	esac
    fi
    fi
    if [ -z ${SOC} ];then
    LOGDATA "#  [WARNING] SOC DETECTION FAILED. USING MANUAL METHOD"
    if [ -e $CPU_FILE ]; then
    if grep -q 'CPU=' $CPU_FILE
    then
    SOC7=$(awk -F= '{ print tolower($2) }' $CPU_FILE) 2>/dev/null
    else
    SOC7=$(cat $CPU_FILE | tr '[:upper:]' '[:lower:]') 2>/dev/null
    fi	
    SOC=${SOC7}
    if [ -z ${SOC} ];then
    error=3
    LOGDATA "#  [ERROR] MANUAL SOC DETECTION FAILED"
    LOGDATA "#  [INFO] $CPU_FILE IS EMPTY"
    LOGDATA "#  [INFO] PLEASE EDIT $CPU_FILE FILE WITH YOUR SOC MODEL NUMBER THEN REBOOT"
    exit 0
    fi
    case ${SOC} in msm* | sm* | "8cx" | apq* | sdm* | sda* | exynos* | universal* | kirin* | hi* | moorefield* | mt*)
	error=0
	;;
	*)
    LOGDATA "#  [ERROR] MANUAL SOC DETECTION FAILED"
    LOGDATA "#  [INFO] $CPU_FILE DOES NOT CONTAIN A VALID CPU MODEL NUMBER"
    LOGDATA "#  [INFO] PLEASE EDIT $CPU_FILE FILE WITH YOUR CORRECT SOC MODEL NUMBER THEN REBOOT"
    exit 0
	;;
	esac
    else
    LOGDATA "#  [ERROR] SOC DETECTION FAILED"
    LOGDATA "#  "
    LOGDATA "#  "
    LOGDATA "#  "
    LOGDATA "#  "
    LOGDATA "# 1) USING A ROOT FILE EXPLORER"
    LOGDATA "#  "
    LOGDATA "# 2) GO TO $CPU_FILE AND EDIT IT WITH YOUR CPU MODEL"
    LOGDATA "#  "
    LOGDATA "#    EXAMPLE (HUAWEI KIRIN 970)       CPU=KIRIN970"
    LOGDATA "#    EXAMPLE (SNAPDRAGON 845)         CPU=SDM845"
    LOGDATA "#    EXAMPLE (SNAPDRAGON 820 OR 821)  CPU=MSM8996"
    LOGDATA "#    EXAMPLE (GALAXY S7 EXYNOS8890)   CPU=EXYNOS8890"
    LOGDATA "#    EXAMPLE (GALAXY S8 EXYNOS8890)   CPU=EXYNOS8895"
    LOGDATA "#  "
    LOGDATA '#    PRECEEDING THE CPU MODEL NUMBER WITH "CPU=" IS NOT REQUIRED '
    LOGDATA "#    YOU CAN ALSO WRITE ONLY YOUR CPU MODEL IN SOC.TXT FILE "
    LOGDATA "#  "
    LOGDATA "# 3) SAVE CHANGES & REBOOT"
    LOGDATA "#  "
    LOGDATA "#  "
    LOGDATA "#  "
    LOGDATA "#  "
    LOGDATA "# TIP: USE CPU-Z APP OR FIND YOUR CORRECT CPU MODEL NUMBER ON THIS PAGE"
    LOGDATA "#  "
    LOGDATA "# https://en.wikipedia.org/wiki/List_of_Qualcomm_Snapdragon_systems-on-chip"
    write $CPU_FILE "CPU="
    exit 0
    fi	
    fi
    SOC="${SOC//[[:space:]]/}"
    SOC=`echo $SOC | tr -d -c '[:alnum:]'`
	freqs_list0=$(cat $GOV_PATH_L/scaling_available_frequencies) 2>/dev/null
    freqs_list4=$(cat $GOV_PATH_B/scaling_available_frequencies) 2>/dev/null
	maxfreq_l="$(max $freqs_list0)"
	maxfreq_b="$(max $freqs_list4)"
	if [ ! -e ${GOV_PATH_L}/scaling_available_frequencies ]; then
	maxfreq_l=$(cat "$GOV_PATH_L/cpuinfo_max_freq") 2>/dev/null	
    maxfreq_b=$(cat "$GOV_PATH_B/cpuinfo_max_freq") 2>/dev/null
    fi
	if [ ! -e "${GOV_PATH_L}/scaling_available_frequencies" ] && [ ! -e "${GOV_PATH_L}/cpuinfo_max_freq" ]; then
	maxfreq_l=$(cat "/sys/devices/system/cpu/cpufreq/scaling_available_frequencies") 2>/dev/null	
    maxfreq_b=${maxfreq_l}
    fi
	if [ ! -e "${GOV_PATH_L}/scaling_available_frequencies" ] && [ ! -e "${GOV_PATH_L}/cpuinfo_max_freq" ] && [ ! -e "/sys/devices/system/cpu/cpufreq/scaling_available_frequencies" ]; then
	maxfreq_l=$(cat "/sys/devices/system/cpu/cpufreq/cpuinfo_max_freq") 2>/dev/null	
    maxfreq_b=${maxfreq_l}
    fi

	GPU_MIN="$(min $GPU_FREQS)"
	GPU_MAX="$(max $GPU_FREQS)"
	
	if [ ! -e ${GPU_FREQS} ]; then
	GPU_MIN=$(cat "$GPU_DIR/devfreq/min_freq") 2>/dev/null	
	GPU_MAX=$(cat "$GPU_DIR/devfreq/max_freq") 2>/dev/null	
	fi

	if [ ! -e ${GPU_DIR}/devfreq/max_freq ] && [ ! -e ${GPU_DIR}/devfreq/max_freq ]; then
	GPU_MIN=$(cat "$GPU_DIR/gpuclk") 2>/dev/null	
	GPU_MAX=$(cat "$GPU_DIR/max_gpuclk") 2>/dev/null	
    fi

    before_modify()
{
for i in ${GOV_PATH_L}/interactive/*
do
chmod 0666 $i
done
for i in ${GOV_PATH_B}/interactive/*
do
chmod 0666 $i
done
if [ -d "/sys/devices/system/cpu/cpufreq/interactive" ]; then
for i in /sys/devices/system/cpu/cpufreq/interactive/*
do
chmod 0666 $i
done
fi
}
    after_modify()
{
for i in ${GOV_PATH_L}/interactive/*
do
chmod 0444 $i
done
for i in ${GOV_PATH_B}/interactive/*
do
chmod 0444 $i
done
if [ -d "/sys/devices/system/cpu/cpufreq/interactive" ]; then
for i in /sys/devices/system/cpu/cpufreq/interactive/*
do
chmod 0444 $i
done
fi
}
    before_modify_eas()
{
for i in ${GOV_PATH_L}/$1/*
do
chown 0.0 $i
chmod 0666 $i
done
for i in ${GOV_PATH_B}/$1/*
do
chown 0.0 $i
chmod 0666 $i
done	
}
    after_modify_eas()
{
for i in ${GOV_PATH_L}/$1/*
do
chmod 0444 $i
done
for i in ${GOV_PATH_B}/$1/*
do
chmod 0444 $i
done	
}
C0_GOVERNOR_DIR="/sys/devices/system/cpu/cpu0/cpufreq/interactive"
C1_GOVERNOR_DIR="/sys/devices/system/cpu/cpu${bcores}/cpufreq/interactive"
C0_CPUFREQ_DIR="/sys/devices/system/cpu/cpu0/cpufreq"
C1_CPUFREQ_DIR="/sys/devices/system/cpu/cpu${bcores}/cpufreq"
if ! ${is_big_little} ; then
	C0_GOVERNOR_DIR="/sys/devices/system/cpu/cpufreq/interactive"
	C1_GOVERNOR_DIR=""
	C0_CPUFREQ_DIR="/sys/devices/system/cpu/cpu0/cpufreq"
	C1_CPUFREQ_DIR=""
fi
set_param_little() 
{
	echo $2 > ${C0_GOVERNOR_DIR}/$1
}
set_param_big() 
{
	echo $2 > ${C1_GOVERNOR_DIR}/$1
}
set_param_HMP()
{
	echo $2 > /proc/sys/kernel/$1
}
set_param() {
 if [ $1 = "cpu0" ];then
	if [ -d "/sys/devices/system/cpu/cpufreq/interactive" ]; then
	write /sys/devices/system/cpu/cpufreq/interactive/$2 "$3"
    else
	i=0
	t_cores=${bcores}
	while [ $i -lt $t_cores ]
	do
	CPU_DIR="/sys/devices/system/cpu/cpu$i"
	write ${CPU_DIR}/cpufreq/interactive/$2 "$3"
	i=$(( $i + 1 ))
	done
	fi
fi
if [ $1 = "cpu${bcores}" ];then
	i=${bcores}
	t_cores=${cores}
	while [ $i -lt $t_cores ]
	do
	CPU_DIR="/sys/devices/system/cpu/cpu$i"
	write ${CPU_DIR}/cpufreq/interactive/$2 "$3"
	i=$(( $i + 1 ))
	done			
fi

}
set_param_all() 
{
	set_param cpu0 $1 $2
	${is_big_little} && set_param cpu${bcores} $1 $2
}
set_param_eas() {

 if [ $2 = "cpu0" ];then
 	if [ -d "/sys/devices/system/cpu/cpufreq/$1" ]; then
	write /sys/devices/system/cpu/cpufreq/$1/$2 $3
	else
	i=0
	t_cores=${bcores}
	while [ $i -lt $t_cores ]
	do
	write /sys/devices/system/cpu/cpu$i/cpufreq/$1/$3 "$4"
	i=$(( $i + 1 ))
	done
	fi
fi
if [ $2 = "cpu${bcores}" ];then
	i=${bcores}
	t_cores=${cores}
	while [ $i -lt $t_cores ]
	do
	write /sys/devices/system/cpu/cpu$i/cpufreq/$1/$3 "$4"
	i=$(( $i + 1 ))
	done			
fi
}
update_clock_speed() {
 if [ $2 = "little" ];then
	i=0
	t_cores=${bcores}
  	set_value "$i:$1" "/sys/module/msm_performance/parameters/cpu_$3_freq"
	chmod 0644 "/sys/module/msm_performance/parameters/cpu_$3_freq"
	while [ $i -lt $t_cores ]
	do
	CPUFREQ_DIR="/sys/devices/system/cpu/cpu$i/cpufreq"
	set_value "$1" "${CPUFREQ_DIR}/scaling_$3_freq"
	chmod 0644 "$1" "${CPUFREQ_DIR}/scaling_$3_freq"
	i=$(( $i + 1 ))
	done		
fi
if [ $2 = "big" ];then
	i=${bcores}
	t_cores=${cores}
  	set_value "$i:$1" "/sys/module/msm_performance/parameters/cpu_$3_freq"
	chmod 0644 "/sys/module/msm_performance/parameters/cpu_$3_freq"
	while [ $i -lt $t_cores ]
	do
	CPUFREQ_DIR="/sys/devices/system/cpu/cpu$i/cpufreq"
	set_value "$1" "${CPUFREQ_DIR}/scaling_$3_freq"
	chmod 0644 "$1" "${CPUFREQ_DIR}/scaling_$3_freq"
	i=$(( $i + 1 ))
	done			
fi
if [ -f  "/proc/cpufreq/cpufreq_limited_$3_freq_by_user"  ]; then
	set_value $1 "/proc/cpufreq/cpufreq_limited_$3_freq_by_user"
	chmod 0644 "/proc/cpufreq/cpufreq_limited_$3_freq_by_user"
fi
}
set_io() {
	if [ -f $2/queue/scheduler ]; then
		if [ `grep -c $1 $2/queue/scheduler` = 1 ]; then
			write $2/queue/scheduler $1
			if [[ "$1" == "cfq" ]];then
			if [ ${PROFILE} -ge 2 ];then
			write $2/queue/read_ahead_kb 512
			else
			write $2/queue/read_ahead_kb 128
			fi
			for i in /sys/block/*/queue/iosched; do
			  write $i/low_latency 0;
			done;
			for i in /sys/block/*/queue/iosched; do
			  write $i/slice_idle 0;
			done;
			for i in /sys/block/*/queue/iosched; do
			  write $i/group_idle 8;
			done;
			elif [[ "$1" == "maple" ]];then
			for i in /sys/block/*/queue/iosched; do
			  write $i/async_read_expire 666;
			done;
			for i in /sys/block/*/queue/iosched; do
			  write $i/async_write_expire 1666;
			done;
			for i in /sys/block/*/queue/iosched; do
			  write $i/fifo_batch 16;
			done;
			for i in /sys/block/*/queue/iosched; do
			  write $i/sleep_latency_multiple 5;
			done;
			for i in /sys/block/*/queue/iosched; do
			  write $i/sync_read_expire 333;
			done;
			for i in /sys/block/*/queue/iosched; do
			  write $i/sync_write_expire 1166;
			done;
			for i in /sys/block/*/queue/iosched; do
			  write $i/writes_starved 3;
			done;
			for i in /sys/block/*/queue/iosched; do
			  write $i/read_ahead_kb 128;
			done;
			else
			write $2/queue/read_ahead_kb 128
			fi
  		fi
	fi
}
    # Manually add infos that are not found/ inaccurate for some devices
	case ${SOC} in sm8150* ) #sd855
    support=1
	maxfreq_l=1880000
	maxfreq_b=2880000
	update_clock_speed 280000 little min
	update_clock_speed 680000 big min
	esac
	case ${SOC} in sdm845* | sda845* ) #sd845
    support=1
	maxfreq_l=1780000
	maxfreq_b=2880000
	update_clock_speed 280000 little min
	update_clock_speed 780000 big min
	esac
	case ${SOC} in msm8998* | apq8098*) #sd835
    support=1
	esac
	case ${SOC} in msm8996* | apq8096*) #sd820
    support=1
	esac
	case ${SOC} in msm8994*) #sd810
    support=1
	maxfreq_l=1555200
	maxfreq_b=1958400
	cores=8
	bcores=4
	esac
	case ${SOC} in msm8992*) #sd808
    support=1
	maxfreq_l=1440000
	maxfreq_b=1824000
	cores=6
	bcores=4
	esac
	case ${SOC} in apq8074* | apq8084* | msm8074* | msm8084* | msm8274* | msm8674*| msm8974*)  #sd800-801-805
	is_big_little=false
    support=1
	esac
	case ${SOC} in sdm660* | sda660*) #sd660
    support=1
	esac
	case ${SOC} in msm8956* | msm8976*)  #sd652/650
    support=1
	esac
	case ${SOC} in sdm636* | sda636*) #sd636
    support=1
	esac
	case ${SOC} in msm8953* | sdm630* | sda630* )  #sd625/626/630
    support=1
	esac
	case ${SOC} in universal9810* | exynos9810*) #exynos9810
    support=1
	maxfreq_l=1794000
	maxfreq_b=2704000
	update_clock_speed 580000 little min
	update_clock_speed 580000 big min
	cores=8
	bcores=4
	MSG=1
	esac
	case ${SOC} in universal8895* | exynos8895*)  #EXYNOS8895 (S8)
    support=1
	maxfreq_l=1690000
	maxfreq_b=2314000
	cores=8
	bcores=4
	esac
	case ${SOC} in universal8890* | exynos8890*)  #EXYNOS8890 (S7)
    support=1
	maxfreq_l=1586000
	maxfreq_b=2600000
	cores=8
	bcores=4
	esac
	case ${SOC} in universal7420* | exynos7420*) #EXYNOS7420 (S6)
    support=1
	esac
	case ${SOC} in kirin970* | hi3670*)  # Huawei Kirin 970
    support=1
	esac
	case ${SOC} in kirin960* | hi3660*)  # Huawei Kirin 960
    support=1
	esac
	case ${SOC} in kirin950* | hi3650* | kirin955* | hi3655*) # Huawei Kirin 950
    support=1
	esac
	case ${SOC} in mt6797*) #Helio X25 / X20	 
    support=1
	maxfreq_l=2100000
	maxfreq_b=2100000
	esac
	case ${SOC} in mt6795*) #Helio X10
    support=1
	maxfreq_l=1950000
	maxfreq_b=1950000
	esac
	case ${SOC} in moorefield*) # Intel Atom
    support=1
	esac
	case ${SOC} in msm8939* | msm8952*)  #sd615/616/617 by@ 橘猫520
	 if [ "$SOC" = "msm8952" ]; then
	 maxfreq_l=1516800
	 maxfreq_b=1209600
	 fi
    support=2
	cores=8
	bcores=4
	MSG=1
    esac
    case ${SOC} in kirin650* | kirin655* | kirin658* | kirin659* | hi625*)  #KIRIN650 by @橘猫520
    support=2
	MSG=1
    esac
    case ${SOC} in apq8026* | apq8028* | apq8030* | msm8226* | msm8228* | msm8230* | msm8626* | msm8628* | msm8630* | msm8926* | msm8928* | msm8930*)  #sd400 series by @cjybyjk
	is_big_little=false
    support=2
	cores=4
	bcores=2
	MSG=1
    esac
	case ${SOC} in apq8016* | msm8916* | msm8216* | msm8917* | msm8217*)  #sd410/sd425 series by @cjybyjk
	is_big_little=false
    support=2
	cores=4
	bcores=2
	MSG=2
    esac
	case ${SOC} in msm8937*)  #sd430 series by @cjybyjk
	maxfreq_l=1401000
	maxfreq_b=1094400
    support=2
	cores=8
	bcores=4
	MSG=1
    esac
	case ${SOC} in msm8940*)  #sd435 series by @cjybyjk
	is_big_little=false
    support=2
	cores=8
	bcores=4
	MSG=1
    esac
	case ${SOC} in sdm450*)  #sd450 series by @cjybyjk
    support=2
	cores=8
	bcores=4
	MSG=1
    esac
	case ${SOC} in mt6755*)  #P10 
    support=2
	MSG=1
    esac
	
	if [[ "$available_governors" == *"schedutil"* ]]; then
	EAS=1
	elif [[ "$available_governors" == *"sched"* ]]; then
	EAS=1
	elif [[ "$available_governors" == *"blu_schedutil"* ]]; then
	EAS=1
	elif [[ "$available_governors" == *"pwrutil"* ]]; then
	EAS=1
	elif [[ "$available_governors" == *"pwrutilx"* ]]; then
	EAS=1
	elif [[ "$available_governors" == *"darkutil"* ]]; then
	EAS=1
	elif [[ "$available_governors" == *"helix"* ]]; then
	EAS=1
	elif [[ "$available_governors" == *"schedalucard"* ]]; then
	EAS=1
	elif [[ "$available_governors" == *"electroutil"* ]]; then
	EAS=1
	elif [ -d "/sys/devices/system/cpu/cpu0/cpufreq/schedutil" ] || [ -d "/sys/devices/system/cpu/cpu0/cpufreq/sched" ]; then
	EAS=1
	elif [ -d "/sys/devices/system/cpu/cpufreq/schedutil" ] || [ -d "/sys/devices/system/cpu/cpufreq/sched" ]; then
	EAS=1
	fi
	
	# If EAS then all profiles all supported (MANUAL - NOT PROJECT WIPE)
	if [ ${EAS} -eq 1 ];then
	support=1
	MSG=0
	fi
	
	if [ ${PROFILE} -eq 0 ];then
	PROFILE_B="Battery"
	elif [ ${PROFILE} -eq 1 ];then
	PROFILE_B="Balanced"
	elif [ ${PROFILE} -eq 2 ];then
	PROFILE_B="Performance"
	elif [ ${PROFILE} -eq 3 ];then
	PROFILE_B="Turbo"
	fi
case ${MSG} in
		"1")
    if [ ${PROFILE} -ne 1 ]; then
	PROFILE=1
	else
	MSG=0
	fi
		;;
		"2")
    if [ ${PROFILE} -eq 0 ] || [ ${PROFILE} -eq 3 ]; then
	PROFILE=1
	else
	MSG=0
	fi
		;;
esac
	if [ ${PROFILE} -eq 0 ];then
	PROFILE_M="Battery"
	elif [ ${PROFILE} -eq 1 ];then
	PROFILE_M="Balanced"
	elif [ ${PROFILE} -eq 2 ];then
	PROFILE_M="Performance"
	elif [ ${PROFILE} -eq 3 ];then
	PROFILE_M="Turbo"
	fi
    maxfreq=$(awk -v x=$maxfreq_b 'BEGIN{print x/1000000}')
    maxfreq=$(round ${maxfreq} 2)
    GPU_MAX_MHz=$(awk -v x=$GPU_MAX 'BEGIN{print x/1000000}')
    GPU_MAX_MHz=$(round ${GPU_MAX_MHz} 0)
	LOGDATA "###### Strm™ $V" 
	LOGDATA "###### PROFILE : ${PROFILE_M}"
    LOGDATA "#  START : $(date +"%d-%m-%Y %r")" 
    LOGDATA "#  =================================" 
    LOGDATA "#  VENDOR : $VENDOR" 
    LOGDATA "#  DEVICE : $APP" 
if [ ${GPU_MAX} -eq 0 ] || [ -z ${GPU_MODEL} ] ;then
    LOGDATA "#  CPU : $SOC @ $maxfreq GHz ($cores x cores)"
else
    LOGDATA "#  CPU : $SOC @ $maxfreq GHz ($cores x cores)"
    LOGDATA "#  GPU : $GPU_MODEL @ $GPU_MAX_MHz MHz"
fi
    LOGDATA "#  RAM : $memg GB" 
    LOGDATA "#  =================================" 
    LOGDATA "#  ANDROID : $OS" 
    LOGDATA "#  KERNEL : $KERNEL" 
    LOGDATA "#  BUSYBOX  : $sbusybox" 
    LOGDATA "# ================================="
    if [ -z ${sbusybox} ]; then
	LOGDATA "#  [WARNING] BUSYBOX NOT FOUND"
	fi
case ${MSG} in
		"1")
	LOGDATA "#  [INFO] ${PROFILE_B} PROFILE ISN'T AVAILABLE FOR YOUR DEVICE"
	LOGDATA "#  [INFO] Strm IS SWITCHED TO BALANCED PROFILE"
		;;
		"2")
	LOGDATA "#  [INFO] ONLY BALANCED & PERFORMANCE PROFILES ARE AVAILABLE FOR YOUR DEVICE"
	LOGDATA "#  [INFO] Strm IS SWITCHED TO BALANCED PROFILE"
		;;
esac
    if [ "$SOC" != "${SOC/sm/}" ] || [ "$SOC" != "${SOC/sda/}" ] || [ "$SOC" != "${SOC/sdm/}" ] || [ "$SOC" != "${SOC/apq/}" ];     then
    snapdragon=1
    else
    snapdragon=0
    fi

disable_lmk() {
if [ -e "/sys/module/lowmemorykiller/parameters/enable_adaptive_lmk" ]; then
 set_value 0 /sys/module/lowmemorykiller/parameters/enable_adaptive_lmk
 set_value 0 /sys/module/process_reclaim/parameters/enable_process_reclaim
 setprop lmk.autocalc false
 else
LOGDATA "#  [WARNING] ADAPTIVE LMK IS NOT SUPPORTED BY YOUR KERNEL" 
fi;
}
ramtuning() { 

# =========
# Low Memory Killer
# =========
# Low Memory Killer Generator
# Tuned by korom42 for multi-tasking and saving CPU cycles
LIGHT=("0.79" "0.79" "0.79" "0.79" "0.60" "0.79")
BALANCED=("1" "1" "1" "1" "1" "1")
AGGRESSIVE=("0.79" "0.79" "0.85" "1" "1" "1")
if [ ${PROFILE} -le 1 ];then
setprop ro.sys.fw.bg_apps_limit 55
setprop ro.vendor.qti.sys.fw.bg_apps_limit 55
else
setprop ro.sys.fw.bg_apps_limit 76
setprop ro.vendor.qti.sys.fw.bg_apps_limit 76
fi
    if [ ${memg} -gt 4 ]; then
    if [ ${PROFILE} -ge 2 ];then
LMK1=18432
LMK2=23040
LMK3=27648
LMK4=51200
LMK5=150296
LMK6=200640
    else
LMK1=23552
LMK2=32768
LMK3=40960
LMK4=73485
LMK5=88182
LMK6=102879
    fi
    elif [ ${memg} -gt 2 ]; then
    if [ ${PROFILE} -ge 2 ];then
LMK1=18432
LMK2=23040
LMK3=27648
LMK4=51200
LMK5=150296 #110296
LMK6=200640 #147456
    else
LMK1=18432
LMK2=23040
LMK3=27648
LMK4=32256 #73485
LMK5=55296 #88182
LMK6=80640 #102879
    fi
    elif [ ${memg} -gt 1 ]; then
LMK1=14746
LMK2=18432
LMK3=22118
LMK4=25805
LMK5=40000
LMK6=55000
    fi

if [ ${memg} -le 2 ]; then
calculator="0.79"
if [ ${PROFILE} -eq 0 ];then
c=("${LIGHT[@]}")
elif [ ${PROFILE} -eq 1 ];then
c=("${LIGHT[@]}")
elif [ ${PROFILE} -eq 2 ];then
c=("${AGGRESSIVE[@]}")
elif [ ${PROFILE} -eq 3 ];then
c=("${LIGHT[@]}")
fi
f_LMK1=$(awk -v x=$LMK1 -v y=${c[0]} -v z=$calculator 'BEGIN{print x*y*z}') #Low Memory Killer 1
LMK1=$(round ${f_LMK1} 0)
f_LMK2=$(awk -v x=$LMK2 -v y=${c[1]} -v z=$calculator 'BEGIN{print x*y*z}') #Low Memory Killer 2
LMK2=$(round ${f_LMK2} 0)
f_LMK3=$(awk -v x=$LMK3 -v y=${c[2]} -v z=$calculator 'BEGIN{print x*y*z}') #Low Memory Killer 3
LMK3=$(round ${f_LMK3} 0)
f_LMK4=$(awk -v x=$LMK4 -v y=${c[3]} -v z=$calculator 'BEGIN{print x*y*z}') #Low Memory Killer 4
LMK4=$(round ${f_LMK4} 0)
f_LMK5=$(awk -v x=$LMK5 -v y=${c[4]} -v z=$calculator 'BEGIN{print x*y*z}') #Low Memory Killer 5
LMK5=$(round ${f_LMK5} 0)
f_LMK6=$(awk -v x=$LMK6 -v y=${c[5]} -v z=$calculator 'BEGIN{print x*y*z}') #Low Memory Killer 6
LMK6=$(round ${f_LMK6} 0)
else
  calculator="1"
fi

if [ -e "/sys/module/lowmemorykiller/parameters/enable_adaptive_lmk" ]; then
set_value 1 /sys/module/lowmemorykiller/parameters/enable_adaptive_lmk
fi
if [ -e "/sys/module/lowmemorykiller/parameters/minfree" ]; then
set_value "$LMK1,$LMK2,$LMK3,$LMK4,$LMK5,$LMK6" /sys/module/lowmemorykiller/parameters/minfree
fi
if [ -e "/sys/module/lowmemorykiller/parameters/oom_reaper" ]; then
set_value 1 /sys/module/lowmemorykiller/parameters/oom_reaper
fi
# =========
# Vitual Memory
# =========
LOGDATA "#  [INFO] CONFIGURING ANDROID VM"
for i in /proc/sys/vm/*;
do
chmod 0666 $i
done
for i in /proc/sys/fs/*;
do
chmod 0666 $i
done

if [ ${memg} -gt 4 ];then
write /proc/sys/vm/swappiness 60
write /proc/sys/vm/dirty_ratio 5
write /proc/sys/vm/dirty_background_ratio 1
else
write /proc/sys/vm/swappiness 100
write /proc/sys/vm/dirty_ratio 20
write /proc/sys/vm/dirty_background_ratio 5
fi

if [ ${PROFILE} -eq 0 ];then
write /proc/sys/vm/drop_caches 1
write /proc/sys/vm/vfs_cache_pressure 30
write /proc/sys/vm/laptop_mode 0
write /proc/sys/vm/dirty_writeback_centisecs 5000
write /proc/sys/vm/dirty_expire_centisecs 200
write /proc/sys/fs/leases-enable 1
write /proc/sys/fs/dir-notify-enable 0
write /proc/sys/fs/lease-break-time 45
write /proc/sys/vm/compact_memory 1
write /proc/sys/vm/compact_unevictable_allowed 1
write /proc/sys/vm/page-cluster 0
write /proc/sys/vm/panic_on_oom 0
#sysctl -e -w kernel.random.read_wakeup_threshold 64
#sysctl -e -w kernel.random.write_wakeup_threshold 96
elif [ ${PROFILE} -eq 1 ] || [ ${PROFILE} -eq 2 ];then
write /proc/sys/vm/drop_caches 1
write /proc/sys/vm/vfs_cache_pressure 76
write /proc/sys/vm/laptop_mode 0
write /proc/sys/vm/dirty_writeback_centisecs 5000
write /proc/sys/vm/dirty_expire_centisecs 200
write /proc/sys/fs/leases-enable 1
write /proc/sys/fs/dir-notify-enable 0
write /proc/sys/fs/lease-break-time 20
write /proc/sys/vm/compact_memory 1
write /proc/sys/vm/compact_unevictable_allowed 1
write /proc/sys/vm/page-cluster 0
write /proc/sys/vm/panic_on_oom 0
#sysctl -e -w kernel.random.read_wakeup_threshold 64
#sysctl -e -w kernel.random.write_wakeup_threshold 128
else
write /proc/sys/vm/drop_caches 3
write /proc/sys/vm/vfs_cache_pressure 100
write /proc/sys/vm/laptop_mode 0
write /proc/sys/vm/dirty_writeback_centisecs 500
write /proc/sys/vm/dirty_expire_centisecs 200
write /proc/sys/fs/leases-enable 1
write /proc/sys/fs/dir-notify-enable 0
write /proc/sys/fs/lease-break-time 10
write /proc/sys/vm/compact_memory 1
write /proc/sys/vm/compact_unevictable_allowed 1
write /proc/sys/vm/page-cluster 0
write /proc/sys/vm/panic_on_oom 0
#sysctl -e -w kernel.random.read_wakeup_threshold 64
#sysctl -e -w kernel.random.write_wakeup_threshold 128
fi

for i in /proc/sys/vm/*;
do
chmod 0444 $i
done

for i in /proc/sys/fs/*;
do
chmod 0444 $i
done

sync;

}
cputuning() {
    if [ ${snapdragon} -eq 1 ];then
    # disable thermal bcl hotplug to switch governor
    write /sys/module/msm_thermal/core_control/enabled "0"
    write /sys/module/msm_thermal/parameters/enabled "N"
    else
    # Linaro HMP, between 0 and 1024, maybe compare to the capacity of current cluster
    # PELT and period average smoothing sampling, so the parameter style differ from WALT by Qualcomm a lot.
    # https://lists.linaro.org/pipermail/linaro-dev/2012-November/014485.html
    # https://www.anandtech.com/show/9330/exynos-7420-deep-dive/6
    # set_value 60 /sys/kernel/hmp/load_avg_period_ms
    set_value 256 /sys/kernel/hmp/down_threshold
    set_value 640 /sys/kernel/hmp/up_threshold
    set_value 0 /sys/kernel/hmp/boost
	# Exynos hotplug
	set_value 0 /sys/power/cpuhotplug/enabled
	set_value 0 /sys/devices/system/cpu/cpuhotplug/enabled
	set_value 1 /sys/devices/system/cpu/cpu4/online
	set_value 1 /sys/devices/system/cpu/cpu5/online
	set_value 1 /sys/devices/system/cpu/cpu6/online
	set_value 1 /sys/devices/system/cpu/cpu7/online
    fi

    for mode in /sys/devices/soc.0/qcom,bcl.*/mode
    do
        echo -n disable > $mode
    done
    for hotplug_mask in /sys/devices/soc.0/qcom,bcl.*/hotplug_mask
    do
        bcl_hotplug_mask=`cat $hotplug_mask`
        write $hotplug_mask 0
    done
    for hotplug_soc_mask in /sys/devices/soc.0/qcom,bcl.*/hotplug_soc_mask
    do
        bcl_soc_hotplug_mask=`cat $hotplug_soc_mask`
        write $hotplug_soc_mask 0
    done
    for mode in /sys/devices/soc.0/qcom,bcl.*/mode
    do
        echo -n enable > $mode
    done

	if [ -e /data/system/perfd/default_values ]; then
	rm /data/system/perfd/default_values
	fi
	sleep "0.001"
	# Bring all cores online
	num=0
	while [ $num -le $coresmax ]
	do
	write "/sys/devices/system/cpu/cpu${num}/online" 1
	num=$(( $num + 1 ))
	done
	write "/sys/devices/system/cpu/online" "0-$coresmax"
	string1="${GOV_PATH_L}/scaling_available_governors";
	string2="${GOV_PATH_B}/scaling_available_governors";
	if [ ${PROFILE} -eq 0 ];then
	if [ -e "/sys/module/lazyplug" ]; then
	write "/sys/module/lazyplug/parameters/cpu_nr_run_theshold" '1250'
	write "/sys/module/lazyplug/parameters/cpu_nr_hysteresis" '5'
	write "/sys/module/lazyplug/parameters/nr_run_profile_sel" '0'
	fi
	fi
	# Enable power efficient work_queue mode
	if [ -e /sys/module/workqueue/parameters/power_efficient ]; then
	set_value "Y" "/sys/module/workqueue/parameters/power_efficient"
	LOGDATA "#  [INFO] ENABLING POWER EFFICIENT WORKQUEUE MODE " 
	fi

if [ ${EAS} -eq 1 ];then
	EAS=1
	if [[ "$available_governors" == *"sched"* ]]; then
	i=0
	while [ $i -lt $cores ]
	do
	dir="/sys/devices/system/cpu/cpu$i/cpufreq"
	set_value "sched" ${dir}/scaling_governor
	i=$(( $i + 1 ))
	done
	fi
	if [[ "$available_governors" == *"schedutil"* ]]; then
	i=0
	while [ $i -lt $cores ]
	do
	dir="/sys/devices/system/cpu/cpu$i/cpufreq"
	set_value "schedutil" ${dir}/scaling_governor
	i=$(( $i + 1 ))
	done
	fi
    govn=$(cat ${GOV_PATH_L}/scaling_governor)
	case ${govn} in sched* | blu_sched* | pwrutil*)
	govn=$(cat ${GOV_PATH_L}/scaling_governor)
	;;
	*)
	govn="schedutil"
	;;
	esac
	before_modify_eas ${govn}
	LOGDATA "#  [INFO] EAS KERNEL SUPPORT DETECTED"
	LOGDATA "#  [INFO] APPLYING ${govn} GOVERNOR PARAMETERS"
	LOGDATA "#  [INFO] ADJUSTING CPUSETS PARAMETERS"
	if [ ${cores} -eq 4 ];then
    write /dev/cpuset/top-app/cpus "0-3"
    write /dev/cpuset/foreground/boost/cpus "0-2"
    write /dev/cpuset/foreground/cpus "0-2"
    write /dev/cpuset/background/cpus "0"
    write /dev/cpuset/system-background/cpus "0-2"
    write /dev/cpuset/camera-daemon/cpus "0-2"
	elif [ ${cores} -eq 8 ];then
    write /dev/cpuset/top-app/cpus "0-7"
    write /dev/cpuset/foreground/boost/cpus "0-5"
    write /dev/cpuset/foreground/cpus "0-5"
    write /dev/cpuset/background/cpus "0"
    write /dev/cpuset/system-background/cpus "0-5"
    write /dev/cpuset/camera-daemon/cpus "0-5"
	fi
	LOGDATA "#  [INFO] ADJUSTING SCHEDTUNE PARAMETERS" 
	write "/dev/stune/schedtune.boost" 0
	write "/dev/stune/schedtune.prefer_idle" 1
	write "/dev/stune/cgroup.clone_children" 0
	write "/dev/stune/cgroup.sane_behavior" 0
	write "/dev/stune/notify_on_release" 0
	write "/dev/stune/top-app/schedtune.sched_boost" 0
	write "/dev/stune/top-app/notify_on_release" 0
	write "/dev/stune/top-app/cgroup.clone_children" 0
   	write "/dev/stune/foreground/schedtune.sched_boost" 0
	write "/dev/stune/foreground/notify_on_release" 0
	write "/dev/stune/foreground/cgroup.clone_children" 0
	write "/dev/stune/background/schedtune.sched_boost" 0
	write "/dev/stune/background/notify_on_release" 0
	write "/dev/stune/background/cgroup.clone_children" 0
	write "/proc/sys/kernel/sched_use_walt_task_util" 1
	write "/proc/sys/kernel/sched_use_walt_cpu_util" 1
	write "/proc/sys/kernel/sched_walt_cpu_high_irqload" 10000000
	write "/proc/sys/kernel/sched_rt_runtime_us" 950000	
	write "/proc/sys/kernel/sched_latency_ns" 100000
	LOGDATA "#  [INFO] TUNING CONTROL GROUPS (CGroups)" 
	write "/dev/cpuset/cgroup.clone_children" 0
	write "/dev/cpuset/cgroup.sane_behavior" 0
	write "/dev/cpuset/notify_on_release" 0
	write "/dev/cpuctl/cgroup.clone_children" 0
	write "/dev/cpuctl/cgroup.sane_behavior" 0
	write "/dev/cpuctl/notify_on_release" 0
	write "/dev/cpuctl/cpu.rt_period_us" 1000000
	write "/dev/cpuctl/cpu.rt_runtime_us" 950000
	write "/dev/cpuctl/bg_non_interactive/cpu.rt_runtime_us" 10000
	set_value 1 "/dev/stune/top-app/schedtune.prefer_idle"
	set_value 1 "/dev/stune/foreground/schedtune.prefer_idle"
    set_value 0 "/dev/stune/background/schedtune.prefer_idle"
    set_value 0 "/dev/stune/rt/schedtune.prefer_idle"
	dynstune=$(cat /data/adb/dynamic_stune_boost.txt | tr -d '\n')	
	TP=$(cat /data/adb/top-app.txt | tr -d '\n')
	FG=$(cat /data/adb/foreground.txt | tr -d '\n')
	BG=$(cat /data/adb/backgroundp.txt | tr -d '\n')
	
	if [[ -e "/sys/module/cpu_boost/parameters/dynamic_stune_boost" ]];then
	if [ ${PROFILE} -eq 0 ];then
	dynstune=$(awk -v x=$dynstune 'BEGIN{print x/3}')
	dynstune=$(round ${dynstune} 0)
	write /sys/module/cpu_boost/parameters/dynamic_stune_boost ${dynstune}
    set_value 0 /dev/stune/top-app/schedtune.boost
    set_value 0 /dev/stune/foreground/schedtune.boost
    set_value "-30" /dev/stune/background/schedtune.boost
	elif [ ${PROFILE} -eq 1 ]; then
	dynstune=$(awk -v x=$dynstune 'BEGIN{print x*0.75}')
	dynstune=$(round ${dynstune} 0)
	write /sys/module/cpu_boost/parameters/dynamic_stune_boost ${dynstune}
    set_value 0 /dev/stune/top-app/schedtune.boost
    set_value 0 /dev/stune/foreground/schedtune.boost
    set_value "-10" /dev/stune/background/schedtune.boost
	elif [ ${PROFILE} -eq 2 ]; then
	if [ ${FG} -le 10 ]; then
	TP=$(awk -v x=$dynstune 'BEGIN{print x*1.5}')
	else
	TP=$(awk -v x=$dynstune 'BEGIN{print x*1.22}')
	fi
    TP=$(round ${dynstune} 0)
	write /sys/module/cpu_boost/parameters/dynamic_stune_boost ${dynstune}
    set_value 0 /dev/stune/top-app/schedtune.boost
    set_value 0 /dev/stune/foreground/schedtune.boost
    set_value 0 /dev/stune/background/schedtune.boost
	elif [ ${PROFILE} -eq 3 ]; then
	write /sys/module/cpu_boost/parameters/dynamic_stune_boost ${dynstune}
    set_value 15 /dev/stune/top-app/schedtune.boost
    set_value 10 /dev/stune/foreground/schedtune.boost
    set_value 0 /dev/stune/background/schedtune.boost
	fi
	else
	if [ ${PROFILE} -eq 0 ];then
	TP=$(awk -v x=$TP 'BEGIN{print x*0.3}')
    TP=$(round ${TP} 0)	
    set_value ${TP} /dev/stune/top-app/schedtune.boost
    set_value ${FG} /dev/stune/foreground/schedtune.boost
    set_value "-30" /dev/stune/background/schedtune.boost
	elif [ ${PROFILE} -eq 1 ]; then
	TP=$(awk -v x=$TP 'BEGIN{print x*0.75}')
    TP=$(round ${TP} 0)
    set_value ${TP} /dev/stune/top-app/schedtune.boost 
    set_value ${FG} /dev/stune/foreground/schedtune.boost 
    set_value "-10" /dev/stune/background/schedtune.boost 
	elif [ ${PROFILE} -eq 2 ]; then
	if [ ${FG} -le 10 ]; then
	TP=$(awk -v x=$TP 'BEGIN{print x*1.5}')
	else
	TP=$(awk -v x=$TP 'BEGIN{print x*1.22}')
	fi
    TP=$(round ${TP} 0)
    set_value ${TP} /dev/stune/top-app/schedtune.boost 
    set_value ${FG} /dev/stune/foreground/schedtune.boost 
    set_value 0 /dev/stune/background/schedtune.boost 
	elif [ ${PROFILE} -eq 3 ]; then
	TP=15
	if [ ${FG} -ne 0 ]; then
	FG=$(awk -v x=$FG 'BEGIN{print x*2}')
    FG=$(round ${FG} 0)
	else
	FG=10
	fi
    set_value 15 /dev/stune/top-app/schedtune.boost
    set_value 10 /dev/stune/foreground/schedtune.boost
    set_value 0 /dev/stune/background/schedtune.boost
	fi
	fi
	set_boost 40
	sleep 2
	case ${SOC} in sm8150* ) #sd855
	maxfreq_b=2419200
	if [ ${PROFILE} -eq 0 ];then
	update_clock_speed 1780000 little max
	update_clock_speed 1680000 big max
	set_value 1880000 "/sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq"
	chmod 0644 "/sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq"
	set_boost_freq "0:1080000 4:0"
	set_value 2 /sys/devices/system/cpu/cpu4/core_ctl/min_cpus
	set_value 2 /sys/devices/system/cpu/cpu4/core_ctl/max_cpus
	set_param_eas ${govn} cpu0 hispeed_freq 1180000
	set_param_eas ${govn} cpu0 hispeed_load 90
	set_param_eas ${govn} cpu0 pl 0
	set_param_eas ${govn} cpu4 hispeed_freq 1080000
	set_param_eas ${govn} cpu4 hispeed_load 90
	set_param_eas ${govn} cpu4 pl 0
	elif [ ${PROFILE} -eq 1 ]; then
	update_clock_speed 1780000 little max
	update_clock_speed 1880000 big max
	set_value 2280000 "/sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq"
	chmod 0644 "/sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq"
	set_boost_freq "0:1180000 4:0"
	set_value 2 /sys/devices/system/cpu/cpu4/core_ctl/min_cpus
	set_value 4 /sys/devices/system/cpu/cpu4/core_ctl/max_cpus
	set_param_eas ${govn} cpu0 hispeed_freq 1280000
	set_param_eas ${govn} cpu0 hispeed_load 90
	set_param_eas ${govn} cpu0 pl 0
	set_param_eas ${govn} cpu4 hispeed_freq 1280000
	set_param_eas ${govn} cpu4 hispeed_load 90
	set_param_eas ${govn} cpu4 pl 0
	elif [ ${PROFILE} -eq 2 ]; then
	update_clock_speed 1880000 little max
	update_clock_speed 2480000 big max
	set_value 2880000 "/sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq"
	chmod 0644 "/sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq"
	set_boost_freq "0:1080000 4:1380000"
	set_value 2 /sys/devices/system/cpu/cpu4/core_ctl/min_cpus
	set_value 4 /sys/devices/system/cpu/cpu4/core_ctl/max_cpus
	set_param_eas ${govn} cpu0 hispeed_freq 1380000
	set_param_eas ${govn} cpu0 hispeed_load 85
	set_param_eas ${govn} cpu0 pl 1
	set_param_eas ${govn} cpu4 hispeed_freq 1580000
	set_param_eas ${govn} cpu4 hispeed_load 90
	set_param_eas ${govn} cpu4 pl 1
	elif [ ${PROFILE} -eq 3 ]; then # Turbo
	update_clock_speed 1880000 little max
	update_clock_speed 2480000 big max
	set_value 2880000 "/sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq"
	chmod 0644 "/sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq"
	set_boost_freq "0:1480000 4:1680000"
	set_value 4 /sys/devices/system/cpu/cpu4/core_ctl/min_cpus
	set_value 4 /sys/devices/system/cpu/cpu4/core_ctl/max_cpus
	set_param_eas ${govn} cpu0 hispeed_freq 1580000
	set_param_eas ${govn} cpu0 hispeed_load 80
	set_param_eas ${govn} cpu0 pl 1
	set_param_eas ${govn} cpu4 hispeed_freq 1580000
	set_param_eas ${govn} cpu4 hispeed_load 85
	set_param_eas ${govn} cpu4 pl 1
	fi
	;;
	sdm845* | sda845*) #sd845
	#write /sys/devices/system/cpu/cpu${bcores}/core_ctl/min_cpus 2
	#write /sys/devices/system/cpu/cpu${bcores}/core_ctl/busy_up_thres 60
	#write /sys/devices/system/cpu/cpu${bcores}/core_ctl/busy_down_thres 30
	#write /sys/devices/system/cpu/cpu${bcores}/core_ctl/offline_delay_ms 100
	#write /sys/devices/system/cpu/cpu${bcores}/core_ctl/is_big_cluster 1
	#write /sys/devices/system/cpu/cpu${bcores}/core_ctl/task_thres 4
	if [ ${PROFILE} -eq 0 ];then
	update_clock_speed 1680000 little max
	update_clock_speed 1880000 big max
	set_boost_freq "0:1080000 4:0"
	set_value 2 /sys/devices/system/cpu/cpu4/core_ctl/min_cpus
	set_value 2 /sys/devices/system/cpu/cpu4/core_ctl/max_cpus
	set_param_eas ${govn} cpu0 hispeed_freq 1180000
	set_param_eas ${govn} cpu0 hispeed_load 90
	set_param_eas ${govn} cpu0 pl 0
	set_param_eas ${govn} cpu4 hispeed_freq 1080000
	set_param_eas ${govn} cpu4 hispeed_load 90
	set_param_eas ${govn} cpu4 pl 0
	elif [ ${PROFILE} -eq 1 ]; then
	update_clock_speed 1680000 little max
	update_clock_speed 2280000 big max
	set_boost_freq "0:1180000 4:0"
	set_value 2 /sys/devices/system/cpu/cpu4/core_ctl/min_cpus
	set_value 4 /sys/devices/system/cpu/cpu4/core_ctl/max_cpus
	set_param_eas ${govn} cpu0 hispeed_freq 1280000
	set_param_eas ${govn} cpu0 hispeed_load 90
	set_param_eas ${govn} cpu0 pl 0
	set_param_eas ${govn} cpu4 hispeed_freq 1280000
	set_param_eas ${govn} cpu4 hispeed_load 90
	set_param_eas ${govn} cpu4 pl 0
	elif [ ${PROFILE} -eq 2 ]; then
	update_clock_speed 1780000 little max
	update_clock_speed 2880000 big max
	set_boost_freq "0:1080000 4:1380000"
	set_value 2 /sys/devices/system/cpu/cpu4/core_ctl/min_cpus
	set_value 4 /sys/devices/system/cpu/cpu4/core_ctl/max_cpus
	set_param_eas ${govn} cpu0 hispeed_freq 1380000
	set_param_eas ${govn} cpu0 hispeed_load 85
	set_param_eas ${govn} cpu0 pl 1
	set_param_eas ${govn} cpu4 hispeed_freq 1580000
	set_param_eas ${govn} cpu4 hispeed_load 90
	set_param_eas ${govn} cpu4 pl 1
	elif [ ${PROFILE} -eq 3 ]; then # Turbo
	update_clock_speed 1780000 little max
	update_clock_speed 2880000 big max
	set_boost_freq "0:1480000 4:1680000"
	set_value 4 /sys/devices/system/cpu/cpu4/core_ctl/min_cpus
	set_value 4 /sys/devices/system/cpu/cpu4/core_ctl/max_cpus
	set_param_eas ${govn} cpu0 hispeed_freq 1580000
	set_param_eas ${govn} cpu0 hispeed_load 80
	set_param_eas ${govn} cpu0 pl 1
	set_param_eas ${govn} cpu4 hispeed_freq 1580000
	set_param_eas ${govn} cpu4 hispeed_load 85
	set_param_eas ${govn} cpu4 pl 1
	fi
	;;
	*)
	#write /sys/devices/system/cpu/cpu${bcores}/core_ctl/min_cpus $((${bcores}/2))
	#write /sys/devices/system/cpu/cpu${bcores}/core_ctl/busy_up_thres 60
	#write /sys/devices/system/cpu/cpu${bcores}/core_ctl/busy_down_thres 30
	#write /sys/devices/system/cpu/cpu${bcores}/core_ctl/offline_delay_ms 100
	write /sys/devices/system/cpu/cpu${bcores}/core_ctl/is_big_cluster 1
	#write /sys/devices/system/cpu/cpu${bcores}/core_ctl/task_thres 4
	FREQ_FILE="/data/adb/boost1.txt"
	IBOOST_FREQ_L=$(awk -F ' 1' '{ print($1) }' $FREQ_FILE)
	IBOOST_FREQ_L=$(echo $IBOOST_FREQ_L |awk -F '0:' '{ print($2) }')
	IBOOST_FREQ_B=$(awk -F ' 5' '{ print($1) }' $FREQ_FILE)
	IBOOST_FREQ_B=$(echo $IBOOST_FREQ_B |awk -F '4:' '{ print($2) }')
	if [ ${IBOOST_FREQ_B} -eq 0 ]; then
	IBOOST_FREQ_B=${IBOOST_FREQ_L}
	fi
	if [ ${PROFILE} -eq 0 ];then
	diff=$(awk -v x=$maxfreq_l -v y=1766000 'BEGIN{print (x/y)*100000}')
    diff=$(round ${diff} 0)	
	maxfreq_l=$((${maxfreq_l}-${diff}))
	diff=$(awk -v x=$maxfreq_b -v y=2800000 'BEGIN{print (x/y)*1000000}')
    diff=$(round ${diff} 0)	
	maxfreq_b=$((${maxfreq_b}-${diff}))
	IBOOST_FREQ_L=$(awk -v x=$IBOOST_FREQ_L 'BEGIN{print x*0.80}')
    IBOOST_FREQ_L=$(round ${IBOOST_FREQ_L} 0)
	if [ ${IBOOST_FREQ_L} -lt 980000 ] && [ ${maxfreq_l} -gt 1600000 ]; then
	IBOOST_FREQ_L=1080000
	fi
	min_cores=$((${cores}/4))
	max_cores=$((${cores}/4))
	update_clock_speed ${maxfreq_l} little max
	update_clock_speed ${maxfreq_b} big max
	set_boost_freq "0:${IBOOST_FREQ_L} ${bcores}:0"
	set_value ${min_cores} /sys/devices/system/cpu/cpu${bcores}/core_ctl/min_cpus
	set_value ${max_cores} /sys/devices/system/cpu/cpu${bcores}/core_ctl/max_cpus
	set_param_eas ${govn} cpu0 hispeed_freq 1180000
	set_param_eas ${govn} cpu0 hispeed_load 90
	set_param_eas ${govn} cpu0 pl 0
	set_param_eas ${govn} cpu${bcores} hispeed_freq 1080000
	set_param_eas ${govn} cpu${bcores} hispeed_load 90
	set_param_eas ${govn} cpu${bcores} pl 0
	elif [ ${PROFILE} -eq 1 ]; then
	diff=$(awk -v x=$maxfreq_l -v y=1766000 'BEGIN{print (x/y)*100000}')
    diff=$(round ${diff} 0)	
	maxfreq_l=$((${maxfreq_l}-${diff}))
	diff=$(awk -v x=$maxfreq_b -v y=2800000 'BEGIN{print (x/y)*600000}')
    diff=$(round ${diff} 0)	
	maxfreq_b=$((${maxfreq_b}-${diff}))
	IBOOST_FREQ_L=$(awk -v x=$IBOOST_FREQ_L 'BEGIN{print x*0.89}')
    IBOOST_FREQ_L=$(round ${IBOOST_FREQ_L} 0)
	if [ ${IBOOST_FREQ_L} -lt 1180000 ] && [ ${maxfreq_l} -gt 1600000 ]; then
	IBOOST_FREQ_L=1180000
	fi
	min_cores=$((${cores}/4))
	max_cores=$((${cores}/2))
	update_clock_speed ${maxfreq_l} little max
	update_clock_speed ${maxfreq_b} big max
	set_boost_freq "0:${IBOOST_FREQ_L} ${bcores}:0"
	set_value ${min_cores} /sys/devices/system/cpu/cpu${bcores}/core_ctl/min_cpus
	set_value ${max_cores} /sys/devices/system/cpu/cpu${bcores}/core_ctl/max_cpus
	set_param_eas ${govn} cpu0 hispeed_freq 1280000
	set_param_eas ${govn} cpu0 hispeed_load 90
	set_param_eas ${govn} cpu0 pl 0
	set_param_eas ${govn} cpu${bcores} hispeed_freq 1280000
	set_param_eas ${govn} cpu${bcores} hispeed_load 90
	set_param_eas ${govn} cpu${bcores} pl 0
	elif [ ${PROFILE} -eq 2 ]; then
	IBOOST_FREQ_L=$(awk -v x=$IBOOST_FREQ_L 'BEGIN{print x*0.9}')
    IBOOST_FREQ_L=$(round ${IBOOST_FREQ_L} 0)
	IBOOST_FREQ_B=$(awk -v x=$IBOOST_FREQ_B 'BEGIN{print x*1.1}')
    IBOOST_FREQ_B=$(round ${IBOOST_FREQ_B} 0)
	if [ ${IBOOST_FREQ_L} -lt 1280000 ] && [ ${maxfreq_l} -gt 1600000 ]; then
	IBOOST_FREQ_L=1280000
	fi
	min_cores=$((${cores}/4))
	max_cores=$((${cores}/2))
	update_clock_speed ${maxfreq_l} little max
	update_clock_speed ${maxfreq_b} big max
	set_boost_freq "0:${IBOOST_FREQ_L} ${bcores}:${IBOOST_FREQ_B}"
	#restore_boost
	set_value ${min_cores} /sys/devices/system/cpu/cpu${bcores}/core_ctl/min_cpus
	set_value ${max_cores} /sys/devices/system/cpu/cpu${bcores}/core_ctl/max_cpus
	set_param_eas ${govn} cpu0 hispeed_freq 1380000
	set_param_eas ${govn} cpu0 hispeed_load 85
	set_param_eas ${govn} cpu0 pl 1
	set_param_eas ${govn} cpu${bcores} hispeed_freq 1580000
	set_param_eas ${govn} cpu${bcores} hispeed_load 90
	set_param_eas ${govn} cpu${bcores} pl 1
	elif [ ${PROFILE} -eq 3 ]; then # Turbo
	IBOOST_FREQ_L=$(awk -v x=$maxfreq_l 'BEGIN{print x*0.83}')
    IBOOST_FREQ_L=$(round ${IBOOST_FREQ_L} 0)
	IBOOST_FREQ_B=$(awk -v x=$IBOOST_FREQ_B 'BEGIN{print x*1.23}')
    IBOOST_FREQ_B=$(round ${IBOOST_FREQ_B} 0)
	min_cores=$((${cores}/2))
	max_cores=$((${cores}/2))
	update_clock_speed ${maxfreq_l} little max
	update_clock_speed ${maxfreq_b} big max
	set_boost_freq "0:${IBOOST_FREQ_L} ${bcores}:${IBOOST_FREQ_B}"
	set_value ${min_cores} /sys/devices/system/cpu/cpu${bcores}/core_ctl/min_cpus
	set_value ${max_cores} /sys/devices/system/cpu/cpu${bcores}/core_ctl/max_cpus
	set_param_eas ${govn} cpu0 hispeed_freq 1580000
	set_param_eas ${govn} cpu0 hispeed_load 80
	set_param_eas ${govn} cpu0 pl 1
	set_param_eas ${govn} cpu${bcores} hispeed_freq 1580000
	set_param_eas ${govn} cpu${bcores} hispeed_load 85
	set_param_eas ${govn} cpu${bcores} pl 1
	fi
	;;
	esac
	after_modify_eas ${govn}
fi
## INTERACTIVE
if [ ${EAS} -eq 0 ];then
    HMP=1
    i=0
	while [ $i -lt $cores ]
	do
	dir="/sys/devices/system/cpu/cpu$i/cpufreq"
	set_value "interactive" ${dir}/scaling_governor
	i=$(( $i + 1 ))
	done
	set_value "interactive" "/sys/devices/system/cpu/cpufreq/scaling_governor"
	LOGDATA "#  [INFO] HMP KERNEL SUPPORT DETECTED" 
	LOGDATA "#  [INFO] APPLYING INTERACTIVE GOVERNOR PARAMETERS"
	before_modify
	if [ ${MSG} -eq 0 ]; then
	update_clock_speed ${maxfreq_l} little max
	update_clock_speed ${maxfreq_b} big max
	fi
	if [ ${PROFILE} -eq 3 ];then
	restore_boost
	fi
	if [ ${PROFILE} -eq 0 ];then
	set_param cpu0 powersave_bias 1
	else
	set_param cpu0 powersave_bias 0
	fi
	set_param cpu0 enable_prediction 0	
	set_param cpu0 ignore_hispeed_on_notif 0
	set_param cpu${bcores} enable_prediction 0	
	set_param cpu${bcores} ignore_hispeed_on_notif 0
	if [ ${shared} -eq 1 ]; then
	set_boost 2500
	fi
	sleep 2
	case ${SOC} in msm8998* | apq8098*) #sd835
	update_clock_speed 280000 little min
	update_clock_speed 280000 big min
	# avoid permission problem, do not set 0444
	write "/dev/cpuset/background/cpus" "2-3"
	write "/dev/cpuset/system-background/cpus" "0-3"
	write "/dev/cpuset/foreground/cpus" "0-3,4-7"
	write "/dev/cpuset/top-app/cpus" "0-3,4-7"
	# set_value 85 /proc/sys/kernel/sched_downmigrate
	# set_value 95 /proc/sys/kernel/sched_upmigrate
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
	set_boost_freq "0:380000 4:380000"
	set_param cpu0 above_hispeed_delay "18000 1380000:58000 1480000:18000 1580000:98000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 98
	set_param cpu0 target_loads "80 380000:59 480000:51 580000:29 780000:92 880000:76 1180000:90 1280000:98 1380000:84 1480000:97"
	set_param cpu0 min_sample_time 18000
	set_param cpu${bcores} above_hispeed_delay "18000 1480000:58000 1580000:98000 1880000:138000"
	set_param cpu${bcores} hispeed_freq 1280000
	set_param cpu${bcores} go_hispeed_load 98
	set_param cpu${bcores} target_loads "80 380000:45 480000:36 580000:41 680000:65 780000:88 1080000:92 1280000:98 1380000:90 1580000:97"
	set_param cpu${bcores} min_sample_time 18000
	elif [ ${PROFILE} -eq 1 ];then
	set_boost_freq "0:380000 4:380000"
	set_param cpu0 above_hispeed_delay "18000 1580000:98000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 98
	set_param cpu0 target_loads "80 380000:30 480000:41 580000:29 680000:4 780000:60 1180000:88 1280000:70 1380000:78 1480000:97"
	set_param cpu0 min_sample_time 18000
	set_param cpu${bcores} above_hispeed_delay "18000 1380000:78000 1480000:18000 1580000:98000 1880000:138000"
	set_param cpu${bcores} hispeed_freq 1280000
	set_param cpu${bcores} go_hispeed_load 98
	set_param cpu${bcores} target_loads "80 380000:39 580000:58 780000:63 980000:81 1080000:92 1180000:77 1280000:98 1380000:86 1580000:98"
	set_param cpu${bcores} min_sample_time 18000
	elif [ ${PROFILE} -eq 2 ];then
	set_boost_freq "0:380000 4:380000"
	set_param cpu0 above_hispeed_delay "18000 1580000:98000 1780000:38000"
	set_param cpu0 hispeed_freq 1480000
	set_param cpu0 go_hispeed_load 98
	set_param cpu0 target_loads "80 380000:42 580000:80 680000:15 980000:36 1080000:9 1180000:90 1280000:59 1480000:88 1680000:98"
	set_param cpu0 min_sample_time 18000
	set_param cpu${bcores} above_hispeed_delay "18000 1580000:98000 1880000:38000"
	set_param cpu${bcores} hispeed_freq 1280000
	set_param cpu${bcores} go_hispeed_load 94
	set_param cpu${bcores} target_loads "80 380000:44 480000:19 680000:54 780000:63 980000:54 1080000:63 1280000:71 1580000:98"
	set_param cpu${bcores} min_sample_time 18000
   	elif [ ${PROFILE} -eq 3 ];then
	update_clock_speed 1480000 little min
	set_param cpu0 above_hispeed_delay "18000 1780000:198000"
	set_param cpu0 hispeed_freq 1480000
	set_param cpu0 target_loads "80 1880000:90"
	set_param cpu0 min_sample_time 38000
	update_clock_speed 1380000 big min
	set_param cpu${bcores} above_hispeed_delay "18000 1880000:198000"
	set_param cpu${bcores} hispeed_freq 1380000
	set_param cpu${bcores} target_loads "80 1980000:90"
	set_param cpu${bcores} min_sample_time 38000
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
	set_param cpu${bcores} min_sample_time 38000
fi
esac
case ${SOC} in msm8994* | msm8992*) #sd810/808
	update_clock_speed 380000 little min
	update_clock_speed 380000 big min
	# avoid permission problem, do not set 0444
	write "/dev/cpuset/background/cpus" "2-3"
	write "/dev/cpuset/system-background/cpus" "0-3"
	write "/dev/cpuset/foreground/cpus" "0-3,4-5"
	write "/dev/cpuset/top-app/cpus" "0-3,4-5"
	set_value 85 /proc/sys/kernel/sched_downmigrate
	set_value 99 /proc/sys/kernel/sched_upmigrate
	set_value 0 /sys/devices/system/cpu/cpu4/core_ctl/min_cpus
	set_value 2 /sys/devices/system/cpu/cpu4/core_ctl/max_cpus
	update_clock_speed 1344000 little max
	update_clock_speed 1440000 big max
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
	set_boost_freq "0:580000 4:480000"
	set_param cpu0 above_hispeed_delay "98000 1280000:38000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 98
	set_param cpu0 target_loads "80 580000:27 680000:48 780000:68 880000:82 1180000:98"
	set_param cpu0 min_sample_time 18000
	set_param cpu${bcores} above_hispeed_delay "18000 1180000:98000 1380000:18000"
	set_param cpu${bcores} hispeed_freq 880000
	set_param cpu${bcores} go_hispeed_load 98
	set_param cpu${bcores} target_loads "80 580000:49 680000:40 780000:58 880000:94 1180000:98"
	set_param cpu${bcores} min_sample_time 38000
	elif [ ${PROFILE} -eq 1 ];then
	set_boost_freq "0:580000 4:480000"
	set_param cpu0 above_hispeed_delay "98000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 97
	set_param cpu0 target_loads "80 580000:59 680000:54 780000:63 880000:85 1180000:98 1280000:94"
	set_param cpu0 min_sample_time 38000
	set_param cpu${bcores} above_hispeed_delay "18000 1180000:98000"
	set_param cpu${bcores} hispeed_freq 880000
	set_param cpu${bcores} go_hispeed_load 98
	set_param cpu${bcores} target_loads "80 580000:64 680000:58 780000:19 880000:97"
	set_param cpu${bcores} min_sample_time 78000
	elif [ ${PROFILE} -eq 2 ];then
	set_boost_freq "0:580000 4:480000"
	set_param cpu0 above_hispeed_delay "38000 1280000:58000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 98
	set_param cpu0 target_loads "80 580000:63 680000:54 780000:60 880000:32 1180000:98 1280000:93"
	set_param cpu0 min_sample_time 38000
	set_param cpu${bcores} above_hispeed_delay "78000 1280000:38000"
	set_param cpu${bcores} hispeed_freq 1180000
	set_param cpu${bcores} go_hispeed_load 98
	set_param cpu${bcores} target_loads "80 480000:44 580000:65 680000:61 780000:20 880000:90 1180000:74 1280000:98"
	set_param cpu${bcores} min_sample_time 78000
   	elif [ ${PROFILE} -eq 3 ];then
	
	update_clock_speed 880000 little min
	set_param cpu0 above_hispeed_delay "18000 1180000:198000"
	set_param cpu0 hispeed_freq 880000
	set_param cpu0 target_loads "80 1280000:90"
	set_param cpu0 min_sample_time 38000
	update_clock_speed 880000 big min
	set_param cpu${bcores} above_hispeed_delay "18000 1280000:198000"
	set_param cpu${bcores} hispeed_freq 880000
	set_param cpu${bcores} target_loads "80 1380000:90"
	set_param cpu${bcores} min_sample_time 38000
fi
esac
case ${SOC} in apq8074* | apq8084* | msm8074* | msm8084* | msm8274* | msm8674* | msm8974*)  #sd800-801-805
	setprop ro.qualcomm.perf.cores_online 2
	update_clock_speed 280000 little min
	update_clock_speed 280000 big min
	set_boost_freq "0:380000 2:380000"
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
	diff=$(awk -v x=$maxfreq_l -v y=1760000 'BEGIN{print (x/y)*85}')
    diff=$(round ${diff} 0)	
	maxfreq_l=$((${maxfreq_l}-${diff}))
	diff=$(awk -v x=$maxfreq_b -v y=2800000 'BEGIN{print (x/y)*1000}')
    diff=$(round ${diff} 0)	
	maxfreq_b=$((${maxfreq_b}-${diff}))
	update_clock_speed ${maxfreq_l} little max
	update_clock_speed ${maxfreq_b} big max
	set_param cpu0 above_hispeed_delay "18000 1680000:98000 1880000:138000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 97
	set_param cpu0 target_loads "80 380000:6 580000:25 680000:43 880000:61 980000:86 1180000:97"
	set_param cpu0 min_sample_time 18000
	set_param cpu${bcores} above_hispeed_delay "18000 1680000:98000 1880000:138000"
	set_param cpu${bcores} hispeed_freq 1180000
	set_param cpu${bcores} go_hispeed_load 97
	set_param cpu${bcores} target_loads "80 380000:6 580000:25 680000:43 880000:61 980000:86 1180000:97"
	set_param cpu${bcores} min_sample_time 18000
	elif [ ${PROFILE} -eq 1 ];then
	diff=$(awk -v x=$maxfreq_l -v y=1760000 'BEGIN{print (x/y)*85}')
    diff=$(round ${diff} 0)	
	maxfreq_l=$((${maxfreq_l}-${diff}))
	diff=$(awk -v x=$maxfreq_b -v y=2800000 'BEGIN{print (x/y)*520}')
    diff=$(round ${diff} 0)	
	maxfreq_b=$((${maxfreq_b}-${diff}))
	update_clock_speed ${maxfreq_l} little max
	update_clock_speed ${maxfreq_b} big max
	set_param cpu0 above_hispeed_delay "38000 1480000:78000 1680000:98000 1880000:138000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 97
	set_param cpu0 target_loads "80 380000:32 580000:47 680000:82 880000:32 980000:39 1180000:83 1480000:79 1680000:98"
	set_param cpu0 min_sample_time 18000
	set_param cpu${bcores} above_hispeed_delay "38000 1480000:78000 1680000:98000 1880000:138000"
	set_param cpu${bcores} hispeed_freq 1180000
	set_param cpu${bcores} go_hispeed_load 97
	set_param cpu${bcores} target_loads "80 380000:32 580000:47 680000:82 880000:32 980000:39 1180000:83 1480000:79 1680000:98"
	set_param cpu${bcores} min_sample_time 18000
	elif [ ${PROFILE} -eq 2 ];then
	set_param cpu0 above_hispeed_delay "18000 1480000:98000 1880000:38000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 97
	set_param cpu0 target_loads "80 380000:32 580000:45 680000:81 880000:63 980000:47 1180000:89 1480000:79 1680000:98"
	set_param cpu0 min_sample_time 38000
	set_param cpu${bcores} above_hispeed_delay "18000 1480000:98000 1880000:38000"
	set_param cpu${bcores} hispeed_freq 1180000
	set_param cpu${bcores} go_hispeed_load 97
	set_param cpu${bcores} target_loads "80 380000:32 580000:45 680000:81 880000:63 980000:47 1180000:89 1480000:79 1680000:98"
	set_param cpu${bcores} min_sample_time 38000
   	elif [ ${PROFILE} -eq 3 ];then
	
	update_clock_speed 1480000 little min
	set_param cpu0 above_hispeed_delay "18000 1880000:198000"
	set_param cpu0 hispeed_freq 1480000
	set_param cpu0 target_loads "80 1980000:90"
	set_param cpu0 min_sample_time 38000
	update_clock_speed 1480000 big min
	set_param cpu${bcores} above_hispeed_delay "18000 1880000:198000"
	set_param cpu${bcores} hispeed_freq 1480000
	set_param cpu${bcores} target_loads "80 1980000:90"
	set_param cpu${bcores} min_sample_time 38000
fi
esac
case ${SOC} in sdm660* | sda660*) #sd660
	update_clock_speed 580000 little min
	update_clock_speed 1080000 big min
	# avoid permission problem, do not set 0444
	write "/dev/cpuset/background/cpus" "2-3"
	write "/dev/cpuset/system-background/cpus" "0-3"
	write "/dev/cpuset/foreground/cpus" "0-3,4-7"
	write "/dev/cpuset/top-app/cpus" "0-3,4-7"
	# set_value 85 /proc/sys/kernel/sched_downmigrate
	# set_value 95 /proc/sys/kernel/sched_upmigrate
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
	set_boost_freq "0:880000 4:1380000"
	set_param cpu0 above_hispeed_delay "38000 1380000:98000"
	set_param cpu0 hispeed_freq 1080000
	set_param cpu0 go_hispeed_load 98
	set_param cpu0 target_loads "80 880000:45 1080000:64 1480000:98"
	set_param cpu0 min_sample_time 18000
	set_param cpu${bcores} above_hispeed_delay "18000 1680000:98000 1880000:138000"
	set_param cpu${bcores} hispeed_freq 1080000
	set_param cpu${bcores} go_hispeed_load 98
	set_param cpu${bcores} target_loads "80 1680000:98"
	set_param cpu${bcores} min_sample_time 18000
	elif [ ${PROFILE} -eq 1 ];then
	set_boost_freq "0:880000 4:1380000"
	set_param cpu0 above_hispeed_delay "98000"
	set_param cpu0 hispeed_freq 1480000
	set_param cpu0 go_hispeed_load 98
	set_param cpu0 target_loads "80 880000:59 1080000:90 1380000:78 1480000:98"
	set_param cpu0 min_sample_time 38000
	set_param cpu${bcores} above_hispeed_delay "18000 1680000:98000 1880000:138000"
	set_param cpu${bcores} hispeed_freq 1080000
	set_param cpu${bcores} go_hispeed_load 83
	set_param cpu${bcores} target_loads "80 1380000:70 1680000:98"
	set_param cpu${bcores} min_sample_time 18000
	elif [ ${PROFILE} -eq 2 ];then
	set_boost_freq "0:880000 4:1380000"
	set_param cpu0 above_hispeed_delay "18000 1380000:98000 1680000:38000"
	set_param cpu0 hispeed_freq 880000
	set_param cpu0 go_hispeed_load 89
	set_param cpu0 target_loads "80 880000:60 1080000:80 1380000:54 1480000:98"
	set_param cpu0 min_sample_time 78000
	set_param cpu${bcores} above_hispeed_delay "18000 1380000:78000 1680000:98000 1880000:38000"
	set_param cpu${bcores} hispeed_freq 1080000
	set_param cpu${bcores} go_hispeed_load 98
	set_param cpu${bcores} target_loads "80 1380000:65 1680000:98"
	set_param cpu${bcores} min_sample_time 78000
   	elif [ ${PROFILE} -eq 3 ];then
	
	update_clock_speed 1080000 little min
	set_param cpu0 above_hispeed_delay "18000 1680000:198000"
	set_param cpu0 hispeed_freq 1080000
	set_param cpu0 target_loads "80 1780000:90"
	set_param cpu0 min_sample_time 38000
	update_clock_speed 1380000 big min
	set_param cpu${bcores} above_hispeed_delay "18000 1880000:198000"
	set_param cpu${bcores} hispeed_freq 1380000
	set_param cpu${bcores} target_loads "80 1980000:90"
	set_param cpu${bcores} min_sample_time 38000
fi
esac
case ${SOC} in msm8956* | msm8976*)  #sd652/650
	update_clock_speed 380000 little min
	update_clock_speed 380000 big min
	# avoid permission problem, do not set 0444
	write "/dev/cpuset/background/cpus" "2-3"
	write "/dev/cpuset/system-background/cpus" "0-3"
	write "/dev/cpuset/foreground/cpus" "0-3,4-7"
	write "/dev/cpuset/top-app/cpus" "0-3,4-7"
	# set_value 85 /proc/sys/kernel/sched_downmigrate
	# set_value 95 /proc/sys/kernel/sched_upmigrate
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
	set_boost_freq "0:680000 4:880000"
	set_param cpu0 above_hispeed_delay "98000 1380000:78000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 95
	set_param cpu0 target_loads "80 680000:58 980000:68 1280000:97"
	set_param cpu0 min_sample_time 18000
	set_param cpu${bcores} above_hispeed_delay "18000 1280000:38000 1380000:18000 1580000:98000"
	set_param cpu${bcores} hispeed_freq 1080000
	set_param cpu${bcores} go_hispeed_load 98
	set_param cpu${bcores} target_loads "80 880000:51 980000:69 1080000:90 1280000:72 1380000:94 1580000:98"
	set_param cpu${bcores} min_sample_time 18000
	elif [ ${PROFILE} -eq 1 ];then
	set_boost_freq "0:680000 4:880000"
	set_param cpu0 above_hispeed_delay "98000 1380000:58000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 97
	set_param cpu0 target_loads "80 680000:68 780000:60 980000:97 1180000:63 1280000:97 1380000:84"
	set_param cpu0 min_sample_time 58000
	set_param cpu${bcores} above_hispeed_delay "18000 1580000:98000"
	set_param cpu${bcores} hispeed_freq 1280000
	set_param cpu${bcores} go_hispeed_load 98
	set_param cpu${bcores} target_loads "80 880000:47 980000:68 1280000:74 1380000:92 1580000:98"
	set_param cpu${bcores} min_sample_time 18000
	elif [ ${PROFILE} -eq 2 ];then
	set_boost_freq "0:680000 4:880000"
	set_param cpu0 above_hispeed_delay "98000 1280000:38000 1380000:78000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 96
	set_param cpu0 target_loads "80 680000:90 780000:57 980000:61 1180000:96 1380000:7"
	set_param cpu0 min_sample_time 78000
	set_param cpu${bcores} above_hispeed_delay "98000 1680000:38000"
	set_param cpu${bcores} hispeed_freq 1580000
	set_param cpu${bcores} go_hispeed_load 98
	set_param cpu${bcores} target_loads "80 880000:47 1080000:52 1180000:63 1280000:71 1380000:76 1580000:98"
	set_param cpu${bcores} min_sample_time 18000
   	elif [ ${PROFILE} -eq 3 ];then
	
	update_clock_speed 1180000 little min
	set_param cpu0 above_hispeed_delay "18000 1280000:198000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 target_loads "80 1380000:90"
	set_param cpu0 min_sample_time 38000
	update_clock_speed 1380000 big min
	set_param cpu${bcores} above_hispeed_delay "18000 1680000:198000"
	set_param cpu${bcores} hispeed_freq 1380000
	set_param cpu${bcores} target_loads "80 1780000:90"
	set_param cpu${bcores} min_sample_time 38000
fi
esac
case ${SOC} in sdm636* | sda636*) #sd636
	update_clock_speed 580000 little min
	update_clock_speed 1080000 big min
	# avoid permission problem, do not set 0444
	write "/dev/cpuset/background/cpus" "2-3"
	write "/dev/cpuset/system-background/cpus" "0-3"
	write "/dev/cpuset/foreground/cpus" "0-3,4-7"
	write "/dev/cpuset/top-app/cpus" "0-3,4-7"
	# set_value 85 /proc/sys/kernel/sched_downmigrate
	# set_value 95 /proc/sys/kernel/sched_upmigrate
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
	set_boost_freq "0:880000 4:1380000"
	set_param cpu0 above_hispeed_delay "18000 1380000:78000 1480000:98000 1580000:38000"
	set_param cpu0 hispeed_freq 1080000
	set_param cpu0 go_hispeed_load 98
	set_param cpu0 target_loads "80 880000:62 1080000:98 1380000:84 1480000:97"
	set_param cpu0 min_sample_time 58000
	set_param cpu${bcores} above_hispeed_delay "18000 1680000:98000"
	set_param cpu${bcores} hispeed_freq 1080000
	set_param cpu${bcores} go_hispeed_load 86
	set_param cpu${bcores} target_loads "80 1380000:84 1680000:98"
	set_param cpu${bcores} min_sample_time 18000
	elif [ ${PROFILE} -eq 1 ];then
	set_boost_freq "0:880000 4:1380000"
	set_param cpu0 above_hispeed_delay "18000 1380000:78000 1480000:98000 1580000:78000"
	set_param cpu0 hispeed_freq 1080000
	set_param cpu0 go_hispeed_load 98
	set_param cpu0 target_loads "80 880000:62 1080000:94 1380000:75 1480000:96"
	set_param cpu0 min_sample_time 58000
	set_param cpu${bcores} above_hispeed_delay "18000 1680000:98000"
	set_param cpu${bcores} hispeed_freq 1080000
	set_param cpu${bcores} go_hispeed_load 81
	set_param cpu${bcores} target_loads "80 1380000:70 1680000:98"
	set_param cpu${bcores} min_sample_time 18000
	elif [ ${PROFILE} -eq 2 ];then
	set_boost_freq "0:880000 4:1380000"
	set_param cpu0 above_hispeed_delay "18000 1380000:98000 1480000:38000"
	set_param cpu0 hispeed_freq 880000
	set_param cpu0 go_hispeed_load 85
	set_param cpu0 target_loads "80 880000:59 1080000:77 1380000:52 1480000:98 1580000:94"
	set_param cpu0 min_sample_time 78000
	set_param cpu${bcores} above_hispeed_delay "18000 1380000:78000 1680000:38000"
	set_param cpu${bcores} hispeed_freq 1080000
	set_param cpu${bcores} go_hispeed_load 89
	set_param cpu${bcores} target_loads "80 1380000:64 1680000:98"
	set_param cpu${bcores} min_sample_time 78000
   	elif [ ${PROFILE} -eq 3 ];then
	
	update_clock_speed 1080000 little min
	set_param cpu0 above_hispeed_delay "18000 1480000:198000"
	set_param cpu0 hispeed_freq 1080000
	set_param cpu0 target_loads "80 1580000:90"
	set_param cpu0 min_sample_time 38000
	update_clock_speed 1380000 big min
	set_param cpu${bcores} above_hispeed_delay "18000 1680000:198000"
	set_param cpu${bcores} hispeed_freq 1380000
	set_param cpu${bcores} target_loads "80 1780000:90"
	set_param cpu${bcores} min_sample_time 38000
fi
esac
case ${SOC} in msm8953* | sdm630* | sda630* )  #sd625/626/630
	update_clock_speed 580000 little min
	update_clock_speed 580000 big min
	# avoid permission problem, do not set 0444
	write "/dev/cpuset/background/cpus" "2-3"
	write "/dev/cpuset/system-background/cpus" "0-3"
	write "/dev/cpuset/foreground/cpus" "0-3,4-7"
	write "/dev/cpuset/top-app/cpus" "0-3,4-7"
	set_value 25 /proc/sys/kernel/sched_downmigrate
	set_value 45 /proc/sys/kernel/sched_upmigrate
	set_param cpu0 use_sched_load 1
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
	set_boost_freq "0:980000 4:0"
	set_param cpu0 above_hispeed_delay "18000 1680000:98000 1880000:138000"
	set_param cpu0 hispeed_freq 1380000
	set_param cpu0 go_hispeed_load 94
	set_param cpu0 target_loads "80 980000:66 1380000:96"
	set_param cpu0 min_sample_time 18000
	set_param cpu${bcores} above_hispeed_delay "18000 1680000:98000 1880000:138000"
	set_param cpu${bcores} hispeed_freq 1380000
	set_param cpu${bcores} go_hispeed_load 94
	set_param cpu${bcores} target_loads "80 980000:66 1380000:96"
	set_param cpu${bcores} min_sample_time 18000
	elif [ ${PROFILE} -eq 1 ];then
	set_boost_freq "0:980000 4:0"
	set_param cpu0 above_hispeed_delay "98000 1880000:138000"
	set_param cpu0 hispeed_freq 1680000
	set_param cpu0 go_hispeed_load 97
	set_param cpu0 target_loads "80 980000:63 1380000:72 1680000:97"
	set_param cpu0 min_sample_time 18000
	set_param cpu${bcores} above_hispeed_delay "98000 1880000:138000"
	set_param cpu${bcores} hispeed_freq 1680000
	set_param cpu${bcores} go_hispeed_load 97
	set_param cpu${bcores} target_loads "80 980000:63 1380000:72 1680000:97"
	set_param cpu${bcores} min_sample_time 18000
	elif [ ${PROFILE} -eq 2 ];then
	set_boost_freq "0:980000 4:0"
	set_param cpu0 above_hispeed_delay "18000 1680000:98000 1880000:38000"
	set_param cpu0 hispeed_freq 980000
	set_param cpu0 go_hispeed_load 89
	set_param cpu0 target_loads "80 980000:55 1380000:75 1680000:98"
	set_param cpu0 min_sample_time 78000
	set_param cpu${bcores} above_hispeed_delay "18000 1680000:98000 1880000:38000"
	set_param cpu${bcores} hispeed_freq 980000
	set_param cpu${bcores} go_hispeed_load 89
	set_param cpu${bcores} target_loads "80 980000:55 1380000:75 1680000:98"
	set_param cpu${bcores} min_sample_time 78000
   	elif [ ${PROFILE} -eq 3 ];then
	
	update_clock_speed 1380000 little min
	set_param cpu0 above_hispeed_delay "18000 1880000:198000"
	set_param cpu0 hispeed_freq 1380000
	set_param cpu0 target_loads "80 1980000:90"
	set_param cpu0 min_sample_time 38000
	update_clock_speed 1380000 big min
	set_param cpu${bcores} above_hispeed_delay "18000 1880000:198000"
	set_param cpu${bcores} hispeed_freq 1380000
	set_param cpu${bcores} target_loads "80 1980000:90"
	set_param cpu${bcores} min_sample_time 38000
fi
esac
case ${SOC} in universal8895* | exynos8895*)  #EXYNOS8895 (S8)
	update_clock_speed 580000 little min
	update_clock_speed 680000 big min
	# avoid permission problem, do not set 0444
	write "/dev/cpuset/background/cpus" "2-3"
	write "/dev/cpuset/system-background/cpus" "0-3"
	write "/dev/cpuset/foreground/cpus" "0-3,4-7"
	write "/dev/cpuset/top-app/cpus" "0-3,4-7"
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
	set_param cpu0 above_hispeed_delay "38000 1380000:98000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 82
	set_param cpu0 target_loads "80 680000:27 780000:39 880000:61 980000:68 1380000:98 1680000:94"
	set_param cpu0 min_sample_time 18000
	set_param cpu${bcores} above_hispeed_delay "18000 1680000:98000 1880000:138000"
	set_param cpu${bcores} hispeed_freq 1380000
	set_param cpu${bcores} go_hispeed_load 98
	set_param cpu${bcores} target_loads "80 780000:73 880000:79 980000:55 1080000:69 1180000:84 1380000:98"
	set_param cpu${bcores} min_sample_time 18000
	elif [ ${PROFILE} -eq 1 ];then
	set_param cpu0 above_hispeed_delay "38000 1380000:98000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 98
	set_param cpu0 target_loads "80 780000:53 880000:70 980000:50 1180000:71 1380000:97 1680000:92"
	set_param cpu0 min_sample_time 58000
	set_param cpu${bcores} above_hispeed_delay "18000 1680000:98000 1880000:138000"
	set_param cpu${bcores} hispeed_freq 1380000
	set_param cpu${bcores} go_hispeed_load 98
	set_param cpu${bcores} target_loads "80 780000:40 880000:34 980000:66 1080000:31 1180000:72 1380000:86 1680000:98"
	set_param cpu${bcores} min_sample_time 18000
	elif [ ${PROFILE} -eq 2 ];then
	set_param cpu0 above_hispeed_delay "38000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 97
	set_param cpu0 target_loads "80 780000:31 880000:62 980000:42 1180000:69 1380000:95 1680000:78"
	set_param cpu0 min_sample_time 58000
	set_param cpu${bcores} above_hispeed_delay "18000 1680000:98000 1880000:38000"
	set_param cpu${bcores} hispeed_freq 1380000
	set_param cpu${bcores} go_hispeed_load 96
	set_param cpu${bcores} target_loads "80 780000:22 880000:3 980000:14 1080000:34 1180000:47 1380000:63 1680000:72 1780000:98"
	set_param cpu${bcores} min_sample_time 18000
   	elif [ ${PROFILE} -eq 3 ];then
	update_clock_speed 1180000 little min
	set_param cpu0 above_hispeed_delay "18000 1380000:198000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 target_loads "80 1680000:90"
	set_param cpu0 min_sample_time 38000
	update_clock_speed 1380000 big min
	set_param cpu${bcores} above_hispeed_delay "18000 1880000:198000"
	set_param cpu${bcores} hispeed_freq 1380000
	set_param cpu${bcores} target_loads "80 1980000:90"
	set_param cpu${bcores} min_sample_time 38000
fi
esac
case ${SOC} in universal8890* | exynos8890*)  #EXYNOS8890 (S7)
	update_clock_speed 380000 little min
	update_clock_speed 680000 big min
	# avoid permission problem, do not set 0444
	write "/dev/cpuset/background/cpus" "2-3"
	write "/dev/cpuset/system-background/cpus" "0-3"
	write "/dev/cpuset/foreground/cpus" "0-3,4-7"
	write "/dev/cpuset/top-app/cpus" "0-3,4-7"
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
	set_param cpu0 above_hispeed_delay "38000 1280000:18000 1480000:98000 1580000:58000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 96
	set_param cpu0 target_loads "80 480000:51 680000:28 780000:56 880000:63 1080000:71 1180000:75 1280000:97"
	set_param cpu0 min_sample_time 18000
	set_param cpu${bcores} above_hispeed_delay "18000 1480000:98000 1880000:138000"
	set_param cpu${bcores} hispeed_freq 1280000
	set_param cpu${bcores} go_hispeed_load 98
	set_param cpu${bcores} target_loads "80 780000:4 880000:77 980000:14 1080000:90 1180000:68 1280000:92 1480000:96"
	set_param cpu${bcores} min_sample_time 18000
	elif [ ${PROFILE} -eq 1 ];then
	set_param cpu0 above_hispeed_delay "18000 1280000:38000 1480000:98000 1580000:18000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 98
	set_param cpu0 target_loads "80 480000:49 680000:34 780000:61 880000:33 980000:63 1080000:69 1180000:77 1480000:98"
	set_param cpu0 min_sample_time 18000
	set_param cpu${bcores} above_hispeed_delay "18000 1580000:98000 1880000:138000"
	set_param cpu${bcores} hispeed_freq 1380000
	set_param cpu${bcores} go_hispeed_load 93
	set_param cpu${bcores} target_loads "80 780000:33 880000:67 980000:42 1080000:75 1180000:65 1280000:74 1480000:97"
	set_param cpu${bcores} min_sample_time 18000
	elif [ ${PROFILE} -eq 2 ];then
	set_param cpu0 above_hispeed_delay "18000 1480000:38000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 97
	set_param cpu0 target_loads "80 480000:54 780000:61 880000:24 980000:63 1080000:57 1180000:81 1280000:71 1480000:96 1580000:87"
	set_param cpu0 min_sample_time 38000
	set_param cpu${bcores} above_hispeed_delay "18000 1580000:98000 1880000:38000"
	set_param cpu${bcores} hispeed_freq 1480000
	set_param cpu${bcores} go_hispeed_load 90
	set_param cpu${bcores} target_loads "80 780000:6 880000:37 980000:59 1180000:42 1280000:67 1580000:96"
	set_param cpu${bcores} min_sample_time 18000
   	elif [ ${PROFILE} -eq 3 ];then
	update_clock_speed 1280000 little min
	set_param cpu0 above_hispeed_delay "18000 1480000:198000"
	set_param cpu0 hispeed_freq 1280000
	set_param cpu0 target_loads "80 1580000:90"
	set_param cpu0 min_sample_time 38000
	update_clock_speed 1380000 big min
	set_param cpu${bcores} above_hispeed_delay "18000 1880000:198000"
	set_param cpu${bcores} hispeed_freq 1380000
	set_param cpu${bcores} target_loads "80 1980000:90"
	set_param cpu${bcores} min_sample_time 38000
fi
esac
case ${SOC} in universal7420* | exynos7420*) #EXYNOS7420 (S6)
	update_clock_speed 380000 little min
	update_clock_speed 780000 big min
	# avoid permission problem, do not set 0444
	write "/dev/cpuset/background/cpus" "2-3"
	write "/dev/cpuset/system-background/cpus" "0-3"
	write "/dev/cpuset/foreground/cpus" "0-3,4-7"
	write "/dev/cpuset/top-app/cpus" "0-3,4-7"
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
	set_param cpu0 above_hispeed_delay "38000 1280000:78000 1380000:98000 1480000:58000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 96
	set_param cpu0 target_loads "80 480000:28 580000:19 680000:37 780000:51 880000:61 1080000:83 1180000:66 1280000:91 1380000:96"
	set_param cpu0 min_sample_time 18000
	set_param cpu${bcores} above_hispeed_delay "98000 1880000:138000"
	set_param cpu${bcores} hispeed_freq 1480000
	set_param cpu${bcores} go_hispeed_load 97
	set_param cpu${bcores} target_loads "80 880000:74 980000:56 1080000:80 1180000:92 1380000:85 1480000:93 1580000:98"
	set_param cpu${bcores} min_sample_time 18000
	elif [ ${PROFILE} -eq 1 ];then
	set_param cpu0 above_hispeed_delay "58000 1280000:18000 1380000:98000 1480000:58000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 97
	set_param cpu0 target_loads "80 480000:29 580000:12 680000:69 780000:22 880000:36 1080000:80 1180000:89 1480000:63"
	set_param cpu0 min_sample_time 38000
	set_param cpu${bcores} above_hispeed_delay "18000 1480000:78000 1580000:98000 1880000:138000"
	set_param cpu${bcores} hispeed_freq 1380000
	set_param cpu${bcores} go_hispeed_load 96
	set_param cpu${bcores} target_loads "80 880000:27 980000:44 1080000:71 1180000:32 1280000:64 1380000:78 1480000:87 1580000:98"
	set_param cpu${bcores} min_sample_time 18000
	elif [ ${PROFILE} -eq 2 ];then
	set_param cpu0 above_hispeed_delay "18000 1280000:98000 1380000:38000 1480000:58000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 97
	set_param cpu0 target_loads "80 480000:26 580000:32 680000:69 780000:50 880000:15 1080000:80 1180000:85 1480000:56"
	set_param cpu0 min_sample_time 38000
	set_param cpu${bcores} above_hispeed_delay "18000 880000:38000 980000:58000 1080000:18000 1180000:38000 1280000:18000 1480000:78000 1580000:98000 1880000:38000"
	set_param cpu${bcores} hispeed_freq 780000
	set_param cpu${bcores} go_hispeed_load 98
	set_param cpu${bcores} target_loads "80 880000:4 980000:29 1080000:57 1280000:66 1480000:44 1580000:66 1680000:98"
	set_param cpu${bcores} min_sample_time 18000
   	elif [ ${PROFILE} -eq 3 ];then
	update_clock_speed 1280000 little min
	set_param cpu0 above_hispeed_delay "18000 1380000:198000"
	set_param cpu0 hispeed_freq 1280000
	set_param cpu0 target_loads "80 1480000:90"
	set_param cpu0 min_sample_time 38000
	update_clock_speed 1380000 big min
	set_param cpu${bcores} above_hispeed_delay "18000 1880000:198000"
	set_param cpu${bcores} hispeed_freq 1380000
	set_param cpu${bcores} target_loads "80 1980000:90"
	set_param cpu${bcores} min_sample_time 38000
fi
esac
case ${SOC} in kirin970* | hi3670*)  # Huawei Kirin 970
	update_clock_speed 480000 little min
	update_clock_speed 680000 big min
	# avoid permission problem, do not set 0444
	write "/dev/cpuset/background/cpus" "2-3"
	write "/dev/cpuset/system-background/cpus" "0-3"
	write "/dev/cpuset/foreground/cpus" "0-3,4-7"
	write "/dev/cpuset/top-app/cpus" "0-3,4-7"
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
	set_param cpu0 above_hispeed_delay "18000 1380000:38000 1480000:98000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 98
	set_param cpu0 target_loads "80 980000:60 1180000:87 1380000:70 1480000:98"
	set_param cpu0 min_sample_time 18000
	set_param cpu${bcores} above_hispeed_delay "18000 1580000:98000 1780000:138000"
	set_param cpu${bcores} hispeed_freq 1280000
	set_param cpu${bcores} go_hispeed_load 98
	set_param cpu${bcores} target_loads "80 1280000:98 1480000:91 1580000:98"
	set_param cpu${bcores} min_sample_time 18000
	elif [ ${PROFILE} -eq 1 ];then
	set_param cpu0 above_hispeed_delay "18000 1480000:38000 1680000:98000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 97
	set_param cpu0 target_loads "80 980000:61 1180000:88 1380000:70 1480000:96"
	set_param cpu0 min_sample_time 38000
	set_param cpu${bcores} above_hispeed_delay "18000 1580000:98000 1780000:138000"
	set_param cpu${bcores} hispeed_freq 1280000
	set_param cpu${bcores} go_hispeed_load 94
	set_param cpu${bcores} target_loads "80 980000:72 1280000:77 1580000:98"
	set_param cpu${bcores} min_sample_time 18000
	elif [ ${PROFILE} -eq 2 ];then
	set_param cpu0 above_hispeed_delay "18000 1680000:38000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 98
	set_param cpu0 target_loads "80 980000:63 1180000:76 1480000:96"
	set_param cpu0 min_sample_time 78000
	set_param cpu${bcores} above_hispeed_delay "18000 1580000:98000 1780000:38000"
	set_param cpu${bcores} hispeed_freq 1480000
	set_param cpu${bcores} go_hispeed_load 86
	set_param cpu${bcores} target_loads "80 980000:57 1280000:70 1480000:65 1580000:98"
	set_param cpu${bcores} min_sample_time 18000
   	elif [ ${PROFILE} -eq 3 ];then
	update_clock_speed 1480000 little min
	set_param cpu0 above_hispeed_delay "18000 1680000:198000"
	set_param cpu0 hispeed_freq 1480000
	set_param cpu0 target_loads "80 1780000:90"
	set_param cpu0 min_sample_time 38000
	update_clock_speed 1280000 big min
	set_param cpu${bcores} above_hispeed_delay "18000 1780000:198000"
	set_param cpu${bcores} hispeed_freq 1280000
	set_param cpu${bcores} target_loads "80 1980000:90"
	set_param cpu${bcores} min_sample_time 38000
fi
esac
case ${SOC} in kirin960* | hi3660*)  # Huawei Kirin 960
	update_clock_speed 480000 little min
	update_clock_speed 880000 big min
	# avoid permission problem, do not set 0444
	write "/dev/cpuset/background/cpus" "2-3"
	write "/dev/cpuset/system-background/cpus" "0-3"
	write "/dev/cpuset/foreground/cpus" "0-3,4-7"
	write "/dev/cpuset/top-app/cpus" "0-3,4-7"
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
	set_param cpu0 above_hispeed_delay "38000 1680000:98000"
	set_param cpu0 hispeed_freq 1380000
	set_param cpu0 go_hispeed_load 97
	set_param cpu0 target_loads "80 980000:93 1380000:97"
	set_param cpu0 min_sample_time 58000
	set_param cpu${bcores} above_hispeed_delay "18000 1780000:138000"
	set_param cpu${bcores} hispeed_freq 880000
	set_param cpu${bcores} go_hispeed_load 84
	set_param cpu${bcores} target_loads "80 1380000:98"
	set_param cpu${bcores} min_sample_time 38000
	elif [ ${PROFILE} -eq 1 ];then
	set_param cpu0 above_hispeed_delay "38000 1680000:98000"
	set_param cpu0 hispeed_freq 1380000
	set_param cpu0 go_hispeed_load 97
	set_param cpu0 target_loads "80 980000:97 1380000:78 1680000:98"
	set_param cpu0 min_sample_time 78000
	set_param cpu${bcores} above_hispeed_delay "18000 1380000:98000 1780000:138000"
	set_param cpu${bcores} hispeed_freq 880000
	set_param cpu${bcores} go_hispeed_load 95
	set_param cpu${bcores} target_loads "80 1380000:59 1780000:98"
	set_param cpu${bcores} min_sample_time 38000
	elif [ ${PROFILE} -eq 2 ];then
	set_param cpu0 above_hispeed_delay "38000"
	set_param cpu0 hispeed_freq 1380000
	set_param cpu0 go_hispeed_load 97
	set_param cpu0 target_loads "80 980000:58 1380000:75 1680000:98"
	set_param cpu0 min_sample_time 78000
	set_param cpu${bcores} above_hispeed_delay "18000 1380000:38000 1780000:138000"
	set_param cpu${bcores} hispeed_freq 880000
	set_param cpu${bcores} go_hispeed_load 93
	set_param cpu${bcores} target_loads "80 1380000:59 1780000:97"
	set_param cpu${bcores} min_sample_time 38000
   	elif [ ${PROFILE} -eq 3 ];then
	update_clock_speed 1380000 little min
	set_param cpu0 above_hispeed_delay "18000 1680000:198000"
	set_param cpu0 hispeed_freq 1380000
	set_param cpu0 target_loads "80 1780000:90"
	set_param cpu0 min_sample_time 38000
	update_clock_speed 1380000 big min
	set_param cpu${bcores} above_hispeed_delay "18000 1780000:198000"
	set_param cpu${bcores} hispeed_freq 1380000
	set_param cpu${bcores} target_loads "80 1980000:90"
	set_param cpu${bcores} min_sample_time 38000
fi
esac
case ${SOC} in kirin950* | hi3650* | kirin955* | hi3655*) # Huawei Kirin 950
	update_clock_speed 480000 little min
	update_clock_speed 780000 big min
	# avoid permission problem, do not set 0444
	write "/dev/cpuset/background/cpus" "2-3"
	write "/dev/cpuset/system-background/cpus" "0-3"
	write "/dev/cpuset/foreground/cpus" "0-3,4-7"
	write "/dev/cpuset/top-app/cpus" "0-3,4-7"
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
	set_param cpu0 above_hispeed_delay "18000 1480000:98000"
	set_param cpu0 hispeed_freq 1280000
	set_param cpu0 go_hispeed_load 98
	set_param cpu0 target_loads "80 780000:62 980000:71 1280000:77 1480000:98"
	set_param cpu0 min_sample_time 18000
	set_param cpu${bcores} above_hispeed_delay "18000 1480000:98000 1780000:138000"
	set_param cpu${bcores} hispeed_freq 780000
	set_param cpu${bcores} go_hispeed_load 80
	set_param cpu${bcores} target_loads "80 1180000:89 1480000:98"
	set_param cpu${bcores} min_sample_time 38000
	elif [ ${PROFILE} -eq 1 ];then
	set_param cpu0 above_hispeed_delay "18000 1480000:98000"
	set_param cpu0 hispeed_freq 1280000
	set_param cpu0 go_hispeed_load 97
	set_param cpu0 target_loads "80 780000:69 980000:76 1280000:80 1480000:96"
	set_param cpu0 min_sample_time 58000
	set_param cpu${bcores} above_hispeed_delay "18000 1780000:138000"
	set_param cpu${bcores} hispeed_freq 1180000
	set_param cpu${bcores} go_hispeed_load 80
	set_param cpu${bcores} target_loads "80 1180000:75 1480000:93 1780000:98"
	set_param cpu${bcores} min_sample_time 38000
	elif [ ${PROFILE} -eq 2 ];then
	set_param cpu0 above_hispeed_delay "18000 1480000:38000"
	set_param cpu0 hispeed_freq 1280000
	set_param cpu0 go_hispeed_load 97
	set_param cpu0 target_loads "80 780000:66 980000:17 1280000:81 1480000:96 1780000:87"
	set_param cpu0 min_sample_time 78000
	set_param cpu${bcores} above_hispeed_delay "18000 1780000:138000"
	set_param cpu${bcores} hispeed_freq 1180000
	set_param cpu${bcores} go_hispeed_load 80
	set_param cpu${bcores} target_loads "80 1180000:65 1480000:85 1780000:96"
	set_param cpu${bcores} min_sample_time 38000
   	elif [ ${PROFILE} -eq 3 ];then
	update_clock_speed 1480000 little min
	set_param cpu0 above_hispeed_delay "18000 1480000:198000"
	set_param cpu0 hispeed_freq 1480000
	set_param cpu0 target_loads "80 1780000:90"
	set_param cpu0 min_sample_time 38000
	update_clock_speed 1180000 big min
	set_param cpu${bcores} above_hispeed_delay "18000 1780000:198000"
	set_param cpu${bcores} hispeed_freq 1180000
	set_param cpu${bcores} target_loads "80 1980000:90"
	set_param cpu${bcores} min_sample_time 38000
fi
esac
case ${SOC} in mt6797*) #Helio X25 / X20
	setprop ro.mtk_perfservice_support 0
	set_value 0 "/proc/sys/kernel/sched_tunable_scaling"
	set_value 0 "/proc/ppm/policy/hica_is_limit_big_freq"
	set_value 10000 "/dev/cpuctl/bg_non_interactive/cpu.rt_runtime_us"
	update_clock_speed 280000 little min
	update_clock_speed 280000 big min
	# CORE CONTROL
	set_value 40 /proc/hps/down_threshold
	# avoid permission problem, do not set 0444
	write "/dev/cpuset/background/cpus" "2-3"
	write "/dev/cpuset/system-background/cpus" "0-3"
	write "/dev/cpuset/foreground/cpus" "0-3,4-7,8"
	write "/dev/cpuset/top-app/cpus" "0-3,4-7,8"
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
	set_value 90 /proc/hps/up_threshold
	set_value "2 2 0" /proc/hps/num_base_perf_serv
	set_param cpu0 above_hispeed_delay "18000 1380000:98000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 94
	set_param cpu0 target_loads "80 380000:15 480000:25 780000:36 880000:80 980000:66 1180000:91 1280000:96"
	set_param cpu0 min_sample_time 18000
	set_param cpu${bcores} above_hispeed_delay "18000 1380000:98000"
	set_param cpu${bcores} hispeed_freq 1180000
	set_param cpu${bcores} go_hispeed_load 94
	set_param cpu${bcores} target_loads "80 380000:15 480000:25 780000:36 880000:80 980000:66 1180000:91 1280000:96"
	set_param cpu${bcores} min_sample_time 18000	
	elif [ ${PROFILE} -eq 1 ];then
	set_value 80 /proc/hps/up_threshold
	set_value "3 3 0" /proc/hps/num_base_perf_serv
	set_param cpu0 above_hispeed_delay "18000 1380000:98000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 93
	set_param cpu0 target_loads "80 380000:8 580000:14 680000:9 780000:41 880000:56 1080000:65 1180000:92 1380000:85 1480000:97"
	set_param cpu0 min_sample_time 18000
	set_param cpu${bcores} above_hispeed_delay "18000 1380000:98000"
	set_param cpu${bcores} hispeed_freq 1180000
	set_param cpu${bcores} go_hispeed_load 93
	set_param cpu${bcores} target_loads "80 380000:8 580000:14 680000:9 780000:41 880000:56 1080000:65 1180000:92 1380000:85 1480000:97"
	set_param cpu${bcores} min_sample_time 18000	
	elif [ ${PROFILE} -eq 2 ];then
	set_value 70 /proc/hps/up_threshold
	set_value "3 3 1" /proc/hps/num_base_perf_serv
	set_param cpu0 above_hispeed_delay "18000 1380000:58000 1480000:98000 1680000:38000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 85
	set_param cpu0 target_loads "80 380000:10 780000:57 1080000:27 1180000:65 1280000:82 1380000:6 1480000:80 1580000:98"
	set_param cpu0 min_sample_time 18000
	set_param cpu${bcores} above_hispeed_delay "18000 1380000:58000 1480000:98000 1680000:38000"
	set_param cpu${bcores} hispeed_freq 1180000
	set_param cpu${bcores} go_hispeed_load 85
	set_param cpu${bcores} target_loads "80 380000:10 780000:57 1080000:27 1180000:65 1280000:82 1380000:6 1480000:80 1580000:98"
	set_param cpu${bcores} min_sample_time 18000	
   	elif [ ${PROFILE} -eq 3 ];then
	set_value 60 /proc/hps/up_threshold
	set_value "4 4 1" /proc/hps/num_base_perf_serv
	update_clock_speed 1280000 little min
	set_param cpu0 above_hispeed_delay "18000 1680000:198000"
	set_param cpu0 hispeed_freq 1280000
	set_param cpu0 target_loads "80 1780000:90"
	set_param cpu0 min_sample_time 38000
	update_clock_speed 1280000 big min
	set_param cpu${bcores} above_hispeed_delay "18000 1680000:198000"
	set_param cpu${bcores} hispeed_freq 1280000
	set_param cpu${bcores} target_loads "80 1780000:90"
	set_param cpu${bcores} min_sample_time 38000
fi
esac
case ${SOC} in mt6795*) #Helio X10
	setprop ro.mtk_perfservice_support 0
	set_value 0 "/proc/sys/kernel/sched_tunable_scaling"
	set_value 0 "/proc/ppm/policy/hica_is_limit_big_freq"
	set_value 10000 "/dev/cpuctl/bg_non_interactive/cpu.rt_runtime_us"
	update_clock_speed 380000 little min
	update_clock_speed 380000 big min
	# CORE CONTROL
	set_value 40 /proc/hps/down_threshold
	# avoid permission problem, do not set 0444
	write "/dev/cpuset/background/cpus" "2-3"
	write "/dev/cpuset/system-background/cpus" "0-3"
	write "/dev/cpuset/foreground/cpus" "0-3,4-7"
	write "/dev/cpuset/top-app/cpus" "0-3,4-7"
	if [ ${PROFILE} -eq 0 ];then
	set_value 90 /proc/hps/up_threshold
	set_value 2 /proc/hps/num_base_perf_serv
	set_param cpu0 above_hispeed_delay "38000 1280000:18000 1480000:98000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 98
	set_param cpu0 target_loads "80 780000:51 1180000:65 1280000:83 1480000:98"
	set_param cpu0 min_sample_time 18000
	set_param cpu${bcores} above_hispeed_delay "38000 1280000:18000 1480000:98000"
	set_param cpu${bcores} hispeed_freq 1180000
	set_param cpu${bcores} go_hispeed_load 98
	set_param cpu${bcores} target_loads "80 780000:51 1180000:65 1280000:83 1480000:98"
	set_param cpu${bcores} min_sample_time 18000
	elif [ ${PROFILE} -eq 1 ];then
	set_value 80 /proc/hps/up_threshold
	set_value 3 /proc/hps/num_base_perf_serv
	set_param cpu0 above_hispeed_delay "18000 1480000:98000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 98
	set_param cpu0 target_loads "80 780000:60 1180000:86 1280000:79 1480000:97"
	set_param cpu0 min_sample_time 38000
	set_param cpu${bcores} above_hispeed_delay "18000 1480000:98000"
	set_param cpu${bcores} hispeed_freq 1180000
	set_param cpu${bcores} go_hispeed_load 98
	set_param cpu${bcores} target_loads "80 780000:60 1180000:86 1280000:79 1480000:97"
	set_param cpu${bcores} min_sample_time 38000
	elif [ ${PROFILE} -eq 2 ];then
	set_value 70 /proc/hps/up_threshold
	set_value 3 /proc/hps/num_base_perf_serv
	set_param cpu0 above_hispeed_delay "38000 1580000:98000"
	set_param cpu0 hispeed_freq 1480000
	set_param cpu0 go_hispeed_load 98
	set_param cpu0 target_loads "80 780000:61 1180000:65 1280000:83 1480000:63 1580000:96"
	set_param cpu0 min_sample_time 38000
	set_param cpu${bcores} above_hispeed_delay "38000 1580000:98000"
	set_param cpu${bcores} hispeed_freq 1480000
	set_param cpu${bcores} go_hispeed_load 98
	set_param cpu${bcores} target_loads "80 780000:61 1180000:65 1280000:83 1480000:63 1580000:96"
	set_param cpu${bcores} min_sample_time 38000
   	elif [ ${PROFILE} -eq 3 ];then
	set_value 60 /proc/hps/up_threshold
	set_value 4 /proc/hps/num_base_perf_serv
	update_clock_speed 1280000 little min
	set_param cpu0 above_hispeed_delay "18000 1580000:198000"
	set_param cpu0 hispeed_freq 1280000
	set_param cpu0 target_loads "80 1880000:90"
	set_param cpu0 min_sample_time 38000
	update_clock_speed 1280000 big min
	set_param cpu${bcores} above_hispeed_delay "18000 1580000:198000"
	set_param cpu${bcores} hispeed_freq 1280000
	set_param cpu${bcores} target_loads "80 1880000:90"
	set_param cpu${bcores} min_sample_time 38000
	fi
	esac
    case ${SOC} in moorefield*) # Intel Atom
	update_clock_speed 480000 little min
	update_clock_speed 480000 big min
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
	set_param cpu0 above_hispeed_delay "18000 1480000:98000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 95
	set_param cpu0 target_loads "80 580000:56 680000:44 780000:33 880000:48 980000:62 1080000:74 1280000:89 1480000:98"
	set_param cpu0 min_sample_time 18000
	set_param cpu${bcores} above_hispeed_delay "18000 1480000:98000"
	set_param cpu${bcores} hispeed_freq 1180000
	set_param cpu${bcores} go_hispeed_load 95
	set_param cpu${bcores} target_loads "80 580000:56 680000:44 780000:33 880000:48 980000:62 1080000:74 1280000:89 1480000:98"
	set_param cpu${bcores} min_sample_time 18000
	elif [ ${PROFILE} -eq 1 ];then
	set_param cpu0 above_hispeed_delay "18000 1480000:98000"
	set_param cpu0 hispeed_freq 1380000
	set_param cpu0 go_hispeed_load 98
	set_param cpu0 target_loads "80 580000:53 680000:38 880000:49 980000:60 1180000:65 1280000:82 1380000:63 1480000:97"
	set_param cpu0 min_sample_time 18000
	set_param cpu${bcores} above_hispeed_delay "18000 1480000:98000"
	set_param cpu${bcores} hispeed_freq 1380000
	set_param cpu${bcores} go_hispeed_load 98
	set_param cpu${bcores} target_loads "80 580000:53 680000:38 880000:49 980000:60 1180000:65 1280000:82 1380000:63 1480000:97"
	set_param cpu${bcores} min_sample_time 18000
	elif [ ${PROFILE} -eq 2 ];then
	set_param cpu0 above_hispeed_delay "38000 1580000:98000 1680000:38000"
	set_param cpu0 hispeed_freq 1480000
	set_param cpu0 go_hispeed_load 95
	set_param cpu0 target_loads "80 580000:59 680000:36 780000:75 880000:39 1080000:56 1380000:52 1480000:57 1580000:97"
	set_param cpu0 min_sample_time 18000
	set_param cpu${bcores} above_hispeed_delay "38000 1580000:98000 1680000:38000"
	set_param cpu${bcores} hispeed_freq 1480000
	set_param cpu${bcores} go_hispeed_load 95
	set_param cpu${bcores} target_loads "80 580000:59 680000:36 780000:75 880000:39 1080000:56 1380000:52 1480000:57 1580000:97"
	set_param cpu${bcores} min_sample_time 18000
   	elif [ ${PROFILE} -eq 3 ];then
	update_clock_speed 1380000 little min
	set_param cpu0 above_hispeed_delay "18000 1680000:198000"
	set_param cpu0 hispeed_freq 1380000
	set_param cpu0 target_loads "80 1780000:90"
	set_param cpu0 min_sample_time 38000
	update_clock_speed 1380000 big min
	set_param cpu${bcores} above_hispeed_delay "18000 1680000:198000"
	set_param cpu${bcores} hispeed_freq 1380000
	set_param cpu${bcores} target_loads "80 1780000:90"
	set_param cpu${bcores} min_sample_time 38000
fi
esac
case ${SOC} in msm8939* | msm8952*)  #sd615/616/617 by@ 橘猫520

	if [ ${soc_revision} == "3.0" ] ;then
	if [ ${PROFILE} -eq 0 ];then
	MSG=1
	elif [ ${PROFILE} -eq 1 ];then
	set_param cpu${bcores} go_hispeed_load 110
	set_param cpu${bcores} above_hispeed_delay 20000
	set_param cpu${bcores} timer_rate 60000
	set_param cpu${bcores} hispeed_freq 998000
	set_param cpu${bcores} timer_slack 380000
	set_param cpu${bcores} target_loads "85 800000:70 998000:82 1113000:84 1209000:82"
	set_param cpu${bcores} min_sample_time 0
	set_param cpu${bcores} ignore_hispeed_on_notif 0
	set_param cpu${bcores} boost 0
	set_param cpu${bcores} fast_ramp_down 0
	set_param cpu${bcores} align_windows 0
	set_param cpu${bcores} use_migration_notif 1
	set_param cpu${bcores} use_sched_load 1
	set_param cpu${bcores} max_freq_hysteresis 0
	set_param cpu${bcores} boostpulse_duration 0
	set_param cpu0 go_hispeed_load 110
	set_param cpu0 above_hispeed_delay 20000
	set_param cpu0 timer_rate 60000
	set_param cpu0 hispeed_freq 1130000
	set_param cpu0 timer_slack 380000
	set_param cpu0 target_loads "85 960000:70 1130000:82 1340000:84 1459000:82"
	set_param cpu0 min_sample_time 0
	set_param cpu0 ignore_hispeed_on_notif 0
	set_param cpu0 boost 0
	set_param cpu0 fast_ramp_down 0
	set_param cpu0 align_windows 0
	set_param cpu0 use_migration_notif 1
	set_param cpu0 use_sched_load 1
	set_param cpu0 max_freq_hysteresis 0
	set_param cpu0 boostpulse_duration 0
	elif [ ${PROFILE} -eq 2 ];then
	MSG=1
   	elif [ ${PROFILE} -eq 3 ];then
	MSG=1
	fi
	else
	if [ ${PROFILE} -eq 0 ];then
	MSG=1
	elif [ ${PROFILE} -eq 1 ];then
	set_param cpu${bcores} hispeed_freq 400000
	set_param cpu0 hispeed_freq 883000
	set_param cpu${bcores} target_loads "98 40000:40 499000:80 533000:95 800000:75 998000:99"
	set_param cpu0 target_loads "98 883000:40 1036000:80 1113000:95 1267000:99"
	set_param cpu${bcores} above_hispeed_delay "20000 499000:60000 533000:150000"
	set_param cpu0 above_hispeed_delay "20000 1036000:60000 1130000:150000"
	set_param cpu0 min_sample_time 40000
	set_param cpu${bcores} min_sample_time 10000
	set_param cpu${bcores} go_hispeed_load 99
	set_param cpu0 go_hispeed_load 99
	set_param cpu${bcores} boostpulse_duration 80000
	set_param cpu0 boostpulse_duration 80000
	set_param cpu${bcores} use_sched_load 1
	set_param cpu0 use_sched_load 1
	set_param cpu${bcores} use_migration_notif 1
	set_param cpu0 use_migration_notif 1
	set_param cpu${bcores} boost 0
	set_param cpu0 boost 0
	elif [ ${PROFILE} -eq 2 ];then
	MSG=1
   	elif [ ${PROFILE} -eq 3 ];then
	MSG=1
	fi
	fi

	esac
    case ${SOC} in kirin650* | kirin655* | kirin658* | kirin659* | hi625*)  #KIRIN650 by @橘猫520
	if [ ${PROFILE} -eq 0 ];then
	MSG=1
	elif [ ${PROFILE} -eq 1 ];then
	set_param cpu0 hispeed_freq 807000
	set_param cpu${bcores} hispeed_freq 1402000
	set_param cpu0 target_loads "98 480000:75 807000:95 1306000:99"
	set_param cpu${bcores} target_loads "98 1402000:95"
	set_param cpu0 above_hispeed_delay "20000 480000:60000 807000:150000"
	set_param cpu${bcores} above_hispeed_delay "20000 1402000:160000"
	set_param cpu${bcores} min_sample_time 50000
	set_param cpu0 min_sample_time 50000
	set_param cpu${bcores} boost 0
	set_param cpu0 boost 0
	set_param cpu${bcores} go_hispeed_load 99
	set_param cpu0 go_hispeed_load 99
	set_param cpu${bcores} boostpulse_duration 80000
	set_param cpu0 boostpulse_duration 80000
	set_param cpu${bcores} use_sched_load 1
	set_param cpu0 use_sched_load 1
	set_param cpu${bcores} use_migration_notif 1
	set_param cpu0 use_migration_notif 1
	elif [ ${PROFILE} -eq 2 ];then
	MSG=1
   	elif [ ${PROFILE} -eq 3 ];then
	MSG=1
	fi
	esac
    case ${SOC} in universal9810* | exynos9810*) # S9 exynos_9810 by @橘猫520
	if [ ${PROFILE} -eq 0 ];then
	MSG=1
	elif [ ${PROFILE} -eq 1 ];then
	set_param cpu0 boostpulse_duration 4000
	set_param cpu${bcores} boostpulse_duration 4000
	set_param cpu0 boost 1
	set_param cpu${bcores} boost 1
	set_param cpu0 timer_rate 20000
	set_param cpu${bcores} timer_rate 20000
	set_param cpu0 timer_slack 10000
	set_param cpu${bcores} timer_slack 10000
	set_param cpu0 min_sample_time 12000
	set_param cpu${bcores} min_sample_time 12000
	set_param cpu0 io_is_busy 0
	set_param cpu${bcores} io_is_busy 0
	set_param cpu0 ignore_hispeed_on_notif 0
	set_param cpu${bcores} ignore_hispeed_on_notif 0
	set_param cpu${bcores} go_hispeed_load 73
	set_param cpu0 go_hispeed_load 65
	set_param cpu${bcores} hispeed_freq 1066000
	set_param cpu0 hispeed_freq 715000
	set_param cpu${bcores} above_hispeed_delay "4000 741000:77000 962000:99000 1170000:110000 1469000:130000 1807000:140000 2002000:1500000 2314000:160000 2496000:171000 2652000:184000 2704000:195000"
	set_param cpu0 above_hispeed_delay "4000 455000:77000 715000:95000 1053000:110000 1456000:130000 1690000:1500000 1794000:163000"
	set_param cpu${bcores} target_loads "55 741000:44 962000:51 1170000:58 1469000:66 1807000:73 2002000:82 2314000:89 2496000:93 2652000:97 2704000:100"
	set_param cpu0 target_loads "45 455000:48 715000:68 949000:71 1248000:86 1690000:91 1794000:100"
	elif [ ${PROFILE} -eq 2 ];then
	MSG=1
   	elif [ ${PROFILE} -eq 3 ];then
	MSG=1
fi
esac
case ${SOC} in apq8026* | apq8028* | apq8030* | msm8226* | msm8228* | msm8230* | msm8626* | msm8628* | msm8630* | msm8926* | msm8928* | msm8930*)  #sd400 series by @cjybyjk
	if [ ${PROFILE} -eq 0 ];then
	MSG=1
	elif [ ${PROFILE} -eq 1 ];then
	set_param_all go_hispeed_load 99
	set_param_all above_hispeed_delay "20000 600000:60000 787000:150000"
	set_param_all timer_rate 20000
	set_param_all hispeed_freq 600000
	set_param_all timer_slack 80000
	set_param_all target_loads "98 384000:75 600000:95 787000:40 998000:80 1094000:99"
	set_param_all min_sample_time 50000
	set_param_all boost 0
	elif [ ${PROFILE} -eq 2 ];then
	MSG=1
   	elif [ ${PROFILE} -eq 3 ];then
	MSG=1
fi
esac
case ${SOC} in apq8016* | msm8916* | msm8216* | msm8917* | msm8217*)  #sd410/sd425 series by @cjybyjk
	if [ ${PROFILE} -eq 0 ];then
	MSG=1
	elif [ ${PROFILE} -eq 1 ];then
	set_param_all go_hispeed_load 99
	set_param_all above_hispeed_delay "0 998000:25000 1152000:41000 1209000:55000"
	set_param_all timer_rate 60000
	set_param_all hispeed_freq 800000
	set_param_all timer_slack 480000
	set_param_all target_loads "98 400000:68 553000:82 800000:72 998000:92 1094000:83 1152000:99 1209000:100"
	set_param_all min_sample_time 0
	set_param_all ignore_hispeed_on_notif 0
	set_param_all boost 0
	set_param_all fast_ramp_down 0
	set_param_all align_windows 0
	set_param_all use_migration_notif 1
	set_param_all use_sched_load 0
	set_param_all max_freq_hysteresis 0
	set_param_all boostpulse_duration 0
	elif [ ${PROFILE} -eq 2 ];then
	set_param_all go_hispeed_load 99
	set_param_all above_hispeed_delay "0 998000:25000 1152000:41000 1209000:55000"
	set_param_all timer_rate 60000
	set_param_all hispeed_freq 1094000
	set_param_all timer_slack 480000
	set_param_all target_loads "80 400000:68 553000:82 800000:72 998000:92 1094000:83 1152000:99 1209000:100"
	set_param_all min_sample_time 0
	set_param_all ignore_hispeed_on_notif 0
	set_param_all boost 0
	set_param_all fast_ramp_down 0
	set_param_all align_windows 0
	set_param_all use_migration_notif 1
	set_param_all use_sched_load 0
	set_param_all max_freq_hysteresis 0
	set_param_all boostpulse_duration 0
   	elif [ ${PROFILE} -eq 3 ];then
	MSG=1
fi
esac
case ${SOC} in msm8937*)  #sd430 series by @cjybyjk
	if [ ${PROFILE} -eq 0 ];then
	MSG=1
	elif [ ${PROFILE} -eq 1 ];then
	set_param cpu0 go_hispeed_load 99
	set_param cpu0 above_hispeed_delay "20000 960000:50000 1094000:150000"
	set_param cpu0 timer_rate 20000
	set_param cpu0 hispeed_freq 960000
	set_param cpu0 timer_slack 80000
	set_param cpu0 target_loads "98 768000:75 960000:95 1094000:40 1209000:80 1344000:99"
	set_param cpu0 min_sample_time 50000
	set_param cpu0 boost 0
	set_param cpu0 boostpulse_duration 80000
	set_param cpu${bcores} go_hispeed_load 99
	set_param cpu${bcores} above_hispeed_delay "20000 998000:60000 1094000:150000"
	set_param cpu${bcores} timer_rate 20000
	set_param cpu${bcores} hispeed_freq 998000
	set_param cpu${bcores} timer_slack 80000
	set_param cpu${bcores} target_loads "98 902000:75 998000:95 1094000:99"
	set_param cpu${bcores} min_sample_time 50000
	set_param cpu${bcores} boost 0
	set_param cpu${bcores} boostpulse_duration 80000
	elif [ ${PROFILE} -eq 2 ];then
	MSG=1
   	elif [ ${PROFILE} -eq 3 ];then
	MSG=1
fi
esac
case ${SOC} in msm8940*)  #sd435 series by @cjybyjk
	if [ ${PROFILE} -eq 0 ];then
	MSG=1
	elif [ ${PROFILE} -eq 1 ];then
	set_param cpu0 go_hispeed_load 110
	set_param cpu0 above_hispeed_delay 20000
	set_param cpu0 timer_rate 60000
	set_param cpu0 hispeed_freq 902000
	set_param cpu0 timer_slack 380000
	set_param cpu0 target_loads "85 768000:70 902000:82 998000:84 1094000:82"
	set_param cpu0 min_sample_time 0
	set_param cpu0 ignore_hispeed_on_notif 0
	set_param cpu0 boost 0
	set_param cpu0 fast_ramp_down 0
	set_param cpu0 align_windows 0
	set_param cpu0 use_migration_notif 1
	set_param cpu0 use_sched_load 1
	set_param cpu0 max_freq_hysteresis 0
	set_param cpu0 boostpulse_duration 0
	set_param cpu${bcores} go_hispeed_load 110
	set_param cpu${bcores} above_hispeed_delay 20000
	set_param cpu${bcores} timer_rate 60000
	set_param cpu${bcores} hispeed_freq 1094000
	set_param cpu${bcores} timer_slack 380000
	set_param cpu${bcores} target_loads "85 960000:70 1094000:82 1209000:84 1248000:82"
	set_param cpu${bcores} min_sample_time 0
	set_param cpu${bcores} ignore_hispeed_on_notif 0
	set_param cpu${bcores} boost 0
	set_param cpu${bcores} fast_ramp_down 0
	set_param cpu${bcores} align_windows 0
	set_param cpu${bcores} use_migration_notif 1
	set_param cpu${bcores} use_sched_load 1
	set_param cpu${bcores} max_freq_hysteresis 0
	set_param cpu${bcores} boostpulse_duration 0
	elif [ ${PROFILE} -eq 2 ];then
	MSG=1
   	elif [ ${PROFILE} -eq 3 ];then
	MSG=1
fi
esac
case ${SOC} in sdm450*)  #sd450 series by @cjybyjk
	if [ ${PROFILE} -eq 0 ];then
	MSG=1
	elif [ ${PROFILE} -eq 1 ];then
	set_param cpu${bcores} hispeed_freq 1401000
	set_param cpu0 hispeed_freq 1036000
	set_param cpu${bcores} above_hispeed_delay "20000 1401000:60000 1689000:150000"
	set_param cpu0 above_hispeed_delay "20000 1036000:60000 1401000:150000"
	set_param cpu${bcores} target_loads "98 1036000:80 1209000:95 1401000:99"
	set_param cpu0 target_loads "98 652000:80 1036000:95 1401000:99"
	set_param_all min_sample_time 24000
	set_param_all use_sched_load 1
	set_param_all use_migration_notif 1
	set_param_all go_hispeed_load 99
	elif [ ${PROFILE} -eq 2 ];then
	MSG=1
   	elif [ ${PROFILE} -eq 3 ];then
	MSG=1
fi
esac
case ${SOC} in mt6755*)  #mtk6755 series by @cjybyjk
	setprop ro.mtk_perfservice_support 0
	set_value 0 "/proc/sys/kernel/sched_tunable_scaling"
	set_value 0 "/proc/ppm/policy/hica_is_limit_big_freq"
	set_value 10000 "/dev/cpuctl/bg_non_interactive/cpu.rt_runtime_us"
	if [ ${PROFILE} -eq 0 ];then
	MSG=1
	elif [ ${PROFILE} -eq 1 ];then
	set_param cpu0 go_hispeed_load 99
	set_param cpu0 above_hispeed_delay "0 689000:61000 871000:65000 1014000:71000 1144000:75000"
	set_param cpu0 timer_rate 60000
	set_param cpu0 hispeed_freq 689000
	set_param cpu0 timer_slack 480000
	set_param cpu0 target_loads "98 338000:68 494000:82 598000:72 689000:92 871000:83 1014000:99 1144000:100"
	set_param cpu0 min_sample_time 0
	set_param cpu0 ignore_hispeed_on_notif 0
	set_param cpu0 boost 0
	set_param cpu0 fast_ramp_down 0
	set_param cpu0 align_windows 0
	set_param cpu0 use_migration_notif 1
	set_param cpu0 use_sched_load 0
	set_param cpu0 max_freq_hysteresis 0
	set_param cpu0 boostpulse_duration 0
	set_param cpu0 io_is_busy 0
	set_param cpu${bcores} go_hispeed_load 99
	set_param cpu${bcores} above_hispeed_delay "20000 1027000:60000 1196000:150000"
	set_param cpu${bcores} timer_rate 20000
	set_param cpu${bcores} hispeed_freq 663000
	set_param cpu${bcores} timer_slack 80000
	set_param cpu${bcores} target_loads "98 663000:40 1027000:80 1196000:95 1573000:75 1755000:99 1950000:100"
	set_param cpu${bcores} min_sample_time 50000
	set_param cpu${bcores} ignore_hispeed_on_notif 0
	set_param cpu${bcores} boost 0
	set_param cpu${bcores} fast_ramp_down 0
	set_param cpu${bcores} align_windows 0
	set_param cpu${bcores} use_migration_notif 1
	set_param cpu${bcores} use_sched_load 0
	set_param cpu${bcores} max_freq_hysteresis 0
	set_param cpu${bcores} boostpulse_duration 80000
	set_param cpu${bcores} io_is_busy 0
	elif [ ${PROFILE} -eq 2 ];then
	set_param cpu0 go_hispeed_load 99
	set_param cpu0 above_hispeed_delay "0 689000:41000 871000:45000 1014000:51000 1144000:55000"
	set_param cpu0 timer_rate 60000
	set_param cpu0 hispeed_freq 1014000
	set_param cpu0 timer_slack 480000
	set_param cpu0 target_loads "80 338000:68 494000:82 598000:72 689000:92 871000:83 1014000:99 1144000:100"
	set_param cpu0 min_sample_time 0
	set_param cpu0 ignore_hispeed_on_notif 0
	set_param cpu0 boost 0
	set_param cpu0 fast_ramp_down 0
	set_param cpu0 align_windows 0
	set_param cpu0 use_migration_notif 1
	set_param cpu0 use_sched_load 0
	set_param cpu0 max_freq_hysteresis 0
	set_param cpu0 boostpulse_duration 0
	set_param cpu0 io_is_busy 0
	set_param cpu${bcores} go_hispeed_load 99
	set_param cpu${bcores} above_hispeed_delay "20000 1027000:60000 1196000:150000"
	set_param cpu${bcores} timer_rate 20000
	set_param cpu${bcores} hispeed_freq 663000
	set_param cpu${bcores} timer_slack 80000
	set_param cpu${bcores} target_loads "98 663000:40 1027000:80 1196000:95 1573000:75 1755000:99 1950000:100"
	set_param cpu${bcores} min_sample_time 50000
	set_param cpu${bcores} ignore_hispeed_on_notif 0
	set_param cpu${bcores} boost 0
	set_param cpu${bcores} fast_ramp_down 0
	set_param cpu${bcores} align_windows 0
	set_param cpu${bcores} use_migration_notif 1
	set_param cpu${bcores} use_sched_load 0
	set_param cpu${bcores} max_freq_hysteresis 0
	set_param cpu${bcores} boostpulse_duration 80000
	set_param cpu${bcores} io_is_busy 0
   	elif [ ${PROFILE} -eq 3 ];then
	MSG=1
   	fi
   	esac
	after_modify
fi
# =========
# HMP Scheduler Tweaks
# =========
	
    if [ ${snapdragon} -eq 1 ];then
	set_param_HMP sched_spill_load 90
	set_param_HMP sched_init_task_load 40
	set_param_HMP sched_freq_inc_notify 3000000
	#set_param_HMP sched_ravg_hist_size 5
	set_param_HMP sched_boost 0
	fi
	
    # Enable thermal & BCL core_control now
	if [ -f "/sys/module/msm_thermal/core_control/enabled" ]; then
    write /sys/module/msm_thermal/core_control/enabled "1"
    # Choose Hotplug, all others must be set to 0
    write /sys/kernel/intelli_plug/intelli_plug_active "0"
    write /sys/module/blu_plug/parameters/enabled "0"
    write /sys/devices/virtual/misc/mako_hotplug_control/enabled "0"
    write /sys/module/autosmp/parameters/enabled "0"
    write /sys/kernel/zen_decision/enabled "0"
	elif [ -f "/sys/module/msm_thermal/parameters/enabled" ]; then
    write /sys/module/msm_thermal/parameters/enabled "Y"
	elif [ -f "/sys/power/cpuhotplug/enabled" ]; then
	set_value 1 /sys/power/cpuhotplug/enabled
	elif [ -f "/sys/devices/system/cpu/cpuhotplug/enabled" ]; then
	set_value 1 /sys/devices/system/cpu/cpuhotplug/enabled
	fi
	
    for mode in /sys/devices/soc.0/qcom,bcl.*/mode
    do
        echo -n disable > $mode
    done
    for hotplug_mask in /sys/devices/soc.0/qcom,bcl.*/hotplug_mask
    do
        echo $bcl_hotplug_mask > $hotplug_mask
    done
    for hotplug_soc_mask in /sys/devices/soc.0/qcom,bcl.*/hotplug_soc_mask
    do
        echo $bcl_soc_hotplug_mask > $hotplug_soc_mask
    done
    for mode in /sys/devices/soc.0/qcom,bcl.*/mode
    do
        echo -n enable > $mode
    done
	
    # Enable all low power modes
    # write /sys/module/lpm_levels/parameters/sleep_disabled "N" 2>/dev/null  # pass not causing lag

}

# =========
# CPU Governor Tuning
# =========
stop "thermald"
stop "thermal-engine"
stop "thermal-hal-1-0"
stop "mpdecision"
if [ $support -eq 1 ];then
    LOGDATA "#  [✓] SOC CHECK SUCCEEDED"
    cputuning
elif [ $support -eq 2 ];then
    LOGDATA "#  [✓] SOC CHECK SUCCEEDED"
    LOGDATA "#  [INFO] THIS DEVICE IS PARTIALLY SUPPORTED BY Strm"
    cputuning
else
    LOGDATA "#  [×] SOC CHECK FAILED"
    LOGDATA "#  [INFO] THIS DEVICE IS UNSUPPORTED BY Strm"
fi
start "thermald"
start "thermal-engine"
start "thermal-hal-1-0"
start "mpdecision"
# Disable KSM to save CPU cycles
if [ -e '/sys/kernel/mm/uksm/run' ]; then
LOGDATA "#  [INFO] DISABLING uKSM"
write '/sys/kernel/mm/uksm/run' 0;
setprop ro.config.uksm.support false;
elif [ -e '/sys/kernel/mm/ksm/run' ]; then
LOGDATA "#  [INFO] DISABLING KSM"
write '/sys/kernel/mm/ksm/run' 0;
setprop ro.config.ksm.support false;
fi;
if [ -e '/sys/kernel/fp_boost/enabled' ]; then
write '/sys/kernel/fp_boost/enabled' 1;
LOGDATA "#  [INFO] ENABLING FINGER PRINT BOOST"
fi;
# =========
# GPU Tweaks
# =========
if [ -e "/sys/module/adreno_idler" ]; then

	if [ ${PROFILE} -eq 0 ];then
	LOGDATA "#  [INFO] ENABLING GPU ADRENO IDLER " 
	write /sys/module/adreno_idler/parameters/adreno_idler_active "Y"
	write /sys/module/adreno_idler/parameters/adreno_idler_idleworkload "10000"
	write /sys/module/adreno_idler/parameters/adreno_idler_downdifferential '40'
	write /sys/module/adreno_idler/parameters/adreno_idler_idlewait '24'
	else
	LOGDATA "#  [INFO] ENABLING GPU ADRENO IDLER " 
	write /sys/module/adreno_idler/parameters/adreno_idler_active "Y"
	write /sys/module/adreno_idler/parameters/adreno_idler_idleworkload "6000"
	write /sys/module/adreno_idler/parameters/adreno_idler_downdifferential '15'
	write /sys/module/adreno_idler/parameters/adreno_idler_idlewait '15'
	fi
	
fi
# Various GPU enhancements
if [ ${GPU_MAX} -eq 0 ] || [ -z ${GPU_MODEL} ] ;then
GPU_PWR=$(cat $GPU_DIR/num_pwrlevels) 2>/dev/null
GPU_PWR=$(($GPU_PWR-1))
GPU_BATT=$(awk -v x=$GPU_PWR 'BEGIN{print((x/2)-0.5)}')
GPU_BATT=$(round ${GPU_BATT} 0)
GPU_TURBO=$(awk -v x=$GPU_PWR 'BEGIN{print((x/2)+0.5)}')
GPU_TURBO=$(round ${GPU_TURBO} 0)
gpu_idle=$(cat /data/adb/idle_timer.txt) 2>/dev/null
idle_batt=$(awk -v x=$gpu_idle 'BEGIN{print x*2}')
idle_balc=$(awk -v x=$gpu_idle 'BEGIN{print (x*3)/4}')
idle_perf=$(awk -v x=$gpu_idle 'BEGIN{print x/2}')
gpu_nap=$(cat /data/adb/deep_nap_timer.txt) 2>/dev/null
nap_batt=$(awk -v x=$gpu_nap 'BEGIN{print x*2}')
nap_balc=$(awk -v x=$gpu_nap 'BEGIN{print (x*3)/4}')
nap_perf=$(awk -v x=$gpu_nap 'BEGIN{print x/2}')
idle_batt=$(round ${idle_batt} 0)
idle_balc=$(round ${idle_balc} 0)
idle_perf=$(round ${idle_perf} 0)
nap_batt=$(round ${nap_batt} 0)
nap_balc=$(round ${nap_balc} 0)
nap_perf=$(round ${nap_perf} 0)
#if [[ "$GPU_GOV" == *"simple_ondemand"* ]]; then
#write "$GPU_DIR/devfreq/governor" "simple_ondemand"
#fi
set_value $GPU_MAX "$GPU_DIR/max_gpuclk"
set_value $GPU_MAX "$GPU_DIR/devfreq/max_freq" 
set_value $GPU_MIN "$GPU_DIR/devfreq/min_freq" 
set_value $GPU_MIN "$GPU_DIR/devfreq/target_freq" 

set_value 0 "$GPU_DIR/throttling"
set_value 0 "$GPU_DIR/force_no_nap"
set_value 1 "$GPU_DIR/bus_split"
set_value 0 "$GPU_DIR/force_bus_on"
set_value 0 "$GPU_DIR/force_clk_on"
set_value 0 "$GPU_DIR/force_rail_on"
write "/proc/gpufreq/gpufreq_limited_thermal_ignore" 1
write "/proc/mali/dvfs_enable" 1

	if [ ${PROFILE} -eq 0 ];then
set_value $GPU_BATT "$GPU_DIR/max_pwrlevel"
set_value $GPU_PWR "$GPU_DIR/min_pwrlevel"
set_value 0 "$GPU_DIR/force_no_nap"
#set_value $nap_batt "$GPU_DIR/deep_nap_timer"
#set_value $idle_batt "$GPU_DIR/idle_timer"
chmod 0644 "/sys/devices/14ac0000.mali/dvfs"
chmod 0644 "/sys/devices/14ac0000.mali/dvfs_max_lock"
chmod 0644 "/sys/devices/14ac0000.mali/dvfs_min_lock"
	elif [ ${PROFILE} -eq 1 ];then
set_value 0 "$GPU_DIR/max_pwrlevel"
set_value $GPU_PWR "$GPU_DIR/min_pwrlevel"
set_value 0 "$GPU_DIR/force_no_nap"
#set_value $idle_balc "$GPU_DIR/deep_nap_timer"
#set_value $nap_balc "$GPU_DIR/idle_timer"
	elif [ ${PROFILE} -eq 2 ];then
set_value 0 "$GPU_DIR/max_pwrlevel"
set_value$GPU_PWR "$GPU_DIR/min_pwrlevel"
set_value 1 "$GPU_DIR/force_no_nap"
#set_value $nap_perf "$GPU_DIR/deep_nap_timer"
#set_value $idle_perf "$GPU_DIR/idle_timer" 
	elif [ ${PROFILE} -eq 3 ];then
set_value 0 "$GPU_DIR/max_pwrlevel"
set_value $GPU_TURBO "$GPU_DIR/min_pwrlevel"
set_value 1 "$GPU_DIR/force_no_nap"
set_value 0 "$GPU_DIR/bus_split"
set_value 1 "$GPU_DIR/force_bus_on"
set_value 1 "$GPU_DIR/force_clk_on"
set_value 1 "$GPU_DIR/force_rail_on"
#set_value $nap_perf "$GPU_DIR/deep_nap_timer"
#set_value $idle_perf  "$GPU_DIR/idle_timer" 
	fi
	
for i in ${GPU_DIR}/devfreq/*
do
chmod 0644 $i
done
for i in ${GPU_DIR}/*
do
chmod 0644 $i
done
fi
# =========
# RAM TWEAKS
# =========
ramtuning
# =========
# I/O TWEAKS
# =========
LOGDATA "#  [INFO] CONFIGURING STORAGE I/O SCHEDULER " 
if [ -d /sys/block/dm-0 ] || [ -d /sys/devices/virtual/block/dm-0 ]; then
if [ -e /sys/devices/virtual/block/dm-0/queue/scheduler ]; then
    DM_PATH=/sys/devices/virtual/block/dm-0/queue
fi
if [ -e /sys/block/dm-0/queue/scheduler ]; then
    DM_PATH=/sys/block/dm-0/queue
fi
sch=$(</sys/devices/virtual/block/dm-0/queue/scheduler);
if [[ $sch == *"maple"* ]]; then
   if [ -e $DM_PATH/scheduler_hard ]; then
   write $DM_PATH/scheduler_hard "maple"
   fi
   write $DM_PATH/scheduler "maple"
   sleep 2
   write $DM_PATH/iosched/async_read_expire 666;
   write $DM_PATH/iosched/async_write_expire 1666;
   write $DM_PATH/iosched/fifo_batch 16;
   write $DM_PATH/iosched/sleep_latency_multiple 5;
   write $DM_PATH/iosched/sync_read_expire 333;
   write $DM_PATH/iosched/sync_write_expire 1166;
   write $DM_PATH/iosched/writes_starved 3;
   write $DM_PATH/iosched/read_ahead_kb 128;
if [ -e "/sys/devices/virtual/block/dm-0/bdi/read_ahead_kb" ]; then
   if [ ${PROFILE} -ge 2 ];then
   write /sys/devices/virtual/block/dm-0/bdi/read_ahead_kb 2048
   else
   write /sys/devices/virtual/block/dm-0/bdi/read_ahead_kb 128
   fi
fi

if [ -e "/sys/block/sda/bdi/read_ahead_kb" ]; then
   if [ ${PROFILE} -ge 2 ];then
   write /sys/block/sda/bdi/read_ahead_kb 2048
   else
   write /sys/block/sda/bdi/read_ahead_kb 128
   fi
fi
else
if [[ $sch == *"cfq"* ]]; then
   if [ -e $DM_PATH/scheduler_hard ]; then
   write $DM_PATH/scheduler_hard "cfq"
   fi
   write $DM_PATH/scheduler "cfq"
   write $DM_PATH/iosched/low_latency 0;
   write $DM_PATH/iosched/slice_idle 0;
   write $DM_PATH/iosched/group_idle 8;
   
if [ -e "/sys/devices/virtual/block/dm-0/bdi/read_ahead_kb" ]; then
   if [ ${PROFILE} -ge 2 ];then
   write /sys/devices/virtual/block/dm-0/bdi/read_ahead_kb 512
   else
   write /sys/devices/virtual/block/dm-0/bdi/read_ahead_kb 128
   fi
fi

if [ -e "/sys/block/sda/bdi/read_ahead_kb" ]; then
   if [ ${PROFILE} -ge 2 ];then
   write /sys/block/sda/bdi/read_ahead_kb 512
   else
   write /sys/block/sda/bdi/read_ahead_kb 128
   fi
fi
fi
fi
	write $DM_PATH/add_random 0
	write $DM_PATH/iostats 0
   	write $DM_PATH/nomerges 2
   	write $DM_PATH/rotational 0
   	write $DM_PATH/rq_affinity 1
fi
sch=$(</sys/block/sda/queue/scheduler);
if [[ $sch == *"maple"* ]]; then
	for i in /sys/block/*; do
	    set_io maple $i;
	done;
	set_io maple /sys/block/mmcblk0
	set_io maple /sys/block/sda
	else
	if [[ $sch == *"cfq"* ]]; then
	for i in /sys/block/*; do
	    set_io cfq $i;
	done;
	set_io cfq /sys/block/mmcblk0
	set_io cfq /sys/block/sda
	fi
fi
for i in /sys/block/*; do
	write $i/queue/add_random 0
	write $i/queue/iostats 0
   	write $i/queue/nomerges 2
   	write $i/queue/rotational 0
   	write $i/queue/rq_affinity 1
done;

# =========
# REDUCE DEBUGGING
# =========
logdata "#  [INFO] CUTTING EXCESSIVE KERNEL DEBUGGING " 
#write "/sys/module/wakelock/parameters/debug_mask" 0
#write "/sys/module/userwakelock/parameters/debug_mask" 0
write "/sys/module/earlysuspend/parameters/debug_mask" 0
write "/sys/module/alarm/parameters/debug_mask" 0
write "/sys/module/alarm_dev/parameters/debug_mask" 0
write "/sys/module/binder/parameters/debug_mask" 0
write "/sys/devices/system/edac/cpu/log_ce" 0
write "/sys/devices/system/edac/cpu/log_ue" 0
write "/sys/module/binder/parameters/debug_mask" 0
write "/sys/module/bluetooth/parameters/disable_ertm" "Y"
write "/sys/module/bluetooth/parameters/disable_esco" "Y"
write "/sys/module/debug/parameters/enable_event_log" 0
write "/sys/module/dwc3/parameters/ep_addr_rxdbg_mask" 0 
write "/sys/module/dwc3/parameters/ep_addr_txdbg_mask" 0
write "/sys/module/edac_core/parameters/edac_mc_log_ce" 0
write "/sys/module/edac_core/parameters/edac_mc_log_ue" 0
write "/sys/module/glink/parameters/debug_mask" 0
write "/sys/module/hid_apple/parameters/fnmode" 0
write "/sys/module/hid_magicmouse/parameters/emulate_3button" "N"
write "/sys/module/hid_magicmouse/parameters/emulate_scroll_wheel" "N"
write "/sys/module/ip6_tunnel/parameters/log_ecn_error" "N"
write "/sys/module/lowmemorykiller/parameters/debug_level" 0
write "/sys/module/mdss_fb/parameters/backlight_dimmer" "N"
write "/sys/module/msm_show_resume_irq/parameters/debug_mask" 0
write "/sys/module/msm_smd/parameters/debug_mask" 0
write "/sys/module/msm_smem/parameters/debug_mask" 0 
write "/sys/module/otg_wakelock/parameters/enabled" "N" 
write "/sys/module/service_locator/parameters/enable" 0 
write "/sys/module/sit/parameters/log_ecn_error" "N"
write "/sys/module/smem_log/parameters/log_enable" 0
write "/sys/module/smp2p/parameters/debug_mask" 0
write "/sys/module/sync/parameters/fsync_enabled" "N"
write "/sys/module/touch_core_base/parameters/debug_mask" 0
write "/sys/module/usb_bam/parameters/enable_event_log" 0
write "/sys/module/printk/parameters/console_suspend" "Y"
write "/proc/sys/debug/exception-trace" 0
write "/proc/sys/kernel/printk" "0 0 0 0"
write "/proc/sys/kernel/compat-log" "0"
sysctl -e -w kernel.panic_on_oops=0
sysctl -e -w kernel.panic=0
if [ -e /sys/module/logger/parameters/log_mode ]; then
 write /sys/module/logger/parameters/log_mode 2
fi;
if [ -e /sys/module/printk/parameters/console_suspend ]; then
 write /sys/module/printk/parameters/console_suspend 'Y'
fi;
for i in $(find /sys/ -name debug_mask); do
 write $i 0;
done
for i in $(find /sys/ -name debug_level); do
 write $i 0;
done
for i in $(find /sys/ -name edac_mc_log_ce); do
 write $i 0;
done
for i in $(find /sys/ -name edac_mc_log_ue); do
 write $i 0;
done
for i in $(find /sys/ -name enable_event_log); do
 write $i 0;
done
for i in $(find /sys/ -name log_ecn_error); do
 write $i 0;
done
for i in $(find /sys/ -name snapshot_crashdumper); do
 write $i 0;
done
# =========
# FIX DEEPSLEEP
# =========
for i in $(ls /sys/class/scsi_disk/); do
 set_value 'temporary none' '/sys/class/scsi_disk/$i/cache_type';
done;
# =========
# TCP TWEAKS
# =========
algos=$(</proc/sys/net/ipv4/tcp_available_congestion_control);
if [[ $algos == *"westwood"* ]]
then
write /proc/sys/net/ipv4/tcp_congestion_control "westwood"
LOGDATA "#  [INFO] ENABLING WESTWOOD TCP ALGORITHM  " 
else
write /proc/sys/net/ipv4/tcp_congestion_control "cubic"
fi
# Increase WI-FI scan delay
# sqlite=/system/xbin/sqlite3 wifi_idle_wait=36000 
# =========
# Blocking Wakelocks
# =========
WK=0
if [ -e "/sys/module/bcmdhd/parameters/wlrx_divide" ]; then
write /sys/module/bcmdhd/parameters/wlrx_divide "8"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/bcmdhd/parameters/wlctrl_divide" ]; then
write /sys/module/bcmdhd/parameters/wlctrl_divide "8"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/wakeup/parameters/enable_bluetooth_timer" ]; then
write /sys/module/wakeup/parameters/enable_bluetooth_timer "Y"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/wakeup/parameters/enable_wlan_ipa_ws" ]; then
write /sys/module/wakeup/parameters/enable_wlan_ipa_ws "N"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/wakeup/parameters/enable_wlan_pno_wl_ws" ]; then
write /sys/module/wakeup/parameters/enable_wlan_pno_wl_ws "N"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/wakeup/parameters/enable_wcnss_filter_lock_ws" ]; then
write /sys/module/wakeup/parameters/enable_wcnss_filter_lock_ws "N"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/wakeup/parameters/wlan_wake" ]; then
write /sys/module/wakeup/parameters/wlan_wake "N"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/wakeup/parameters/wlan_ctrl_wake" ]; then
write /sys/module/wakeup/parameters/wlan_ctrl_wake "N"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/wakeup/parameters/wlan_rx_wake" ]; then
write /sys/module/wakeup/parameters/wlan_rx_wake "N"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/wakeup/parameters/enable_msm_hsic_ws" ]; then
write /sys/module/wakeup/parameters/enable_msm_hsic_ws "N"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/wakeup/parameters/enable_si_ws" ]; then
write /sys/module/wakeup/parameters/enable_si_ws "N"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/wakeup/parameters/enable_si_ws" ]; then
write /sys/module/wakeup/parameters/enable_si_ws "N"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/wakeup/parameters/enable_bluedroid_timer_ws" ]; then
write /sys/module/wakeup/parameters/enable_bluedroid_timer_ws "N"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/wakeup/parameters/enable_ipa_ws" ]; then
write /sys/module/wakeup/parameters/enable_ipa_ws "N"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/wakeup/parameters/enable_netlink_ws" ]; then
write /sys/module/wakeup/parameters/enable_netlink_ws "N"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/wakeup/parameters/enable_netmgr_wl_ws" ]; then
write /sys/module/wakeup/parameters/enable_netmgr_wl_ws "N"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/wakeup/parameters/enable_qcom_rx_wakelock_ws" ]; then
write /sys/module/wakeup/parameters/enable_qcom_rx_wakelock_ws "N"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/wakeup/parameters/enable_timerfd_ws" ]; then
write /sys/module/wakeup/parameters/enable_timerfd_ws "N"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/wakeup/parameters/enable_wlan_extscan_wl_ws" ]; then
write /sys/module/wakeup/parameters/enable_wlan_extscan_wl_ws "N"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/wakeup/parameters/enable_wlan_rx_wake_ws" ]; then
write /sys/module/wakeup/parameters/enable_wlan_rx_wake_ws "N"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/wakeup/parameters/enable_wlan_wake_ws" ]; then
write /sys/module/wakeup/parameters/enable_wlan_wake_ws "N"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/wakeup/parameters/enable_wlan_wow_wl_ws" ]; then
write /sys/module/wakeup/parameters/enable_wlan_wow_wl_ws "N"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/wakeup/parameters/enable_wlan_ws" ]; then
write /sys/module/wakeup/parameters/enable_wlan_ws "N"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/wakeup/parameters/enable_wlan_ctrl_wake_ws" ]; then
write /sys/module/wakeup/parameters/enable_wlan_ctrl_wake_ws "N"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/smb135x_charger/parameters/use_wlock" ]; then
write /sys/module/smb135x_charger/parameters/use_wlock "N"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/wakeup/parameters/enable_smb135x_wake_ws" ]; then
write /sys/module/wakeup/parameters/enable_smb135x_wake_ws "N"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/wakeup/parameters/enable_si_ws" ]; then
write /sys/module/wakeup/parameters/enable_si_wsk "N"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/wakeup/parameters/enable_bluesleep_ws" ]; then
write /sys/module/wakeup/parameters/enable_bluesleep_ws "N"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/bcmdhd/parameters/wlrx_divide" ]; then
write /sys/module/bcmdhd/parameters/wlrx_divide "N"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/bcmdhd/parameters/wlctrl_divide" ]; then
write /sys/module/bcmdhd/parameters/wlctrl_divide "N"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/xhci_hcd/parameters/wl_divide" ]; then
write /sys/module/xhci_hcd/parameters/wl_divide "N"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/smb135x_charger/parameters/use_wlock" ]; then
write /sys/module/smb135x_charger/parameters/use_wlock "N"
WK=$(( ${WK} + 1 ))
fi
if [ ${WK} -gt 0 ] ;then
LOGDATA "#  [INFO] BLOCKING ${WK} DETECTED KERNEL WAKELOCKS"
fi
if [ -e "/sys/class/misc/boeffla_wakelock_blocker/wakelock_blocker" ]; then
LOGDATA "#  [INFO] ENABLING BOEFFLA WAKELOCK BLOCKER "
write /sys/class/misc/boeffla_wakelock_blocker/wakelock_blocker "wlan_pno_wl;wlan_ipa;wcnss_filter_lock;[timerfd];hal_bluetooth_lock;IPA_WS;sensor_ind;wlan;netmgr_wl;qcom_rx_wakelock;wlan_wow_wl;wlan_extscan_wl;NETLINK"
fi
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
LOGDATA "#  BATTERY TEMP: $BATT_TEMP °C"
LOGDATA "#  BATTERY VOLTAGE: $BATT_VOLT VOLTS "
LOGDATA "# =================================" 
LOGDATA "#  FINISHED : $(date +"%d-%m-%Y %r")"


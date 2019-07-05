#========================================
# Strm Turbo
# Codename : Strm
# Source source Strm
# Version : 101
# Developer : @chengfu
Date=2019-7-6
#========================================
# 设置介绍
## 模式吖 ( mode.prop )
# 0 = 均衡模式
# 1 = 性能模式
# 2 = Turbo(涡轮模式)
# 3 = 省电模式
## ZRAM 开启与关闭 ( comp.prop )
# 0 = 自动
# 1 = 开启
# 2 = 关闭
## Swap优化 ( swap.prop )
# 0 = 优化
# 1 = 停用
# PATH LOG =========================================#

Path=/data
if [ ! -d $Path/Strm ]; then
 ST=Clean
 mkdir -p $Path/Strm
fi;
Strm=$Path/Strm
LOG=/$Strm/Strm.prop
V=6.5
S=Stable
Code=Archer
#CodeT=**
box=$(busybox | awk 'NR==1{print $2}') 2>/dev/null
MEM=$(free -m | awk '/Mem:/{print $2}') 2>/dev/null
mem=$(free | grep Mem |  awk '{print $2}') 2>/dev/null
VENDOR=$(getprop ro.product.brand) 2>/dev/null
ROM=$(getprop ro.build.display.id) 2>/dev/null
KERNEL=$(uname -r) 2>/dev/null
APP=$(getprop ro.product.model) 2>/dev/null
SDK=$(getprop ro.build.version.sdk) 2>/dev/null
ROOT=$(magisk -c) 2>/dev/null
CHIP=$(getprop ro.product.board) 2>/dev/null
CHIP1=$(getprop ro.product.platform) 2>/dev/null
CHIP2=$(getprop ro.board.platform) 2>/dev/null

if [ ! "$CHIP" = "" ]; then
 SOC=$(getprop ro.product.board) 2>/dev/null
elif [ ! "$CHIP1" = "" ]; then
 SOC=$(getprop ro.product.platform) 2>/dev/null
elif [ ! "$CHIP2" = "" ]; then
 SOC=$(getprop ro.board.platform) 2>/dev/null
else
 SOC=Unidentified_Soc
fi;

BATT=$(cat /sys/class/power_supply/battery/capacity)

if [ -e /sys/kernel/fast_charge/ac_charge_level ]; then
 if [ -e /sys/class/power_supply/battery/batt_slate_mode ]; then
  echo "0" > /sys/class/power_supply/battery/batt_slate_mode
 fi;
fi;

if [ -d /sbin/.core/img ]; then
 SBIN=/sbin/.core/img
elif [ -d /sbin/.magisk/img ]; then
 SBIN=/sbin/.magisk/img
fi;

 BREAKER() {
 echo "*...您貌似安装了其他优化模块，Strm无法正常运行...*" | tee -a $LOG;exit 1
}

TACC=/proc/sys/net/ipv4/tcp_available_congestion_control
if [ -e /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors ]; then
 AGB=/sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors
elif [ -e /sys/devices/system/cpu/cpu1/cpufreq/scaling_available_governors ]; then
 AGB=/sys/devices/system/cpu/cpu1/cpufreq/scaling_available_governors
fi;
if [ -e /sys/block/mmcblk0/queue/scheduler ]; then
 SA=/sys/block/mmcblk0/queue/scheduler
elif [ -e /sys/block/sda/queue/scheduler ]; then
 SA=/sys/block/sda/queue/scheduler
elif [ -d /sys/block/dm-0/queue/scheduler ]; then
 SA=/sys/block/dm-0/queue/scheduler
elif [ -d /sys/block/loop0/queue/scheduler ]; then
 SA=/sys/block/loop0/queue/scheduler
fi;

if grep 'blu_schedutil' $AGB; then
 eas=1
elif grep 'sched' $AGB; then
 eas=1
elif grep 'pwrutil' $AGB; then
eas=1
elif grep 'darkutil' $AGB; then
 eas=1
elif grep 'schedutil' $AGB; then
eas=1
elif grep 'helix' $AGB; then
 eas=1
elif grep 'schedalucard' $AGB; then
 eas=1
elif grep 'electroutil' $AGB; then
 eas=1
else
 eas=0
fi;

battcheckgov() {
if grep 'blu_schedutil' $AGB; then
 gov=blu_schedutil
elif grep 'zzmoove' $AGB; then
 gov=zzmoove
elif grep 'smurfutil_flex' $AGB; then
 gov=smurfutil_flex
elif grep 'pixutil' $AGB; then
 gov=pixutil
elif grep 'pwrutilx' $AGB; then
 gov=pwrutilx
elif grep 'helix_schedutil' $AGB; then
 gov=helix_schedutil
elif grep 'pixel_schedutil' $AGB; then
 gov=pixel_schedutil
elif grep 'schedutil' $AGB; then
 gov=schedutil
elif grep 'cultivation' $AGB; then 
 gov=cultivation
elif grep 'interactive' $AGB; then
 gov=interactive
elif grep 'interactivepro' $AGB; then
 gov=interactivepro
elif grep 'interactive_pro' $AGB; then
 gov=interactive_pro
elif grep 'interactiveplus' $AGB; then
 gov=interactiveplus
elif grep 'interactivex' $AGB; then
 gov=interactivex
elif grep 'darkness' $AGB; then
 gov=darkness
elif grep 'blu_active' $AGB; then
 gov=blu_active
elif grep 'phantom' $AGB; then
 gov=phantom
elif grep 'elementalx' $AGB; then
 gov=elementalx
elif grep 'ondemand' $AGB; then
 gov=ondemand
elif grep 'performance' $AGB; then
 gov=performance
fi;
}
balcheckgov() {
if grep 'smurfutil_flex' $AGB; then
 gov=smurfutil_flex
elif grep 'pixutil' $AGB; then
 gov=pixutil
elif grep 'pwrutilx' $AGB; then
 gov=pwrutilx
elif grep 'helix_schedutil' $AGB; then
 gov=helix_schedutil
elif grep 'pixel_schedutil' $AGB; then
 gov=pixel_schedutil
elif grep 'schedutil' $AGB; then
 gov=schedutil
elif grep 'cultivation' $AGB; then
 gov=cultivation
elif grep 'interactive' $AGB; then
 gov=interactive
elif grep 'interactivepro' $AGB; then
 gov=interactivepro
elif grep 'interactive_pro' $AGB; then
 gov=interactive_pro
elif grep 'interactiveplus' $AGB; then
 gov=interactiveplus
elif grep 'interactivex' $AGB; then
 gov=interactivex
elif grep 'darkness' $AGB; then
 gov=darkness
elif grep 'elementalx' $AGB; then
 gov=elementalx
elif grep 'blu_active' $AGB; then
 gov=blu_active
elif grep 'phantom' $AGB; then
 gov=phantom
elif grep 'blu_schedutil' $AGB; then
 gov=blu_schedutil
elif grep 'zzmoove' $AGB; then
 gov=zzmoove
elif grep 'ondemand' $AGB; then
 gov=ondemand
elif grep 'performance' $AGB; then
 gov=performance
fi;
}
perfcheckgov() {
if grep 'smurfutil_flex' $AGB; then
 gov=smurfutil_flex
elif grep 'pixutil' $AGB; then
 gov=pixutil
elif grep 'pwrutilx' $AGB; then
 gov=pwrutilx
elif grep 'helix_schedutil' $AGB; then
 gov=helix_schedutil
elif grep 'pixel_schedutil' $AGB; then
 gov=pixel_schedutil
elif grep 'schedutil' $AGB; then
 gov=schedutil
elif grep 'elementalx' $AGB; then
 gov=elementalx
elif grep 'cultivation' $AGB; then
 gov=cultivation
elif grep 'interactive' $AGB; then
 gov=interactive
elif grep 'interactivepro' $AGB; then
 gov=interactivepro
elif grep 'interactive_pro' $AGB; then
 gov=interactive_pro
elif grep 'interactiveplus' $AGB; then
 gov=interactiveplus
elif grep 'interactivex' $AGB; then
 gov=interactivex
elif grep 'darkness' $AGB; then
 gov=darkness
elif grep 'blu_active' $AGB; then
 gov=blu_active
elif grep 'phantom' $AGB; then
 gov=phantom
elif grep 'blu_schedutil' $AGB; then
 gov=blu_schedutil
elif grep 'zzmoove' $AGB; then
 gov=zzmoove
elif grep 'ondemand' $AGB; then
 gov=ondemand
elif grep 'performance' $AGB; then
 gov=performance
fi;
}
battcheckio() {
if grep 'anxiety' $SA; then
 sch=anxiety
elif grep 'maple' $SA; then
 sch=maple
elif grep 'noop' $SA; then
 sch=noop 
elif grep 'fiops' $SA; then
 sch=fiops
elif grep 'sio' $SA; then
 sch=sio
elif grep 'sioplus' $SA; then
 sch=sioplus 
elif grep 'row' $SA; then
 sch=row
elif grep 'zen' $SA; then
 sch=zen
elif grep 'tripndroid' $SA; then
 sch=tripndroid
elif grep 'deadline' $SA; then
 sch=deadline
elif grep 'cfq' $SA; then
 sch=cfq
elif grep 'bfq' $SA; then
 sch=bfq
fi;
}
balcheckio() {
if grep 'zen' $SA; then
 sch=zen
elif grep 'tripndroid' $SA; then
 sch=tripndroid
elif grep 'sio' $SA; then
 sch=sio
elif grep 'cfq' $SA; then
 sch=cfq
elif grep 'bfq' $SA; then
 sch=bfq
elif grep 'sioplus' $SA; then
 sch=sioplus
elif grep 'fiops' $SA; then
 sch=fiops
elif grep 'row' $SA; then
 sch=row
elif grep 'deadline' $SA; then
 sch=deadline
elif grep 'anxiety' $SA; then
 sch=anxiety
elif grep 'maple' $SA; then
 sch=maple
elif grep 'noop' $SA; then
 sch=noop
fi;
}
perfcheckio() {
if grep 'fiops' $SA; then
 sch=fiops
elif grep 'sioplus' $SA; then
 sch=sioplus
elif grep 'sio' $SA; then
 sch=sio
elif grep 'row' $SA; then
 sch=row
elif grep 'deadline' $SA; then
 sch=deadline
elif grep 'zen' $SA; then
 sch=zen
elif grep 'tripndroid' $SA; then
 sch=tripndroid
elif grep 'cfq' $SA; then
 sch=cfq
elif grep 'bfq' $SA; then
 sch=bfq
elif grep 'anxiety' $SA; then
 sch=anxiety
elif grep 'maple' $SA; then
 sch=maple
elif grep 'noop' $SA; then
 sch=noop
fi;
}
if grep -l 'ascarex' $TACC; then
 tcp=ascarex
elif  grep -l 'sociopath' $TACC; then
 tcp=sociopath
elif  grep -l 'westwood' $TACC; then
 tcp=westwood
elif  grep -l 'cubic' $TACC; then
 tcp=cubic
else
 tcp=reno
fi;

# CHECK BREAKER =========================================#

if [ -e $SBIN/legendary_kernel_tweaks ]; then
 IT=LTK
  BREAKER
elif [ -e $SBIN/FDE ]; then
 IT=FDE.AI
 BREAKER
elif [ -e $SBIN/GPUTurboBoost ]; then
 IT=GPUTurbo
 BREAKER
elif [ -e $SYS/bin/L_Speed ]; then
 IT=LSpeed
 BREAKER
elif [ -e $SYS/xbin/killjoy ]; then
 IT=KillJoy
 BREAKER
elif [ -e $SYS/bin/The_Thing ]; then
 IT=TheThing
 BREAKER
elif [ -e $SYS/KITANA/COMMON/KI00Rngd ]; then
 IT=Kitana
 BREAKER
elif [ -e $SYS/xbin/fde ]; then
 IT=FDE
 BREAKER
elif [ -e $SYS/bin/ABS ]; then
 IT=ABS
 BREAKER
elif [ -e $SYS/etc/CrossBreeder/CrossBreeder ]; then
 IT=CrossBeeder
 BREAKER
elif [ -e $SYS/etc/init.d/999fde ]; then
 IT=FDE
 BREAKER
elif [ -e /data/data/com.paget96.lspeed/files/binaries/busybox ]; then
 IT=LSpeedApp
 BREAKER
fi;

# SMART CONTROL  =========================================#

if [ "$MEM" -lt 2048 ]; then
 RAMCAP=0
 level=0
 stage=LowRam
elif [ "$MEM" -lt 2560 ]; then
 RAMCAP=1
 level=1
 stage=Middle_Range
elif [ "$MEM" -lt 3840 ]; then
 RAMCAP=1
 level=2
 stage=Middle_Range
elif [ "$MEM" -lt 5120 ]; then
 RAMCAP=1
 level=3
 stage=High_Ram
elif [ "$MEM" -lt 6400 ]; then
 RAMCAP=1
 level=4
 stage=Flagship
else
 RAMCAP=1
 level=4
 stage=Flagship_Killer
fi;

if [ -d /data/data/com.FDGEntertainment.Oceanhorn.gp ]; then
 play=1
elif [ -d /data/data/com.ironhidegames.android.ironmarines ]; then
 play=1
elif [ -d /data/data/com.ironhidegames.android.kingdomrush4 ]; then
 play=1
elif [ -d /data/data/com.bandainamcoent.dblegends_ww ]; then
 play=1
elif [ -d /data/data/com.ea.games.r3_row ]; then
 play=1
elif [ -d /data/data/com.epicgames.fortnite ]; then
 play=1
elif [ -d /data/data/com.jagex.runescape.android ]; then
 play=1
elif [ -d /data/data/com.nianticlabs.pokemongo ]; then
 play=1
elif [ -d /data/data/com.namcobandaigames.pacmantournaments ]; then
 play=1
elif [ -d /data/data/com.nintendo.zara ]; then
 play=1
elif [ -d /data/data/com.supercell.clashroyale ]; then
 play=1
elif [ -d /data/data/com.supercell.clashofclans ]; then
 play=1
elif [ -d /data/data/jp.konami.pesam ]; then
 play=1
elif [ -d /data/data/com.lilithgame.roc.gp ]; then
 play=1
elif [ -d /data/data/mobi.gameguru.racingfever ]; then
 play=1
elif [ -d /data/data/com.mgs.sniper1 ]; then
 play=1
elif [ -d /data/data/com.nintendo.zaga ]; then
 play=1
elif [ -d /data/data/com.netmarble.revolutionthm ]; then
 play=1
elif [ -d /data/data/com.neowiz.game.koh ]; then
 play=1
elif [ -d /data/data/com.ninjakiwi.bloonstd6 ]; then
 play=1
elif [ -d /data/data/com.dts.freefireth ]; then
 play=1
elif [ -d /data/data/com.robtopx.geometryjump ]; then
 play=1
elif [ -d /data/data/com.t2ksports.nba2k19 ]; then
 play=1
elif [ -d /data/data/com.squareenixmontreal.hitmansniperandroid ]; then
 play=1
elif [ -d /data/data/com.vg.bsm ]; then
 play=1
elif [ -d /data/data/com.nekki.shadowfight3 ]; then
 play=1
elif [ -d /data/data/com.nekki.shadowfight ]; then
 play=1
elif [ -d /data/data/com.ea.game.Strm14_row ]; then
 play=1
elif [ -d /data/data/com.FireproofStudios.TheRoom4 ]; then
 play=1
elif [ -d /data/data/com.netease.lztgglobal ]; then
 play=1
elif [ -d /data/data/com.gameloft.android.ANMP.GloftA9HM ]; then
 play=1
elif [ -d /data/data/com.theonegames.gunshipbattle ]; then
 play=1
elif [ -d /data/data/com.tencent.tmgp.pubgmhd ]; then
 play=1
elif [ -d /data/data/com.tencent.tmgp.pubgm ]; then
 play=1
elif [ -d /data/data/com.tencent.iglite ]; then
 play=1
elif [ -d /data/data/com.pubg.krmobile ]; then
 play=1
elif [ -d /data/data/com.rekoo.pubgm ]; then
 play=1
elif [ -d /data/data/com.tencent.ig ]; then
 play=1
elif [ -d /data/data/com.mobile.legends ]; then
 play=1
else
 play=0
fi;

if [ $level -eq "0" ] && [ $play -eq "0" ]; then
 land=1
elif [ $level -eq "0" ] && [ $play -eq "1" ]; then
 land=2
elif [ $level -eq "1" ] && [ $play -eq "0" ]; then
 land=1
elif [ $level -eq "1" ] && [ $play -eq "1" ]; then
 land=1
elif [ $level -eq "2" ] && [ $play -eq "0" ]; then
 land=0
elif [ $level -eq "2" ] && [ $play -eq "1" ]; then
 land=1
elif [ $level -eq "3" ] && [ $play -eq "0" ]; then
 land=0
elif [ $level -eq "3" ] && [ $play -eq "1" ]; then
 land=0
elif [ $level -eq "4" ] && [ $play -eq "0" ]; then
 land=3
elif [ $level -eq "4" ] && [ $play -eq "1" ]; then
 land=0
fi;

if [ $land -eq "0" ]; then
 balcheckgov
 balcheckio
elif [ $land -eq "1" ]; then
 perfcheckgov
 perfcheckio
elif [ $land -eq "2" ]; then
 perfcheckgov
 perfcheckio
elif [ $land -eq "3" ]; then
 battcheckgov
 battcheckio
fi;

# WAITING TIME =========================================#

if [ -e $LOG ]; then
 rm $LOG;
fi;

while ! pgrep com.android ;
do
 sleep 85
done

# 设置 =========================================#

if [ ! -e $Strm/governor.txt ]; then
 echo "$gov" > $Strm/governor.txt
fi;
if [ ! -e $Strm/scheduler.txt ]; then
 echo "$sch" > $Strm/scheduler.txt
fi;
if [ ! -e $Strm/tcp.prop ]; then
 echo "$tcp" > $Strm/tcp.prop
fi;
if [ ! -e $Strm/mode.prop ]; then
 echo "$land" > $Strm/mode.prop
fi;
if [ ! -e $Strm/swap.txt ]; then
 echo "0" > $Strm/swap.prop
fi;
if [ ! -e $Strm/zram开关.prop ]; then
 echo "0" > $Strm/zram开关.prop
fi;
if [ ! -e $Strm/support.txt ]; then
 SP=$Strm/support.txt
 echo "** GOVERNOR'S AVAILABLE : $(cat $AGB) *" | tee -a $SP;
 echo "" | tee -a $SP;
 echo "** SCHEDULER'S AVAILABLE : $(cat $SA) *" | tee -a $SP;
fi;

# LOGGING =========================================#

echo "================================================" | tee -a $LOG;
echo "Strm™     "|  tee -a $LOG;
echo "AI与优化结合为一体的模块 " |  tee -a $LOG;
echo "模块模式 : $S  " |  tee -a $LOG;
echo "================================================" | tee -a $LOG;
echo " 设置介绍                                " | tee -a $LOG;
echo "## 模式( mode.prop )                     " | tee -a $LOG;
echo "# 0 = 均衡模式                           " | tee -a $LOG;
echo "# 1 = 性能模式                            " | tee -a $LOG;
echo "# 2 = Turbo(涡轮模式)                    " | tee -a $LOG;
echo "# 3 = 省电模式                            " | tee -a $LOG;
echo "## ZRAM 开启与关闭 ( comp.prop )     " | tee -a $LOG;
echo "# 0 = 自动                                 " | tee -a $LOG;
echo "# 1 = 开启                                  " | tee -a $LOG;
echo "# 2 = 关闭                                 " | tee -a $LOG;
echo "## Swap优化 ( swap.prop )                 " | tee -a $LOG;
echo "# 0 = 优化                                 " | tee -a $LOG;
echo "# 1 = 停用                                  " | tee -a $LOG;

echo "" | tee -a $LOG;
echo "** 手机硬件信息 *" | tee -a $LOG;
echo "** 版本 : $VENDOR *" | tee -a $LOG;
echo "** 手机型号 : $APP *" | tee -a $LOG;
echo "** 处理器 : $SOC *" | tee -a $LOG;
echo "** 充电方式 : $stage *" | tee -a $LOG;
echo "** Rom : $ROM *" | tee -a $LOG;
echo "** Root : $ROOT *" | tee -a $LOG;
echo "** 安卓版本 : $(getprop ro.build.version.release) *" | tee -a $LOG;
echo "** Sdk : $SDK *" | tee -a $LOG;
echo "** Kernel : $KERNEL *" | tee -a $LOG;
echo "** Ram : $MEM Mb *" | tee -a $LOG;
echo "** Busybox  : $box *" | tee -a $LOG;
echo "** Battery Level : $BATT % *" | tee -a $LOG;
if [ -d /data/data/com.kerneladiutor.mod ]; then
 echo "** Kernel Adiutor Mod : Installed *" | tee -a $LOG;
fi;
if [ -d /data/data/com.grarak.kerneladiutor ]; then
 echo "** Kernel Adiutor : Installed *" | tee -a $LOG;
fi;
if [ -d /data/data/flar2.exkernelmanager ]; then
 echo "** Ex Kernel : Installed *" | tee -a $LOG;
fi;
if [ -d /data/data/com.FDGEntertainment.Oceanhorn.gp ]; then
 Game=Oceanhorn
 echo "** Game : $Game *" | tee -a $LOG;
fi;
if [ -d /data/data/com.ironhidegames.android.ironmarines ]; then
 Game=IronMarines
 echo "** Game : $Game *" | tee -a $LOG;
fi;
if [ -d /data/data/com.ironhidegames.android.kingdomrush4 ]; then
 Game=KingdomRush
 echo "** Game : $Game *" | tee -a $LOG;
fi;
if [ -d /data/data/com.bandainamcoent.dblegends_ww ]; then
 Game=DbLegend
 echo "** Game : $Game *" | tee -a $LOG;
fi;
if [ -d /data/data/com.ea.games.r3_row ]; then
 Game=RealRacing
 echo "** Game : $Game *" | tee -a $LOG;
fi;
if [ -d /data/data/com.epicgames.fortnite ]; then
 Game=Fortnite
 echo "** Game : $Game *" | tee -a $LOG;
fi;
if [ -d /data/data/com.jagex.runescape.android ]; then
 Game=Runscape
 echo "** Game : $Game *" | tee -a $LOG;
fi;
if [ -d /data/data/com.nianticlabs.pokemongo ]; then
 Game=PokemonGo
 echo "** Game : $Game *" | tee -a $LOG;
fi;
if [ -d /data/data/com.namcobandaigames.pacmantournaments ]; then
 Game=PacMan
 echo "** Game : $Game *" | tee -a $LOG;
fi;
if [ -d /data/data/com.nintendo.zara ]; then
 Game=SuperMarioRun
 echo "** Game : $Game *" | tee -a $LOG;
fi;
if [ -d /data/data/com.supercell.clashroyale ]; then
 Game=ClashRoyale
 echo "** Game : $Game *" | tee -a $LOG;
fi;
if [ -d /data/data/com.supercell.clashofclans ]; then
 Game=ClashOfClans
 echo "** Game : $Game *" | tee -a $LOG;
fi;
if [ -d /data/data/jp.konami.pesam ]; then
 Game=PeS
 echo "** Game : $Game *" | tee -a $LOG;
fi;
if [ -d /data/data/com.lilithgame.roc.gp ]; then
 Game=RiseOfKingdom
 echo "** Game : $Game *" | tee -a $LOG;
fi;
if [ -d /data/data/mobi.gameguru.racingfever ]; then
 Game=RacingFever
 echo "** Game : $Game *" | tee -a $LOG;
fi;
if [ -d /data/data/com.mgs.sniper1 ]; then
 Game=SniperStrike
 echo "** Game : $Game *" | tee -a $LOG;
fi;
if [ -d /data/data/com.nintendo.zaga ]; then
 Game=DragaliaLost
 echo "** Game : $Game *" | tee -a $LOG;
fi;
if [ -d /data/data/com.neowiz.game.koh ]; then
 Game=KingdomOfHero
 echo "** Game : $Game *" | tee -a $LOG;
fi;
if [ -d /data/data/com.ninjakiwi.bloonstd6 ]; then
 Game=Bloons
 echo "** Game : $Game *" | tee -a $LOG;
fi;
if [ -d /data/data/com.dts.freefireth ]; then
 Game=GarenaFreeFire
 echo "** Game : $Game *" | tee -a $LOG;
fi;
if [ -d /data/data/com.robtopx.geometryjump ]; then
 Game=GeometryDash
 echo "** Game : $Game *" | tee -a $LOG;
fi;
if [ -d /data/data/com.t2ksports.nba2k19 ]; then
 Game=NbA2k19
 echo "** Game : $Game *" | tee -a $LOG;
fi;
if [ -d /data/data/com.squareenixmontreal.hitmansniperandroid ]; then
 Game=HitmanSniper
 echo "** Game : $Game *" | tee -a $LOG;
fi;
if [ -d /data/data/com.vg.bsm ]; then
 Game=BlackShot
 echo "** Game : $Game *" | tee -a $LOG;
fi;
if [ -d /data/data/com.nekki.shadowfight3 ]; then
 Game=ShadowFight3
 echo "** Game : $Game *" | tee -a $LOG;
fi;
if [ -d /data/data/com.nekki.shadowfight ]; then
 Game=ShadowFight2
 echo "** Game : $Game *" | tee -a $LOG;
fi;
if [ -d /data/data/com.ea.game.Strm14_row ]; then
 Game=StrmNoLimit
 echo "** Game : $Game *" | tee -a $LOG;
fi;
if [ -d /data/data/com.FireproofStudios.TheRoom4 ]; then
 Game=Room
 echo "** Game : $Game *" | tee -a $LOG;
fi;
if [ -d /data/data/com.netease.lztgglobal ]; then
 Game=CyberHunter
 echo "** Game : $Game *" | tee -a $LOG;
fi;
if [ -d /data/data/com.gameloft.android.ANMP.GloftA9HM ]; then
 Game=Asphalt9
 echo "** Game : $Game *" | tee -a $LOG;
fi;
if [ -d /data/data/com.theonegames.gunshipbattle ]; then
 Game=GunshipBattle
 echo "** Game : $Game *" | tee -a $LOG;
fi;
if [ -d /data/data/com.tencent.tmgp.pubgmhd ]; then
 Game=Pubg
 echo "** Game : $Game *" | tee -a $LOG;
fi;
if [ -d /data/data/com.tencent.tmgp.pubgm ]; then
 Game=Pubg
 echo "** Game : $Game *" | tee -a $LOG;
fi;
if [ -d /data/data/com.tencent.iglite ]; then
 Game=Pubg
 echo "** Game : $Game *" | tee -a $LOG;
fi;
if [ -d /data/data/com.pubg.krmobile ]; then
 Game=Pubg
 echo "** Game : $Game *" | tee -a $LOG;
fi;
if [ -d /data/data/com.rekoo.pubgm ]; then
 Game=Pubg
 echo "** Game : $Game *" | tee -a $LOG;
fi;
if [ -d /data/data/com.tencent.ig ]; then
 Game=Pubg
 echo "** Game : $Game *" | tee -a $LOG;
fi;
if [ -d /data/data/com.mobile.legends ]; then
 Game=MobileLegends
 echo "** Game : $Game *" | tee -a $LOG;
fi;
if [ -d /data/data/com.netmarble.revolutionthm ]; then
 Game=LineageRev
 echo "** Game : $Game *" | tee -a $LOG;
fi;

echo "" | tee -a $LOG;

# VARIABLES =========================================#

MODE=$(cat $Strm/mode.prop)
SE=$(cat $Strm/swap.prop)
CPU=/sys/devices/system/cpu
GOV=$(cat $Strm/governor.txt)
current1=$(getprop dalvik.vm.dex2oat-threads)
current2=$(getprop dalvik.vm.boot-dex2oat-threads)
current3=$(getprop persist.dalvik.vm.dex2oat-threads)
current4=$(getprop dalvik.vm.image-dex2oat-threads)
current5=$(getprop ro.sys.fw.dex2oat_thread_count)
CP=$(cat $Strm/comp.prop)
CC=$(cat $Strm/tcp.txt)
FC=$(cat /sys/kernel/fast_charge/force_fast_charge)

if [ $MODE -eq "2" ]; then
 M=Gaming
elif [ $MODE -eq "1" ]; then
 M=Ultra
elif [ $MODE -eq "3" ]; then
 M=Battery_Saver
elif [ $MODE -eq "0" ]; then
 M=Balanced
fi;

if [ "$land" == "$MODE" ]; then
 echo "* SMART CONTROL = Active *" | tee -a $LOG;
 echo "* Intuitive Mode  = $M *" | tee -a $LOG;
else 
 echo "* SMART CONTROL = Not Active *" | tee -a $LOG;
 echo "* User Mode = $M *" | tee -a $LOG;
fi;

echo "" | tee -a $LOG;
echo "* START OPTIMIZATIONS : $( date +"%m-%d-%Y %H:%M:%S" ) *" | tee -a $LOG;

# SELINUX PERMISSIVE =========================================#

if [ -e /sys/fs/selinux/enforce ]; then
 setenforce 0
 echo "$SE" > /sys/fs/selinux/enforce
 LIN=$(cat /sys/fs/selinux/enforce)
fi;

if [ $LIN -eq 1 ]; then
 echo "* Security-Enhanced Linux = Enforcing *" |  tee -a $LOG;
else
 echo "* Security-Enhanced Linux = Permissive *" |  tee -a $LOG;
fi;

# MMC CRC =========================================#

MMC() {
echo "* MMC CRC checking = Disabled *" | tee -a $LOG;
}
if [ -e /sys/module/mmc_core/parameters/removable ]; then
 MC=/sys/module/mmc_core/parameters/removable
 echo "N" > $MC
 MMC
elif [ -e /sys/module/mmc_core/parameters/crc ]; then
 MC=/sys/module/mmc_core/parameters/crc
 echo "N" > $MC
 MMC
elif [ -e /sys/module/mmc_core/parameters/use_spi_crc ]; then
 MC=/sys/module/mmc_core/parameters/use_spi_crc
 echo "N" > $MC
 MMC
fi;

# SYSCTL / DVFS =========================================#

if [ -e $SYS/etc/sysctl.conf ]; then
 mv -f $SYS/etc/sysctl.conf $SYS/etc/sysctl.conf.bak
echo "* Tuner Sysctl System  = Disabled *" |  tee -a $LOG;
fi;

# VM TWEAKS =========================================#

sync;
chmod 0644 /proc/sys/*; 2>/dev/null

if [ "$MODE" -eq "2" ]; then
 sysctl -e -w vm.dirty_background_ratio=3 2>/dev/null
 sysctl -e -w vm.dirty_ratio=15 2>/dev/null
 sysctl -e -w vm.vfs_cache_pressure=150 2>/dev/null
elif [ "$MODE" -eq "1" ]; then
 sysctl -e -w vm.dirty_background_ratio=30 2>/dev/null
 sysctl -e -w vm.dirty_ratio=60 2>/dev/null
 sysctl -e -w vm.vfs_cache_pressure=100 2>/dev/null
elif [ "$MODE" -eq "3" ]; then
 sysctl -e -w vm.dirty_background_ratio=20 2>/dev/null
 sysctl -e -w vm.dirty_ratio=40 2>/dev/null
 sysctl -e -w vm.vfs_cache_pressure=10 2>/dev/null
elif [ "$MODE" -eq "0" ]; then
 sysctl -e -w vm.dirty_background_ratio=30 2>/dev/null
 sysctl -e -w vm.dirty_ratio=60 2>/dev/null
 sysctl -e -w vm.vfs_cache_pressure=100 2>/dev/null
fi;
sysctl -e -w vm.drop_caches=0 2>/dev/null
sysctl -e -w vm.oom_kill_allocating_task=0 2>/dev/null
sysctl -e -w vm.block_dump=0 2>/dev/null
sysctl -e -w vm.overcommit_memory=1 2>/dev/null
sysctl -e -w vm.oom_dump_tasks=1 2>/dev/null
sysctl -e -w vm.dirty_writeback_centisecs=0 2>/dev/null
sysctl -e -w vm.dirty_expire_centisecs=0 2>/dev/null
sysctl -e -w vm.min_free_order_shift=4 2>/dev/null
sysctl -e -w vm.swappiness=0 2>/dev/null
sysctl -e -w vm.page-cluster=0 2>/dev/null
sysctl -e -w vm.laptop_mode=0 2>/dev/null
sysctl -e -w fs.lease-break-time=10 2>/dev/null
sysctl -e -w fs.leases-enable=1 2>/dev/null
sysctl -e -w fs.dir-notify-enable=0 2>/dev/null
sysctl -e -w vm.compact_memory=1 2>/dev/null
sysctl -e -w vm.compact_unevictable_allowed=1 2>/dev/null
#Panic Off
sysctl -e -w vm.panic_on_oom=0 2>/dev/null
sysctl -e -w kernel.panic_on_oops=0 2>/dev/null
sysctl -e -w kernel.panic=0 2>/dev/null
sysctl -e -w kernel.panic_on_warn=0 2>/dev/null
echo "* Virtual Memory = Optimized *" |  tee -a $LOG;

# LOW MEM KILLER =========================================#

if [ "$MODE" -eq "2" ]; then
 FP=$((($MEM*2/100)*1024/4));
 VP=$((($MEM*3/100)*1024/4));
 SR=$((($MEM*5/100)*1024/4));
 HP=$((($MEM*6/100)*1024/4));
 CR=$((($MEM*11/100)*1024/4));
 EP=$((($MEM*16/100)*1024/4));
 MFK=$(($MEM*8))
 ADJ1=0; ADJ2=117; ADJ3=235; ADJ4=411; ADJ5=823; ADJ6=1000 # Strm
elif [ "$MODE" -eq "1" ]; then
 FP=$((($MEM*2/100)*1024/4));
 VP=$((($MEM*3/100)*1024/4));
 SR=$((($MEM*5/100)*1024/4));
 HP=$((($MEM*6/100)*1024/4));
 CR=$((($MEM*11/100)*1024/4));
 EP=$((($MEM*16/100)*1024/4));
 MFK=$(($MEM*7))
 ADJ1=0; ADJ2=117; ADJ3=235; ADJ4=411; ADJ5=823; ADJ6=1000 # Strm
elif [ "$MODE" -eq "3" ]; then
 FP=$((($MEM*2/100)*1024/4));
 VP=$((($MEM*3/100)*1024/4));
 SR=$((($MEM*5/100)*1024/4));
 HP=$((($MEM*7/100)*1024/4));
 CR=$((($MEM*10/100)*1024/4));
 EP=$((($MEM*13/100)*1024/4));
 MFK=$(($MEM*3))
 ADJ1=0; ADJ2=117; ADJ3=235; ADJ4=411; ADJ5=823; ADJ6=1000 # Strm
else
 FP=$((($MEM*2/100)*1024/4));
 VP=$((($MEM*3/100)*1024/4));
 SR=$((($MEM*5/100)*1024/4));
 HP=$((($MEM*7/100)*1024/4));
 CR=$((($MEM*10/100)*1024/4));
 EP=$((($MEM*13/100)*1024/4));
 MFK=$(($MEM*5))
 ADJ1=0; ADJ2=117; ADJ3=235; ADJ4=411; ADJ5=823; ADJ6=1000 # Strm
fi;

if [ -e /sys/module/lowmemorykiller/parameters/enable_adaptive_lmk ]; then
 chmod 0666 /sys/module/lowmemorykiller/parameters/enable_adaptive_lmk;
 echo "0" > /sys/module/lowmemorykiller/parameters/enable_adaptive_lmk
 setprop lmk.autocalc false;
fi;
if [ -e /sys/module/lowmemorykiller/parameters/debug_level ]; then
 chmod 666 /sys/module/lowmemorykiller/parameters/debug_level;
 echo "0" > /sys/module/lowmemorykiller/parameters/debug_level;
fi;
if [ -e  /sys/module/lowmemorykiller/parameters/oom_reaper ]; then
 chmod 0666 /sys/module/lowmemorykiller/parameters/oom_reaper;
 echo "1" >  /sys/module/lowmemorykiller/parameters/oom_reaper
fi;

chmod 0666 /sys/module/lowmemorykiller/parameters/adj;
chmod 0666 /sys/module/lowmemorykiller/parameters/minfree;
echo "$ADJ1,$ADJ2,$ADJ3,$ADJ4,$ADJ5,$ADJ6" > /sys/module/lowmemorykiller/parameters/adj;
echo "$FP,$VP,$SR,$HP,$CR,$EP" > /sys/module/lowmemorykiller/parameters/minfree;

MFK1=$(($MFK*2))

sysctl -e -w vm.min_free_kbytes=$MFK;

if [ -e /proc/sys/vm/extra_free_kbytes ]; then
 sysctl -e -w vm.extra_free_kbytes=$MFK1 2>/dev/null
fi;
echo "* Full Ram Management = Activated *" |  tee -a $LOG;

# PROPERTY  =========================================#

if [ "$MODE" -eq "2" ]; then
 setprop MIN_HIDDEN_APPS false
 setprop ACTIVITY_INACTIVE_RESET_TIME false
 setprop MIN_RECENT_TASKS false
 setprop PROC_START_TIMEOUT false
 setprop CPU_MIN_CHECK_DURATION false
 setprop GC_TIMEOUT false
 setprop SERVICE_TIMEOUT false
 setprop MIN_CRASH_INTERVAL false
 setprop ENFORCE_PROCESS_LIMIT false
 setprop persist.sys.NV_FPSLIMIT 90
 setprop persist.sys.NV_POWERMODE 1
 setprop persist.sys.NV_PROFVER 15
 setprop persist.sys.NV_STEREOCTRL 0
 setprop persist.sys.NV_STEREOSEPCHG 0
 setprop persist.sys.NV_STEREOSEP 20
 setprop persist.sys.use_16bpp_alpha 1
 echo "* Property = Adjusted  *" |  tee -a $LOG;
elif [ "$MODE" -eq "1" ]; then
 setprop MIN_HIDDEN_APPS false
 setprop ACTIVITY_INACTIVE_RESET_TIME false
 setprop MIN_RECENT_TASKS false
 setprop PROC_START_TIMEOUT false
 setprop CPU_MIN_CHECK_DURATION false
 setprop GC_TIMEOUT false
 setprop SERVICE_TIMEOUT false
 setprop MIN_CRASH_INTERVAL false
 setprop ENFORCE_PROCESS_LIMIT false
 echo "* Property = Adjusted  *" |  tee -a $LOG;
elif [ "$MODE" -eq "3" ]; then
 setprop enforce_process_limit 4
 echo "* Property = Adjusted  *" |  tee -a $LOG;
elif [ "$MODE" -eq "0" ]; then
 setprop ENFORCE_PROCESS_LIMIT false
 echo "* Property = Adjusted  *" |  tee -a $LOG;
fi;

# CPU_BOOST =========================================#

if [ "$MODE" -eq "2" ]; then
 if [ -e /sys/module/cpu_input_boost/parameters/input_boost_duration ]; then
  chmod 0644 /sys/module/cpu_input_boost/parameters/input_boost_duration
  echo "256" > /sys/module/cpu_input_boost/parameters/input_boost_duration
  echo "* CPU Boost Input Duration = Enabled *" | tee  -a $LOG;
 fi;
 if [ -e /sys/module/cpu_boost/parameters/input_boost_ms ]; then
  chmod 0644 /sys/module/cpu_boost/parameters/input_boost_ms
  echo "150" > /sys/module/cpu_boost/parameters/input_boost_ms
  echo "* CPU Boost Input Ms = Enabled *" | tee  -a $LOG;
 fi;
 if [ -e /sys/module/cpu_boost/parameters/input_boost_ms_s2 ]; then
  chmod 0644 /sys/module/cpu_boost/parameters/input_boost_ms_s2
  echo "75" > /sys/module/cpu_boost/parameters/input_boost_ms_s2
  echo "* CPU Boost Input Ms_S2 = Enabled *" | tee  -a $LOG;
 fi;
 if [ -e /sys/module/cpu_boost/parameters/dynamic_stune_boost ]; then
  chmod 0644 /sys/module/cpu_boost/parameters/dynamic_stune_boost
  echo "40" > /sys/module/cpu_boost/parameters/dynamic_stune_boost
  echo "* CPU Boost Dyn_Stune_Boost = Enabled *" | tee  -a $LOG;
 fi;
 if [ -e /sys/module/cpu_input_boost/parameters/dynamic_stune_boost ]; then
  chmod 0644 /sys/module/cpu_input_boost/parameters/dynamic_stune_boost
  echo "60" > /sys/module/cpu_input_boost/parameters/dynamic_stune_boost
  echo "* CPU Boost Dyn_Stune_Boost = Enabled *" | tee  -a $LOG;
 fi;
 if [ -e /sys/module/cpu_input_boost/parameters/general_stune_boost ]; then
  chmod 0644 /sys/module/cpu_input_boost/parameters/general_stune_boost
  echo "10" > /sys/module/cpu_input_boost/parameters/general_stune_boost
  echo "* CPU Boost General_Stune_Boost = Enabled *" | tee  -a $LOG;
 fi;
 if [ -e /sys/module/dsboost/parameters/input_boost_duration ]; then
  chmod 0644 /sys/module/dsboost/parameters/input_boost_duration
  echo "256" > /sys/module/dsboost/parameters/input_boost_duration
  echo "* Dsboost Input Boost Duration = Enabled *" | tee  -a $LOG;
 fi;
 if [ -e /sys/module/dsboost/parameters/input_stune_boost ]; then
  chmod 0644 /sys/module/dsboost/parameters/input_stune_boost
  echo "50" > /sys/module/dsboost/parameters/input_stune_boost
  echo "* Dsboost Input_Stune_Boost = Enabled *" | tee  -a $LOG;
 fi;
 if [ -e /sys/module/dsboost/parameters/sched_stune_boost ]; then
  chmod 0644 /sys/module/dsboost/parameters/sched_stune_boost
  echo "10" > /sys/module/dsboost/parameters/sched_stune_boost
  echo "* Dsboost Sched_Stune_Boost = Enabled *" | tee  -a $LOG;
 fi;
 if [ -e /sys/module/dsboost/parameters/cooldown_boost_duration ]; then
  chmod 0644 /sys/module/dsboost/parameters/cooldown_boost_duration
  echo "256" > /sys/module/dsboost/parameters/cooldown_boost_duration
  echo "* Dsboost Cooldown Boost Duration = Enabled *" | tee  -a $LOG;
 fi;
 if [ -e /sys/module/dsboost/parameters/cooldown_stune_boost ]; then
  chmod 0644 /sys/module/dsboost/parameters/cooldown_stune_boost
  echo "10" > /sys/module/dsboost/parameters/cooldown_stune_boost
  echo "* Dsboost Cooldown_Stune_Boost = Enabled *" | tee  -a $LOG;
 fi;
elif [ "$MODE" -eq "1" ]; then
 if [ -e /sys/module/cpu_input_boost/parameters/input_boost_duration ]; then
  chmod 0644 /sys/module/cpu_input_boost/parameters/input_boost_duration
  echo "256" > /sys/module/cpu_input_boost/parameters/input_boost_duration
  echo "* CPU Boost Input Duration = Enabled *" | tee  -a $LOG;
 fi;
 if [ -e /sys/module/cpu_boost/parameters/input_boost_ms ]; then
  chmod 0644 /sys/module/cpu_boost/parameters/input_boost_ms
  echo "100" > /sys/module/cpu_boost/parameters/input_boost_ms
  echo "* CPU Boost Input Ms = Enabled *" | tee  -a $LOG;
 fi;
 if [ -e /sys/module/cpu_boost/parameters/input_boost_ms_s2 ]; then
  chmod 0644 /sys/module/cpu_boost/parameters/input_boost_ms_s2
  echo "50" > /sys/module/cpu_boost/parameters/input_boost_ms_s2
  echo "* CPU Boost Input Ms_S2 = Enabled *" | tee  -a $LOG;
 fi;
 if [ -e /sys/module/cpu_boost/parameters/dynamic_stune_boost ]; then
  chmod 0644 /sys/module/cpu_boost/parameters/dynamic_stune_boost
  echo "30" > /sys/module/cpu_boost/parameters/dynamic_stune_boost
  echo "* CPU Boost Dyn_Stune_Boost = Enabled *" | tee  -a $LOG;
 fi;
 if [ -e /sys/module/cpu_input_boost/parameters/dynamic_stune_boost ]; then
  chmod 0644 /sys/module/cpu_input_boost/parameters/dynamic_stune_boost
  echo "50" > /sys/module/cpu_input_boost/parameters/dynamic_stune_boost
  echo "* CPU Boost Dyn_Stune_Boost = Enabled *" | tee  -a $LOG;
 fi;
 if [ -e /sys/module/cpu_input_boost/parameters/general_stune_boost ]; then
  chmod 0644 /sys/module/cpu_input_boost/parameters/general_stune_boost
  echo "10" > /sys/module/cpu_input_boost/parameters/general_stune_boost
  echo "* CPU Boost General_Stune_Boost = Enabled *" | tee  -a $LOG;
 fi;
 if [ -e /sys/module/dsboost/parameters/input_boost_duration ]; then
  chmod 0644 /sys/module/dsboost/parameters/input_boost_duration
  echo "256" > /sys/module/dsboost/parameters/input_boost_duration
  echo "* Dsboost Input Boost Duration = Enabled *" | tee  -a $LOG;
 fi;
 if [ -e /sys/module/dsboost/parameters/input_stune_boost ]; then
  chmod 0644 /sys/module/dsboost/parameters/input_stune_boost
  echo "50" > /sys/module/dsboost/parameters/input_stune_boost
  echo "* Dsboost Input_Stune_Boost = Enabled *" | tee  -a $LOG;
 fi;
 if [ -e /sys/module/dsboost/parameters/sched_stune_boost ]; then
  chmod 0644 /sys/module/dsboost/parameters/sched_stune_boost
  echo "10" > /sys/module/dsboost/parameters/sched_stune_boost
  echo "* Dsboost Sched_Stune_Boost = Enabled *" | tee  -a $LOG;
 fi;
 if [ -e /sys/module/dsboost/parameters/cooldown_boost_duration ]; then
  chmod 0644 /sys/module/dsboost/parameters/cooldown_boost_duration
  echo "256" > /sys/module/dsboost/parameters/cooldown_boost_duration
  echo "* Dsboost Cooldown Boost Duration = Enabled *" | tee  -a $LOG;
 fi;
 if [ -e /sys/module/dsboost/parameters/cooldown_stune_boost ]; then
  chmod 0644 /sys/module/dsboost/parameters/cooldown_stune_boost
  echo "10" > /sys/module/dsboost/parameters/cooldown_stune_boost
  echo "* Dsboost Cooldown_Stune_Boost = Enabled *" | tee  -a $LOG;
 fi;
elif [ "$MODE" -eq "3" ]; then
 if [ -e /sys/module/cpu_input_boost/parameters/input_boost_duration ]; then
  chmod 0644 /sys/module/cpu_input_boost/parameters/input_boost_duration
  echo "0" > /sys/module/cpu_input_boost/parameters/input_boost_duration
  echo "* CPU Boost Input Duration = Disabled *" | tee  -a $LOG;
 fi;
 if [ -e /sys/module/cpu_boost/parameters/input_boost_ms ]; then
  chmod 0644 /sys/module/cpu_boost/parameters/input_boost_ms
  echo "0" > /sys/module/cpu_boost/parameters/input_boost_ms
  echo "* CPU Boost Input Ms = Disabled *" | tee  -a $LOG;
 fi;
 if [ -e /sys/module/cpu_boost/parameters/input_boost_ms_s2 ]; then
  chmod 0644 /sys/module/cpu_boost/parameters/input_boost_ms_s2
  echo "0" > /sys/module/cpu_boost/parameters/input_boost_ms_s2
  echo "* CPU Boost Input Ms_S2 = Disabled *" | tee  -a $LOG;
 fi;
 if [ -e /sys/module/cpu_boost/parameters/dynamic_stune_boost ]; then
  chmod 0644 /sys/module/cpu_boost/parameters/dynamic_stune_boost
  echo "0" > /sys/module/cpu_boost/parameters/dynamic_stune_boost
  echo "* CPU Boost Dyn_Stune_Boost = Disabled *" | tee  -a $LOG;
 fi;
 if [ -e /sys/module/cpu_input_boost/parameters/dynamic_stune_boost ]; then
  chmod 0644 /sys/module/cpu_input_boost/parameters/dynamic_stune_boost
  echo "0" > /sys/module/cpu_input_boost/parameters/dynamic_stune_boost
  echo "* CPU Boost Dyn_Stune_Boost = Disabled *" | tee  -a $LOG;
 fi;
 if [ -e /sys/module/cpu_input_boost/parameters/general_stune_boost ]; then
  chmod 0644 /sys/module/cpu_input_boost/parameters/general_stune_boost
  echo "0" > /sys/module/cpu_input_boost/parameters/general_stune_boost
  echo "* CPU Boost General_Stune_Boost = Disabled *" | tee  -a $LOG;
 fi;
 if [ -e /sys/module/dsboost/parameters/input_boost_duration ]; then
  chmod 0644 /sys/module/dsboost/parameters/input_boost_duration
  echo "0" > /sys/module/dsboost/parameters/input_boost_duration
  echo "* Dsboost Input Boost Duration = Disabled *" | tee  -a $LOG;
 fi;
 if [ -e /sys/module/dsboost/parameters/input_stune_boost ]; then
  chmod 0644 /sys/module/dsboost/parameters/input_stune_boost
  echo "0" > /sys/module/dsboost/parameters/input_stune_boost
  echo "* Dsboost Input Stune Boost Duration = Disabled *" | tee  -a $LOG;
 fi;
 if [ -e /sys/module/dsboost/parameters/sched_stune_boost ]; then
  chmod 0644 /sys/module/dsboost/parameters/sched_stune_boost
  echo "0" > /sys/module/dsboost/parameters/sched_stune_boost
  echo "* Dsboost Sched_Stube_Boost = Disabled *" | tee  -a $LOG;
 fi;
 if [ -e /sys/module/dsboost/parameters/cooldown_boost_duration ]; then
  chmod 0644 /sys/module/dsboost/parameters/cooldown_boost_duration
  echo "0" > /sys/module/dsboost/parameters/cooldown_boost_duration
  echo "* Dsboost Cooldown_Boost_Duration = Disabled *" | tee  -a $LOG;
 fi;
 if [ -e /sys/module/dsboost/parameters/cooldown_stune_boost ]; then
  chmod 0644 /sys/module/dsboost/parameters/cooldown_stune_boost
  echo "0" > /sys/module/dsboost/parameters/cooldown_stune_boost
  echo "* Dsboost Cooldown_Stune_Boost = Disabled *" | tee  -a $LOG;
 fi;
elif [ "$MODE" -eq "0" ]; then
 if [ -e /sys/module/cpu_input_boost/parameters/input_boost_duration ]; then
  chmod 0644 /sys/module/cpu_input_boost/parameters/input_boost_duration
  echo "60" > /sys/module/cpu_input_boost/parameters/input_boost_duration
  echo "* CPU Boost Input Duration = Enabled *" | tee  -a $LOG;
 fi;
 if [ -e /sys/module/cpu_boost/parameters/input_boost_ms ]; then
  chmod 0644 /sys/module/cpu_boost/parameters/input_boost_ms
  echo "60" > /sys/module/cpu_boost/parameters/input_boost_ms
  echo "* CPU Boost Input Ms = Enabled *" | tee  -a $LOG;
 fi;
 if [ -e /sys/module/cpu_boost/parameters/input_boost_ms_s2 ]; then
  chmod 0644 /sys/module/cpu_boost/parameters/input_boost_ms_s2
  echo "25" > /sys/module/cpu_boost/parameters/input_boost_ms_s2
  echo "* CPU Boost Input Ms_S2 = Enabled *" | tee  -a $LOG;
 fi;
 if [ -e /sys/module/cpu_boost/parameters/dynamic_stune_boost ]; then
  chmod 0644 /sys/module/cpu_boost/parameters/dynamic_stune_boost
  echo "10" > /sys/module/cpu_boost/parameters/dynamic_stune_boost
  echo "* CPU Boost Dyn_Stune_Boost = Enabled *" | tee  -a $LOG;
 fi;
 if [ -e /sys/module/cpu_input_boost/parameters/dynamic_stune_boost ]; then
  chmod 0644 /sys/module/cpu_input_boost/parameters/dynamic_stune_boost
  echo "10" > /sys/module/cpu_input_boost/parameters/dynamic_stune_boost
  echo "* CPU Boost Dyn_Stune_Boost = Enabled *" | tee  -a $LOG;
 fi;
 if [ -e /sys/module/dsboost/parameters/input_boost_duration ]; then
  chmod 0644 /sys/module/dsboost/parameters/input_boost_duration
  echo "256" > /sys/module/dsboost/parameters/input_boost_duration
  echo "* Dsboost Duration = Enabled *" | tee  -a $LOG;
 fi;
 if [ -e /sys/module/dsboost/parameters/input_stune_boost ]; then
  chmod 0644 /sys/module/dsboost/parameters/input_stune_boost
  echo "50" > /sys/module/dsboost/parameters/input_stune_boost
  echo "* Dsboost Stune_Boost = Enabled *" | tee  -a $LOG;
 fi;
 if [ -e /sys/module/dsboost/parameters/sched_stune_boost ]; then
  chmod 0644 /sys/module/dsboost/parameters/sched_stune_boost
  echo "10" > /sys/module/dsboost/parameters/sched_stune_boost
  echo "* Dsboost Sched_Stune_Boost = Enabled *" | tee  -a $LOG;
 fi;
 if [ -e /sys/module/dsboost/parameters/cooldown_boost_duration ]; then
  chmod 0644 /sys/module/dsboost/parameters/cooldown_boost_duration
  echo "256" > /sys/module/dsboost/parameters/cooldown_boost_duration
  echo "* Dsboost Cooldown_Boost_Duration = Enabled *" | tee  -a $LOG;
 fi;
 if [ -e /sys/module/dsboost/parameters/cooldown_stune_boost ]; then
  chmod 0644 /sys/module/dsboost/parameters/cooldown_stune_boost
  echo "10" > /sys/module/dsboost/parameters/cooldown_stune_boost
  echo "* Dsboost Cooldown_Stune_Boost = Enabled *" | tee  -a $LOG;
 fi;
fi;

#=========================================#

if [ -e /sys/module/msm_performance/parameters/touchboost ]; then
 chmod 0644 /sys/module/msm_performance/parameters/touchboost
 echo "0" > /sys/module/msm_performance/parameters/touchboost
 echo "* TouchBoost MSM = Disabled *" | tee -a $LOG;
fi;
if [ -e /sys/module/cpu_boost/parameters/boost_ms ]; then
 chmod 0644 /sys/module/cpu_boost/parameters/boost_ms
 echo "0" > /sys/module/cpu_boost/parameters/boost_ms
 echo "* CPU Boost Ms = Disabled *" | tee  -a $LOG;
fi;
if [ -e /sys/module/cpu_boost/parameters/sched_boost_on_input ]; then
 chmod 0644 /sys/module/cpu_boost/parameters/sched_boost_on_input
 echo "N" > /sys/module/cpu_boost/parameters/sched_boost_on_input
 echo "* CPU Boost Sched = Disabled *" | tee  -a $LOG;
fi;

if [ -e /sys/power/pnpmgr/touch_boost ]; then
 chmod 0644 /sys/power/pnpmgr/touch_boost
 echo "0" > /sys/power/pnpmgr/touch_boost
 echo "* Touch_Boost PNP = Disabled *" | tee  -a $LOG;
fi;

# I/O SCHED =========================================#

MMC=$(ls -d /sys/block/mmc*)
DM=$(ls -d /sys/block/dm-*)
SD=$(ls -d /sys/block/sd*)
LOOP=$(ls -d /sys/block/loop*)
RAM=$(ls -d /sys/block/ram*)
ZRAM=$(ls -d /sys/block/zram*)
SCH=$(cat $Strm/scheduler.txt)

if [ "$MODE" -eq "2" ]; then
 RQ=2
 NOM=0
 NR=128
elif [ "$MODE" -eq "1" ]; then
 RQ=2
 NOM=0
 NR=128
elif [ "$MODE" -eq "3" ]; then
 RQ=0
 NOM=0
 NR=64
elif [ "$MODE" -eq "0" ]; then
 RQ=2
 NOM=0
 NR=128
fi;

for X in $MMC $SD $DM $LOOP $RAM $ZRAM
do
 echo "$SCH" > $X/queue/scheduler 2>/dev/null
 echo "0" > $X/queue/rotational 2>/dev/null
 echo "0" > $X/queue/iostats 2>/dev/null
 echo "0" > $X/queue/add_random 2>/dev/null
 echo "$NR" > $X/queue/nr_requests 2>/dev/null
 echo "$NOM" > $X/queue/nomerges 2>/dev/null
 echo "$RQ" > $X/queue/rq_affinity 2>/dev/null
 echo "$NR" > $X/queue/read_ahead_kb 2>/dev/null
 echo "0" > $X/queue/iosched/slice_idle 2>/dev/null
 echo "2" > $X/queue/iosched/fifo_batch 2>/dev/null
 echo "0" > $X/queue/iosched/front_merges 2>/dev/null
 echo "4" > $X/queue/iosched/writes_starved 2>/dev/null
 echo "350" > $X/queue/iosched/read_expire 2>/dev/null
 echo "3500" > $X/queue/iosched/write_expire 2>/dev/null
 echo "350" > $X/queue/iosched/sync_read_expire 2>/dev/null
 echo "3500" > $X/queue/iosched/sync_write_expire 2>/dev/null
 echo "350" > $X/queue/iosched/async_read_expire 2>/dev/null
 echo "3500" > $X/queue/iosched/async_write_expire 2>/dev/null
 echo "10" > $X/queue/iosched/async_scale 2>/dev/null
 echo "8" > $X/queue/iosched/read_scale 2>/dev/null
 echo "8" > $X/queue/iosched/sync_scale 2>/dev/null
 echo "12" > $X/queue/iosched/write_scale 2>/dev/null
done

if [ "`ls /sys/devices/virtual/bdi/179*/read_ahead_kb`" ]; then
 for RH in /sys/devices/virtual/bdi/179*/read_ahead_kb
do
 echo "$KB" > $RH
done
fi; 2>/dev/null

for I in `find /sys/devices/platform -name iostats`
do
 echo "0" > $I
done

echo "* I/O Scheduling = Tweaked *" |  tee -a $LOG;
echo "* Scheduler $SCH = Enabled *" |  tee -a $LOG;

# CPU POWER =========================================#

if [ -d $CPU/cpu9 ]; then
 chmod 0666 /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
 chmod 0666 /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
 chmod 0666 /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor
 chmod 0666 /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor
 chmod 0666 /sys/devices/system/cpu/cpu4/cpufreq/scaling_governor
 chmod 0666 /sys/devices/system/cpu/cpu5/cpufreq/scaling_governor
 chmod 0666 /sys/devices/system/cpu/cpu6/cpufreq/scaling_governor
 chmod 0666 /sys/devices/system/cpu/cpu7/cpufreq/scaling_governor
 chmod 0666 /sys/devices/system/cpu/cpu8/cpufreq/scaling_governor
 chmod 0666 /sys/devices/system/cpu/cpu9/cpufreq/scaling_governor
 echo "$GOV" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
 echo "$GOV" > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
 echo "$GOV" > /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor
 echo "$GOV" > /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor
 echo "$GOV" > /sys/devices/system/cpu/cpu4/cpufreq/scaling_governor
 echo "$GOV" > /sys/devices/system/cpu/cpu5/cpufreq/scaling_governor
 echo "$GOV" > /sys/devices/system/cpu/cpu6/cpufreq/scaling_governor
 echo "$GOV" > /sys/devices/system/cpu/cpu7/cpufreq/scaling_governor
 echo "$GOV" > /sys/devices/system/cpu/cpu8/cpufreq/scaling_governor
 echo "$GOV" > /sys/devices/system/cpu/cpu9/cpufreq/scaling_governor
 chmod 0444 /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
 chmod 0444 /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
 chmod 0444 /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor
 chmod 0444 /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor
 chmod 0444 /sys/devices/system/cpu/cpu4/cpufreq/scaling_governor
 chmod 0444 /sys/devices/system/cpu/cpu5/cpufreq/scaling_governor
 chmod 0444 /sys/devices/system/cpu/cpu6/cpufreq/scaling_governor
 chmod 0444 /sys/devices/system/cpu/cpu7/cpufreq/scaling_governor
 chmod 0444 /sys/devices/system/cpu/cpu8/cpufreq/scaling_governor
 chmod 0444 /sys/devices/system/cpu/cpu9/cpufreq/scaling_governor

 CORES=Deca-Core
 core=10
 ML=/sys/devices/system/cpu/cpu0/cpufreq/$GOV
 MB=/sys/devices/system/cpu/cpu5/cpufreq/$GOV
 if [ -e /sys/devices/system/cpu/cpufreq/$GOV ]; then
  ML=/sys/devices/system/cpu/cpufreq/$GOV
 fi;
elif [ -d $CPU/cpu7 ]; then
 chmod 0666 /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
 chmod 0666 /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
 chmod 0666 /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor
 chmod 0666 /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor
 chmod 0666 /sys/devices/system/cpu/cpu4/cpufreq/scaling_governor
 chmod 0666 /sys/devices/system/cpu/cpu5/cpufreq/scaling_governor
 chmod 0666 /sys/devices/system/cpu/cpu6/cpufreq/scaling_governor
 chmod 0666 /sys/devices/system/cpu/cpu7/cpufreq/scaling_governor
 echo "$GOV" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
 echo "$GOV" > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
 echo "$GOV" > /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor
 echo "$GOV" > /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor
 echo "$GOV" > /sys/devices/system/cpu/cpu4/cpufreq/scaling_governor
 echo "$GOV" > /sys/devices/system/cpu/cpu5/cpufreq/scaling_governor
 echo "$GOV" > /sys/devices/system/cpu/cpu6/cpufreq/scaling_governor
 echo "$GOV" > /sys/devices/system/cpu/cpu7/cpufreq/scaling_governor
 chmod 0444 /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
 chmod 0444 /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
 chmod 0444 /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor
 chmod 0444 /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor
 chmod 0444 /sys/devices/system/cpu/cpu4/cpufreq/scaling_governor
 chmod 0444 /sys/devices/system/cpu/cpu5/cpufreq/scaling_governor
 chmod 0444 /sys/devices/system/cpu/cpu6/cpufreq/scaling_governor
 chmod 0444 /sys/devices/system/cpu/cpu7/cpufreq/scaling_governor

 CORES=Octa-Core
 core=8
 ML=/sys/devices/system/cpu/cpu0/cpufreq/$GOV
 MB=/sys/devices/system/cpu/cpu4/cpufreq/$GOV
 if [ -e /sys/devices/system/cpu/cpufreq/$GOV ]; then
  ML=/sys/devices/system/cpu/cpufreq/$GOV
 fi;
elif [ -d $CPU/cpu5 ]; then
 chmod 0666 /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
 chmod 0666 /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
 chmod 0666 /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor
 chmod 0666 /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor
 chmod 0666 /sys/devices/system/cpu/cpu4/cpufreq/scaling_governor
 chmod 0666 /sys/devices/system/cpu/cpu5/cpufreq/scaling_governor
 echo "$GOV" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
 echo "$GOV" > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
 echo "$GOV" > /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor
 echo "$GOV" > /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor
 echo "$GOV" > /sys/devices/system/cpu/cpu4/cpufreq/scaling_governor
 echo "$GOV" > /sys/devices/system/cpu/cpu5/cpufreq/scaling_governor
 chmod 0444 /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
 chmod 0444 /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
 chmod 0444 /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor
 chmod 0444 /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor
 chmod 0444 /sys/devices/system/cpu/cpu4/cpufreq/scaling_governor
 chmod 0444 /sys/devices/system/cpu/cpu5/cpufreq/scaling_governor

 CORES=Hexa-Core
 core=6
 ML=/sys/devices/system/cpu/cpu0/cpufreq/$GOV
 MB=/sys/devices/system/cpu/cpu3/cpufreq/$GOV
 if [ -e /sys/devices/system/cpu/cpufreq/$GOV ]; then
  ML=/sys/devices/system/cpu/cpufreq/$GOV
 fi;
elif [ -d $CPU/cpu3 ]; then
 chmod 0666 /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
 chmod 0666 /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
 chmod 0666 /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor
 chmod 0666 /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor
 echo "$GOV" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
 echo "$GOV" > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
 echo "$GOV" > /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor
 echo "$GOV" > /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor
 chmod 0444 /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
 chmod 0444 /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
 chmod 0444 /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor
 chmod 0444 /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor

 CORES=Quad-Core
 core=4
 ML=/sys/devices/system/cpu/cpu0/cpufreq/$GOV
 MB=/sys/devices/system/cpu/cpu2/cpufreq/$GOV
 if [ -e /sys/devices/system/cpu/cpufreq/$GOV ]; then
  ML=/sys/devices/system/cpu/cpufreq/$GOV
 fi;
elif [ -d $CPU/cpu1 ]; then
 chmod 0666 /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
 chmod 0666 /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
 echo "$GOV" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
 echo "$GOV" > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
 chmod 0444 /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
 chmod 0444 /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor

 CORES=Dual-Core
 core=2
 ML=/sys/devices/system/cpu/cpu0/cpufreq/$GOV
 MB=/sys/devices/system/cpu/cpu1/cpufreq/$GOV
 if [ -e /sys/devices/system/cpu/cpufreq/$GOV ]; then
  ML=/sys/devices/system/cpu/cpufreq/$GOV
 fi;
fi;

CPUBATTERY() {
if [ "$GOV" == "smurfutil_flex" ]; then
 echo "1" > $ML/pl 2>/dev/null
 echo "9" > $ML/bit_shift1 2>/dev/null
 echo "6" > $ML/bit_shift1_2 2>/dev/null
 echo "6" > $ML/bit_shift2 2>/dev/null
 echo "45" > $ML/target_load1 2>/dev/null
 echo "75" > $ML/target_load2 2>/dev/null
 echo "1" > $MB/pl 2>/dev/null
 echo "9" > $MB/bit_shift1 2>/dev/null
 echo "6" > $MB/bit_shift1_2 2>/dev/null
 echo "6" > $MB/bit_shift2 2>/dev/null
 echo "45" > $MB/target_load1 2>/dev/null
 echo "75" > $MB/target_load2 2>/dev/null
 TUNE=Tuned
elif [ "$GOV" == "pixutil" ]; then
 echo "1000" > $MB/up_rate_limit_us 2>/dev/null
 echo "1000" > $MB/down_rate_limit_us 2>/dev/null
 echo "0" > $MB/iowait_boost_enable 2>/dev/null
 echo "1000" > $ML/up_rate_limit_us 2>/dev/null
 echo "1000" > $ML/down_rate_limit_us 2>/dev/null
 echo "0" > $MB/iowait_boost_enable 2>/dev/null
 TUNE=Tuned
elif [ "$GOV" == "pwrutilx" ]; then
 echo "1000" > $MB/up_rate_limit_us 2>/dev/null
 echo "1000" > $MB/down_rate_limit_us 2>/dev/null
 echo "0" > $MB/iowait_boost_enable 2>/dev/null
 echo "1000" > $ML/up_rate_limit_us 2>/dev/null
 echo "1000" > $ML/down_rate_limit_us 2>/dev/null
 echo "0" > $MB/iowait_boost_enable 2>/dev/null
 TUNE=Tuned
elif [ "$GOV" == "pixel_schedutil" ]; then
 echo "1000" > $MB/up_rate_limit_us 2>/dev/null
 echo "1000" > $MB/down_rate_limit_us 2>/dev/null
 echo "0" > $MB/iowait_boost_enable 2>/dev/null
 echo "1000" > $ML/up_rate_limit_us 2>/dev/null
 echo "1000" > $ML/down_rate_limit_us 2>/dev/null
 echo "0" > $MB/iowait_boost_enable 2>/dev/null
 TUNE=Tuned
elif [ "$GOV" == "helix_schedutil" ]; then
 echo "1000" > $MB/up_rate_limit_us 2>/dev/null
 echo "1000" > $MB/down_rate_limit_us 2>/dev/null
 echo "0" > $MB/iowait_boost_enable 2>/dev/null
 echo "1000" > $ML/up_rate_limit_us 2>/dev/null
 echo "1000" > $ML/down_rate_limit_us 2>/dev/null
 echo "0" > $MB/iowait_boost_enable 2>/dev/null
 TUNE=Tuned
elif [ "$GOV" == "schedutil" ]; then
 echo "1000" > $MB/up_rate_limit_us 2>/dev/null
 echo "1000" > $MB/down_rate_limit_us 2>/dev/null
 echo "0" > $MB/iowait_boost_enable 2>/dev/null
 echo "1000" > $ML/up_rate_limit_us 2>/dev/null
 echo "1000" > $ML/down_rate_limit_us 2>/dev/null
 echo "0" > $MB/iowait_boost_enable 2>/dev/null
 TUNE=Tuned
elif [ "$GOV" == "blu_schedutil" ]; then
 echo "1000" > $MB/up_rate_limit_us 2>/dev/null
 echo "1000" > $MB/down_rate_limit_us 2>/dev/null
 echo "0" > $MB/iowait_boost_enable 2>/dev/null
 echo "1000" > $ML/up_rate_limit_us 2>/dev/null
 echo "1000" > $ML/down_rate_limit_us 2>/dev/null
 echo "0" > $MB/iowait_boost_enable 2>/dev/null
 TUNE=Tuned
elif [ "$GOV" == "blu_active" ]; then
 echo "0" > $ML/boost 2>/dev/null
 echo "0" > $ML/boostpulse_duration 2>/dev/null
 echo "1" > $ML/fastlane 2>/dev/null
 echo "0" > $ML/align_windows 2>/dev/null
 echo "1" > $ML/use_migration_notif 2>/dev/null
 echo "1" > $ML/use_sched_load 2>/dev/null
 echo "0" > $ML/enable_prediction 2>/dev/null
 echo "1" > $ML/fast_ramp_down 2>/dev/null
 echo "99" > $ML/go_hispeed_load 2>/dev/null
 echo "10000" > $ML/timer_rate 2>/dev/null
 echo "0" > $ML/io_is_busy 2>/dev/null
 echo "40000" > $ML/min_sample_time 2>/dev/null
#############################################
 echo "0" > $MB/boost 2>/dev/null
 echo "0" > $MB/boostpulse_duration 2>/dev/null
 echo "1" > $MB/fastlane 2>/dev/null
 echo "0" > $MB/align_windows 2>/dev/null
 echo "1" > $MB/use_migration_notif 2>/dev/null
 echo "1" > $MB/use_sched_load 2>/dev/null
 echo "0" > $MB/enable_prediction 2>/dev/null
 echo "1" > $MB/fast_ramp_down 2>/dev/null
 echo "99" > $MB/go_hispeed_load 2>/dev/null
 echo "12000" > $MB/timer_rate 2>/dev/null
 echo "0" > $MB/io_is_busy 2>/dev/null
 echo "60000" > $MB/min_sample_time 2>/dev/null
 TUNE=Tuned
elif [ "$GOV" == "darkness" ]; then
 echo "0" > $ML/boost 2>/dev/null
 echo "0" > $ML/boostpulse_duration 2>/dev/null
 echo "1" > $ML/fastlane 2>/dev/null
 echo "0" > $ML/align_windows 2>/dev/null
 echo "1" > $ML/use_migration_notif 2>/dev/null
 echo "1" > $ML/use_sched_load 2>/dev/null
 echo "0" > $ML/enable_prediction 2>/dev/null
 echo "1" > $ML/fast_ramp_down 2>/dev/null
 echo "99" > $ML/go_hispeed_load 2>/dev/null
 echo "10000" > $ML/timer_rate 2>/dev/null
 echo "0" > $ML/io_is_busy 2>/dev/null
 echo "40000" > $ML/min_sample_time 2>/dev/null
#############################################
 echo "0" > $MB/boost 2>/dev/null
 echo "0" > $MB/boostpulse_duration 2>/dev/null
 echo "1" > $MB/fastlane 2>/dev/null
 echo "0" > $MB/align_windows 2>/dev/null
 echo "1" > $MB/use_migration_notif 2>/dev/null
 echo "1" > $MB/use_sched_load 2>/dev/null
 echo "0" > $MB/enable_prediction 2>/dev/null
 echo "1" > $MB/fast_ramp_down 2>/dev/null
 echo "99" > $MB/go_hispeed_load 2>/dev/null
 echo "12000" > $MB/timer_rate 2>/dev/null
 echo "0" > $MB/io_is_busy 2>/dev/null
 echo "60000" > $MB/min_sample_time 2>/dev/null
 TUNE=Tuned
elif [ "$GOV" == "elementalx" ]; then
 echo "5" > $MB/down_differential 2>/dev/null
 echo "0" > $MB/gboost 2>/dev/null
 echo "0" > $MB/input_event_timeout 2>/dev/null
 echo "40000" > $MB/sampling_rate 2>/dev/null
 echo "30000" > $MB/ui_sampling_rate 2>/dev/null
 echo "99" > $MB/up_threshold 2>/dev/null
 echo "99" > $MB/up_threshold_any_cpu_load 2>/dev/null
 echo "99" > $MB/up_threshold_multi_core 2>/dev/null
 echo "5" > $ML/down_differential 2>/dev/null
 echo "0" > $ML/gboost 2>/dev/null
 echo "0" > $ML/input_event_timeout 2>/dev/null
 echo "40000" > $ML/sampling_rate 2>/dev/null
 echo "30000" > $ML/ui_sampling_rate 2>/dev/null
 echo "99" > $ML/up_threshold 2>/dev/null
 echo "99" > $ML/up_threshold_any_cpu_load 2>/dev/null
 echo "99" > $ML/up_threshold_multi_core 2>/dev/null
 TUNE=Tuned
elif [ "$GOV" == "zzmoove" ]; then
 echo "85" > $MB/up_threshold 2>/dev/null
 echo "75" > $MB/smooth_up 2>/dev/null
 echo "0" > $MB/scaling_proportional 2>/dev/null
 echo "70000" $MB/sampling_rate_min 2>/dev/null
 echo "70000" $MB/sampling_rate 2>/dev/null
 echo "1" > $MB/sampling_down_factor 2>/dev/null
 echo "0" > $MB/ignore_nice_load 2>/dev/null
 echo "0" > $MB/fast_scaling_up 2>/dev/null
 echo "0" > $MB/fast_scaling_down 2>/dev/null
 echo "50" > $MB/down_threshold 2>/dev/null
 echo "85" > $ML/up_threshold 2>/dev/null
 echo "75" > $ML/smooth_up 2>/dev/null
 echo "0" > $ML/scaling_proportional 2>/dev/null
 echo "70000" $ML/sampling_rate_min 2>/dev/null
 echo "70000" $ML/sampling_rate 2>/dev/null
 echo "1" > $ML/sampling_down_factor 2>/dev/null
 echo "0" > $ML/ignore_nice_load 2>/dev/null 
 echo "0" > $ML/fast_scaling_up 2>/dev/null
 echo "0" > $ML/fast_scaling_down 2>/dev/null
 echo "50" > $ML/down_threshold 2>/dev/null
 TUNE=Tuned
elif [ "$GOV" == "cultivation" ]; then
 echo "0" > $ML/boost 2>/dev/null
 echo "0" > $ML/boostpulse_duration 2>/dev/null
 echo "1" > $ML/fastlane 2>/dev/null
 echo "0" > $ML/align_windows 2>/dev/null
 echo "1" > $ML/use_migration_notif 2>/dev/null
 echo "1" > $ML/use_sched_load 2>/dev/null
 echo "0" > $ML/enable_prediction 2>/dev/null
 echo "1" > $ML/fast_ramp_down 2>/dev/null
 echo "99" > $ML/go_hispeed_load 2>/dev/null
 echo "10000" > $ML/timer_rate 2>/dev/null
 echo "0" > $ML/io_is_busy 2>/dev/null
 echo "40000" > $ML/min_sample_time 2>/dev/null
#############################################
 echo "0" > $MB/boost 2>/dev/null
 echo "0" > $MB/boostpulse_duration 2>/dev/null
 echo "1" > $MB/fastlane 2>/dev/null
 echo "0" > $MB/align_windows 2>/dev/null
 echo "1" > $MB/use_migration_notif 2>/dev/null
 echo "1" > $MB/use_sched_load 2>/dev/null
 echo "0" > $MB/enable_prediction 2>/dev/null
 echo "1" > $MB/fast_ramp_down 2>/dev/null
 echo "99" > $MB/go_hispeed_load 2>/dev/null
 echo "12000" > $MB/timer_rate 2>/dev/null
 echo "0" > $MB/io_is_busy 2>/dev/null
 echo "60000" > $MB/min_sample_time 2>/dev/null
 TUNE=Tuned
elif [ "$GOV" == "interactiveplus" ]; then
 echo "0" > $ML/boost 2>/dev/null
 echo "0" > $ML/boostpulse_duration 2>/dev/null
 echo "1" > $ML/fastlane 2>/dev/null
 echo "0" > $ML/align_windows 2>/dev/null
 echo "1" > $ML/use_migration_notif 2>/dev/null
 echo "1" > $ML/use_sched_load 2>/dev/null
 echo "0" > $ML/enable_prediction 2>/dev/null
 echo "1" > $ML/fast_ramp_down 2>/dev/null
 echo "99" > $ML/go_hispeed_load 2>/dev/null
 echo "10000" > $ML/timer_rate 2>/dev/null
 echo "0" > $ML/io_is_busy 2>/dev/null
 echo "40000" > $ML/min_sample_time 2>/dev/null
#############################################
 echo "0" > $MB/boost 2>/dev/null
 echo "0" > $MB/boostpulse_duration 2>/dev/null
 echo "1" > $MB/fastlane 2>/dev/null
 echo "0" > $MB/align_windows 2>/dev/null
 echo "1" > $MB/use_migration_notif 2>/dev/null
 echo "1" > $MB/use_sched_load 2>/dev/null
 echo "0" > $MB/enable_prediction 2>/dev/null
 echo "1" > $MB/fast_ramp_down 2>/dev/null
 echo "99" > $MB/go_hispeed_load 2>/dev/null
 echo "12000" > $MB/timer_rate 2>/dev/null
 echo "0" > $MB/io_is_busy 2>/dev/null
 echo "60000" > $MB/min_sample_time 2>/dev/null
 TUNE=Tuned
elif [ "$GOV" == "interactive_pro" ]; then
 echo "0" > $ML/boost 2>/dev/null
 echo "0" > $ML/boostpulse_duration 2>/dev/null
 echo "1" > $ML/fastlane 2>/dev/null
 echo "0" > $ML/align_windows 2>/dev/null
 echo "1" > $ML/use_migration_notif 2>/dev/null
 echo "1" > $ML/use_sched_load 2>/dev/null
 echo "0" > $ML/enable_prediction 2>/dev/null
 echo "1" > $ML/fast_ramp_down 2>/dev/null
 echo "99" > $ML/go_hispeed_load 2>/dev/null
 echo "10000" > $ML/timer_rate 2>/dev/null
 echo "0" > $ML/io_is_busy 2>/dev/null
 echo "40000" > $ML/min_sample_time 2>/dev/null
#############################################
 echo "0" > $MB/boost 2>/dev/null
 echo "0" > $MB/boostpulse_duration 2>/dev/null
 echo "1" > $MB/fastlane 2>/dev/null
 echo "0" > $MB/align_windows 2>/dev/null
 echo "1" > $MB/use_migration_notif 2>/dev/null
 echo "1" > $MB/use_sched_load 2>/dev/null
 echo "0" > $MB/enable_prediction 2>/dev/null
 echo "1" > $MB/fast_ramp_down 2>/dev/null
 echo "99" > $MB/go_hispeed_load 2>/dev/null
 echo "12000" > $MB/timer_rate 2>/dev/null
 echo "0" > $MB/io_is_busy 2>/dev/null
 echo "60000" > $MB/min_sample_time 2>/dev/null
 TUNE=Tuned
elif [ "$GOV" == "interactivepro" ]; then
 echo "0" > $ML/boost 2>/dev/null
 echo "0" > $ML/boostpulse_duration 2>/dev/null
 echo "1" > $ML/fastlane 2>/dev/null
 echo "0" > $ML/align_windows 2>/dev/null
 echo "1" > $ML/use_migration_notif 2>/dev/null
 echo "1" > $ML/use_sched_load 2>/dev/null
 echo "0" > $ML/enable_prediction 2>/dev/null
 echo "1" > $ML/fast_ramp_down 2>/dev/null
 echo "99" > $ML/go_hispeed_load 2>/dev/null
 echo "10000" > $ML/timer_rate 2>/dev/null
 echo "0" > $ML/io_is_busy 2>/dev/null
 echo "40000" > $ML/min_sample_time 2>/dev/null
#############################################
 echo "0" > $MB/boost 2>/dev/null
 echo "0" > $MB/boostpulse_duration 2>/dev/null
 echo "1" > $MB/fastlane 2>/dev/null
 echo "0" > $MB/align_windows 2>/dev/null
 echo "1" > $MB/use_migration_notif 2>/dev/null
 echo "1" > $MB/use_sched_load 2>/dev/null
 echo "0" > $MB/enable_prediction 2>/dev/null
 echo "1" > $MB/fast_ramp_down 2>/dev/null
 echo "99" > $MB/go_hispeed_load 2>/dev/null
 echo "12000" > $MB/timer_rate 2>/dev/null
 echo "0" > $MB/io_is_busy 2>/dev/null
 echo "60000" > $MB/min_sample_time 2>/dev/null
 TUNE=Tuned
elif [ "$GOV" == "interactive" ]; then
 echo "0" > $ML/boost 2>/dev/null
 echo "0" > $ML/boostpulse_duration 2>/dev/null
 echo "1" > $ML/fastlane 2>/dev/null
 echo "0" > $ML/align_windows 2>/dev/null
 echo "1" > $ML/use_migration_notif 2>/dev/null
 echo "1" > $ML/use_sched_load 2>/dev/null
 echo "0" > $ML/enable_prediction 2>/dev/null
 echo "1" > $ML/fast_ramp_down 2>/dev/null
 echo "99" > $ML/go_hispeed_load 2>/dev/null
 echo "10000" > $ML/timer_rate 2>/dev/null
 echo "0" > $ML/io_is_busy 2>/dev/null
 echo "40000" > $ML/min_sample_time 2>/dev/null
#############################################
 echo "0" > $MB/boost 2>/dev/null
 echo "0" > $MB/boostpulse_duration 2>/dev/null
 echo "1" > $MB/fastlane 2>/dev/null
 echo "0" > $MB/align_windows 2>/dev/null
 echo "1" > $MB/use_migration_notif 2>/dev/null
 echo "1" > $MB/use_sched_load 2>/dev/null
 echo "0" > $MB/enable_prediction 2>/dev/null
 echo "1" > $MB/fast_ramp_down 2>/dev/null
 echo "99" > $MB/go_hispeed_load 2>/dev/null
 echo "12000" > $MB/timer_rate 2>/dev/null
 echo "0" > $MB/io_is_busy 2>/dev/null
 echo "60000" > $MB/min_sample_time 2>/dev/null
 TUNE=Tuned
elif [ "$GOV" == "interactivex" ]; then
 echo "0" > $ML/boost 2>/dev/null
 echo "0" > $ML/boostpulse_duration 2>/dev/null
 echo "1" > $ML/fastlane 2>/dev/null
 echo "0" > $ML/align_windows 2>/dev/null
 echo "1" > $ML/use_migration_notif 2>/dev/null
 echo "1" > $ML/use_sched_load 2>/dev/null
 echo "0" > $ML/enable_prediction 2>/dev/null
 echo "1" > $ML/fast_ramp_down 2>/dev/null
 echo "99" > $ML/go_hispeed_load 2>/dev/null
 echo "10000" > $ML/timer_rate 2>/dev/null
 echo "0" > $ML/io_is_busy 2>/dev/null
 echo "40000" > $ML/min_sample_time 2>/dev/null
#############################################
 echo "0" > $MB/boost 2>/dev/null
 echo "0" > $MB/boostpulse_duration 2>/dev/null
 echo "1" > $MB/fastlane 2>/dev/null
 echo "0" > $MB/align_windows 2>/dev/null
 echo "1" > $MB/use_migration_notif 2>/dev/null
 echo "1" > $MB/use_sched_load 2>/dev/null
 echo "0" > $MB/enable_prediction 2>/dev/null
 echo "1" > $MB/fast_ramp_down 2>/dev/null
 echo "99" > $MB/go_hispeed_load 2>/dev/null
 echo "12000" > $MB/timer_rate 2>/dev/null
 echo "0" > $MB/io_is_busy 2>/dev/null
 echo "60000" > $MB/min_sample_time 2>/dev/null
 TUNE=Tuned
elif [ "$GOV" == "phantom" ]; then
 echo "0" > $ML/boost 2>/dev/null
 echo "0" > $ML/boostpulse_duration 2>/dev/null
 echo "1" > $ML/fastlane 2>/dev/null
 echo "0" > $ML/align_windows 2>/dev/null
 echo "1" > $ML/use_migration_notif 2>/dev/null
 echo "1" > $ML/use_sched_load 2>/dev/null
 echo "0" > $ML/enable_prediction 2>/dev/null
 echo "1" > $ML/fast_ramp_down 2>/dev/null
 echo "99" > $ML/go_hispeed_load 2>/dev/null
 echo "10000" > $ML/timer_rate 2>/dev/null
 echo "0" > $ML/io_is_busy 2>/dev/null
 echo "40000" > $ML/min_sample_time 2>/dev/null
#############################################
 echo "0" > $MB/boost 2>/dev/null
 echo "0" > $MB/boostpulse_duration 2>/dev/null
 echo "1" > $MB/fastlane 2>/dev/null
 echo "0" > $MB/align_windows 2>/dev/null
 echo "1" > $MB/use_migration_notif 2>/dev/null
 echo "1" > $MB/use_sched_load 2>/dev/null
 echo "0" > $MB/enable_prediction 2>/dev/null
 echo "1" > $MB/fast_ramp_down 2>/dev/null
 echo "99" > $MB/go_hispeed_load 2>/dev/null
 echo "12000" > $MB/timer_rate 2>/dev/null
 echo "0" > $MB/io_is_busy 2>/dev/null
 echo "60000" > $MB/min_sample_time 2>/dev/null
 TUNE=Tuned
elif [ "$GOV" == "ondemand" ]; then
 echo "90" > $MB/up_threshold 2>/dev/null
 echo "85" > $MB/up_threshold_any_cpu_load 2>/dev/null
 echo "85" > $MB/up_threshold_multi_core 2>/dev/null
 echo "75000" > $MB/sampling_rate 2>/dev/null
 echo "2" > $MB/sampling_down_factor 2>/dev/null
 echo "10" > $MB/down_differential 2>/dev/null
 echo "35" > $MB/freq_step 2>/dev/null
 echo "90" > $ML/up_threshold 2>/dev/null
 echo "85" > $ML/up_threshold_any_cpu_load 2>/dev/null
 echo "85" > $ML/up_threshold_multi_core 2>/dev/null
 echo "75000" > $ML/sampling_rate 2>/dev/null
 echo "2" > $ML/sampling_down_factor 2>/dev/null
 echo "10" > $ML/down_differential 2>/dev/null
 echo "35" > $ML/freq_step 2>/dev/null
 TUNE=Tuned
else
TUNE=Not_Tuned
fi;

chmod 0444 $ML
chmod 0444 $MB
echo "* CPU Power $CORES $GOV = $TUNE *" |  tee -a $LOG;
}

CPUBALANCE() {
if [ "$GOV" == "smurfutil_flex" ]; then
 echo "1" > $ML/pl 2>/dev/null
 echo "6" > $ML/bit_shift1 2>/dev/null
 echo "5" > $ML/bit_shift1_2 2>/dev/null
 echo "6" > $ML/bit_shift2 2>/dev/null
 echo "40" > $ML/target_load1 2>/dev/null
 echo "75" > $ML/target_load2 2>/dev/null
 echo "1" > $MB/pl 2>/dev/null
 echo "6" > $MB/bit_shift1 2>/dev/null
 echo "5" > $MB/bit_shift1_2 2>/dev/null
 echo "6" > $MB/bit_shift2 2>/dev/null
 echo "40" > $MB/target_load1 2>/dev/null
 echo "75" > $MB/target_load2 2>/dev/null
 TUNE=Tuned
elif [ "$GOV" == "pixutil" ]; then
 echo "1000" > $MB/up_rate_limit_us 2>/dev/null
 echo "2000" > $MB/down_rate_limit_us 2>/dev/null
 echo "0" > $MB/iowait_boost_enable 2>/dev/null
 echo "1000" > $ML/up_rate_limit_us 2>/dev/null
 echo "2000" > $ML/down_rate_limit_us 2>/dev/null
 echo "0" > $MB/iowait_boost_enable 2>/dev/null
 TUNE=Tuned
elif [ "$GOV" == "pwrutilx" ]; then
 echo "1000" > $MB/up_rate_limit_us 2>/dev/null
 echo "2000" > $MB/down_rate_limit_us 2>/dev/null
 echo "0" > $MB/iowait_boost_enable 2>/dev/null
 echo "1000" > $ML/up_rate_limit_us 2>/dev/null
 echo "2000" > $ML/down_rate_limit_us 2>/dev/null
 echo "0" > $MB/iowait_boost_enable 2>/dev/null
 TUNE=Tuned
elif [ "$GOV" == "pixel_schedutil" ]; then
 echo "1000" > $MB/up_rate_limit_us 2>/dev/null
 echo "2000" > $MB/down_rate_limit_us 2>/dev/null
 echo "0" > $MB/iowait_boost_enable 2>/dev/null
 echo "1000" > $ML/up_rate_limit_us 2>/dev/null
 echo "2000" > $ML/down_rate_limit_us 2>/dev/null
 echo "0" > $MB/iowait_boost_enable 2>/dev/null
 TUNE=Tuned
elif [ "$GOV" == "helix_schedutil" ]; then
 echo "1000" > $MB/up_rate_limit_us 2>/dev/null
 echo "2000" > $MB/down_rate_limit_us 2>/dev/null
 echo "0" > $MB/iowait_boost_enable 2>/dev/null
 echo "1000" > $ML/up_rate_limit_us 2>/dev/null
 echo "2000" > $ML/down_rate_limit_us 2>/dev/null
 echo "0" > $MB/iowait_boost_enable 2>/dev/null
 TUNE=Tuned
elif [ "$GOV" == "schedutil" ]; then
 echo "1000" > $MB/up_rate_limit_us 2>/dev/null
 echo "2000" > $MB/down_rate_limit_us 2>/dev/null
 echo "0" > $MB/iowait_boost_enable 2>/dev/null
 echo "1000" > $ML/up_rate_limit_us 2>/dev/null
 echo "2000" > $ML/down_rate_limit_us 2>/dev/null
 echo "0" > $MB/iowait_boost_enable 2>/dev/null
 TUNE=Tuned
elif [ "$GOV" == "blu_schedutil" ]; then
 echo "1000" > $MB/up_rate_limit_us 2>/dev/null
 echo "2000" > $MB/down_rate_limit_us 2>/dev/null
 echo "0" > $MB/iowait_boost_enable 2>/dev/null
 echo "1000" > $ML/up_rate_limit_us 2>/dev/null
 echo "2000" > $ML/down_rate_limit_us 2>/dev/null
 echo "0" > $MB/iowait_boost_enable 2>/dev/null
 TUNE=Tuned
elif [ "$GOV" == "blu_active" ]; then
 echo "0" > $ML/boost 2>/dev/null
 echo "0" > $ML/boostpulse_duration 2>/dev/null
 echo "1" > $ML/fastlane 2>/dev/null
 echo "0" > $ML/align_windows 2>/dev/null
 echo "1" > $ML/use_migration_notif 2>/dev/null
 echo "1" > $ML/use_sched_load 2>/dev/null
 echo "0" > $ML/enable_prediction 2>/dev/null
 echo "1" > $ML/fast_ramp_down 2>/dev/null
 echo "95" > $ML/go_hispeed_load 2>/dev/null
 echo "10000" > $ML/timer_rate 2>/dev/null
 echo "0" > $ML/io_is_busy 2>/dev/null
 echo "40000" > $ML/min_sample_time 2>/dev/null
#############################################
 echo "0" > $MB/boost 2>/dev/null
 echo "0" > $MB/boostpulse_duration 2>/dev/null
 echo "1" > $MB/fastlane 2>/dev/null
 echo "0" > $MB/align_windows 2>/dev/null
 echo "1" > $MB/use_migration_notif 2>/dev/null
 echo "1" > $MB/use_sched_load 2>/dev/null
 echo "0" > $MB/enable_prediction 2>/dev/null
 echo "1" > $MB/fast_ramp_down 2>/dev/null
 echo "90" > $MB/go_hispeed_load 2>/dev/null
 echo "12000" > $MB/timer_rate 2>/dev/null
 echo "0" > $MB/io_is_busy 2>/dev/null
 echo "60000" > $MB/min_sample_time 2>/dev/null
 TUNE=Tuned
elif [ "$GOV" == "darkness" ]; then
 echo "0" > $ML/boost 2>/dev/null
 echo "0" > $ML/boostpulse_duration 2>/dev/null
 echo "1" > $ML/fastlane 2>/dev/null
 echo "0" > $ML/align_windows 2>/dev/null
 echo "1" > $ML/use_migration_notif 2>/dev/null
 echo "1" > $ML/use_sched_load 2>/dev/null
 echo "0" > $ML/enable_prediction 2>/dev/null
 echo "1" > $ML/fast_ramp_down 2>/dev/null
 echo "95" > $ML/go_hispeed_load 2>/dev/null
 echo "10000" > $ML/timer_rate 2>/dev/null
 echo "0" > $ML/io_is_busy 2>/dev/null
 echo "40000" > $ML/min_sample_time 2>/dev/null
#############################################
 echo "0" > $MB/boost 2>/dev/null
 echo "0" > $MB/boostpulse_duration 2>/dev/null
 echo "1" > $MB/fastlane 2>/dev/null
 echo "0" > $MB/align_windows 2>/dev/null
 echo "1" > $MB/use_migration_notif 2>/dev/null
 echo "1" > $MB/use_sched_load 2>/dev/null
 echo "0" > $MB/enable_prediction 2>/dev/null
 echo "1" > $MB/fast_ramp_down 2>/dev/null
 echo "90" > $MB/go_hispeed_load 2>/dev/null
 echo "12000" > $MB/timer_rate 2>/dev/null
 echo "0" > $MB/io_is_busy 2>/dev/null
 echo "60000" > $MB/min_sample_time 2>/dev/null
 TUNE=Tuned
elif [ "$GOV" == "elementalx" ]; then
 echo "5" > $MB/down_differential 2>/dev/null
 echo "0" > $MB/gboost 2>/dev/null
 echo "0" > $MB/input_event_timeout 2>/dev/null
 echo "40000" > $MB/sampling_rate 2>/dev/null
 echo "30000" > $MB/ui_sampling_rate 2>/dev/null
 echo "99" > $MB/up_threshold 2>/dev/null
 echo "99" > $MB/up_threshold_any_cpu_load 2>/dev/null
 echo "99" > $MB/up_threshold_multi_core 2>/dev/null
 echo "5" > $ML/down_differential 2>/dev/null
 echo "0" > $ML/gboost 2>/dev/null
 echo "0" > $ML/input_event_timeout 2>/dev/null
 echo "40000" > $ML/sampling_rate 2>/dev/null
 echo "30000" > $ML/ui_sampling_rate 2>/dev/null
 echo "99" > $ML/up_threshold 2>/dev/null
 echo "99" > $ML/up_threshold_any_cpu_load 2>/dev/null
 echo "99" > $ML/up_threshold_multi_core 2>/dev/null
 TUNE=Tuned
elif [ "$GOV" == "zzmoove" ]; then
 echo "85" > $MB/up_threshold 2>/dev/null
 echo "75" > $MB/smooth_up 2>/dev/null
 echo "0" > $MB/scaling_proportional 2>/dev/null
 echo "70000" $MB/sampling_rate_min 2>/dev/null
 echo "70000" $MB/sampling_rate 2>/dev/null
 echo "1" > $MB/sampling_down_factor 2>/dev/null
 echo "0" > $MB/ignore_nice_load 2>/dev/null
 echo "0" > $MB/fast_scaling_up 2>/dev/null
 echo "0" > $MB/fast_scaling_down 2>/dev/null
 echo "50" > $MB/down_threshold 2>/dev/null
 echo "85" > $ML/up_threshold 2>/dev/null
 echo "75" > $ML/smooth_up 2>/dev/null
 echo "0" > $ML/scaling_proportional 2>/dev/null
 echo "70000" $ML/sampling_rate_min 2>/dev/null
 echo "70000" $ML/sampling_rate 2>/dev/null
 echo "1" > $ML/sampling_down_factor 2>/dev/null
 echo "0" > $ML/ignore_nice_load 2>/dev/null
 echo "0" > $ML/fast_scaling_up 2>/dev/null
 echo "0" > $ML/fast_scaling_down 2>/dev/null
 echo "50" > $ML/down_threshold 2>/dev/null
 TUNE=Tuned
elif [ "$GOV" == "interactiveplus" ]; then
 echo "0" > $ML/boost 2>/dev/null
 echo "0" > $ML/boostpulse_duration 2>/dev/null
 echo "1" > $ML/fastlane 2>/dev/null
 echo "0" > $ML/align_windows 2>/dev/null
 echo "1" > $ML/use_migration_notif 2>/dev/null
 echo "1" > $ML/use_sched_load 2>/dev/null
 echo "0" > $ML/enable_prediction 2>/dev/null
 echo "1" > $ML/fast_ramp_down 2>/dev/null
 echo "95" > $ML/go_hispeed_load 2>/dev/null
 echo "10000" > $ML/timer_rate 2>/dev/null
 echo "0" > $ML/io_is_busy 2>/dev/null
 echo "40000" > $ML/min_sample_time 2>/dev/null
#############################################
 echo "0" > $MB/boost 2>/dev/null
 echo "0" > $MB/boostpulse_duration 2>/dev/null
 echo "1" > $MB/fastlane 2>/dev/null
 echo "0" > $MB/align_windows 2>/dev/null
 echo "1" > $MB/use_migration_notif 2>/dev/null
 echo "1" > $MB/use_sched_load 2>/dev/null
 echo "0" > $MB/enable_prediction 2>/dev/null
 echo "1" > $MB/fast_ramp_down 2>/dev/null
 echo "90" > $MB/go_hispeed_load 2>/dev/null
 echo "12000" > $MB/timer_rate 2>/dev/null
 echo "0" > $MB/io_is_busy 2>/dev/null
 echo "60000" > $MB/min_sample_time 2>/dev/null
 TUNE=Tuned
elif [ "$GOV" == "cultivation" ]; then
 echo "0" > $ML/boost 2>/dev/null
 echo "0" > $ML/boostpulse_duration 2>/dev/null
 echo "1" > $ML/fastlane 2>/dev/null
 echo "0" > $ML/align_windows 2>/dev/null
 echo "1" > $ML/use_migration_notif 2>/dev/null
 echo "1" > $ML/use_sched_load 2>/dev/null
 echo "0" > $ML/enable_prediction 2>/dev/null
 echo "1" > $ML/fast_ramp_down 2>/dev/null
 echo "95" > $ML/go_hispeed_load 2>/dev/null
 echo "10000" > $ML/timer_rate 2>/dev/null
 echo "0" > $ML/io_is_busy 2>/dev/null
 echo "40000" > $ML/min_sample_time 2>/dev/null
#############################################
 echo "0" > $MB/boost 2>/dev/null
 echo "0" > $MB/boostpulse_duration 2>/dev/null
 echo "1" > $MB/fastlane 2>/dev/null
 echo "0" > $MB/align_windows 2>/dev/null
 echo "1" > $MB/use_migration_notif 2>/dev/null
 echo "1" > $MB/use_sched_load 2>/dev/null
 echo "0" > $MB/enable_prediction 2>/dev/null
 echo "1" > $MB/fast_ramp_down 2>/dev/null
 echo "90" > $MB/go_hispeed_load 2>/dev/null
 echo "12000" > $MB/timer_rate 2>/dev/null
 echo "0" > $MB/io_is_busy 2>/dev/null
 echo "60000" > $MB/min_sample_time 2>/dev/null
 TUNE=Tuned
elif [ "$GOV" == "interactive_pro" ]; then
 echo "0" > $ML/boost 2>/dev/null
 echo "0" > $ML/boostpulse_duration 2>/dev/null
 echo "1" > $ML/fastlane 2>/dev/null
 echo "0" > $ML/align_windows 2>/dev/null
 echo "1" > $ML/use_migration_notif 2>/dev/null
 echo "1" > $ML/use_sched_load 2>/dev/null
 echo "0" > $ML/enable_prediction 2>/dev/null
 echo "1" > $ML/fast_ramp_down 2>/dev/null
 echo "95" > $ML/go_hispeed_load 2>/dev/null
 echo "10000" > $ML/timer_rate 2>/dev/null
 echo "0" > $ML/io_is_busy 2>/dev/null
 echo "40000" > $ML/min_sample_time 2>/dev/null
#############################################
 echo "0" > $MB/boost 2>/dev/null
 echo "0" > $MB/boostpulse_duration 2>/dev/null
 echo "1" > $MB/fastlane 2>/dev/null
 echo "0" > $MB/align_windows 2>/dev/null
 echo "1" > $MB/use_migration_notif 2>/dev/null
 echo "1" > $MB/use_sched_load 2>/dev/null
 echo "0" > $MB/enable_prediction 2>/dev/null
 echo "1" > $MB/fast_ramp_down 2>/dev/null
 echo "90" > $MB/go_hispeed_load 2>/dev/null
 echo "12000" > $MB/timer_rate 2>/dev/null
 echo "0" > $MB/io_is_busy 2>/dev/null
 echo "60000" > $MB/min_sample_time 2>/dev/null
 TUNE=Tuned
elif [ "$GOV" == "interactivepro" ]; then
 echo "0" > $ML/boost 2>/dev/null
 echo "0" > $ML/boostpulse_duration 2>/dev/null
 echo "1" > $ML/fastlane 2>/dev/null
 echo "0" > $ML/align_windows 2>/dev/null
 echo "1" > $ML/use_migration_notif 2>/dev/null
 echo "1" > $ML/use_sched_load 2>/dev/null
 echo "0" > $ML/enable_prediction 2>/dev/null
 echo "1" > $ML/fast_ramp_down 2>/dev/null
 echo "95" > $ML/go_hispeed_load 2>/dev/null
 echo "10000" > $ML/timer_rate 2>/dev/null
 echo "0" > $ML/io_is_busy 2>/dev/null
 echo "40000" > $ML/min_sample_time 2>/dev/null
#############################################
 echo "0" > $MB/boost 2>/dev/null
 echo "0" > $MB/boostpulse_duration 2>/dev/null
 echo "1" > $MB/fastlane 2>/dev/null
 echo "0" > $MB/align_windows 2>/dev/null
 echo "1" > $MB/use_migration_notif 2>/dev/null
 echo "1" > $MB/use_sched_load 2>/dev/null
 echo "0" > $MB/enable_prediction 2>/dev/null
 echo "1" > $MB/fast_ramp_down 2>/dev/null
 echo "90" > $MB/go_hispeed_load 2>/dev/null
 echo "12000" > $MB/timer_rate 2>/dev/null
 echo "0" > $MB/io_is_busy 2>/dev/null
 echo "60000" > $MB/min_sample_time 2>/dev/null
 TUNE=Tuned
elif [ "$GOV" == "interactive" ]; then
 echo "0" > $ML/boost 2>/dev/null
 echo "0" > $ML/boostpulse_duration 2>/dev/null
 echo "1" > $ML/fastlane 2>/dev/null
 echo "0" > $ML/align_windows 2>/dev/null
 echo "1" > $ML/use_migration_notif 2>/dev/null
 echo "1" > $ML/use_sched_load 2>/dev/null
 echo "0" > $ML/enable_prediction 2>/dev/null
 echo "1" > $ML/fast_ramp_down 2>/dev/null
 echo "95" > $ML/go_hispeed_load 2>/dev/null
 echo "10000" > $ML/timer_rate 2>/dev/null
 echo "0" > $ML/io_is_busy 2>/dev/null
 echo "40000" > $ML/min_sample_time 2>/dev/null
#############################################
 echo "0" > $MB/boost 2>/dev/null
 echo "0" > $MB/boostpulse_duration 2>/dev/null
 echo "1" > $MB/fastlane 2>/dev/null
 echo "0" > $MB/align_windows 2>/dev/null
 echo "1" > $MB/use_migration_notif 2>/dev/null
 echo "1" > $MB/use_sched_load 2>/dev/null
 echo "0" > $MB/enable_prediction 2>/dev/null
 echo "1" > $MB/fast_ramp_down 2>/dev/null
 echo "90" > $MB/go_hispeed_load 2>/dev/null
 echo "12000" > $MB/timer_rate 2>/dev/null
 echo "0" > $MB/io_is_busy 2>/dev/null
 echo "60000" > $MB/min_sample_time 2>/dev/null
 TUNE=Tuned
elif [ "$GOV" == "interactivex" ]; then
 echo "0" > $ML/boost 2>/dev/null
 echo "0" > $ML/boostpulse_duration 2>/dev/null
 echo "1" > $ML/fastlane 2>/dev/null
 echo "0" > $ML/align_windows 2>/dev/null
 echo "1" > $ML/use_migration_notif 2>/dev/null
 echo "1" > $ML/use_sched_load 2>/dev/null
 echo "0" > $ML/enable_prediction 2>/dev/null
 echo "1" > $ML/fast_ramp_down 2>/dev/null
 echo "95" > $ML/go_hispeed_load 2>/dev/null
 echo "10000" > $ML/timer_rate 2>/dev/null
 echo "0" > $ML/io_is_busy 2>/dev/null
 echo "40000" > $ML/min_sample_time 2>/dev/null
#############################################
 echo "0" > $MB/boost 2>/dev/null
 echo "0" > $MB/boostpulse_duration 2>/dev/null
 echo "1" > $MB/fastlane 2>/dev/null
 echo "0" > $MB/align_windows 2>/dev/null
 echo "1" > $MB/use_migration_notif 2>/dev/null
 echo "1" > $MB/use_sched_load 2>/dev/null
 echo "0" > $MB/enable_prediction 2>/dev/null
 echo "1" > $MB/fast_ramp_down 2>/dev/null
 echo "90" > $MB/go_hispeed_load 2>/dev/null
 echo "12000" > $MB/timer_rate 2>/dev/null
 echo "0" > $MB/io_is_busy 2>/dev/null
 echo "60000" > $MB/min_sample_time 2>/dev/null
 TUNE=Tuned
elif [ "$GOV" == "phantom" ]; then
 echo "0" > $ML/boost 2>/dev/null
 echo "0" > $ML/boostpulse_duration 2>/dev/null
 echo "1" > $ML/fastlane 2>/dev/null
 echo "0" > $ML/align_windows 2>/dev/null
 echo "1" > $ML/use_migration_notif 2>/dev/null
 echo "1" > $ML/use_sched_load 2>/dev/null
 echo "0" > $ML/enable_prediction 2>/dev/null
 echo "1" > $ML/fast_ramp_down 2>/dev/null
 echo "95" > $ML/go_hispeed_load 2>/dev/null
 echo "10000" > $ML/timer_rate 2>/dev/null
 echo "0" > $ML/io_is_busy 2>/dev/null
 echo "40000" > $ML/min_sample_time 2>/dev/null
#############################################
 echo "0" > $MB/boost 2>/dev/null
 echo "0" > $MB/boostpulse_duration 2>/dev/null
 echo "1" > $MB/fastlane 2>/dev/null
 echo "0" > $MB/align_windows 2>/dev/null
 echo "1" > $MB/use_migration_notif 2>/dev/null
 echo "1" > $MB/use_sched_load 2>/dev/null
 echo "0" > $MB/enable_prediction 2>/dev/null
 echo "1" > $MB/fast_ramp_down 2>/dev/null
 echo "90" > $MB/go_hispeed_load 2>/dev/null
 echo "12000" > $MB/timer_rate 2>/dev/null
 echo "0" > $MB/io_is_busy 2>/dev/null
 echo "60000" > $MB/min_sample_time 2>/dev/null
 TUNE=Tuned
elif [ "$GOV" == "ondemand" ]; then
 echo "90" > $MB/up_threshold 2>/dev/null
 echo "85" > $MB/up_threshold_any_cpu_load 2>/dev/null
 echo "85" > $MB/up_threshold_multi_core 2>/dev/null
 echo "75000" > $MB/sampling_rate 2>/dev/null
 echo "2" > $MB/sampling_down_factor 2>/dev/null
 echo "10" > $MB/down_differential 2>/dev/null
 echo "35" > $MB/freq_step 2>/dev/null
 echo "90" > $ML/up_threshold 2>/dev/null
 echo "85" > $ML/up_threshold_any_cpu_load 2>/dev/null
 echo "85" > $ML/up_threshold_multi_core 2>/dev/null
 echo "75000" > $ML/sampling_rate 2>/dev/null
 echo "2" > $ML/sampling_down_factor 2>/dev/null
 echo "10" > $ML/down_differential 2>/dev/null
 echo "35" > $ML/freq_step 2>/dev/null
 TUNE=Tuned
else
TUNE=Not_Tuned
fi;

chmod 0444 $ML
chmod 0444 $MB
echo "* CPU Power $CORES $GOV = $TUNE *" |  tee -a $LOG;
}

CPUULTRA() {
if [ "$GOV" == "smurfutil_flex" ]; then
 echo "1" > $ML/pl 2>/dev/null
 echo "3" > $ML/bit_shift1 2>/dev/null
 echo "2" > $ML/bit_shift1_2 2>/dev/null
 echo "10" > $ML/bit_shift2 2>/dev/null
 echo "25" > $ML/target_load1 2>/dev/null
 echo "75" > $ML/target_load2 2>/dev/null
 echo "1" > $MB/pl 2>/dev/null
 echo "3" > $MB/bit_shift1 2>/dev/null
 echo "2" > $MB/bit_shift1_2 2>/dev/null
 echo "10" > $MB/bit_shift2 2>/dev/null
 echo "25" > $MB/target_load1 2>/dev/null
 echo "75" > $MB/target_load2 2>/dev/null
 TUNE=Tuned
elif [ "$GOV" == "pixutil" ]; then
 echo "2000" > $MB/up_rate_limit_us 2>/dev/null
 echo "5000" > $MB/down_rate_limit_us 2>/dev/null
 echo "1" > $MB/iowait_boost_enable 2>/dev/null
 echo "2000" > $ML/up_rate_limit_us 2>/dev/null
 echo "5000" > $ML/down_rate_limit_us 2>/dev/null
 echo "1" > $MB/iowait_boost_enable 2>/dev/null
 TUNE=Tuned
elif [ "$GOV" == "pwrutilx" ]; then
 echo "2000" > $MB/up_rate_limit_us 2>/dev/null
 echo "5000" > $MB/down_rate_limit_us 2>/dev/null
 echo "1" > $MB/iowait_boost_enable 2>/dev/null
 echo "2000" > $ML/up_rate_limit_us 2>/dev/null
 echo "5000" > $ML/down_rate_limit_us 2>/dev/null
 echo "1" > $MB/iowait_boost_enable 2>/dev/null
 TUNE=Tuned
elif [ "$GOV" == "pixel_schedutil" ]; then
 echo "2000" > $MB/up_rate_limit_us 2>/dev/null
 echo "5000" > $MB/down_rate_limit_us 2>/dev/null
 echo "1" > $MB/iowait_boost_enable 2>/dev/null
 echo "2000" > $ML/up_rate_limit_us 2>/dev/null
 echo "5000" > $ML/down_rate_limit_us 2>/dev/null
 echo "1" > $MB/iowait_boost_enable 2>/dev/null
 TUNE=Tuned
elif [ "$GOV" == "helix_schedutil" ]; then
 echo "2000" > $MB/up_rate_limit_us 2>/dev/null
 echo "5000" > $MB/down_rate_limit_us 2>/dev/null
 echo "1" > $MB/iowait_boost_enable 2>/dev/null
 echo "2000" > $ML/up_rate_limit_us 2>/dev/null
 echo "5000" > $ML/down_rate_limit_us 2>/dev/null
 echo "1" > $MB/iowait_boost_enable 2>/dev/null
 TUNE=Tuned
elif [ "$GOV" == "schedutil" ]; then
 echo "2000" > $MB/up_rate_limit_us 2>/dev/null
 echo "5000" > $MB/down_rate_limit_us 2>/dev/null
 echo "1" > $MB/iowait_boost_enable 2>/dev/null
 echo "2000" > $ML/up_rate_limit_us 2>/dev/null
 echo "5000" > $ML/down_rate_limit_us 2>/dev/null
 echo "1" > $MB/iowait_boost_enable 2>/dev/null
 TUNE=Tuned
elif [ "$GOV" == "blu_active" ]; then
 echo "0" > $ML/boost 2>/dev/null
 echo "0" > $ML/boostpulse_duration 2>/dev/null
 echo "1" > $ML/fastlane 2>/dev/null
 echo "0" > $ML/align_windows 2>/dev/null
 echo "1" > $ML/use_migration_notif 2>/dev/null
 echo "1" > $ML/use_sched_load 2>/dev/null
 echo "0" > $ML/enable_prediction 2>/dev/null
 echo "1" > $ML/fast_ramp_down 2>/dev/null
 echo "90" > $ML/go_hispeed_load 2>/dev/null
 echo "10000" > $ML/timer_rate 2>/dev/null
 echo "0" > $ML/io_is_busy 2>/dev/null
 echo "40000" > $ML/min_sample_time 2>/dev/null
#############################################
 echo "0" > $MB/boost 2>/dev/null
 echo "0" > $MB/boostpulse_duration 2>/dev/null
 echo "1" > $MB/fastlane 2>/dev/null
 echo "0" > $MB/align_windows 2>/dev/null
 echo "1" > $MB/use_migration_notif 2>/dev/null
 echo "1" > $MB/use_sched_load 2>/dev/null
 echo "0" > $MB/enable_prediction 2>/dev/null
 echo "1" > $MB/fast_ramp_down 2>/dev/null
 echo "85" > $MB/go_hispeed_load 2>/dev/null
 echo "12000" > $MB/timer_rate 2>/dev/null
 echo "0" > $MB/io_is_busy 2>/dev/null
 echo "60000" > $MB/min_sample_time 2>/dev/null
 TUNE=Tuned
elif [ "$GOV" == "darkness" ]; then
 echo "0" > $ML/boost 2>/dev/null
 echo "0" > $ML/boostpulse_duration 2>/dev/null
 echo "1" > $ML/fastlane 2>/dev/null
 echo "0" > $ML/align_windows 2>/dev/null
 echo "1" > $ML/use_migration_notif 2>/dev/null
 echo "1" > $ML/use_sched_load 2>/dev/null
 echo "0" > $ML/enable_prediction 2>/dev/null
 echo "1" > $ML/fast_ramp_down 2>/dev/null
 echo "90" > $ML/go_hispeed_load 2>/dev/null
 echo "10000" > $ML/timer_rate 2>/dev/null
 echo "0" > $ML/io_is_busy 2>/dev/null
 echo "40000" > $ML/min_sample_time 2>/dev/null
#############################################
 echo "0" > $MB/boost 2>/dev/null
 echo "0" > $MB/boostpulse_duration 2>/dev/null
 echo "1" > $MB/fastlane 2>/dev/null
 echo "0" > $MB/align_windows 2>/dev/null
 echo "1" > $MB/use_migration_notif 2>/dev/null
 echo "1" > $MB/use_sched_load 2>/dev/null
 echo "0" > $MB/enable_prediction 2>/dev/null
 echo "1" > $MB/fast_ramp_down 2>/dev/null
 echo "85" > $MB/go_hispeed_load 2>/dev/null
 echo "12000" > $MB/timer_rate 2>/dev/null
 echo "0" > $MB/io_is_busy 2>/dev/null
 echo "60000" > $MB/min_sample_time 2>/dev/null
 TUNE=Tuned
elif [ "$GOV" == "elementalx" ]; then
 echo "5" > $MB/down_differential 2>/dev/null
 echo "0" > $MB/gboost 2>/dev/null
 echo "0" > $MB/input_event_timeout 2>/dev/null
 echo "40000" > $MB/sampling_rate 2>/dev/null
 echo "30000" > $MB/ui_sampling_rate 2>/dev/null
 echo "99" > $MB/up_threshold 2>/dev/null
 echo "99" > $MB/up_threshold_any_cpu_load 2>/dev/null
 echo "99" > $MB/up_threshold_multi_core 2>/dev/null
 echo "5" > $ML/down_differential 2>/dev/null
 echo "0" > $ML/gboost 2>/dev/null
 echo "0" > $ML/input_event_timeout 2>/dev/null
 echo "40000" > $ML/sampling_rate 2>/dev/null
 echo "30000" > $ML/ui_sampling_rate 2>/dev/null
 echo "99" > $ML/up_threshold 2>/dev/null
 echo "99" > $ML/up_threshold_any_cpu_load 2>/dev/null
 echo "99" > $ML/up_threshold_multi_core 2>/dev/null
 TUNE=Tuned
elif [ "$GOV" == "zzmoove" ]; then
 echo "75" > $MB/up_threshold 2>/dev/null
 echo "75" > $MB/smooth_up 2>/dev/null
 echo "0" > $MB/scaling_proportional 2>/dev/null
 echo "60000" $MB/sampling_rate_min 2>/dev/null
 echo "60000" $MB/sampling_rate 2>/dev/null
 echo "1" > $MB/sampling_down_factor 2>/dev/null
 echo "0" > $MB/ignore_nice_load 2>/dev/null
 echo "0" > $MB/fast_scaling_up 2>/dev/null
 echo "0" > $MB/fast_scaling_down 2>/dev/null
 echo "30" > $MB/down_threshold 2>/dev/null
 echo "75" > $ML/up_threshold 2>/dev/null
 echo "75" > $ML/smooth_up 2>/dev/null
 echo "0" > $ML/scaling_proportional 2>/dev/null
 echo "60000" $ML/sampling_rate_min 2>/dev/null
 echo "60000" $ML/sampling_rate 2>/dev/null
 echo "1" > $ML/sampling_down_factor 2>/dev/null
 echo "0" > $ML/ignore_nice_load 2>/dev/null 
 echo "0" > $ML/fast_scaling_up 2>/dev/null
 echo "0" > $ML/fast_scaling_down 2>/dev/null
 echo "30" > $ML/down_threshold 2>/dev/null
 TUNE=Tuned
elif [ "$GOV" == "interactiveplus" ]; then
 echo "0" > $ML/boost 2>/dev/null
 echo "0" > $ML/boostpulse_duration 2>/dev/null
 echo "1" > $ML/fastlane 2>/dev/null
 echo "0" > $ML/align_windows 2>/dev/null
 echo "1" > $ML/use_migration_notif 2>/dev/null
 echo "1" > $ML/use_sched_load 2>/dev/null
 echo "0" > $ML/enable_prediction 2>/dev/null
 echo "1" > $ML/fast_ramp_down 2>/dev/null
 echo "90" > $ML/go_hispeed_load 2>/dev/null
 echo "10000" > $ML/timer_rate 2>/dev/null
 echo "0" > $ML/io_is_busy 2>/dev/null
 echo "40000" > $ML/min_sample_time 2>/dev/null
#############################################
 echo "0" > $MB/boost 2>/dev/null
 echo "0" > $MB/boostpulse_duration 2>/dev/null
 echo "1" > $MB/fastlane 2>/dev/null
 echo "0" > $MB/align_windows 2>/dev/null
 echo "1" > $MB/use_migration_notif 2>/dev/null
 echo "1" > $MB/use_sched_load 2>/dev/null
 echo "0" > $MB/enable_prediction 2>/dev/null
 echo "1" > $MB/fast_ramp_down 2>/dev/null
 echo "85" > $MB/go_hispeed_load 2>/dev/null
 echo "12000" > $MB/timer_rate 2>/dev/null
 echo "0" > $MB/io_is_busy 2>/dev/null
 echo "60000" > $MB/min_sample_time 2>/dev/null
 TUNE=Tuned
elif [ "$GOV" == "cultivation" ]; then
 echo "0" > $ML/boost 2>/dev/null
 echo "0" > $ML/boostpulse_duration 2>/dev/null
 echo "1" > $ML/fastlane 2>/dev/null
 echo "0" > $ML/align_windows 2>/dev/null
 echo "1" > $ML/use_migration_notif 2>/dev/null
 echo "1" > $ML/use_sched_load 2>/dev/null
 echo "0" > $ML/enable_prediction 2>/dev/null
 echo "1" > $ML/fast_ramp_down 2>/dev/null
 echo "90" > $ML/go_hispeed_load 2>/dev/null
 echo "10000" > $ML/timer_rate 2>/dev/null
 echo "0" > $ML/io_is_busy 2>/dev/null
 echo "40000" > $ML/min_sample_time 2>/dev/null
#############################################
 echo "0" > $MB/boost 2>/dev/null
 echo "0" > $MB/boostpulse_duration 2>/dev/null
 echo "1" > $MB/fastlane 2>/dev/null
 echo "0" > $MB/align_windows 2>/dev/null
 echo "1" > $MB/use_migration_notif 2>/dev/null
 echo "1" > $MB/use_sched_load 2>/dev/null
 echo "0" > $MB/enable_prediction 2>/dev/null
 echo "1" > $MB/fast_ramp_down 2>/dev/null
 echo "85" > $MB/go_hispeed_load 2>/dev/null
 echo "12000" > $MB/timer_rate 2>/dev/null
 echo "0" > $MB/io_is_busy 2>/dev/null
 echo "60000" > $MB/min_sample_time 2>/dev/null
 TUNE=Tuned
elif [ "$GOV" == "interactive_pro" ]; then
 echo "0" > $ML/boost 2>/dev/null
 echo "0" > $ML/boostpulse_duration 2>/dev/null
 echo "1" > $ML/fastlane 2>/dev/null
 echo "0" > $ML/align_windows 2>/dev/null
 echo "1" > $ML/use_migration_notif 2>/dev/null
 echo "1" > $ML/use_sched_load 2>/dev/null
 echo "0" > $ML/enable_prediction 2>/dev/null
 echo "1" > $ML/fast_ramp_down 2>/dev/null
 echo "90" > $ML/go_hispeed_load 2>/dev/null
 echo "10000" > $ML/timer_rate 2>/dev/null
 echo "0" > $ML/io_is_busy 2>/dev/null
 echo "40000" > $ML/min_sample_time 2>/dev/null
#############################################
 echo "0" > $MB/boost 2>/dev/null
 echo "0" > $MB/boostpulse_duration 2>/dev/null
 echo "1" > $MB/fastlane 2>/dev/null
 echo "0" > $MB/align_windows 2>/dev/null
 echo "1" > $MB/use_migration_notif 2>/dev/null
 echo "1" > $MB/use_sched_load 2>/dev/null
 echo "0" > $MB/enable_prediction 2>/dev/null
 echo "1" > $MB/fast_ramp_down 2>/dev/null
 echo "85" > $MB/go_hispeed_load 2>/dev/null
 echo "12000" > $MB/timer_rate 2>/dev/null
 echo "0" > $MB/io_is_busy 2>/dev/null
 echo "60000" > $MB/min_sample_time 2>/dev/null
 TUNE=Tuned
elif [ "$GOV" == "interactivepro" ]; then
 echo "0" > $ML/boost 2>/dev/null
 echo "0" > $ML/boostpulse_duration 2>/dev/null
 echo "1" > $ML/fastlane 2>/dev/null
 echo "0" > $ML/align_windows 2>/dev/null
 echo "1" > $ML/use_migration_notif 2>/dev/null
 echo "1" > $ML/use_sched_load 2>/dev/null
 echo "0" > $ML/enable_prediction 2>/dev/null
 echo "1" > $ML/fast_ramp_down 2>/dev/null
 echo "90" > $ML/go_hispeed_load 2>/dev/null
 echo "10000" > $ML/timer_rate 2>/dev/null
 echo "0" > $ML/io_is_busy 2>/dev/null
 echo "40000" > $ML/min_sample_time 2>/dev/null
#############################################
 echo "0" > $MB/boost 2>/dev/null
 echo "0" > $MB/boostpulse_duration 2>/dev/null
 echo "1" > $MB/fastlane 2>/dev/null
 echo "0" > $MB/align_windows 2>/dev/null
 echo "1" > $MB/use_migration_notif 2>/dev/null
 echo "1" > $MB/use_sched_load 2>/dev/null
 echo "0" > $MB/enable_prediction 2>/dev/null
 echo "1" > $MB/fast_ramp_down 2>/dev/null
 echo "85" > $MB/go_hispeed_load 2>/dev/null
 echo "12000" > $MB/timer_rate 2>/dev/null
 echo "0" > $MB/io_is_busy 2>/dev/null
 echo "60000" > $MB/min_sample_time 2>/dev/null
 TUNE=Tuned
elif [ "$GOV" == "interactive" ]; then
 echo "0" > $ML/boost 2>/dev/null
 echo "0" > $ML/boostpulse_duration 2>/dev/null
 echo "1" > $ML/fastlane 2>/dev/null
 echo "0" > $ML/align_windows 2>/dev/null
 echo "1" > $ML/use_migration_notif 2>/dev/null
 echo "1" > $ML/use_sched_load 2>/dev/null
 echo "0" > $ML/enable_prediction 2>/dev/null
 echo "1" > $ML/fast_ramp_down 2>/dev/null
 echo "90" > $ML/go_hispeed_load 2>/dev/null
 echo "10000" > $ML/timer_rate 2>/dev/null
 echo "0" > $ML/io_is_busy 2>/dev/null
 echo "40000" > $ML/min_sample_time 2>/dev/null
#############################################
 echo "0" > $MB/boost 2>/dev/null
 echo "0" > $MB/boostpulse_duration 2>/dev/null
 echo "1" > $MB/fastlane 2>/dev/null
 echo "0" > $MB/align_windows 2>/dev/null
 echo "1" > $MB/use_migration_notif 2>/dev/null
 echo "1" > $MB/use_sched_load 2>/dev/null
 echo "0" > $MB/enable_prediction 2>/dev/null
 echo "1" > $MB/fast_ramp_down 2>/dev/null
 echo "85" > $MB/go_hispeed_load 2>/dev/null
 echo "12000" > $MB/timer_rate 2>/dev/null
 echo "0" > $MB/io_is_busy 2>/dev/null
 echo "60000" > $MB/min_sample_time 2>/dev/null
 TUNE=Tuned
elif [ "$GOV" == "interactivex" ]; then
 echo "0" > $ML/boost 2>/dev/null
 echo "0" > $ML/boostpulse_duration 2>/dev/null
 echo "1" > $ML/fastlane 2>/dev/null
 echo "0" > $ML/align_windows 2>/dev/null
 echo "1" > $ML/use_migration_notif 2>/dev/null
 echo "1" > $ML/use_sched_load 2>/dev/null
 echo "0" > $ML/enable_prediction 2>/dev/null
 echo "1" > $ML/fast_ramp_down 2>/dev/null
 echo "90" > $ML/go_hispeed_load 2>/dev/null
 echo "10000" > $ML/timer_rate 2>/dev/null
 echo "0" > $ML/io_is_busy 2>/dev/null
 echo "40000" > $ML/min_sample_time 2>/dev/null
#############################################
 echo "0" > $MB/boost 2>/dev/null
 echo "0" > $MB/boostpulse_duration 2>/dev/null
 echo "1" > $MB/fastlane 2>/dev/null
 echo "0" > $MB/align_windows 2>/dev/null
 echo "1" > $MB/use_migration_notif 2>/dev/null
 echo "1" > $MB/use_sched_load 2>/dev/null
 echo "0" > $MB/enable_prediction 2>/dev/null
 echo "1" > $MB/fast_ramp_down 2>/dev/null
 echo "85" > $MB/go_hispeed_load 2>/dev/null
 echo "12000" > $MB/timer_rate 2>/dev/null
 echo "0" > $MB/io_is_busy 2>/dev/null
 echo "60000" > $MB/min_sample_time 2>/dev/null
 TUNE=Tuned
elif [ "$GOV" == "phantom" ]; then
 echo "0" > $ML/boost 2>/dev/null
 echo "0" > $ML/boostpulse_duration 2>/dev/null
 echo "1" > $ML/fastlane 2>/dev/null
 echo "0" > $ML/align_windows 2>/dev/null
 echo "1" > $ML/use_migration_notif 2>/dev/null
 echo "1" > $ML/use_sched_load 2>/dev/null
 echo "0" > $ML/enable_prediction 2>/dev/null
 echo "1" > $ML/fast_ramp_down 2>/dev/null
 echo "90" > $ML/go_hispeed_load 2>/dev/null
 echo "10000" > $ML/timer_rate 2>/dev/null
 echo "0" > $ML/io_is_busy 2>/dev/null
 echo "40000" > $ML/min_sample_time 2>/dev/null
#############################################
 echo "0" > $MB/boost 2>/dev/null
 echo "0" > $MB/boostpulse_duration 2>/dev/null
 echo "1" > $MB/fastlane 2>/dev/null
 echo "0" > $MB/align_windows 2>/dev/null
 echo "1" > $MB/use_migration_notif 2>/dev/null
 echo "1" > $MB/use_sched_load 2>/dev/null
 echo "0" > $MB/enable_prediction 2>/dev/null
 echo "1" > $MB/fast_ramp_down 2>/dev/null
 echo "85" > $MB/go_hispeed_load 2>/dev/null
 echo "12000" > $MB/timer_rate 2>/dev/null
 echo "0" > $MB/io_is_busy 2>/dev/null
 echo "60000" > $MB/min_sample_time 2>/dev/null
 TUNE=Tuned
elif [ "$GOV" == "ondemand" ]; then
 echo "90" > $MB/up_threshold 2>/dev/null
 echo "85" > $MB/up_threshold_any_cpu_load 2>/dev/null
 echo "85" > $MB/up_threshold_multi_core 2>/dev/null
 echo "75000" > $MB/sampling_rate 2>/dev/null
 echo "2" > $MB/sampling_down_factor 2>/dev/null
 echo "10" > $MB/down_differential 2>/dev/null
 echo "35" > $MB/freq_step 2>/dev/null
 echo "90" > $ML/up_threshold 2>/dev/null
 echo "85" > $ML/up_threshold_any_cpu_load 2>/dev/null
 echo "85" > $ML/up_threshold_multi_core 2>/dev/null
 echo "75000" > $ML/sampling_rate 2>/dev/null
 echo "2" > $ML/sampling_down_factor 2>/dev/null
 echo "10" > $ML/down_differential 2>/dev/null
 echo "35" > $ML/freq_step 2>/dev/null
 TUNE=Tuned
else
TUNE=Not_Tuned
fi;

chmod 0444 $ML
chmod 0444 $MB
echo "* CPU Power $CORES $GOV = $TUNE *" |  tee -a $LOG;
}

if [ "$MODE" -eq "2" ]; then
 CPUBALANCE
elif [ "$MODE" -eq "1" ]; then
 CPUULTRA
elif [ "$MODE" -eq "3" ]; then
 CPUBATTERY
elif [ "$MODE" -eq "0" ]; then
 CPUBALANCE
fi;

# GPU OPTIMIZER =========================================#

if [ -d /sys/class/kgsl/kgsl-3d0 ]; then
 GPU=/sys/class/kgsl/kgsl-3d0
else
 GPU=/sys/devices/soc/*.qcom,kgsl-3d0/kgsl/kgsl-3d0
fi; 
if [ -e $GPU/max_pwrlevel ]; then 
 echo "0" > $GPU/max_pwrlevel
  #if [ -e $GPU/min_pwrlevel ] && [ -e $GPU/num_pwrlevels ]; then
  #MIN=$(cat $GPU/num_pwrlevels)
  #echo "$MIN" > $GPU/min_pwrlevel
  #fi;
 echo "* GPU Scale = Optimized *" | tee -a $LOG;
fi;
if [ -e /sys/module/simple_gpu_algorithm/parameters/simple_gpu_activate ]; then 
 echo "1" > /sys/module/simple_gpu_algorithm/parameters/simple_gpu_activate
 echo "Y" > /sys/module/simple_gpu_algorithm/parameters/simple_gpu_activate
 echo "* GPU Algorithm = Activated *" | tee -a $LOG;
fi;

#0 - off 1 - low 2 - medium 3 - High

GPUUL() {
if [ -e $GPU/devfreq/adrenoboost ]; then 
 echo "2" > $GPU/devfreq/adrenoboost
 echo "* AdrenoBoost = Medium *" | tee -a $LOG;
fi;
}
GPUBAT() {
if [ -e $GPU/devfreq/adrenoboost ]; then 
 echo "0" > $GPU/devfreq/adrenoboost
 echo "* AdrenoBoost = Off *" | tee -a $LOG;
fi;
}
GPUBAL() {
if [ -e $GPU/devfreq/adrenoboost ]; then 
 echo "1" > $GPU/devfreq/adrenoboost
 echo "* AdrenoBoost = Low *" | tee -a $LOG;
fi;
}

if [ "$MODE" -eq "2" ]; then
 GPUUL
elif [ "$MODE" -eq "1" ]; then
 GPUUL
elif [ "$MODE" -eq "3" ]; then
 GPUBAT
elif [ "$MODE" -eq "0" ]; then
 GPUBAL
fi;

if [ -e /sys/devices/14ac0000.mali/dvfs ]; then
 chmod 0000 /sys/devices/14ac0000.mali/dvfs
 chmod 0000 /sys/devices/14ac0000.mali/dvfs_max_lock
 chmod 0000 /sys/devices/14ac0000.mali/dvfs_min_lock
 echo "* Dyn Voltage / Freqs Scaling = Disabled *" |  tee -a $LOG;
fi;

# SPECIFIC EAS/HMP KERNEL =========================================#

easbatt() {
if [ "$eas" -eq "1" ]; then
 echo "64" > /proc/sys/kernel/sched_nr_migrate 2>/dev/null
 echo "1" > /proc/sys/kernel/sched_cstate_aware 2>/dev/null
 echo "0" > /proc/sys/kernel/sched_initial_task_util 2>/dev/null
 if [ -e /proc/sys/kernel/sched_use_walt_task_util ]; then	
  echo "0" > /proc/sys/kernel/sched_use_walt_task_util
  echo "0" > /proc/sys/kernel/sched_use_walt_cpu_util 2>/dev/null
  echo "0" > /proc/sys/kernel/sched_walt_init_task_load_pct 2>/dev/null
 fi;
 echo "* Specific EAS Kernel Part = Tuned *" | tee -a $LOG;
fi;
}

easbal() {
if [ "$eas" -eq "1" ]; then
 echo "96" > /proc/sys/kernel/sched_nr_migrate 2>/dev/null
 echo "1" > /proc/sys/kernel/sched_cstate_aware 2>/dev/null
 echo "0" > /proc/sys/kernel/sched_initial_task_util 2>/dev/null
 if [ -e /proc/sys/kernel/sched_use_walt_task_util ]; then
  echo "1" > /proc/sys/kernel/sched_use_walt_task_util
  echo "1" > /proc/sys/kernel/sched_use_walt_cpu_util 2>/dev/null
  echo "0" > /proc/sys/kernel/sched_walt_init_task_load_pct 2>/dev/null
 fi;
 echo "* Specific EAS Kernel Part = Tuned *" | tee -a $LOG;
fi;
}

easperf() {
if [ "$eas" -eq "1" ]; then
 echo "128" > /proc/sys/kernel/sched_nr_migrate 2>/dev/null
 echo "1" > /proc/sys/kernel/sched_cstate_aware 2>/dev/null
 echo "10" > /proc/sys/kernel/sched_initial_task_util 2>/dev/null
 if [ -e /proc/sys/kernel/sched_autogroup_enabled ]; then
  echo "0" > /proc/sys/kernel/sched_autogroup_enabled
 fi;
 if [ -e /proc/sys/kernel/sched_is_big_little ]; then
  echo "1" > /proc/sys/kernel/sched_is_big_little	
 fi;
 if [ -e /proc/sys/kernel/sched_boost ]; then
  echo "0" > /proc/sys/kernel/sched_boost
 fi;
 if [ -e /proc/sys/kernel/sched_use_walt_task_util ]; then
  echo "1" > /proc/sys/kernel/sched_use_walt_task_util
  echo "1" > /proc/sys/kernel/sched_use_walt_cpu_util 2>/dev/null
  echo "10" > /proc/sys/kernel/sched_walt_init_task_load_pct	2>/dev/null
 fi;
 echo "* Specific EAS Kernel Part = Tuned *" | tee -a $LOG;
fi;
}

hmpbatt() {
if [ "$eas" -eq "0" ]; then
 echo "1" > /proc/sys/kernel/sched_enable_thread_grouping	2>/dev/null
 echo "40" > /proc/sys/kernel/sched_big_waker_task_load 2>/dev/null
 echo "2" > /proc/sys/kernel/sched_window_stats_policy	 2>/dev/null
 echo "4" > /proc/sys/kernel/sched_ravg_hist_size	 2>/dev/null
 echo "95" > /proc/sys/kernel/sched_upmigrate	 2>/dev/null
 echo "75" > /proc/sys/kernel/sched_downmigrate 2>/dev/null
 echo "15" > /proc/sys/kernel/sched_small_wakee_task_load 2>/dev/null
 echo "0" > /proc/sys/kernel/sched_init_task_load 2>/dev/null
 echo "3" > /proc/sys/kernel/sched_spill_nr_run	 2>/dev/null
 echo "99" > /proc/sys/kernel/sched_spill_load 2>/dev/null
 echo "1" > /proc/sys/kernel/sched_enable_thread_grouping	2>/dev/null
 echo "1" > /proc/sys/kernel/sched_restrict_cluster_spill	2>/dev/null
 if [ -e /proc/sys/kernel/sched_enable_power_aware ]; then
  echo "1" > /proc/sys/kernel/sched_enable_power_aware
 fi;
 if [ -e /proc/sys/kernel/sched_upmigrate_min_nice ]; then
  echo "0" > /proc/sys/kernel/sched_upmigrate_min_nice
 fi;
 if [ -e /proc/sys/kernel/sched_wakeup_load_threshold ]; then
  echo "110" > /proc/sys/kernel/sched_wakeup_load_threshold
 fi;
 echo "10" > /proc/sys/kernel/sched_rr_timeslice_ms
 if [ -e /proc/sys/kernel/sched_migration_fixup ]; then				
  echo "1" > /proc/sys/kernel/sched_migration_fixup
 fi;
 if [ -e /proc/sys/kernel/sched_boost ]; then
  echo "0" > /proc/sys/kernel/sched_boost
 fi;
 if [ -e /proc/sys/kernel/sched_heavy_task ]; then
  echo "100" > /proc/sys/kernel/sched_heavy_task
 fi;
 if [ -e /proc/sys/kernel/sched_enable_power_aware ]; then
  echo "1" > /proc/sys/kernel/sched_enable_power_aware
 fi;
 if [ -e /proc/sys/kernel/sched_small_task ]; then
  echo "10" > /proc/sys/kernel/sched_small_task
 fi;
 if [ -e /proc/sys/kernel/sched_migration_fixup ]; then
  echo "1" > /proc/sys/kernel/sched_migration_fixup
 fi;
 if [ -e /proc/sys/kernel/sched_boost ]; then
  echo "0" > /proc/sys/kernel/sched_boost
 fi;
 echo "* Specific HMP Kernel Part = Tuned *" | tee -a $LOG;
fi;
}

hmpbal() {
if [ "$eas" -eq "0" ]; then
 echo "1" > /proc/sys/kernel/sched_enable_thread_grouping	2>/dev/null
 echo "35" > /proc/sys/kernel/sched_big_waker_task_load 2>/dev/null
 echo "3" > /proc/sys/kernel/sched_window_stats_policy 2>/dev/null
 echo "4" > /proc/sys/kernel/sched_ravg_hist_size	 2>/dev/null
 echo "3" > /proc/sys/kernel/sched_spill_nr_run 2>/dev/null
 echo "65" > /proc/sys/kernel/sched_spill_load 2>/dev/null
 echo "1" > /proc/sys/kernel/sched_enable_thread_grouping 2>/dev/null
 echo "1" > /proc/sys/kernel/sched_restrict_cluster_spill 2>/dev/null
 echo "80" > /proc/sys/kernel/sched_upmigrate 2>/dev/null
 echo "65" > /proc/sys/kernel/sched_downmigrate 2>/dev/null
 echo "15" > /proc/sys/kernel/sched_small_wakee_task_load 	2>/dev/null
 echo "0" > /proc/sys/kernel/sched_init_task_load 2>/dev/null
 if [ -e /proc/sys/kernel/sched_enable_power_aware ]; then
  echo "1" > /proc/sys/kernel/sched_enable_power_aware
 fi;
 if [ -e /proc/sys/kernel/sched_upmigrate_min_nice ]; then
  echo "9" > /proc/sys/kernel/sched_upmigrate_min_nice
 fi;
 if [ -e /proc/sys/kernel/sched_wakeup_load_threshold ]; then
  echo "110" > /proc/sys/kernel/sched_wakeup_load_threshold
 fi; 
 echo "10" > /proc/sys/kernel/sched_rr_timeslice_ms
 if [ -e /proc/sys/kernel/sched_migration_fixup ]; then
  echo "1" > /proc/sys/kernel/sched_migration_fixup
 fi;
 if [ -e /proc/sys/kernel/sched_boost ]; then
  echo "0" > /proc/sys/kernel/sched_boost
 fi;
 if [ -e /proc/sys/kernel/sched_heavy_task ]; then
  echo "65" > /proc/sys/kernel/sched_heavy_task
 fi;
 if [ -e /proc/sys/kernel/sched_enable_power_aware ]; then
  echo "1" > /proc/sys/kernel/sched_enable_power_aware
 fi;		
 if [ -e /proc/sys/kernel/sched_small_task ]; then
  echo "10" > /proc/sys/kernel/sched_small_task
 fi;
 if [ -e /proc/sys/kernel/sched_migration_fixup ]; then
  echo "1" > /proc/sys/kernel/sched_migration_fixup
 fi;			
 if [ -e /proc/sys/kernel/sched_boost ]; then
  echo "0" > /proc/sys/kernel/sched_boost
 fi;
  echo "* Specific HMP Kernel Part = Tuned *" | tee -a $LOG;
fi;
}

hmpperf() {
if [ "$eas" -eq "0" ]; then
 echo "1" > /proc/sys/kernel/sched_enable_thread_grouping 2>/dev/null
 echo "30" > /proc/sys/kernel/sched_big_waker_task_load 2>/dev/null
 echo "3" > /proc/sys/kernel/sched_window_stats_policy 2>/dev/null
 echo "4" > /proc/sys/kernel/sched_ravg_hist_size 2>/dev/null
 echo "3" > /proc/sys/kernel/sched_spill_nr_run 2>/dev/null
 echo "55" > /proc/sys/kernel/sched_spill_load 2>/dev/null
 echo "1" > /proc/sys/kernel/sched_enable_thread_grouping 2>/dev/null
 echo "1" > /proc/sys/kernel/sched_restrict_cluster_spill 2>/dev/null
 echo "50" > /proc/sys/kernel/sched_upmigrate 2>/dev/null
 echo "15" > /proc/sys/kernel/sched_downmigrate 2>/dev/null
 echo "15" > /proc/sys/kernel/sched_small_wakee_task_load 2>/dev/null
 echo "0" > /proc/sys/kernel/sched_init_task_load 2>/dev/null
 if [ -e /proc/sys/kernel/sched_enable_power_aware ]; then
  echo "1" > /proc/sys/kernel/sched_enable_power_aware
 fi;
 if [ -e /proc/sys/kernel/sched_upmigrate_min_nice ]; then
  echo "9" > /proc/sys/kernel/sched_upmigrate_min_nice
 fi;
 if [ -e /proc/sys/kernel/sched_wakeup_load_threshold ]; then
  echo "110" > /proc/sys/kernel/sched_wakeup_load_threshold
 fi;
 echo "30" > /proc/sys/kernel/sched_rr_timeslice_ms
 if [ -e /proc/sys/kernel/sched_migration_fixup ]; then
  echo "1" > /proc/sys/kernel/sched_migration_fixup
 fi; 
 if [ -e /proc/sys/kernel/sched_boost ]; then
  echo "0" > /proc/sys/kernel/sched_boost
 fi;
 if [ -e /proc/sys/kernel/sched_heavy_task ]; then
  echo "55" > /proc/sys/kernel/sched_heavy_task
 fi;			
 if [ -e /proc/sys/kernel/sched_enable_power_aware ]; then
  echo "1" > /proc/sys/kernel/sched_enable_power_aware
 fi;			
 if [ -e /proc/sys/kernel/sched_small_task ]; then
  echo "10" > /proc/sys/kernel/sched_small_task
 fi;
 if [ -e /proc/sys/kernel/sched_migration_fixup ]; then
  echo "1" > /proc/sys/kernel/sched_migration_fixup
 fi;
 if [ -e /proc/sys/kernel/sched_boost ]; then
  echo "0" > /proc/sys/kernel/sched_boost
 fi;
 echo "* Specific HMP Kernel Part = Tuned *" | tee -a $LOG;
fi;
}

if [ "$MODE" -eq "2" ]; then
 easperf
 hmpperf
elif [ "$MODE" -eq "1" ]; then
 easperf
 hmpperf
elif [ "$MODE" -eq "3" ]; then
 easbatt
 hmpbatt
elif [ "$MODE" -eq "0" ]; then
 easbal
 hmpbal
fi;

# LPM LEVELS =========================================#

LPM=/sys/module/lpm_levels

if [ -d $LPM/parameters ]; then
 echo "4" > $LPM/enable_low_power/l2 2>/dev/null
 echo "Y" > $LPM/parameters/lpm_prediction 2>/dev/null
 echo "0" > $LPM/parameters/sleep_time_override 2>/dev/null
 echo "N" > $LPM/parameters/sleep_disable 2>/dev/null
 echo "N" > $LPM/parameters/menu_select 2>/dev/null
 echo "N" > $LPM/parameters/print_parsed_dt 2>/dev/null
 echo "100" > $LPM/parameters/red_stddev 2>/dev/null
 echo "100" > $LPM/parameters/tmr_add 2>/dev/null
 echo "Y" > $LPM/system/system-pc/idle-enabled 2>/dev/null
 echo "Y" > $LPM/system/system-pc/suspend_enabled 2>/dev/null
 echo "Y" > $LPM/system/system-wifi/idle-enabled 2>/dev/null
 echo "Y" > $LPM/system/system-wifi/suspend_enabled 2>/dev/null
 echo "N" > $LPM/system/perf/perf-l2-dynret/idle-enabled 2>/dev/null
 echo "Y" > $LPM/system/perf/perf-l2-dynret/suspend_enabled 2>/dev/null
 echo "Y" > $LPM/system/perf/perf-l2-pc/idle-enabled 2>/dev/null
 echo "Y" > $LPM/system/perf/perf-l2-pc/suspend_enabled 2>/dev/null
 echo "N" > $LPM/system/perf/perf-l2-ret/idle-enabled 2>/dev/null
 echo "Y" > $LPM/system/perf/perf-l2-ret/suspend_enabled 2>/dev/null
 echo "Y" > $LPM/system/perf/perf-l2-wifi/idle-enabled 2>/dev/null
 echo "Y" > $LPM/system/perf/perf-l2-wifi/suspend_enabled 2>/dev/null
 echo "N" > $LPM/system/pwr/pwr-l2-dynret/idle-enabled 2>/dev/null
 echo "Y" > $LPM/system/pwr/pwr-l2-dynret/suspend_enabled 2>/dev/null
 echo "Y" > $LPM/system/pwr/pwr-l2-pc/idle-enabled 2>/dev/null
 echo "Y" > $LPM/system/pwr/pwr-l2-pc/suspend_enabled 2>/dev/null
 echo "N" > $LPM/system/pwr/pwr-l2-ret/idle-enabled 2>/dev/null
 echo "Y" > $LPM/system/pwr/pwr-l2-ret/suspend_enabled 2>/dev/null
 echo "Y" > $LPM/system/pwr/pwr-l2-wifi/idle-enabled 2>/dev/null
 echo "Y" > $LPM/system/pwr/pwr-l2-wifi/suspend_enabled 2>/dev/null
for i in 4 5 6 7; do
 echo "Y" > $LPM/system/perf/cpu$i/pc/idle-enabled 2>/dev/null
 echo "Y" > $LPM/system/perf/cpu$i/pc/suspend_enabled 2>/dev/null
 echo "N" > $LPM/system/perf/cpu$i/ret/idle-enabled 2>/dev/null
 echo "Y" > $LPM/system/perf/cpu$i/ret/suspend_enabled 2>/dev/null
 echo "Y" > $LPM/system/perf/cpu$i/wfi/idle-enabled 2>/dev/null
 echo "Y" > $LPM/system/perf/cpu$i/wfi/suspend_enabled 2>/dev/null
done
for i in 0 1 2 3; do
 echo "Y" > $LPM/system/pwr/cpu$i/pc/idle-enabled 2>/dev/null
 echo "Y" > $LPM/system/pwr/cpu$i/pc/suspend_enabled 2>/dev/null
 echo "N" > $LPM/system/pwr/cpu$i/ret/idle-enabled 2>/dev/null
 echo "Y" > $LPM/system/pwr/cpu$i/ret/suspend_enabled 2>/dev/null
 echo "Y" > $LPM/system/pwr/cpu$i/wfi/idle-enabled 2>/dev/null
 echo "Y" > $LPM/system/pwr/cpu$i/wfi/suspend_enabled 2>/dev/null
done
echo "* Low Power Levels = Adjusted *" | tee  -a $LOG;
fi;

# DALVIK TUNER =========================================#

if [ ! "$current1" = "" ]; then
 setprop dalvik.vm.dex2oat-threads $core
 echo "* Dalvik Tuner Dex2oat = Activated *" |  tee -a $LOG;
fi;
if [ ! "$current2" = "" ]; then
 setprop dalvik.vm.boot-dex2oat-threads $core
 echo "* Dalvik Tuner Dex2oat Boot = Activated *" |  tee -a $LOG;
fi;
if [ ! "$current3" = "" ]; then
 setprop persist.dalvik.vm.dex2oat-threads $core
 echo "* Dalvik Tuner Pers Dex2oat = Activated *" |  tee -a $LOG;
fi;
if [ ! "$current4" = "" ]; then
 setprop dalvik.vm.image-dex2oat-threads $core
 echo "* Dalvik Tuner Img Dex2oat = Activated *" |  tee -a $LOG;
fi;
if [ ! "$current5" = "" ]; then
 setprop ro.sys.fw.dex2oat_thread_count $core
 echo "* Dalvik Tuner Fw Dex2oat = Activated *" |  tee -a $LOG;
fi;

# ZRAM ZSWAP CONFIGURATION =========================================#
# Function

swapOFF() {
if [ -e /dev/block/zram0 ]; then
 swapoff /dev/block/zram0
 setprop vnswap.enabled false
 setprop ro.config.zram false
 setprop ro.config.zram.support false
 setprop zram.disksize 0
 echo "* ZRAM0 = Disabled *" |  tee -a $LOG;
fi;
if [ -e /dev/block/zram1 ]; then
 swapoff /dev/block/zram1
 setprop vnswap.enabled false
 setprop ro.config.zram false
 setprop ro.config.zram.support false
 setprop zram.disksize 0
 echo "* ZRAM1 = Disabled *" |  tee -a $LOG;
fi;
if [ -e /dev/block/zram2 ]; then
 swapoff /dev/block/zram2
 setprop vnswap.enabled false
 setprop ro.config.zram false
 setprop ro.config.zram.support false
 setprop zram.disksize 0
 echo "* ZRAM2 = Disabled *" |  tee -a $LOG;
fi;
}

swapON() {
if [ -e /dev/block/zram0 ]; then
 swapoff /dev/block/zram0
 echo "1" > /sys/block/zram0/reset
 echo "$((ZR*1024*2048))" > /sys/block/zram0/disksize
 mkswap /dev/block/zram0
 swapon /dev/block/zram0
 #sysctl -e -w vm.swappiness=20
 setprop vnswap.enabled true
 setprop ro.config.zram true
 setprop ro.config.zram.support true
 setprop zram.disksize $ZR
 echo "* ZRAM0 = Activated for $ZR MB *" |  tee -a $LOG;
fi;
if [ -e /dev/block/zram1 ]; then
 swapoff /dev/block/zram1
 echo "1" > /sys/block/zram1/reset
 echo "$((ZR*1024*3048))" > /sys/block/zram1/disksize
 mkswap /dev/block/zram1
 swapon /dev/block/zram1
 #sysctl -e -w vm.swappiness=20
 setprop vnswap.enabled true
 setprop ro.config.zram true
 setprop ro.config.zram.support true
 setprop zram.disksize $ZR
 echo "* ZRAM1 = Activated for $ZR MB *" |  tee -a $LOG;
fi;
if [ -e /dev/block/zram2 ]; then
 swapoff /dev/block/zram2
 echo "1" > /sys/block/zram2/reset
 echo "$((ZR*1024*2048))" > /sys/block/zram2/disksize
 mkswap /dev/block/zram2
 swapon /dev/block/zram2
 #sysctl -e -w vm.swappiness=20
 setprop vnswap.enabled true
 setprop ro.config.zram true
 setprop ro.config.zram.support true
 setprop zram.disksize $ZR
 echo "* ZRAM2 = Activated for $ZR MB *" |  tee -a $LOG;
fi;
}

zswapON() {
if [ -e /sys/module/zswap/parameters/enabled ]; then
 if [ -e /sys/module/zswap/parameters/enabled ]; then
  echo "Y" > /sys/module/zswap/parameters/enabled
 fi;
 if [ -e /sys/module/zswap/parameters/max_pool_percent ]; then
  echo "30" > /sys/module/zswap/parameters/max_pool_percent
 fi;
 #sysctl -e -w vm.swappiness=30
 echo "* ZSwap = Activated *" |  tee -a $LOG;
fi;
}

zswapOFF() {
if [ -e /sys/module/zswap/parameters/enabled ]; then
 echo "N" > /sys/module/zswap/parameters/enabled
 echo "* ZSwap = Disabled *" |  tee -a $LOG;
fi;
}

ZR=$(($MEM/4))

if [ "$CP" -eq "1" ]; then
 swapON 2>/dev/null
 zswapON 2>/dev/null
elif [ "$CP" -eq "2" ]; then
 swapOFF 2>/dev/null
 zswapOFF 2>/dev/null
elif [ "$CP" -eq "0" ]; then
 if [ "$RAMCAP" -eq "0" ]; then
  swapON 2>/dev/null
  zswapON 2>/dev/null
 else
  swapOFF 2>/dev/null
  zswapOFF 2>/dev/null
 fi;
fi;

if [ -e /sys/kernel/mm/uksm/run ]; then
 echo "0" > /sys/kernel/mm/uksm/run
 setprop ro.config.ksm.support false
 echo "* UKSM = Disabled *" |  tee -a $LOG;
elif [ -e /sys/kernel/mm/ksm/run ]; then
 echo "0" > /sys/kernel/mm/ksm/run
 setprop ro.config.ksm.support false
 echo "* KSM = Disabled *" |  tee -a $LOG;
fi;

if [ -e /dev/block/vnswap0 ]; then
 swapoff /dev/block/vnswap0
 setprop vnswap.enabled false
 echo "* Touchwiz Samsung Swap = Disabled *" |  tee -a $LOG;
fi;

# DEEP SLEEP ENHANCEMENT =========================================#

for i in $(ls /sys/class/scsi_disk/); do
 echo "temporary none" > /sys/class/scsi_disk/"$i"/cache_type
 if [ -e /sys/class/scsi_disk/"$i"/cache_type ]; then
  DP=1
 fi;
done

if [ "$DP" -eq "1" ]; then
 echo "* Deep Sleep Enhancement = Fixed *" |  tee -a $LOG;
fi;

# KERNEL TASK  =========================================#
 
if [ -e /sys/kernel/debug/sched_features ]; then
 echo "NO_NORMALIZED_SLEEPER" > /sys/kernel/debug/sched_features
 echo "GENTLE_FAIR_SLEEPERS" > /sys/kernel/debug/sched_features
 echo "NO_NEW_FAIR_SLEEPERS" > /sys/kernel/debug/sched_features
 echo "WAKEUP_PREEMPT" > /sys/kernel/debug/sched_features
 echo "NO_AFFINE_WAKEUPS" > /sys/kernel/debug/sched_features
 echo "* CPU Scheduler = Adjusted *" |  tee -a $LOG;
fi;

if [ -e /sys/kernel/sched/gentle_fair_sleepers ]; then
 echo "0" > /sys/kernel/sched/gentle_fair_sleepers
 echo "* Gentle Fair Sleeper = Disabled *" |  tee -a $LOG;
fi;

# NETWORK SPEED =========================================#

echo "$CC" > /proc/sys/net/ipv4/tcp_congestion_control
echo "* Network TCP $CC = Activated *" |  tee -a $LOG;
sysctl -e -w net.ipv4.tcp_timestamps=0
sysctl -e -w net.ipv4.tcp_sack=1
sysctl -e -w net.ipv4.tcp_fack=1
sysctl -e -w net.ipv4.tcp_window_scaling=1
echo "* IPv4 Traffic Performance = Improved *" |  tee -a $LOG;


# FIX GP SERVICES =========================================#

pm enable com.google.android.gms/.update.SystemUpdateActivity
pm enable com.google.android.gms/.update.SystemUpdateService
pm enable com.google.android.gms/.update.SystemUpdateService$ActiveReceiver
pm enable com.google.android.gms/.update.SystemUpdateService$Receiver
pm enable com.google.android.gms/.update.SystemUpdateService$SecretCodeReceiver
pm enable com.google.android.gsf/.update.SystemUpdateActivity
pm enable com.google.android.gsf/.update.SystemUpdatePanoActivity
pm enable com.google.android.gsf/.update.SystemUpdateService
pm enable com.google.android.gsf/.update.SystemUpdateService$Receiver
pm enable com.google.android.gsf/.update.SystemUpdateService$SecretCodeReceiver
echo "* Fix GP Services = Activated *" |  tee -a $LOG;

# WAKELOCKS =========================================#

if [ -e /sys/module/bcmdhd/parameters/wlrx_divide ]; then
 echo "4" > /sys/module/bcmdhd/parameters/wlrx_divide 2>/dev/null
 echo "4" > /sys/module/bcmdhd/parameters/wlctrl_divide 2>/dev/null
 echo "* Wlan Wakelocks = Blocked *" |  tee -a $LOG;
fi;

if [ -e /sys/module/wakeup/parameters/enable_bluetooth_timer ]; then
 echo "Y" > /sys/module/wakeup/parameters/enable_bluetooth_timer 2>/dev/null
 echo "N" > /sys/module/wakeup/parameters/enable_ipa_ws 2>/dev/null
 echo "Y" > /sys/module/wakeup/parameters/enable_netlink_ws 2>/dev/null
 echo "Y" > /sys/module/wakeup/parameters/enable_netmgr_wl_ws 2>/dev/null
 echo "N" > /sys/module/wakeup/parameters/enable_qcom_rx_wakelock_ws 2>/dev/null
 echo "Y" > /sys/module/wakeup/parameters/enable_timerfd_ws 2>/dev/null
 echo "N" > /sys/module/wakeup/parameters/enable_wlan_extscan_wl_ws 2>/dev/null
 echo "N" > /sys/module/wakeup/parameters/enable_wlan_wow_wl_ws 2>/dev/null
 echo "N" > /sys/module/wakeup/parameters/enable_wlan_ws 2>/dev/null
 echo "N" > /sys/module/wakeup/parameters/enable_netmgr_wl_ws 2>/dev/null
 echo "N" > /sys/module/wakeup/parameters/enable_wlan_wow_wl_ws 2>/dev/null
 echo "N" > /sys/module/wakeup/parameters/enable_wlan_ipa_ws 2>/dev/null
 echo "N" > /sys/module/wakeup/parameters/enable_wlan_pno_wl_ws 2>/dev/null
 echo "N" > /sys/module/wakeup/parameters/enable_wcnss_filter_lock_ws 2>/dev/null
 echo "* Wakelocks = Blocked *" |  tee -a $LOG;
fi;

if [ -e /sys/class/misc/boeffla_wakelock_blocker/wakelock_blocker ]; then
 echo "IPA_WS;wlan;netmgr_wl;qcom_rx_wakelock;wlan_wow_wl;wlan_extscan_wl;bam_dmux_wakelock;" > /sys/class/misc/boeffla_wakelock_blocker/wakelock_blocker
 echo "* Boeffla_Wakelock_Blocker = Activated *" |  tee -a $LOG;
fi;

# ZRAM/ZSWAP/SWAP ADJUSTEMENTS =========================================#

ZR=$(grep -l zram0 /proc/swaps)
SW=$(grep -l swap /proc/swaps)
ZS=$(grep -l zswap /proc/swaps)

if [ -e /proc/swaps ]; then
 if [ "$ZR" == "/proc/swaps" ]; then
  sysctl -e -w vm.swappiness=15
  #sysctl -e -w vm.page-cluster=2
  echo "* Virtual Swap Compressor = Adjusted*" | tee  -a $LOG;
 elif [ "$SW" == "/proc/swaps" ]; then
  sysctl -e -w vm.swappiness=15
  #sysctl -e -w vm.page-cluster=2
  echo "* Swap Partition Exchanged = Adjusted *" | tee  -a $LOG;
 elif [ "$ZS" == "/proc/swaps" ]; then
  sysctl -e -w vm.swappiness=15
  #sysctl -e -w vm.page-cluster=2
  echo "* Compressed Writeback Cache = Adjusted *" | tee  -a $LOG;
 fi;
fi;

# KERNEL / MODULES / MASKS DEBUGGERS OFF =========================================#

for i in $(find /sys/ -name debug_mask); do
 echo "0" > $i
done
for i in $(find /sys/ -name debug_level); do
 echo "0" > $i
done
for i in $(find /sys/ -name edac_mc_log_ce); do
 echo "0" > $i
done
for i in $(find /sys/ -name edac_mc_log_ue); do
 echo "0" > $i
done
for i in $(find /sys/ -name enable_event_log); do
 echo "0" > $i
done
for i in $(find /sys/ -name log_ecn_error); do
 echo "0" > $i
done
for i in $(find /sys/ -name snapshot_crashdumper); do
 echo "0" > $i
done
if [ -e /sys/module/logger/parameters/log_mode ]; then
 echo "2" > /sys/module/logger/parameters/log_mode;
fi;

echo "* Debug Logging Killer = Executed *" |  tee -a $LOG;

# MISC MODES =========================================#

if [ -e /sys/class/lcd/panel/power_reduce ]; then
 echo "1" > /sys/class/lcd/panel/power_reduce
 echo "* LCD Power = Activated *" |  tee -a $LOG;
fi;

if [ "$MODE" -eq "2" ]; then
 if [ -e /sys/module/workqueue/parameters/power_efficient ]; then
  chmod 0644 /sys/module/workqueue/parameters/power_efficient
  echo "N" > /sys/module/workqueue/parameters/power_efficient
  echo "* Power Save Workqueues = Disabled *" |  tee -a $LOG;
 fi;
 if [ -e /sys/module/adreno_idler/parameters/adreno_idler_active ]; then
  chmod 0644 /sys/module/adreno_idler/parameters/adreno_idler_active
  echo "0" > /sys/module/adreno_idler/parameters/adreno_idler_active
  echo "* Adreno Idler = Disabled *" |  tee -a $LOG;
 fi;
 if [ -e /sys/kernel/sched/arch_power ]; then
  echo "0" > /sys/kernel/sched/arch_power
  echo "* Arch Power = Disabled *" |  tee -a $LOG;
 fi;
elif [ "$MODE" -eq "1" ]; then
 if [ -e /sys/module/workqueue/parameters/power_efficient ]; then
  chmod 0644 /sys/module/workqueue/parameters/power_efficient
  echo "N" > /sys/module/workqueue/parameters/power_efficient
  echo "* Power Save Workqueues = Disabled *" |  tee -a $LOG;
 fi;
 if [ -e /sys/module/adreno_idler/parameters/adreno_idler_active ]; then
  chmod 0644 /sys/module/adreno_idler/parameters/adreno_idler_active
  echo "0" > /sys/module/adreno_idler/parameters/adreno_idler_active
  echo "* Adreno Idler = Disabled *" |  tee -a $LOG;
 fi;
 if [ -e /sys/kernel/sched/arch_power ]; then
  echo "0" > /sys/kernel/sched/arch_power
  echo "* Arch Power = Disabled *" |  tee -a $LOG;
 fi;
elif [ "$MODE" -eq "3" ]; then
 if [ -e /sys/module/workqueue/parameters/power_efficient ]; then
  chmod 0644 /sys/module/workqueue/parameters/power_efficient
  echo "Y" > /sys/module/workqueue/parameters/power_efficient
  echo "* Power Save Workqueues = Enabled *" |  tee -a $LOG;
 fi;
 if [ -e /sys/module/adreno_idler/parameters/adreno_idler_active ]; then
  chmod 0644 /sys/module/adreno_idler/parameters/adreno_idler_active
  echo "1" > /sys/module/adreno_idler/parameters/adreno_idler_active
  echo "* Adreno Idler = Enabled *" |  tee -a $LOG;
 fi;
 if [ -e /sys/kernel/sched/arch_power ]; then
  echo "1" > /sys/kernel/sched/arch_power
  echo "* Arch Power = Enabled *" |  tee -a $LOG;
 fi;
elif [ "$MODE" -eq "0" ]; then
 if [ -e /sys/module/workqueue/parameters/power_efficient ]; then
  chmod 0644 /sys/module/workqueue/parameters/power_efficient
  echo "Y" > /sys/module/workqueue/parameters/power_efficient
  echo "* Power Save Workqueues = Enabled *" |  tee -a $LOG;
 fi;
 if [ -e /sys/module/adreno_idler/parameters/adreno_idler_active ]; then
  chmod 0644 /sys/module/adreno_idler/parameters/adreno_idler_active
  echo "0" > /sys/module/adreno_idler/parameters/adreno_idler_active
  echo "* Adreno Idler = Disabled *" |  tee -a $LOG;
 fi;
 if [ -e /sys/kernel/sched/arch_power ]; then
  echo "0" > /sys/kernel/sched/arch_power
  echo "* Arch Power = Disabled *" |  tee -a $LOG;
 fi;
fi;

# FAST CHARGE =========================================#

if [ "$FC" -eq "2" ]; then
 echo "* Fast Charge 1 = Activated *" |  tee -a $LOG;
elif [ "$FC" -eq "1" ]; then
 echo "* Fast Charge 2 = Activated *" |  tee -a $LOG;
fi;

# CHECK  PROCESS =========================================#

if [ `cat /proc/sys/vm/min_free_kbytes` -eq "$MFK" ] && [ `cat /proc/sys/vm/oom_kill_allocating_task` -eq "0" ]; then
 echo "* ALL FUNCTIONS =  ACTIVE *" |  tee -a $LOG;
else
 echo "* ALL FUNCTIONS = PARTIAL *" |  tee -a $LOG;
fi;

echo "# ================================="  | tee -a $LOG;
echo "#  BATTERY LEVEL: $BATT_LEV % " | tee -a $LOG;
echo "#  BATTERY TECHNOLOGY: $BATT_TECH" | tee -a $LOG;
echo "#  BATTERY HEALTH: $BATT_HLTH" | tee -a $LOG;
echo "#  BATTERY TEMP: $BATT_TEMP °C" | tee -a $LOG;
echo "#  BATTERY VOLTAGE: $BATT_VOLT VOLTS " | tee -a $LOG;
echo "# ================================="  | tee -a $LOG;
echo "* END OF OPTIMIZATIONS : $( date +"%m-%d-%Y %H:%M:%S" ) *" | tee -a $LOG;"
#FINISHED : $(date +"%d-%m-%Y %r")"
echo "================================================" | tee -a $LOG;
echo "*               *" | tee -a $LOG;
echo "*      Strm    *" | tee -a $LOG;
echo "*   by chengfu  *" | tee -a $LOG;
echo "*               *" | tee -a $LOG;
echo "================================================" | tee -a $LOG;
exit 0
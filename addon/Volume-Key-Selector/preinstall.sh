# External Tools

chmod -R 0755 $TMPDIR/addon/Volume-Key-Selector/tools
cp -R $TMPDIR/addon/Volume-Key-Selector/tools $UF 2>/dev/null

keytest() {
  ui_print "- 按上音量键进行测试 -"
  ui_print "  按下音量键"
  (/system/bin/getevent -lc 1 2>&1 | /system/bin/grep VOLUME | /system/bin/grep " DOWN" > $TMPDIR/events) || return 1
  return 0
}

chooseport() {
  # Original idea by chainfire @xda-developers, improved on by ianmacd @xda-developers
  #note from chainfire @xda-developers: getevent behaves weird when piped, and busybox grep likes that even less than toolbox/toybox grep
  while true; do
    /system/bin/getevent -lc 1 2>&1 | /system/bin/grep VOLUME | /system/bin/grep " DOWN" > $TMPDIR/events
    if (`cat $TMPDIR/events 2>/dev/null | /system/bin/grep VOLUME >/dev/null`); then
      break
    fi
  done
  if (`cat $TMPDIR/events 2>/dev/null | /system/bin/grep VOLUMEUP >/dev/null`); then
    return 0
  else
    return 1
  fi
}

chooseportold() {
  # Keycheck binary by someone755 @Github, idea for code below by Zappo @xda-developers
  # Calling it first time detects previous input. Calling it second time will do what we want
  keycheck
  keycheck
  SEL=$?
  if [ "$1" == "UP" ]; then
    UP=$SEL
  elif [ "$1" == "DOWN" ]; then
    DOWN=$SEL
  elif [ $SEL -eq $UP ]; then
    return 0
  elif [ $SEL -eq $DOWN ]; then
    return 1
  else
    abort " 没有检测到按上音量键！停止！"
  fi
}

# Have user option to skip vol keys

# Use the current running profile in case of upgrade
if $KEEPPROFILE ; then
	PROFILEMODE=$(cat /data/adb/lktprofile.txt | tr -d '\n')
fi

OIFS=$IFS; IFS=\|; MID=false; NEW=false
if [ -z $PROFILEMODE ] ; then
case $(echo $(basename $ZIPFILE) | tr '[:upper:]' '[:lower:]') in
  *batt*) PROFILEMODE=0 ui_print "- .跳过";;
  *balanc*) PROFILEMODE=1 ui_print "- 跳过 -";;
  *perf*) PROFILEMODE=2 ui_print "- 跳过-";;
  *turb*) PROFILEMODE=3 ui_print "- 跳过 -";;
  *) if keytest; then
       VKSEL=chooseport
     else
       VKSEL=chooseportold
       ui_print "  ! 检测到旧设备！ 使用旧的方法"
       ui_print " "
       ui_print "- 请照以下来按音量键 -"
       ui_print " 请按上音量键"
       $VKSEL "UP"
       ui_print "  请按下音量键"
       $VKSEL "DOWN"
     fi;;
esac
fi
IFS=$OIFS



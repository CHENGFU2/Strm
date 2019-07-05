
# FAST CHARGE =========================================#

FFC=/sys/kernel/fast_charge/force_fast_charge
ACL=/sys/kernel/fast_charge/ac_charge_level
FL=/sys/kernel/fast_charge/failsafe
UCL=/sys/kernel/fast_charge/usb_charge_level
WCL=/sys/kernel/fast_charge/wireless_charge_level

chmod 0644 $FFC
chmod 0644 $FL

if [ -e /sys/kernel/fast_charge/ac_charge_level ]; then	
 if [ -e /sys/class/power_supply/battery/batt_slate_mode ]; then	
  echo "1" > /sys/class/power_supply/battery/batt_slate_mode
 fi;
fi;

if [ -e $ACL ]; then
 echo "2" > $FFC
 echo "2100" > $ACL
 echo "1200" > $UCL
 echo "1200" > $WCL
 echo "0" > $FL
elif [ -e $FFC ]; then
 echo "1" > $FFC
fi;

chmod 0444 $FFC
chmod 0444 $FL
exit 0#
echo 1 > /sys/class/graphics/fb0/SRGB

ModPath=${0%/*}
export PATH="/sbin/.core/busybox:/dev/magisk/bin:$PATH"
SysPaths="/sbin/.core/mirror/system
/dev/magisk/mirror/system"
rm -rf /dev/syscfgp_tmp 2>/dev/null


for p in $SysPaths; do
	if [ $p/build.prop ]; then
		SysPath="$p"
		break
	fi
done


if [ "$(cat $ModPath/.SystemSizeK)" -ne "$(du -s $SysPath | cut -f1)" ]; then
	mkdir /dev/syscfgp_tmp
	cp -R $SysPath/etc/sysconfig /dev/syscfgp_tmp
	
	# Detect MagicGApps
	FoundMGA="$(find /sbin/.core/img /magisk -type d -name MagicGApps 2>/dev/null | head -n1)"
	echo "$FoundMGA" | grep -q '/MagicGApps$' && cp -a "$FoundMGA"/etc/sysconfig/* /dev/syscfgp_tmp/sysconfig 2>/dev/null
	
	for file in /dev/syscfgp_tmp/sysconfig/*; do
		if [ -f "$file" ]; then
			if grep -Eq '<allow-in-power-save|<allow-in-data-usage-save' "$file"; then
				sed -i '/allow-in-.*-save/s/<a/<!-- a/' $file
			else
				rm "$file"
			fi
		fi
	done
	sed -i '/.volta/s/<!-- a/<a/' /dev/syscfgp_tmp/sysconfig/google.xml

	rm -rf $ModPath/system/etc/sysconfig
	mv /dev/syscfgp_tmp/sysconfig $ModPath/system/etc/

	# Export /system size info for automatic re-patching across ROM/GApps updates
	du -s $SysPath | cut -f1 >$ModPath/.SystemSizeK
fi
exit 0

alias SWAPT='grep -i SwapTotal /proc/meminfo | tr -d "[a-zA-Z :]"'

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

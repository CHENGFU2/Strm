#!/system/bin/sh
# 自定义卸载文件,示例:
# (until [ -f /data/swapfile ]; do sleep 20; done
# rm /data/swapfile &) &
# exit 0

(until [ -f /data/swapfile ]; do sleep 20; done
 rm /data/swapfile &) &
 exit 0
busybox mount -o remount,rw -t auto /data
busybox mount -o remount,rw -t auto /system

rm -rf /data/data/com.android.thememanager/files/cache
mkdir /data/data/com.android.thememanager/files/cache
chmod 000 /data/data/com.android.thememanager/files/cache
chmod 777 /data/user/0/com.android.thememanager/files

#去游戏加速广告
security=`pm list packages | grep com.miui.securitycenter`
if [[ -n "$security" ]];then
echo " " >/data/data/com.miui.securitycenter/files/gamebooster/gbintlgamewall
echo " " >/data/data/com.miui.securitycenter/files/gamebooster/gbviewpoints
chmod 000 /data/data/com.miui.securitycenter/files/gamebooster/gbintlgamewall
chmod 000 /data/data/com.miui.securitycenter/files/gamebooster/gbviewpoints
fi

#去除小米浏览器某些广告
browser=`pm list packages | grep com.android.browser`
if [[ -n "$browser" ]];then
rm -rf /data/data/com.android.browser/files/data/banners
mkdir -p /data/data/com.android.browser/files/data/banners
chmod 000 /data/data/com.android.browser/files/data/banners

rm -rf /data/data/com.android.browser/files/data/kw
mkdir -p /data/data/com.android.browser/files/data/kw
chmod 000 /data/data/com.android.browser/files/data/kw

rm -rf /data/data/com.android.browser/files/data/kw1
mkdir -p /data/data/com.android.browser/files/data/kw1
chmod 000 /data/data/com.android.browser/files/data/kw1

rm -rf /data/data/com.android.browser/files/data/kw2
mkdir -p /data/data/com.android.browser/files/data/kw2
chmod 000 /data/data/com.android.browser/files/data/kw2

rm -rf /data/data/com.android.browser/files/data/suggest
mkdir -p /data/data/com.android.browser/files/data/suggest
chmod 000 /data/data/com.android.browser/files/data/suggest

rm -rf /data/data/com.android.browser/files/data/adblock/miui_watchlist.json
echo " " >/data/data/com.android.browser/files/data/adblock/miui_watchlist.json
chmod 000 /data/data/com.android.browser/files/data/adblock/miui_watchlist.json

rm -f /data/data/com.android.browser/files/data/adblock/miui_whitelist.json
echo " " >/data/data/com.android.browser/files/data/adblock/miui_whitelist.json
chmod 000 /data/data/com.android.browser/files/data/adblock/miui_whitelist.json

rm -rf /data/data/com.android.browser/files/data/homepagecards
mkdir -p /data/data/com.android.browser/files/data/homepagecards
chmod 000 /data/data/com.android.browser/files/data/homepagecards

rm -rf /data/data/com.android.browser/files/data/topcontentv6n
mkdir -p /data/data/com.android.browser/files/data/topcontentv6n
chmod 000 /data/data/com.android.browser/files/data/topcontentv6n

#去除小米浏览器黑名单网站
rm -rf /data/data/com.android.browser/files/data/caclist/cac_url.json
touch /data/data/com.android.browser/files/data/caclist/cac_url.json
chmod 000 /data/data/com.android.browser/files/data/caclist/cac_url.json

am kill-all com.android.browser
fi


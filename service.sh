#!/system/bin/sh

MODDIR=${0%/*}
LOG=/data/adb/moto_debloat.log
EMPTY="$MODDIR/empty"

# This script is also installed in /data/adb/service.d for LKM. In that
# location the empty bind source remains in the installed module directory.
[ -d "$EMPTY" ] || EMPTY=/data/adb/modules/moto_debloat/empty

hide_dir() {
  target="$1"
  [ -d "$target" ] || return 0
  set -- "$target"/*.apk
  [ -e "$1" ] || return 0
  /system/bin/mount -o bind "$EMPTY" "$target" >>"$LOG" 2>&1
}

hide_dir /product/priv-app/TFDevicePulse
hide_dir /product/priv-app/TFIgnite
hide_dir /product/app/TFDashboard
hide_dir /product/app/TFGamesHub
hide_dir /product/priv-app/GameMode
hide_dir /product/priv-app/SmartFeed
hide_dir /product/priv-app/TFTheDaily

remove_package() {
  /system/bin/su 2000 -c "/system/bin/pm uninstall --user 0 $1" >/dev/null 2>&1
}

# LKM loads after PackageManager has scanned /product. Stop processes that
# may already have received BOOT_COMPLETED before the mount was applied.
/system/bin/su 2000 -c '/system/bin/am force-stop com.tracfone.preload.accountservices' >/dev/null 2>&1
/system/bin/su 2000 -c '/system/bin/am force-stop com.dti.tracfone' >/dev/null 2>&1
/system/bin/su 2000 -c '/system/bin/am force-stop com.swishme.tracfone' >/dev/null 2>&1
/system/bin/su 2000 -c '/system/bin/am force-stop com.dti.folderlauncher' >/dev/null 2>&1
/system/bin/su 2000 -c '/system/bin/am force-stop com.motorola.gamemode' >/dev/null 2>&1
/system/bin/su 2000 -c '/system/bin/am force-stop com.motorola.smartfeed' >/dev/null 2>&1
/system/bin/su 2000 -c '/system/bin/am force-stop com.huub.tiger' >/dev/null 2>&1

# Remove every app attributed to the Digital Turbine installer. Capture the
# installer list before removing the installer itself so attribution is kept.
/system/bin/su 2000 -c '/system/bin/pm list packages -i' 2>/dev/null |
  while IFS= read -r line; do
    case "$line" in
      *"installer=com.dti.tracfone")
        package=${line#package:}
        package=${package%% *}
        [ -n "$package" ] && remove_package "$package"
        ;;
    esac
  done

# Updated system apps can survive under /data/app and be registered as normal
# apps after their product copies are hidden. Remove those copies every load.
for package in \
  com.tracfone.preload.accountservices \
  com.dti.tracfone \
  com.swishme.tracfone \
  com.dti.folderlauncher \
  com.motorola.gamemode \
  com.motorola.smartfeed \
  com.huub.tiger \
  com.handmark.expressweather; do
  remove_package "$package"
done

echo "$(/system/bin/date '+%F %T') service complete" >>"$LOG"

# With LKM late-load, PackageManager has already scanned /product. Restart
# system_server once per boot only when it still caches the now-hidden APK.
BOOT_ID=$(/system/bin/cat /proc/sys/kernel/random/boot_id 2>/dev/null)
BOOT_MARKER=/data/adb/moto_debloat.boot_id
LAST_BOOT=$(/system/bin/cat "$BOOT_MARKER" 2>/dev/null)
if [ -n "$BOOT_ID" ] && [ "$BOOT_ID" != "$LAST_BOOT" ] && \
   [ ! -e /product/priv-app/TFDevicePulse/TFDevicePulse.apk ] && \
   /system/bin/pm path com.tracfone.preload.accountservices 2>/dev/null | \
     /system/bin/grep -q '^package:'; then
  echo "$BOOT_ID" >"$BOOT_MARKER"
  echo "$(/system/bin/date '+%F %T') restarting framework" >>"$LOG"
  SYSTEM_SERVER=$(/system/bin/pidof system_server)
  [ -n "$SYSTEM_SERVER" ] && /system/bin/kill -9 "$SYSTEM_SERVER"
fi

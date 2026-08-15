#!/system/bin/sh

MODDIR=${0%/*}

for target in \
  /product/priv-app/TFDevicePulse \
  /product/priv-app/TFIgnite \
  /product/app/TFDashboard \
  /product/app/TFGamesHub \
  /product/priv-app/GameMode \
  /product/priv-app/SmartFeed \
  /product/priv-app/TFTheDaily; do
  [ -d "$target" ] || continue
  mount -o bind "$MODDIR/empty" "$target"
done

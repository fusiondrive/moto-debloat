#!/system/bin/sh

MODDIR=${0%/*}

for target in \
  /product/priv-app/TFDevicePulse \
  /product/priv-app/TFIgnite \
  /product/app/TFDashboard \
  /product/app/TFGamesHub \
  /product/priv-app/GameMode \
  /product/priv-app/SmartFeed \
  /product/priv-app/TFTheDaily \
  /product/priv-app/BRApps2 \
  /product/priv-app/AppCloudOobeMotorolaStub \
  /product/priv-app/MotorolaIgnite \
  /product/priv-app/DTIgniteUSC \
  /product/priv-app/CricketIgnite \
  /product/priv-app/VzwIgnite-v22-5-7-884 \
  /product/app/DTIgniteWidgetUSC; do
  [ -d "$target" ] || continue
  mount -o bind "$MODDIR/empty" "$target"
done

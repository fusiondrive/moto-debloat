# Motorola Debloat KernelSU Module

This KernelSU module hides selected Motorola and carrier preload applications
from the read-only `product` partition on compatible Motorola devices.

## Hidden packages

- Device Pulse: `com.tracfone.preload.accountservices`
- Digital Turbine carrier installer: `com.dti.tracfone`
- Swish carrier dashboard: `com.swishme.tracfone`
- GamesHub: `com.dti.folderlauncher`
- Motorola Games: `com.motorola.gamemode`
- Motorola Smart Feed: `com.motorola.smartfeed`
- TheDaily: `com.huub.tiger`
- App Box: `com.motorola.brapps`
- MotoApps: `com.aura.oobe.motorola`
- Moto App Manager: `com.dti.motorola`
- Carrier Mobile Services managers: `com.dti.cricket`,
  `com.LogiaGroup.LogiaDeck`
- NewsPOP: `com.digitalturbine.android.apps.news.uscellular`

## Requirements

- A rooted Android device with KernelSU.
- LKM mode is supported. The module runs its service after KernelSU is loaded.

## Installation

1. Install the release ZIP from the KernelSU manager.
2. Reboot the device.
3. In LKM mode, load KernelSU after boot as usual.

The service binds empty directories over the selected product app directories,
stops any already-started processes, removes residual user updates from
`/data/app`, and removes apps attributed to the Digital Turbine installer. It
keeps PackageManager's per-user uninstall records intact so the hidden apps do
not return as newly discovered packages on the next boot. The read-only product
partition is never modified.

## SELinux network rule

Some Android 16 builds expose Wi-Fi packets as `unlabeled`. The included
`sepolicy.rule` permits the required packet, peer, netif, and node operations
while keeping SELinux enforcing.

## Rollback

Disable or remove the module from KernelSU Manager and reboot. The original
product applications remain untouched and can be restored by re-enabling the
module or reinstalling their user updates through the normal package manager.

## Build

The module root is the directory containing `module.prop`. To create an install
ZIP, archive the contents of this directory without adding a parent directory:

```sh
cd moto-debloat
zip -r ../moto_debloat.zip .
```

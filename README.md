# Motorola Debloat KernelSU Module

This KernelSU module hides selected Motorola and carrier preload applications
from the read-only `product` partition on compatible Motorola devices.

## Hidden packages

- Device Pulse: `com.tracfone.preload.accountservices`
- Digital Turbine carrier installer: `com.dti.tracfone`
- Swish carrier dashboard: `com.swishme.tracfone`
- GamesHub: `com.dti.folderlauncher`
- Motorola Games: `com.motorola.gamemode`
- The Daily / Smart Feed: `com.motorola.smartfeed`
- TheDaily preload: `com.huub.tiger`

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
also restarts `system_server` once per boot when PackageManager still has a
cached system package. This refresh removes cached launcher entries without
modifying the read-only product partition.

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

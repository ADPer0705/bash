# ADPer's Bash Scripts
This repo contains the bash scripts I wrote to automate tasks.

```bash
fed_fuck_windows_updates.sh
```
This is for when windows rolls an update, and it messes with my dual-boot setup. Currently it does the following things : 
- Fixes the LUKS2 + TPM2 Disc Encryption Auto Unlock setup.
- Checks and Fixes NVIDIA setup. 
- Checks and Fixes RTC Timezone and NPC Synchronization.

```bash
make_desktop_shortcut.sh
```
This script takes in either terminal commands or web links and makes them into desktop applications. SO that when you hit the super key, you can search for them using the name you set and when you run them like you would open any application, it would either run the terminal command or open the link in the browser.
e.g. I use notion a lot, so I made the link to my default notion page into a sort-of desktop application, so that I can use the desktop app launcher to open notion on my default page in a new browser tab.

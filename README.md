
<img width="985" height="489" alt="iPAW-big" src="https://github.com/user-attachments/assets/ccfef046-9a2c-41b6-9277-ad35ad2f87fd" />

# IP Allowlist Watcher for CrowdSec

iPAW is a tool to update a CrowdSec allowlist with your homelab's public IP when using CrowdSec with a WireGuard-connected server (e.g., a VPS). 
It extracts your server's (homelab) public IP from the WireGuard tunnel and automatically updates the respective CrowdSec allowlist.

<details>
<summary>What is CrowdSec and an allowlist?</summary>

CrowdSec is a open-source and participative security solution offering a crowdsourced protection against malicious IPs. 
<img src="https://github.com/crowdsecurity/crowdsec-docs/raw/main/crowdsec-docs/static/img/simplified_SE_overview.svg" alt="Crowdsec Overview" width="auto" />
Source - [Github - Crowdsec](https://github.com/crowdsecurity/crowdsec)

Sometimes a CrowdSec parser is buggy and accidentally bans your homelab IP, which can cause many problems. The allowlist feature whitelists certain IPs on all LAPI-connected devices.

</details>

## Installation
```
cd /to/your/desired/path
wget https://raw.githubusercontent.com/se7entynine/iPAW/main/iPAW.sh
chmod +x iPAW.sh
```
<details>
<summary>Requirements</summary>

Run the script with root privileges or sudo on the CrowdSec LAPI machine that has access to both WireGuard and CrowdSec's CSCLI.  
</details>

<details>
  
<summary>Configuration</summary>

You need to change the `PEER_KEY` and `WG_INTERFACE` values in the configuration section at the top of the script. If you leave the default values, you will find your current WireGuard setup in the log file next to your script file and can copy and paste the desired `PEER_KEY` and `WG_INTERFACE` values. Additional descriptive configuration options are also available.
```
PEER_KEY="AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="
WG_INTERFACE="wg0"
```
</details>
  
<details>
  
<summary>Automatic execution</summary>
  
<details>
<summary>Option 1: crontab</summary>
  
Open crontab with `sudo crontab -e` and add a new line:  

`*/5 * * * * /path/to/iPaw.sh` # executes iPAW every 5 minutes
</details> 
<details>
<summary>Option 2: Systemd (recommended)</summary>
  
**1. Create service file:**

```bash
sudo nano /etc/systemd/system/ipaw.service
```

Add the following content and make sure to edit the `ExecStart` value:

```ini
[Unit]
Description=iPAW - IP Allowlist Watcher for CrowdSec
After=network-online.target wireguard.target crowdsec.service
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/path/to/iPaw.sh
User=root
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
```

**2. Create timer file:**

```bash
sudo nano /etc/systemd/system/ipaw.timer
```

Add the following content:

```ini
[Unit]
Description=Run iPAW every 5 minutes
Requires=ipaw.service

[Timer]
OnBootSec=2min
OnUnitActiveSec=5min
Unit=ipaw.service

[Install]
WantedBy=timers.target
```
`OnBootSec=2min` - Runs the service 2 minutes after system boot. This gives time for network, WireGuard, and CrowdSec to start.
`OnUnitActiveSec=5min`- Runs the service 5 minutes after the last execution completed. 

Change these values according to your preferences. [See here for more information about timers.](https://linuxconfig.org/how-to-schedule-tasks-with-systemd-timers-in-linux)

**3. Enable and start the timer:**

```bash
sudo systemctl daemon-reload
sudo systemctl enable ipaw.timer
sudo systemctl start ipaw.timer
```

**4. Check status:**

```bash
sudo systemctl status ipaw.timer
sudo systemctl list-timers ipaw.timer
```

**5. View logs:**

```bash
sudo journalctl -u ipaw.service
```
</details> 
</details>

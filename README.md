
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
  

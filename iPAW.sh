#!/bin/bash

# --- Configuration ---
PEER_KEY="AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=" 				# CHANGEME: Replace with your WireGuard peer public key
WG_INTERFACE="wg0" 														# CHANGEME: Replace with your WireGuard interface name
ALLOWLIST_NAME="homelab-whitelist"	
ALLOWLIST_DESCRIPTION="Homelab public IP allowlist"
COMMENT_IDENTIFIER="homelab-public-ip"
LOGFILE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/ipaw.log"
# --- End Configuration ---

> "$LOGFILE"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOGFILE"
}

log_title() {
    echo "$1" | tee -a "$LOGFILE"
}

log_title "
██╗██████╗  █████╗ ██╗    ██╗
║ ║██   ██╗██   ██╗██║    ██║
██║██████╔╝███████║██║ █╗ ██║
██║██╔═══╝ ██╔══██║██║███╗██║
██║██║     ██║  ██║╚███╔███╔╝
╚═╝╚═╝     ╚═╝  ╚═╝ ╚══╝╚══╝ by 79
                             
"

# Retrieve current public IP from WireGuard
CURRENT_IP=$(wg show $WG_INTERFACE | grep -A 2 "peer: $PEER_KEY" | grep "endpoint:" | awk '{print $2}' | cut -d: -f1)

if [ -z "$CURRENT_IP" ]; then
    log "ERROR: Could not retrieve current homelab IP"
    log "Available WireGuard interfaces and connections:"
    log "---"
    wg show all | tee -a "$LOGFILE"
    log "---"
    log "Please verify PEER_KEY and WG_INTERFACE in the configuration"
    exit 1
fi

log "Current homelab IP: $CURRENT_IP"

# Check if allowlist exists, create if necessary
if ! cscli allowlist list | grep -q "$ALLOWLIST_NAME"; then
    log "Allowlist '$ALLOWLIST_NAME' does not exist - creating now"
    cscli allowlist create "$ALLOWLIST_NAME" -d "$ALLOWLIST_DESCRIPTION"
    if [ $? -eq 0 ]; then
        log "Allowlist '$ALLOWLIST_NAME' successfully created"
    else
        log "ERROR: Failed to create allowlist '$ALLOWLIST_NAME'"
        exit 1
    fi
fi

# Inspect allowlist
ALLOWLIST_OUTPUT=$(cscli allowlist inspect $ALLOWLIST_NAME 2>/dev/null)

# Search for old homelab IP by comment identifier
OLD_IP=$(echo "$ALLOWLIST_OUTPUT" | grep "$COMMENT_IDENTIFIER" | awk '{print $1}')

# Check if current IP is already correctly listed
if echo "$ALLOWLIST_OUTPUT" | grep -q "$CURRENT_IP.*$COMMENT_IDENTIFIER"; then
    log "IP already correctly in allowlist - no change required"
    exit 0
fi

# Remove old IP if it exists and differs from current IP
if [ -n "$OLD_IP" ] && [ "$OLD_IP" != "$CURRENT_IP" ]; then
    log "IP change detected: $OLD_IP -> $CURRENT_IP"
    cscli allowlist remove $ALLOWLIST_NAME $OLD_IP 2>/dev/null
    log "Old IP $OLD_IP removed from allowlist"
fi

# Add new IP without time restriction
cscli allowlist add $ALLOWLIST_NAME $CURRENT_IP -d "$COMMENT_IDENTIFIER" 2>/dev/null
log "New IP $CURRENT_IP added to allowlist"
exit 0
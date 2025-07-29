#!/bin/bash

# Modified. Based on AWS's /home/ec2-user/.c9/stop-if-inactive.sh.

set -euo pipefail
SHUTDOWN_TIMEOUT=1  # minutes
GRACEPERIOD=300  # seconds
me=$BASH_SOURCE

# This works for Amazon Linux 2 and also for Amazon Linux 2023:
is_shutting_down_al2() {
    local FILE
    FILE=/run/systemd/shutdown/scheduled
    if [[ -f "$FILE" ]]; then
        return 0
    else
        return 1
    fi
}
is_vscode_connected() {
    pgrep -u ec2-user -f ".vscode-server/(cli/servers)|(bin)/" -a | grep -v -F 'shellIntegration-bash.sh' >/dev/null
}

if is_vscode_connected; then
    if is_shutting_down_al2; then
        sudo shutdown -c
        # Erase autoshutdown-timestamp if any:
        echo > "/home/ec2-user/.autoshutdown/autoshutdown-timestamp"
        echo $me : Shutdown aborted. Reason: VSCode seems to be connected.
    fi
else
    TIMESTAMP=$(date +%s)
    LASTBOOTTIMESTAMP=$(cat /home/ec2-user/.autoshutdown/lastboottime)
    GRACETIMESTAMP=$(($LASTBOOTTIMESTAMP + $GRACEPERIOD))
    if [[ $TIMESTAMP -lt $GRACETIMESTAMP ]]; then
        echo $me: Shutdown is not being scheduled. Reason: grace period until $(date --date=@$GRACETIMESTAMP)
    else
        echo "$TIMESTAMP" > "/home/ec2-user/.autoshutdown/autoshutdown-timestamp"
        echo $me: Shutdown is being scheduled at $(date --date=@$TIMESTAMP) with TIMEOUT=$SHUTDOWN_TIMEOUT
        sudo shutdown -h $SHUTDOWN_TIMEOUT
    fi
fi

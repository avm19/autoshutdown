# Auto-shutdown script for Amazon Linux 2023

This script automatically shuts down an AWS EC2 instance running Amazon Linux 2023 that is used for remote development with VSCode.

See also: https://github.com/aws-samples/cloud9-to-power-vscode-blog/blob/main/scripts/stop-if-inactive.sh.

## How it works

File `/etc/cron.d/autoshutdown-cron` is a cron job file. It schedules 2 jobs.
1. At boot time, a current timestamp is written to `~/.autoshutdown/lastboottime`.
2. Every 10 minutes, `home/ec2-user/.autoshutdown/stop-if-inactive.sh` is run:
    - `is_vscode_connected()` determines if a VSCode-related process is running
    - if VSCode is running, then a shutdown is cancelled (if it is in progress);
    - if VSCode is not running, a shutdown is scheduled in `SHUTDOWN_TIMEOUT` minutes, unless a grace period applies.  
    The grace period ends `GRACEPERIOD` seconds after the last boot time.

## Setup

1. Install `cronie`, since Cron is not present on AWS AL2023 by default:  
    ```bash
    sudo dnf install cronie
    ```
2. Copy the contents of this directory to `/home/ec2-user/.autoshutdown/`
3. Set correct permissions for scripts:  
    ```bash
    sudo chmod 7740 ~/.autoshutdown/writeboottime.sh ~/.autoshutdown/stop-if-inactive.sh
    ```
4. Copy `/home/ec2-user/.autoshutdown/autoshutdown-cron` into `/etc/cron.d/`
    ```bash
    sudo cp /home/ec2-user/.autoshutdown/autoshutdown-cron /etc/cron.d/
    ```

Edit `home/ec2-user/.autoshutdown/stop-if-inactive.sh` to change the default values:
- `SHUTDOWN_TIMEOUT=1`, minutes;
- `GRACEPERIOD=300`, seconds.

To be on the safe side, ensure that the automatic shutdown works before relying on it.
When debugging, one may use:
```bash
systemctl status crond.service
```
Enjoy.

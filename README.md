# SSL Checker Script for SLACK

![SSL Checker & Slack Channel message](slack-channel.png?raw=true)

## Overview

The SSL Checker script is a Bash script designed to check the SSL certificate expiration status for a list of domains and send notifications to Slack channels based on the remaining days until expiration. It utilizes WHOIS information and OpenSSL to retrieve SSL certificate details.

## Features

- Checks SSL certificate expiration for multiple domains.
- Sends notifications to Slack channels with color-coded information and icons.
- Supports different Slack channels for each domain.

## Prerequisites

Before using the script, ensure the following prerequisites are met:

1. Bash shell environment.
2. `dig`, `whois`, `openssl`, and `curl` commands installed.
3. [Incoming Webhooks](https://slack.com/apps/A0F7XDUAZ-incoming-webhooks?tab=more_info) integration enabled in your Slack workspace.

## Setting up Incoming Webhooks in Slack

1. Visit [Incoming Webhooks](https://slack.com/apps/A0F7XDUAZ-incoming-webhooks?tab=more_info).
2. Click on "Add to Slack" to add the Incoming Webhooks integration to your workspace.
3. Choose the channel where you want to receive notifications and click on "Add Incoming WebHooks integration."
4. Copy the generated Webhook URL.

## Usage

### Clone the repository

```bash
git clone https://github.com/alexmeanpug/ssl-checker-slack
cd ssl-checker-slack
```

### Configuration

- Copy `.env.example` to `.env` and update the `SLACK_WEBHOOK_URL` variable with your Slack Incoming Webhook URL.
- Copy `domains_channels.txt.example` to `domains_channels.txt` and update the list of domains to monitor and their channels where the message should be sent.

### Running the script

You can either run the command manually with `./ssl-domains.sh` or you can set up a cronjob to do this automagically for you:

```bash
EDITOR=nano crontab -e
```

The example sets the editor to nano if you aren't comfortable with vi/vim, which is the default in most systems.

Copy and paste this to the end of your crontab file:

```bash
0 10 1 * * /usr/env/bash ~/path/to/ssl-domains.sh
```

Please update the path to your `ssl-domains.sh` file or else `cron` won't be able to find it.

To exit nano, hit `CTRL+x` and answer `y` to the question.

Now the script should be scheduled to run at 10:00am 1st day of each Month.
To tweak the time and date, you can take a look at [crontab.guru](https://crontab.guru/#0_10_1_*_*).

## Output

The script will display information about each domain, including the domain name, expiry date, remaining days until expiration, color-coded status, and the Slack channel it's notifying.

## Troubleshooting

- Ensure proper permissions are set for the script (`chmod +x ssl-domains.sh`).
- Use the copied Webhook URL to update the `SLACK_WEBHOOK_URL` variable in the script.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

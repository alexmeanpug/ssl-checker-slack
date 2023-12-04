# SSL Checker Script for SLACK
![Alt text](slack-channel.png?raw=true "SSL Checker & Slack Channel message")
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

1. **Visit [Incoming Webhooks](https://slack.com/apps/A0F7XDUAZ-incoming-webhooks?tab=more_info).**
2. **Click on "Add to Slack" to add the Incoming Webhooks integration to your workspace.**
3. **Choose the channel where you want to receive notifications and click on "Add Incoming WebHooks integration."**
4. **Copy the generated Webhook URL.**

## Usage

1. **Clone the repository:**
    ```bash
    git clone https://github.com/alexmeanpug/ssl-checker-slack
    cd ssl-checker-slack
    ```
2. **Open the script file (`ssl-domains.sh`) and update the `SLACK_WEBHOOK_URL` variable with your Slack Incoming Webhook URL.**
3. **Make the script executable:**
    ```bash
    chmod +x ssl-domains.sh
    ```
4. **Edit the `DOMAINS` array in the script, adding domains and their corresponding Slack channels.**
5. **Run the script:**
    ```bash
    ./ssl-domains.sh
    ```

## Configuration
- __SLACK_WEBHOOK_URL__: Your Slack Incoming Webhook URL for sending notifications.
- __DOMAINS__: An array containing domains and their associated Slack channels.

## Output
The script will display information about each domain, including the domain name, expiry date, remaining days until expiration, color-coded status, and the Slack channel it's notifying.

## Notes
- Ensure proper permissions are set for the script (`chmod +x`).
- Use the copied Webhook URL to update the `SLACK_WEBHOOK_URL` variable in the script.
- Update the `DOMAINS` array with the desired domains and Slack channels.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

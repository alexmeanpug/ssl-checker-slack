#!/bin/bash
# Script to check SSL certificate expiration for multiple domains and send notifications to Slack
#
# Dependencies: dig, openssl, gdate, curl
# License: MIT

# Check that required tools are installed
required_tools=("dig" "openssl" "gdate" "curl")

for tool in "${required_tools[@]}"; do
  if ! command -v "$tool" &>/dev/null; then
    echo "Command '$tool' not found! Please install it."
    exit 1
  fi
done

# Check that .env file exists
if [[ ! -f ".env" ]]; then
  echo "File .env not found! Check the example file (.env.example) for reference and save it as .env."
  exit 1
fi

# As .env file format is KEY=VALUE, we can source it to set the variables
source .env

# If SLACK_WEBHOOK_URL contains 'XXXXXXX' then it's not set, exit with an error
if [[ "$SLACK_WEBHOOK_URL" == *"XXXXXXX"* ]]; then
  echo "SLACK_WEBHOOK_URL is not set! Please set it in the .env file."
  exit 1
fi

# File containing domain and Slack channel information
file="domains_channels.txt"

# Check if the file exists
if [[ ! -f "$file" ]]; then
  echo "File $file not found! Check the example file ($file.example) for reference and save it as $file."
  exit 1
fi

# Function to send notifications to Slack
notify() {
  DOMAIN="$1"
  EXPIRY_DAYS="$2"
  EXPIRY_DATE="$3"
  COLOR="$4"
  SLACK_CHANNEL="$5"
  CURRENT_DATE=$(date -u +"%b %d %H:%M:%S %Y GMT")

  # Prepare Slack payload in JSON format
  SLACK_PAYLOAD="payload={\"channel\":\"${SLACK_CHANNEL}\",\"icon_emoji\":\"$ICON\",\"username\":\"${SLACK_BOTNAME}\",\"attachments\":[{\"color\":\"${COLOR}\",\"fields\":[{\"title\":\"Domain:\",\"value\":\"${DOMAIN}\",\"short\":true},{\"title\":\"Expiry day(s):\",\"value\":\"$EXPIRY_DAYS\",\"short\":true},{\"title\":\"Expiry date:\",\"value\":\"$EXPIRY_DATE\",\"short\":true},{\"title\":\"Current date:\",\"value\":\"$CURRENT_DATE\",\"short\":true}]}]}"

  # Send the payload to Slack using curl
  curl -X POST --data-urlencode "$SLACK_PAYLOAD" $SLACK_WEBHOOK_URL
}

# Function to check if a domain has an A record
check_domain_availability() {
  local name="$1"

  if ! dig +short a "$name" &>/dev/null; then
    echo "Domain $name is not available or doesn't have an A record."
    exit 1
  fi
}

# Function to calculate the remaining days until certificate expiration
check_expiry_days() {
  local expiry_date="$1"
  local current_date=$(date -u +"%s")
  local expiry_epoch=$(gdate -u -d "$expiry_date" +"%s")

  # Calculate and echo the remaining days
  echo $(((expiry_epoch - current_date) / (60 * 60 * 24)))
}

# Function to check SSL certificate for a domain and send notifications
check_certs() {
  local name="$1"
  local slack_channel="$2"

  # Check if the domain is available and has an A record
  check_domain_availability "$name"

  # Get the IP address of the server
  local ip_server=$(dig +short a "$name")

  # Loop through each IP address associated with the domain
  while read -r ip; do
    # Check if the IP matches the server's IP
    if [ "$ip" == "$ip_server" ]; then
      # Retrieve SSL certificate information
      data=$(echo | openssl x509 -noout -enddate -in <(openssl s_client -showcerts -servername "$name" -connect "$ip:443" 2>/dev/null) 2>/dev/null)
      expiry_date=$(echo "$data" | grep -Eo "notAfter=(.*)GMT" | cut -d "=" -f 2)

      # Use gdate (GNU date) for precise calculation of remaining days
      EXPIRY_DAYS=$(check_expiry_days "$expiry_date")

      # Set color based on remaining days for Slack notification
      if [ "$EXPIRY_DAYS" -lt 30 ]; then
        COLOR="#ff0000"
        ICON=":skull:"
      else
        COLOR="#2eb886"
        ICON=":white_check_mark:"
      fi

      # Send notification to Slack
      notify "$name" "$EXPIRY_DAYS" "$expiry_date" "$COLOR" "$slack_channel"
    fi
  done < <(dig +noall +answer +short "$name")
}

# Loop through each domain-channel pair and check certificates
while IFS=':' read -r domain slack_channel; do
  # Skip empty lines
  [[ -z "$domain" || -z "$slack_channel" ]] && continue

  # If domain contains http:// or https:// remove it
  domain=$(echo "$domain" | sed -e 's/https\?:\/\///')

  # If slack_channels doesn't start with # add it
  if [[ ! "$slack_channel" =~ ^# ]]; then
    slack_channel="#$slack_channel"
  fi

  check_certs "$domain" "$slack_channel"
done <"$file"

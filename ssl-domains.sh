#!/bin/bash

# Function to send notifications to Slack
notify() {
  SLACK_WEBHOOK_URL="https://hooks.slack.com/services/XXXXXXX/XXXXXXX/XXXXXXXXXXXXXXXXXXXXXXXXX"
  SLACK_BOTNAME="SSL Checker"

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
  echo $(( (expiry_epoch - current_date) / (60*60*24) ))
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

# Add more domains to the list with Slack channels
DOMAINS=(
  "google.com: #general"
  "instagram.com: #general"
)

# Loop through each domain-channel pair and check certificates
for domain_channel in "${DOMAINS[@]}"; do
  IFS=":" read -r domain slack_channel <<< "$domain_channel"
  check_certs "$domain" "$slack_channel"
done

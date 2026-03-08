#!/bin/bash

REGION="us-east-2"
SSH_CONFIG="$HOME/.ssh/config"
SSH_KEY="$HOME/.ssh/awsMEEN6931.pem"

# Define instances as simple pairs
INSTANCES=(
    "aws-meen:i-0471d7c1bb57b9300"
    "secondInstance:i-0e04e21d2a35a3035"  
    "thirdInstance:i-0af087353b0d896db"
)

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

START_MARKER="# === AWS EC2 Auto-Config START ==="
END_MARKER="# === AWS EC2 Auto-Config END ==="

echo "🔄 Updating SSH config with current EC2 instance IPs..."
echo ""

# Backup
if [ -f "$SSH_CONFIG" ]; then
    cp "$SSH_CONFIG" "${SSH_CONFIG}.backup.$(date +%Y%m%d_%H%M%S)"
    echo "✅ Backed up existing SSH config"
fi

# Remove old section
if [ -f "$SSH_CONFIG" ]; then
    sed "/$START_MARKER/,/$END_MARKER/d" "$SSH_CONFIG" > "${SSH_CONFIG}.tmp"
    mv "${SSH_CONFIG}.tmp" "$SSH_CONFIG"
fi

# Create temp config
TEMP_CONFIG=$(mktemp)
cat > "$TEMP_CONFIG" << EOF

$START_MARKER
# Auto-generated on $(date)

EOF

# Process instances
for ENTRY in "${INSTANCES[@]}"; do
    HOST_NAME="${ENTRY%%:*}"
    INSTANCE_ID="${ENTRY##*:}"
    
    echo -n "📡 Fetching IP for $HOST_NAME ($INSTANCE_ID)... "
    
    INSTANCE_INFO=$(aws ec2 describe-instances \
        --instance-ids "$INSTANCE_ID" \
        --region "$REGION" \
        --query 'Reservations[0].Instances[0].[State.Name,PublicIpAddress]' \
        --output text 2>/dev/null)
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}FAILED${NC}"
        continue
    fi
    
    STATE=$(echo "$INSTANCE_INFO" | awk '{print $1}')
    PUBLIC_IP=$(echo "$INSTANCE_INFO" | awk '{print $2}')
    
    if [ "$STATE" != "running" ]; then
        echo -e "${YELLOW}$STATE${NC}"
        continue
    fi
    
    if [ -z "$PUBLIC_IP" ] || [ "$PUBLIC_IP" == "None" ]; then
        echo -e "${RED}NO IP${NC}"
        continue
    fi
    
    echo -e "${GREEN}$PUBLIC_IP${NC}"
    
    cat >> "$TEMP_CONFIG" << EOF
Host $HOST_NAME
    HostName $PUBLIC_IP
    User ec2-user
    IdentityFile $SSH_KEY

EOF
done

echo "$END_MARKER" >> "$TEMP_CONFIG"
cat "$TEMP_CONFIG" >> "$SSH_CONFIG"
rm "$TEMP_CONFIG"

echo ""
echo "✅ Done! Connect with: ssh aws-meen"
echo "✅ Done! Connect with: ssh secondInstance"


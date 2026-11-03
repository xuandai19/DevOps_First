
#!/bin/bash

# ==========================================
# QuickBite - Initial Environment Setup
# ==========================================

set -e

echo "======================================"
echo " Starting QuickBite Environment Setup"
echo "======================================"

# 1. Update and upgrade system
echo "[1/4] Updating system..."
apt-get update
apt-get upgrade -y

# 2. Install required packages
echo "[2/4] Installing required packages..."
apt-get install -y openjdk-17-jdk git curl

# 3. Create quickbite group if it does not exist
echo "[3/4] Checking quickbite group..."

if ! getent group quickbite > /dev/null; then
    groupadd quickbite
    echo "Group quickbite created successfully."
else
    echo "Group quickbite already exists."
fi

# 4. Create quickbite system user if it does not exist
echo "[4/4] Checking quickbite user..."

if ! id quickbite > /dev/null 2>&1; then
    useradd -r -g quickbite -s /bin/false quickbite
    echo "System user quickbite created successfully."
else
    echo "User quickbite already exists."
fi

echo "======================================"
echo " QuickBite Setup Completed!"
echo "======================================"

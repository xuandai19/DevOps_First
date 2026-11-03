
#!/bin/bash

# ==========================================
# QuickBite - Setup Project Directories
# ==========================================

set -e

echo "Starting QuickBite directory setup..."

# 1. Create project directory
mkdir -p /opt/quickbite/user-service

# 2. Change ownership
chown -R quickbite:quickbite /opt/quickbite

# 3. Set directory permissions
chmod 750 /opt/quickbite

# 4. Verify directory permissions
ls -la /opt
ls -ld /opt/quickbite

echo "QuickBite directory setup completed!"


#!/bin/bash

# ==========================================
# QUICKBITE - LOCAL DEPLOYMENT SCRIPT
# ==========================================

# ANSI Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Cấu hình
PROJECT_DIR="/home/dai/DevOps_First/user-service"
APP_DIR="/opt/quickbite/user-service"
JAR_PATH="/opt/quickbite/user-service-0.0.1.jar"
LOG_DIR="/var/log/quickbite"
LOG_FILE="$LOG_DIR/user-service.log"
PID_FILE="$APP_DIR/user-service.pid"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}   QUICKBITE DEPLOYMENT STARTING${NC}"
echo -e "${BLUE}========================================${NC}"

# Kiểm tra quyền root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}[ERROR] Hãy chạy script bằng sudo!${NC}"
    exit 1
fi

# ==========================================
# STEP 1: BUILD & TEST
# ==========================================

echo -e "\n${YELLOW}[STEP 1] BUILD & TEST${NC}"

if [ ! -d "$PROJECT_DIR" ]; then
    echo -e "${RED}[ERROR] Không tìm thấy source code: $PROJECT_DIR${NC}"
    exit 1
fi

cd "$PROJECT_DIR" || exit 1

./gradlew clean bootJar

BUILD_EXIT_CODE=$?

if [ $BUILD_EXIT_CODE -ne 0 ]; then
    echo -e "${RED}[ERROR] BUILD FAILED! Deployment stopped.${NC}"
    exit 1
fi

echo -e "${GREEN}[SUCCESS] Build completed!${NC}"

# Tìm file JAR vừa build
JAR_FILE=$(find "$PROJECT_DIR/build/libs" \
    -maxdepth 1 -type f -name "*.jar" ! -name "*-plain.jar" | head -n 1)

if [ -z "$JAR_FILE" ]; then
    echo -e "${RED}[ERROR] Không tìm thấy file JAR!${NC}"
    exit 1
fi

# ==========================================
# STEP 2: PREPARE DIRECTORY
# ==========================================

echo -e "\n${YELLOW}[STEP 2] PREPARING INFRASTRUCTURE${NC}"

# Tạo group nếu chưa tồn tại
if ! getent group quickbite > /dev/null; then
    groupadd --system quickbite
fi

# Tạo user nếu chưa tồn tại
if ! id quickbite > /dev/null 2>&1; then
    useradd --system --gid quickbite --no-create-home \
        --shell /bin/false quickbite
fi

mkdir -p "$APP_DIR" "$LOG_DIR"

chown -R quickbite:quickbite /opt/quickbite
chown -R quickbite:quickbite "$LOG_DIR"

echo -e "${GREEN}[SUCCESS] Directories prepared!${NC}"

# ==========================================
# STEP 3: STOP OLD APP & COPY JAR
# ==========================================

echo -e "\n${YELLOW}[STEP 3] COPYING APPLICATION${NC}"

# Dừng tiến trình cũ nếu có PID file
if [ -f "$PID_FILE" ]; then
    OLD_PID=$(cat "$PID_FILE")

    if kill -0 "$OLD_PID" 2>/dev/null; then
        kill "$OLD_PID"

        # Chờ tiến trình kết thúc
        for i in {1..10}; do
            kill -0 "$OLD_PID" 2>/dev/null || break
            sleep 1
        done

        if kill -0 "$OLD_PID" 2>/dev/null; then
            kill -9 "$OLD_PID"
        fi

        echo -e "${GREEN}[INFO] Old application stopped.${NC}"
    fi

    rm -f "$PID_FILE"
fi

cp "$JAR_FILE" "$JAR_PATH"
chown quickbite:quickbite "$JAR_PATH"
chmod 500 "$JAR_PATH"

echo -e "${GREEN}[SUCCESS] New JAR copied successfully!${NC}"

# ==========================================
# STEP 4: START APPLICATION
# ==========================================

echo -e "\n${YELLOW}[STEP 4] STARTING APPLICATION${NC}"

touch "$LOG_FILE"
chown quickbite:quickbite "$LOG_FILE"

runuser -u quickbite -- bash -c \
    "nohup java -jar '$JAR_PATH' >> '$LOG_FILE' 2>&1 & echo \$! > '$PID_FILE'"

chown quickbite:quickbite "$PID_FILE"

echo -e "${GREEN}[SUCCESS] Application starting in background!${NC}"

# ==========================================
# STEP 5: SMOKE TEST
# ==========================================

echo -e "\n${YELLOW}[STEP 5] SMOKE TEST${NC}"

echo "Waiting 5 seconds for JVM initialization..."
sleep 5

if timeout 2 bash -c '</dev/tcp/127.0.0.1/8080' 2>/dev/null; then
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}   DEPLOYS DỊCH VỤ THÀNH CÔNG!${NC}"
    echo -e "${GREEN}========================================${NC}"
    exit 0
else
    echo -e "${RED}[ERROR] Application is not listening on port 8080!${NC}"

    echo -e "${YELLOW}Last 30 lines of application log:${NC}"

    tail -n 30 "$LOG_FILE"

    exit 1
fi

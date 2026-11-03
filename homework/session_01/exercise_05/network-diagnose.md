# Network Diagnosis – Exercise 05

## 1. Tình huống 1: Xử lý xung đột cổng 8080

### Mục tiêu
Tìm PID của tiến trình đang chiếm cổng 8080 và dừng tiến trình để giải phóng cổng.

### Các câu lệnh đã sử dụng

**Kiểm tra tiến trình đang sử dụng cổng 8080:**

```bash
sudo ss -tulpn | grep :8080
```

Giải thích:
- `ss`: kiểm tra socket mạng.
- `-t`: hiển thị TCP.
- `-u`: hiển thị UDP.
- `-l`: chỉ hiển thị các cổng đang lắng nghe.
- `-p`: hiển thị thông tin tiến trình.
- `-n`: hiển thị địa chỉ và cổng dạng số.
- `grep :8080`: lọc kết quả liên quan đến cổng 8080.

Từ kết quả, xác định PID của tiến trình đang chiếm cổng.

**Dừng tiến trình:**

```bash
sudo kill -9 <PID>
```

Thay `<PID>` bằng PID thực tế tìm được.

Giải thích: `kill -9` gửi tín hiệu SIGKILL để buộc tiến trình kết thúc.

**Kiểm tra lại cổng:**

```bash
sudo ss -tulpn | grep :8080
```

Nếu không có kết quả, không còn tiến trình phù hợp đang lắng nghe trên cổng 8080.

## 2. Tình huống 2: Kiểm tra kết nối PostgreSQL

### Mục tiêu
Kiểm tra khả năng kết nối tới máy chủ Database `10.0.1.20` và trạng thái cổng PostgreSQL `5432`.

**Kiểm tra kết nối IP:**

```bash
ping -c 4 10.0.1.20
```

Giải thích:
- `ping`: kiểm tra khả năng phản hồi ICMP từ máy chủ.
- `-c 4`: gửi 4 gói tin rồi dừng.

Nếu nhận được phản hồi, máy chủ có thể truy cập qua ICMP. Nếu không nhận được phản hồi, cần kiểm tra mạng hoặc khả năng máy chủ chặn ICMP.

**Kiểm tra cổng PostgreSQL:**

```bash
nc -vz -w 3 10.0.1.20 5432
```

Giải thích:
- `nc`: công cụ kiểm tra kết nối mạng.
- `-v`: hiển thị thông tin chi tiết.
- `-z`: kiểm tra cổng mà không truyền dữ liệu.
- `-w 3`: đặt thời gian chờ 3 giây.

Nếu xuất hiện `succeeded`, cổng TCP 5432 có thể kết nối được. Nếu xuất hiện `Connection refused`, máy chủ từ chối kết nối. Nếu `timed out`, không nhận được phản hồi trong thời gian chờ.

## 3. Kết luận

- Tình huống 1: Sử dụng `ss` để tìm PID, `kill -9` để dừng tiến trình và kiểm tra lại cổng 8080.
- Tình huống 2: Sử dụng `ping` để kiểm tra khả năng kết nối IP và `nc` để kiểm tra khả năng kết nối tới cổng PostgreSQL 5432.

Kết quả thực tế được ghi nhận từ terminal trong quá trình thực hiện bài tập.

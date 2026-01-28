# 1. Dùng Python 3.9 bản nhẹ
FROM python:3.9-slim

# 2. Đặt thư mục làm việc trong Docker là /app
WORKDIR /app

# 3. Copy file thư viện vào trước
COPY requirements.txt .

# 4. Cài các thư viện cần thiết
RUN pip install --no-cache-dir -r requirements.txt

# 5. Copy toàn bộ code còn lại vào
COPY . .

# 6. Mở cổng 5000
EXPOSE 5000

# 7. Lệnh chạy mặc định (sẽ bị docker-compose ghi đè, nhưng cứ để đây cho chuẩn)
CMD ["python", "app_paramacia.py"]
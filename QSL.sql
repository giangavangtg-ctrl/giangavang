-- =======================================================
-- PHẦN 1: KHỞI TẠO CẤU TRÚC CŨ (LEGACY)
-- =======================================================
CREATE DATABASE IF NOT EXISTS autoride_db;
USE autoride_db;

CREATE TABLE IF NOT EXISTS Cars (
    car_id INT AUTO_INCREMENT PRIMARY KEY,
    model_name VARCHAR(100) NOT NULL,
    license_plate VARCHAR(20) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS Rentals (
    rental_id INT AUTO_INCREMENT PRIMARY KEY,
    car_id INT,
    customer_name VARCHAR(100) NOT NULL,
    rent_date DATETIME NOT NULL,
    return_date DATETIME,
    status VARCHAR(50) DEFAULT 'BOOKED', 
    FOREIGN KEY (car_id) REFERENCES Cars(car_id)
);

-- =======================================================
-- PHẦN 2 & 3: TỐI ƯU HÓA (SCHEMA OPTIMIZATION)
-- =======================================================

-- 1. Nâng cấp bảng Rentals: Khóa chặt trạng thái và thêm cột tài chính
ALTER TABLE Rentals
MODIFY COLUMN status ENUM('BOOKED', 'ACTIVE', 'COMPLETED', 'CANCELLED') DEFAULT 'BOOKED',
ADD COLUMN security_deposit DECIMAL(10,2) DEFAULT 0.00,
ADD COLUMN late_fee DECIMAL(10,2) DEFAULT 0.00,
ADD COLUMN damage_fee DECIMAL(10,2) DEFAULT 0.00;

-- 2. Khởi tạo bảng Inspections (Biên bản kiểm tra)
CREATE TABLE Inspections (
    inspection_id INT AUTO_INCREMENT PRIMARY KEY,
    rental_id INT NOT NULL,
    inspection_date DATETIME NOT NULL,
    damage_description TEXT,
    inspector_name VARCHAR(100) NOT NULL,
    -- Ràng buộc RESTRICT: Không cho phép xóa hợp đồng nếu đã có biên bản kiểm tra
    FOREIGN KEY (rental_id) REFERENCES Rentals(rental_id) ON DELETE RESTRICT
);

-- =======================================================
-- PHẦN 4: VẬN HÀNH VÀ CHÉP LIỆU THỰC TẾ (DML)
-- =======================================================

-- Bước A: Nhập dữ liệu xe nền tảng
INSERT INTO Cars (model_name, license_plate) 
VALUES ('Honda Civic 2023', '30G-123.45');

-- Bước B: Khách hàng Nguyen Van A thuê xe (Đóng cọc 10tr, Trạng thái ACTIVE)
INSERT INTO Rentals (car_id, customer_name, rent_date, status, security_deposit)
VALUES (1, 'Nguyen Van A', '2026-10-01 08:00:00', 'ACTIVE', 10000000.00);

-- Bước C: Khách trả xe, nhân viên kiểm tra phát hiện lỗi
INSERT INTO Inspections (rental_id, inspection_date, damage_description, inspector_name)
VALUES (1, '2026-10-03 08:00:00', 'Vỡ đèn pha trái', 'Tran Van B');

-- Bước D: Cập nhật hợp đồng (Trạng thái COMPLETED, Phạt hư hỏng 2tr)
UPDATE Rentals 
SET status = 'COMPLETED', return_date = '2026-10-03 08:00:00', late_fee = 0.00, damage_fee = 2000000.00
WHERE rental_id = 1;

-- Bước E: Truy vấn tính toán Tiền hoàn lại (Refund) an toàn với hàm COALESCE xử lý NULL
SELECT 
    r.rental_id,
    r.customer_name,
    r.status,
    r.security_deposit,
    r.late_fee,
    r.damage_fee,
    i.damage_description,
    (r.security_deposit - COALESCE(r.late_fee, 0) - COALESCE(r.damage_fee, 0)) AS refund_amount
FROM Rentals r
LEFT JOIN Inspections i ON r.rental_id = i.rental_id
WHERE r.rental_id = 1;
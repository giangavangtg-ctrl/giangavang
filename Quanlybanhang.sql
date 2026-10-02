-- 1. Tạo và sử dụng cơ sở dữ liệu
CREATE DATABASE QuanLyBanHang;
USE QuanLyBanHang;

-- 2. Tạo bảng Customer (Khách hàng - Bảng độc lập)
CREATE TABLE Customer (
    cID INT AUTO_INCREMENT PRIMARY KEY,
    cName VARCHAR(50) NOT NULL,
    cAge INT
);

-- 3. Tạo bảng Product (Sản phẩm - Bảng độc lập)
CREATE TABLE Product (
    pID INT AUTO_INCREMENT PRIMARY KEY,
    pName VARCHAR(100) NOT NULL,
    pPrice DECIMAL(10, 2) NOT NULL
);

-- 4. Tạo bảng Order (Hóa đơn - Phụ thuộc vào Customer)
-- Chú ý: 'Order' là từ khóa hệ thống của SQL nên cần đặt trong dấu backtick (` `)
CREATE TABLE `Order` (
    oID INT AUTO_INCREMENT PRIMARY KEY,
    cID INT NOT NULL,
    oDate DATETIME NOT NULL,
    oTotalPrice DECIMAL(10, 2),
    FOREIGN KEY (cID) REFERENCES Customer(cID)
);

-- 5. Tạo bảng OrderDetail (Chi tiết hóa đơn - Bảng trung gian n-n)
CREATE TABLE OrderDetail (
    oID INT,
    pID INT,
    odQTY INT NOT NULL,
    PRIMARY KEY (oID, pID),
    FOREIGN KEY (oID) REFERENCES `Order`(oID),
    FOREIGN KEY (pID) REFERENCES Product(pID)
);
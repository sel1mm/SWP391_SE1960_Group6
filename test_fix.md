# Sửa lỗi hiển thị mã hợp đồng và loại thiết bị

## Vấn đề ban đầu
Bạn báo cáo rằng:
1. **Thiết bị phụ lục hiển thị mã hợp đồng là "N/A"** thay vì mã hợp đồng thực tế
2. **Cột loại không phân biệt** được giữa thiết bị từ "hợp đồng" và "phụ lục"

## Nguyên nhân đã tìm thấy

### 1. Lỗi SQL trong method `getEquipmentContractInfo`
**File:** `CRM/src/java/dal/EquipmentDAO.java`
**Vấn đề:** SQL query sử dụng `ca.appendixDate` nhưng trong database schema trường này tên là `ca.effectiveDate`

### 2. Lỗi SQL trong method `getEquipmentRepairInfo` 
**File:** `CRM/src/java/dal/EquipmentDAO.java`
**Vấn đề:** SQL query sử dụng tên bảng và trường không đúng với schema hiện tại

## Các sửa đổi đã thực hiện

### ✅ Sửa 1: Method `getEquipmentContractInfo`
```java
// TRƯỚC (lỗi):
"ORDER BY ca.appendixDate DESC LIMIT 1"

// SAU (đã sửa):
"ORDER BY ca.effectiveDate DESC LIMIT 1"
```

### ✅ Sửa 2: Method `getEquipmentRepairInfo`
```java
// TRƯỚC (lỗi - sử dụng schema cũ):
FROM Equipment e 
LEFT JOIN ServiceRequest sr ON e.equipment_id = sr.equipment_id
LEFT JOIN Quotation q ON sr.request_id = q.request_id
LEFT JOIN Users u ON q.technician_id = u.user_id

// SAU (đã sửa - sử dụng schema đúng):
FROM Equipment e 
LEFT JOIN ServiceRequest sr ON e.equipmentId = sr.equipmentId
LEFT JOIN RepairReport rr ON sr.requestId = rr.requestId
LEFT JOIN Account a ON rr.technicianId = a.accountId
```

## Cách hoạt động sau khi sửa

### 🔍 Luồng xử lý dữ liệu:
1. **Controller** (`EquipmentServlet.java`) gọi `getEquipmentContractInfo(equipmentId, customerId)`
2. **DAO** kiểm tra thiết bị trong 2 bảng:
   - `ContractEquipment` (thiết bị hợp đồng chính) → trả về source = "Contract"
   - `ContractAppendixEquipment` (thiết bị phụ lục) → trả về source = "Appendix"
3. **Controller** chuyển đổi:
   - `source = "Contract"` → `sourceType = "Hợp Đồng"`
   - `source = "Appendix"` → `sourceType = "Phụ Lục"`
   - `contractId` được format thành "HD001", "HD002", etc.
4. **JSP** hiển thị:
   - Cột "Loại": Badge màu xanh cho "Hợp Đồng", màu xanh dương cho "Phụ Lục"
   - Cột "Mã Hợp Đồng": Badge màu primary với mã đã format

## Kết quả mong đợi

### ✅ Trước khi sửa:
- Thiết bị phụ lục: Mã hợp đồng = "N/A", Loại = "Không xác định"
- Thiết bị hợp đồng: Mã hợp đồng = "HD001", Loại = "Hợp Đồng"

### ✅ Sau khi sửa:
- Thiết bị phụ lục: Mã hợp đồng = "HD001", Loại = "Phụ Lục" 
- Thiết bị hợp đồng: Mã hợp đồng = "HD001", Loại = "Hợp Đồng"

## Cách kiểm tra

### 1. Kiểm tra dữ liệu test
Đảm bảo có dữ liệu trong các bảng:
```sql
-- Kiểm tra thiết bị trong phụ lục
SELECT ca.contractId, cae.equipmentId, e.model 
FROM ContractAppendixEquipment cae
JOIN ContractAppendix ca ON cae.appendixId = ca.appendixId  
JOIN Equipment e ON cae.equipmentId = e.equipmentId;
```

### 2. Kiểm tra giao diện
1. Đăng nhập với tài khoản khách hàng có thiết bị phụ lục
2. Vào trang "Thiết Bị"
3. Xác nhận:
   - ✅ Cột "Mã Hợp Đồng" hiển thị mã thực tế (HD001, HD002...) thay vì "N/A"
   - ✅ Cột "Loại" hiển thị "Phụ Lục" với badge màu xanh dương
   - ✅ Thiết bị hợp đồng chính vẫn hiển thị "Hợp Đồng" với badge màu xanh

## Lưu ý kỹ thuật
- **Build project:** Cần compile lại sau khi sửa đổi Java code
- **Database:** Đảm bảo có dữ liệu test trong `ContractAppendix` và `ContractAppendixEquipment`
- **Compatibility:** Sửa đổi tương thích với schema hiện tại, không ảnh hưởng chức năng khác
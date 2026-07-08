# Database và models

## Database trung tâm
- File: lib/core/database/database_helper.dart
- Dùng sqflite
- Tạo và quản lý các bảng:
  - users
  - categories
  - transactions
  - budgets
  - settings

## Bảng quan trọng
### users
Lưu tài khoản người dùng, gồm:
- id
- name
- email
- password
- avatarUrl
- phone
- createdAt

### categories
Lưu danh mục thu/chi cho từng user.

### transactions
Lưu giao dịch thu/chi, gồm:
- amount
- date
- note
- category_id
- type
- user_id

### budgets
Lưu ngân sách theo danh mục hoặc tổng thể.

### settings
Lưu theme, currency, notification.

## Model mapping
- TransactionModel: ánh xạ từ map DB sang object.
- CategoryModel: ánh xạ từ map DB sang object.
- Provider sẽ đọc dữ liệu từ DB, chuyển thành model và expose cho UI.

## Khi thêm feature mới
- Nếu cần lưu dữ liệu mới, thêm bảng trong DatabaseHelper.
- Nếu cần query riêng, thêm method mới vào DatabaseHelper.
- Không nên gọi DB trực tiếp từ UI.

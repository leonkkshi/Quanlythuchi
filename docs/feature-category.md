# Module Category

## Mục đích
Quản lý danh mục thu/chi, gồm tạo mới, xóa và phân loại theo expense/income.

## File chính
- lib/features/category/application/providers/category_provider.dart
- lib/features/category/presentation/views/category_management_page.dart
- lib/features/category/presentation/views/create_category_page.dart
- lib/features/category/data/models/category_model.dart
- lib/features/category/domain/entities/category.dart

## Provider responsibilities
- loadCategories(userId)
- addCategory(...)
- deleteCategory(id)
- expose expenseCategories và incomeCategories

## Lưu ý
- Mỗi category có iconCode và colorHex.
- Khi thêm loại danh mục mới, cần đảm bảo UI hiển thị đúng.
- Danh mục được bind với user_id để tách dữ liệu theo người dùng.

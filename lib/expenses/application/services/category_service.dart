import 'package:mobile_app_frontend/expenses/domain/entities/category.dart';
import 'package:mobile_app_frontend/expenses/domain/repositories/expenses_repository.dart';

class CategoryService {
  final ExpensesRepository repository;

  CategoryService(this.repository);

  Future<List<Category>> getCategories() {
    return repository.getCategories();
  }

  Future<Category> createCategory(Category category) {
    return repository.createCategory(category);
  }

  Future<Category> getCategoryById(int categoryId) {
    return repository.getCategoryById(categoryId);
  }

  Future<void> deleteCategory(int categoryId) {
    return repository.deleteCategory(categoryId);
  }
}
import '../../domain/entities/product.dart';
import '../models/product_model.dart';

abstract class ProductsDatasource {
  Future<List<ProductModel>> getProducts({
    int page = 1,
    int limit = 20,
    String? search,
    String? categoryId,
    double? minPrice,
    double? maxPrice,
    String? sort,
  });

  Future<ProductModel> getProductById(String id);
  Future<List<ProductCategory>> getCategories();
}

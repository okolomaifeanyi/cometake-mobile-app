import '../entities/product.dart';

abstract class ProductsRepository {
  Future<({List<Product> products, bool hasMore})> getProducts({
    int page = 1,
    int limit = 20,
    String? search,
    String? categoryId,
    double? minPrice,
    double? maxPrice,
    String? sort,
  });

  Future<Product> getProductById(String id);
  Future<List<ProductCategory>> getCategories();
}

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/products_repository.dart';
import '../datasources/products_datasource.dart';

class ProductsRepositoryImpl implements ProductsRepository {
  final ProductsDatasource _datasource;
  const ProductsRepositoryImpl(this._datasource);

  @override
  Future<({List<Product> products, bool hasMore})> getProducts({
    int page = 1,
    int limit = 20,
    String? search,
    String? categoryId,
    double? minPrice,
    double? maxPrice,
    String? sort,
  }) async {
    try {
      final models = await _datasource.getProducts(
        page: page,
        limit: limit,
        search: search,
        categoryId: categoryId,
        minPrice: minPrice,
        maxPrice: maxPrice,
        sort: sort,
      );
      return (
        products: models.map((m) => m.toEntity()).toList(),
        hasMore: models.length >= limit,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException('Products unavailable. Please try again.');
    }
  }

  @override
  Future<Product> getProductById(String id) async {
    try {
      final model = await _datasource.getProductById(id);
      return model.toEntity();
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException('Could not load product.');
    }
  }

  @override
  Future<List<ProductCategory>> getCategories() =>
      _datasource.getCategories();
}

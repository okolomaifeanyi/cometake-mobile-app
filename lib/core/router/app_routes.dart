abstract final class AppRoutes {
  // Unauthenticated
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const otp = '/otp';
  static const forgotPassword = '/forgot-password';

  // Shell tabs
  static const home = '/home';
  static const products = '/products';
  static const cart = '/cart';
  static const wallet = '/wallet';
  static const profile = '/profile';
  static const profileEdit = '/profile/edit';

  // Nested under /products
  static const productDetail = ':productId';
  static String productDetailPath(String id) => '/products/$id';

  // Nested under /wallet
  static const walletTopup = '/wallet/topup';

  // Top-level authenticated (still inside shell)
  static const orders = '/orders';
  static const orderDetail = '/order/:orderId';
  static String orderDetailPath(String id) => '/order/$id';

  static const vtu = '/vtu';
  static const vtuPurchase = '/vtu/:serviceType';
  static String vtuPurchasePath(String type) => '/vtu/$type';
  static const vtuHistory = '/vtu-history';

  static const chat = '/chat';
  static const conversation = '/chat/:conversationId';
  static String conversationPath(String id) => '/chat/$id';

  static const vendor = '/vendor';
  static const vendorAddProduct = '/vendor/add-product';
  static const vendorEditProduct = '/vendor/edit-product/:productId';
  static String vendorEditProductPath(String id) => '/vendor/edit-product/$id';
}

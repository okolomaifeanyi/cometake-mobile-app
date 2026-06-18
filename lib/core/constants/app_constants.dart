abstract final class AppConstants {
  // Pagination
  static const int pageSize = 20;
  static const int chatPageSize = 50;
  static const int searchPageSize = 10;

  // Debounce
  static const int searchDebounceMs = 400;

  // Network
  static const int connectTimeoutSeconds = 15;
  static const int receiveTimeoutSeconds = 30;
  static const int maxRetries = 1;

  // Cache
  static const int imageCacheMaxAgeDays = 30;
  static const int providerCacheTtlMinutes = 5;

  // Cloudinary
  static const double cloudinaryDefaultWidth = 400.0;
  static const double cloudinaryThumbnailWidth = 100.0;
  static const double cloudinaryBannerWidth = 800.0;

  // Upload
  static const int maxImageUploadSizeMb = 10;
  static const int maxImageUploadSizeBytes = maxImageUploadSizeMb * 1024 * 1024;

  // Wallet
  static const double minWalletFunding = 100.0;
  static const double maxWalletFunding = 1000000.0;
}

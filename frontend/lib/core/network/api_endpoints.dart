/// All backend API route strings in one place.
/// Import this instead of hard-coding strings in sources.
class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const login          = '/auth/login';
  static const signup         = '/auth/signup';
  static const forgotPassword = '/auth/forgot-password';
  static const resetPassword  = '/auth/reset-password';

  // Categories
  static const categories        = '/categories';
  static String category(int id) => '/categories/$id';

  // Products
  static const products          = '/products';
  static String product(int id)  => '/products/$id';
}

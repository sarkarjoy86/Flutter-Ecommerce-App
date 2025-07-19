import 'package:get/get.dart';

import '../data/repositories/addresses/address_repository.dart';
import '../data/repositories/authentications/authentication_repository.dart';
import '../data/repositories/authentications/category_repository.dart';
import '../data/repositories/authentications/user_repository.dart';
import '../data/repositories/cart/cart_repository.dart';
import '../data/repositories/orders/order_repository.dart';
import '../data/repositories/products/product_repository.dart';
import '../data/repositories/reviews/review_repository.dart';
import '../data/repositories/wishlist/wishlist_repository.dart';
import '../features/personalization/controllers/address_controller.dart';
import '../features/personalization/controllers/user_controller.dart';
import '../features/shop/controllers/cart_controller.dart';
import '../features/shop/controllers/category_controller.dart';
import '../features/shop/controllers/order_controller.dart';
import '../features/shop/controllers/product_controller.dart';
import '../features/shop/controllers/review_controller.dart';
import '../features/shop/controllers/wishlist_controller.dart';
import '../features/shop/screens/product_details/widgets/product_attributes.dart';
import '../utils/helpers/network_manager.dart';

class GeneralBindings extends Bindings {
  @override
  void dependencies() {
    // Network Manager - Singleton
    Get.put(NetworkManager());
    
    // Repositories first (before controllers that depend on them)
    Get.put(CategoryRepository());
    Get.put(ProductRepository());
    Get.put(CartRepository());
    Get.put(WishlistRepository());
    Get.put(ReviewRepository());
    Get.put(OrderRepository());
    Get.put(AddressRepository());
    
    // Authentication
    Get.put(AuthenticationRepository());
    Get.put(UserRepository());
    Get.put(UserController());
    
    // Controllers after repositories are ready
    Get.put(ProductController(), permanent: true);
    Get.put(CartController(), permanent: true);
    Get.put(WishlistController(), permanent: true);
    Get.put(CategoryController(), permanent: true);
    Get.put(ReviewController(), permanent: true);
    Get.put(AddressController(), permanent: true);
    Get.put(OrderController(), permanent: true);
    
    // Product Attribute Controller - Lazily loaded when needed
    Get.lazyPut<ProductAttributeController>(() => ProductAttributeController());
  }
}

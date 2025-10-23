import 'package:get/get.dart';
import '../modules/home/home_view.dart';
import '../modules/home/home_controller.dart';
import '../modules/auth/auth_view.dart';
import '../modules/auth/auth_controller.dart';
import '../modules/welcome/welcome_view.dart';
import '../modules/saved_locations/saved_locations_view.dart';
import '../modules/saved_locations/saved_locations_controller.dart';
import '../modules/route_to_location/route_to_location_view.dart';
import '../modules/simple_locations/simple_locations_view.dart';
import '../modules/simple_locations/simple_locations_controller.dart';
import 'app_routes.dart';

class AppPages {
  static const INITIAL = Routes.WELCOME;

  static final routes = [
    GetPage(
      name: Routes.WELCOME,
      page: () => const WelcomeView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<HomeController>(() => HomeController());
      }),
    ),
    GetPage(
      name: Routes.HOME,
      page: () => const HomeView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<HomeController>(() => HomeController());
      }),
    ),
    GetPage(
      name: Routes.AUTH,
      page: () => const AuthView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController());
      }),
    ),
    GetPage(
      name: Routes.SAVED_LOCATIONS,
      page: () => const SavedLocationsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<SavedLocationsController>(() => SavedLocationsController());
      }),
    ),
    GetPage(
      name: Routes.ROUTE_TO_LOCATION,
      page: () => const RouteToLocationView(),
    ),
    GetPage(
      name: Routes.SIMPLE_LOCATIONS,
      page: () => const SimpleLocationsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<SimpleLocationsController>(() => SimpleLocationsController());
      }),
    ),
  ];
}
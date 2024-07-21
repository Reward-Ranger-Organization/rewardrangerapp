import 'package:get_it/get_it.dart';
import 'package:rewardrangerapp/helper_function/api_service.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton<ApiService>(() => ApiService());
}

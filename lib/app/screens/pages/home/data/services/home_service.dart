import 'package:jiosaavn_handler/jiosaavn_handler.dart';

class HomeService {
  // get home page data

  // get top charts
  Future<Map<dynamic, dynamic>> getHomePage() async {
    return await Api().fetchHomePageData();
  }
}

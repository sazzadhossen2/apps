import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'features/admin/ui/controller/admin_controller.dart';
import 'features/ai_assistant/ui/controller/ai_controller.dart';
import 'features/auth/ui/controller/auth_controller.dart';
import 'features/home/ui/controller/home_controller.dart';
import 'features/my_bookings/ui/controller/my_bookings_controller.dart';

/// App-wide controllers (Provider + ChangeNotifier).
/// Screen-scoped controllers (e.g. BookingController) are created inside their screen.
class ControllerBinding {
  ControllerBinding._();

  static List<SingleChildWidget> get providers => [
        ChangeNotifierProvider<AuthController>(create: (_) => AuthController()),
        ChangeNotifierProvider<HomeController>(create: (_) => HomeController()),
        ChangeNotifierProvider<MyBookingsController>(create: (_) => MyBookingsController()),
        ChangeNotifierProvider<AiController>(create: (_) => AiController()),
        ChangeNotifierProvider<AdminController>(create: (_) => AdminController()),
      ];
}

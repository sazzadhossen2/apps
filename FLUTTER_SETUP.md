# Flutter app setup (v2: OTP, Stripe, Admin, Reviews)

Replace your project's `lib/` folder with the one in `lib.zip`, then:

## 1. pubspec.yaml dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.2
  dio: ^5.7.0
  flutter_secure_storage: ^9.2.2
  intl: ^0.19.0
  cached_network_image: ^3.4.1
  flutter_stripe: ^11.2.0     # NEW (payments)
```
Run `flutter pub get`.

## 2. Android setup for flutter_stripe (required, otherwise the payment sheet crashes)
- `android/app/src/main/kotlin/.../MainActivity.kt` must extend **FlutterFragmentActivity**:
  ```kotlin
  import io.flutter.embedding.android.FlutterFragmentActivity
  class MainActivity : FlutterFragmentActivity()
  ```
- `android/app/src/main/res/values/styles.xml` and `values-night/styles.xml`: set `LaunchTheme` and `NormalTheme` parents to
  `Theme.MaterialComponents.Light.NoActionBar` (or `Theme.AppCompat.Light.NoActionBar`).
- `android/app/build.gradle`: `minSdkVersion 21` (or higher), a current Kotlin version (1.8+).
- `AndroidManifest.xml`: `<uses-permission android:name="android.permission.INTERNET"/>`, and while your API is plain `http://` add
  `android:usesCleartextTraffic="true"` to `<application>` (not needed for an https API).
- If the **release** build fails in R8 with "Missing class com.stripe.android.pushProvisioning...", add to `android/app/proguard-rules.pro`:
  `-dontwarn com.stripe.android.pushProvisioning.**`
- iOS: platform 13+.

## 3. Point the app to your API
```bash
# Android emulator (default already): http://10.0.2.2:5000/api/v1
flutter run --dart-define=API_BASE_URL=http://192.168.0.10:5000/api/v1      # real phone on the same Wi-Fi
flutter build apk --release --dart-define=API_BASE_URL=https://YOUR-HOSTED-API/api/v1 --dart-define=STRIPE_PUBLISHABLE_KEY=pk_test_xxx
```
The APK you submit must use a **hosted** API URL (Render, Railway...), not localhost.

## 4. Stripe key
The publishable key (`pk_...`) is safe inside the app. The server also sends its own key with every payment, so keep the server `.env` and the app on the SAME mode (both test or both live).
Use **test keys** for the demo video. Test card: `4242 4242 4242 4242`, any future date, any CVC.

## Who sees what
After login the app checks `user.role`: **admin** → Admin panel (Dashboard, Requests, Busy, Services, Profile); **user** → Home, Bookings, Assistant, Profile.

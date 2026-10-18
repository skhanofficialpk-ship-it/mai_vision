// Picks the right implementation at compile time:
// - On web, uses splash_screen_web.dart (calls the JS removeSplashScreen()).
// - On every other platform, falls back to the no-op stub.
//
// Call removeSplashScreen() once the app's first meaningful frame has been
// drawn (see main.dart) so the HTML splash screen in web/index.html fades
// out cleanly instead of leaving a static logo on screen forever.
export 'splash_screen_stub.dart' if (dart.library.js_interop) 'splash_screen_web.dart';

// Web implementation — calls the `window.removeSplashScreen()` JS function
// defined in web/index.html, which fades out and removes the splash screen
// once Flutter has rendered its first frame.
//
// This file is only ever compiled when targeting web (see splash_screen.dart's
// conditional import), so dart:js_interop is safe to use here.
import 'dart:js_interop';

@JS('removeSplashScreen')
external void _removeSplashScreen();

void removeSplashScreen() {
  try {
    _removeSplashScreen();
  } catch (_) {
    // If the splash element or JS function isn't present for any reason,
    // fail silently rather than crash the app.
  }
}

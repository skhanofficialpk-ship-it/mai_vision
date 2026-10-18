// No-op implementation used on any platform other than web (where there is
// no HTML splash screen to remove). Keeps splash_screen.dart's conditional
// import valid if this project ever adds Android/iOS/desktop targets.
void removeSplashScreen() {
  // Nothing to do on non-web platforms.
}

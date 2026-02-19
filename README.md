# Freight Match

## Google Maps setup

1. Android:
- Open `/Users/kera03/Coding/mobile/freight_match/android/app/src/main/AndroidManifest.xml`.
- Replace `YOUR_ANDROID_GOOGLE_MAPS_API_KEY` with your Google Maps API key.

2. iOS:
- Open `/Users/kera03/Coding/mobile/freight_match/ios/Runner/Info.plist`.
- Replace `YOUR_IOS_GOOGLE_MAPS_API_KEY` with your Google Maps API key.

## Google Sign-In setup

Run with your OAuth client ids using dart defines:

```bash
flutter run \
  --dart-define=GOOGLE_CLIENT_ID=YOUR_GOOGLE_CLIENT_ID \
  --dart-define=GOOGLE_SERVER_CLIENT_ID=YOUR_GOOGLE_SERVER_CLIENT_ID
```

If your platform configuration already provides client ids, these defines can be omitted.

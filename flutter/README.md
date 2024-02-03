# accrualtracker

A new Flutter project.

## Environment
```
AZ_TABLE_ACCOUNT_NAME = environ('AZ_TABLE_ACCOUNT_NAME')
AZURE_TABLE_ACCOUNT_KEY = environ('AZURE_TABLE_ACCOUNT_KEY')
```

## Start Local Function Test Environmen
```func host start```
## Make a Test Request
```python post-request.py ```

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

### Provide my own app logo
(according to ChatGPT)  

To provide your own app logo for a Flutter app targeting Android, you need to replace the default launcher icon with your custom icon. The launcher icon is the image that represents your app on the device's home screen and in the app drawer.

Here are the steps to replace the launcher icon with your own custom icon:

1. **Prepare your custom icon**: Create a PNG image for your app icon in various sizes. The icon sizes required for Android are usually 48x48, 72x72, 96x96, 144x144, and 192x192 pixels. Make sure your icon follows the design guidelines for app icons on Android.

2. **Replace the default icon**: In your Flutter project, navigate to the `android/app/src/main/res` directory. Here, you'll find subdirectories named `mipmap-xxxhdpi`, `mipmap-xxhdpi`, `mipmap-xhdpi`, `mipmap-hdpi`, `mipmap-mdpi`. Each of these directories contains launcher icons in various densities. Replace the default icons in these directories with your custom icons. Ensure that you use the same filenames for your custom icons as the default icons (`ic_launcher.png`).

3. **Update the `AndroidManifest.xml`**: Open the `AndroidManifest.xml` file located in `android/app/src/main` directory. Find the `<application>` tag, and within it, locate the `android:icon` attribute. Update the value of this attribute to point to your custom launcher icon. It should look something like this:

    ```xml
    <application
        android:name="io.flutter.app.FlutterApplication"
        android:label="YourAppName"
        android:icon="@mipmap/ic_launcher"> <!-- Change this to point to your custom icon -->
    ```

4. **Rebuild your app**: After replacing the default icons and updating the `AndroidManifest.xml`, rebuild your Flutter app. You can do this by running `flutter clean` followed by `flutter build apk` or `flutter build appbundle` depending on your desired output.

5. **Test your app**: Once the build process is complete, install the app on an Android device or emulator to see your custom launcher icon in action.

By following these steps, you can provide your own app logo for a Flutter app targeting Android. Make sure to adhere to the design guidelines and requirements for app icons on the Android platform for the best user experience.
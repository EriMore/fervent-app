# Codemagic iOS Build Setup Instructions

This guide will help you set up automatic code signing in Codemagic so your iOS app can build and publish to TestFlight automatically.

## Prerequisites

- An Apple Developer account (paid membership required)
- Access to App Store Connect
- A Codemagic account

## Step 1: Create App Store Connect API Key

1. Log in to [App Store Connect](https://appstoreconnect.apple.com/)
2. Navigate to **Users and Access** → **Keys** tab
3. Click the **"+"** button (or "Generate API Key" button) to create a new key
4. Provide a name for the key (e.g., "Codemagic CI/CD")
5. Select the **App Manager** role (this provides the necessary permissions)
6. Click **Generate**
7. **IMPORTANT**: Download the `.p8` key file immediately - you can only download it once!
8. Note the following information (you'll need these later):
   - **Key ID**: Displayed in the keys list
   - **Issuer ID**: Found at the top of the Keys page (above the list of keys)

## Step 2: Connect Developer Portal Integration in Codemagic

1. Log in to your [Codemagic account](https://codemagic.io/)
2. Navigate to **User settings** (click your profile icon) → **Integrations**
3. Find **Developer Portal** in the list and click **Connect**
4. Fill in the following details:
   - **App Store Connect API key name**: Enter a descriptive name (e.g., "app_store_connect")
     - **Note**: This name must match the integration name in your `codemagic.yaml` file
     - Currently set to: `app_store_connect` (as seen in line 9 of codemagic.yaml)
   - **Issuer ID**: Paste the Issuer ID from Step 1
   - **Key ID**: Paste the Key ID from Step 1
   - **API key**: Upload the `.p8` file you downloaded in Step 1
5. Click **Save** to complete the integration

## Step 3: Verify Your codemagic.yaml Configuration

Your `codemagic.yaml` file is already configured to use the integration. Verify that:

- Line 9: `app_store_connect: app_store_connect` matches the integration name you set in Step 2
- The bundle identifier (`com.erioluwa.fervent`) matches your app's bundle ID in Xcode

## Step 4: Test Your Build

1. Push your code to your repository (if you haven't already)
2. In Codemagic, go to your app's page
3. Click **Start new build**
4. Select the `build-ios` workflow
5. Start the build

The build should now:
- Automatically fetch/create code signing certificates
- Build and archive your app
- Export an IPA file
- Upload to App Store Connect
- Submit to TestFlight (to "Internal Testers" group)

## Troubleshooting

### Build fails with "Integration not found"
- Verify the integration name in Codemagic matches `app_store_connect` in your yaml file
- Make sure you saved the integration in Codemagic UI

### Build fails with "Bundle ID not found"
- Verify your bundle ID `com.erioluwa.fervent` exists in App Store Connect
- Create the app in App Store Connect if it doesn't exist yet

### Code signing errors
- Ensure your Apple Developer account has an active membership
- Verify the API key has "App Manager" role
- Check that the bundle ID matches exactly between Xcode and App Store Connect

### TestFlight submission fails
- Verify the "Internal Testers" beta group exists in App Store Connect
- Ensure your app has passed App Store review at least once (for new apps)
- Check that the bundle ID and version are correctly configured

## Additional Resources

- [Codemagic iOS Code Signing Documentation](https://docs.codemagic.io/flutter-code-signing/ios-code-signing/)
- [App Store Connect API Keys Guide](https://developer.apple.com/documentation/appstoreconnectapi/creating_api_keys_for_app_store_connect_api)
- [Codemagic Publishing to App Store Connect](https://docs.codemagic.io/yaml-publishing/app-store-connect/)

## Need Help?

If you encounter issues:
1. Check the build logs in Codemagic for specific error messages
2. Verify all steps above were completed correctly
3. Consult Codemagic's documentation or support


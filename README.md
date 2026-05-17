# Lumena

Lumena is an iOS social beauty app prototype built around short-form makeup and skincare content. The app combines a vertical video feed, creator posting tools, cosmetic product tagging, user profiles, search, comments, likes, follows, notifications, and AWS-backed account/data storage.

This repository is an older project that I keep as a portfolio piece because it shows a full mobile product implementation across UI, camera/media workflows, authentication, cloud data models, and content upload pipelines.

## What It Does

- Presents short-form "Lume" posts in a swipeable video feed with recommendation and following tabs.
- Supports account creation, login, Cognito-backed session handling, profile setup, profile images, and background images.
- Provides camera-based content creation for photos, videos, timed recording, flash controls, image selection, text-based posts, previews, and save/upload flows.
- Lets users attach music previews to content through Spotify-style track search and audio preview playback.
- Stores post media, cosmetic images, audio, and profile assets through AWS S3.
- Uses AWS AppSync/GraphQL and generated Amplify models for users, posts, comments, likes, follows, cosmetics, tags, notifications, and skin settings.
- Includes cosmetic product submission, product metadata, product image upload, and search-oriented cosmetic models.
- Handles push notification registration and event tracking through AWS Pinpoint.

## Tech Stack

- **Language/UI:** Swift, SwiftUI, UIKit
- **Media:** AVFoundation, AVKit, Photos, custom camera and video playback components
- **Cloud:** AWS Amplify, Cognito Auth, AppSync GraphQL, DataStore, S3 Storage, Pinpoint Push Notifications
- **Dependencies:** CocoaPods, Swift Package Manager
- **Other libraries:** XLPagerTabStrip, TwitterProfile, ACThumbnailGenerator-Swift, Zip, ColorKit
- **Minimum iOS target:** iOS 16.0 for the main app target

## Project Structure

```text
Lumena/
|-- Account/                         # Auth, profile, account setup, Amplify helpers
|-- Main/                            # Main feed, reels/video playback, bottom navigation
|-- Models/                          # App-side models for lumes, cosmetics, music, search, profiles
|-- SubFunctions/                    # Camera helpers, search UI, product submission, browser, audio tools
|-- ViewControllers/                 # UIKit screens for feed, posting, comments, login, loading states
|-- Assets.xcassets/                 # App icons, logos, visual assets
AmplifyModels/                       # Generated AWS Amplify model types
graphql/                            # GraphQL queries, mutations, subscriptions, and schema artifacts
LumenaNotificationAPNAWS/            # Notification service extension
Podfile                              # CocoaPods dependencies
Lumena.xcworkspace                   # Open this workspace in Xcode
```

## Running Locally

1. Install CocoaPods if needed:

   ```bash
   sudo gem install cocoapods
   ```

2. Install pod dependencies:

   ```bash
   pod install
   ```

3. Open the workspace:

   ```bash
   open Lumena.xcworkspace
   ```

4. Select the `Lumena` scheme in Xcode and run on an iOS simulator or device.

The app expects valid AWS Amplify configuration for Cognito, AppSync, S3, and Pinpoint. Some cloud-backed flows will not work unless the matching backend environment and credentials are configured.

## Notes

This is a legacy showcase repository, not a polished production release. The value of the project is in the breadth of implementation: a native iOS social media experience, media capture/editing, cloud persistence, generated GraphQL models, authentication, push notifications, and product/search workflows in one app.

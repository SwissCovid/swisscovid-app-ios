<h1 align="center">SwissCovid for iOS</h1>
<h4 align="center">DP^3T Exposure Notification App for Switzerland 🇨🇭</h4>
<br />
<div align="center">
  <img width="180" height="180" src="DP3TApp/Resources/Assets.xcassets/AppIcon.appiconset/appicon@180x180.png" />
  <br />
  <div>
    <!-- App Store -->
    <a href="https://apps.apple.com/ch/app/swisscovid/id1509275381">
      <img height="40" src="https://bag-coronavirus.ch/wp-content/uploads/2020/04/app-store.png" alt="Download on the App Store" />
    </a>
  </div>
</div>
<br />
<div align="center">
    <!-- SPM -->
    <a href="https://github.com/apple/swift-package-manager">
      <img alt="Swift Package Manager"
      src="https://img.shields.io/badge/SPM-%E2%9C%93-brightgreen.svg?style=flat">
    </a>
    <!-- Build -->
    <a href="https://github.com/DP-3T/dp3t-app-ios-ch/build">
      <img alt="Build"
      src="https://github.com/DP-3T/dp3t-app-ios-ch/workflows/build/badge.svg">
    </a>
    <!-- License -->
    <a href="https://github.com/DP-3T/dp3t-sdk-ios-ch/blob/master/LICENSE">
      <img alt="License: MPL 2.0"
      src="https://img.shields.io/badge/License-MPL%202.0-brightgreen.svg">
    </a>
</div>

## DP^3T
The Decentralised Privacy-Preserving Proximity Tracing (DP-3T) project is an open protocol for COVID-19 proximity tracing using Bluetooth Low Energy functionality on mobile devices that ensures personal data and computation stays entirely on an individual's phone. It was produced by a core team of over 25 scientists and academic researchers from across Europe. It has also been scrutinized and improved by the wider community.

DP^3T is a free-standing effort started at EPFL and ETHZ that produced this protocol and that is implementing it in an open-sourced app and server.

## Introduction
This is a COVID-19 tracing client using the [DP3T iOS SDK](https://github.com/DP-3T/dp3t-sdk-ios). This project was released as the released as the official COVID-19 tracing solution for Switzerland, therefore UX, messages and flows are optimized for this specific case. Nevertheless, the source code should be a solid foundation to build a similar app for other countries and demostrate how the SDK can be used in a real app. The app design, UX and implementation was done by [Ubique](https://www.ubique.ch?app=github).

<p align="center">
<img src="Documentation/screenshots/screenshots.png" width="80%">
</p>

## Contribution Guide

This project is truly open-source and we welcome any feedback on the code regarding both the implementation and security aspects.

Bugs or potential problems should be reported using Github issues. We welcome all pull requests that improve the quality the source code. 

Please note that the app will be available with approved translations in English, German, French, Italian, Romansh, Albanian, Bosnian, Croatian, Portuguese, Serbian and Spanish. Pull requests for additional translations currently won't be merged.

Platform independent UX and design discussions should be reported in [dp3t-ux-screenflows-ch](https://github.com/DP-3T/dp3t-ux-screenflows-ch)

## Repositories
* Android SDK & Calibration app: [dp3t-sdk-android](https://github.com/DP-3T/dp3t-sdk-android)
* iOS SDK & Calibration app: [dp3t-sdk-ios](https://github.com/DP-3T/dp3t-sdk-ios)
* Android App: [dp3t-app-android-ch](https://github.com/DP-3T/dp3t-app-android-ch)
* iOS App: [dp3t-app-ios-ch](https://github.com/DP-3T/dp3t-app-ios-ch)
* Backend SDK: [dp3t-sdk-backend](https://github.com/DP-3T/dp3t-sdk-backend)
* UX & Screenflows
[dp3t-ux-screenflows-ch](https://github.com/DP-3T/dp3t-ux-screenflows-ch)


## Further Documentation
The full set of documents for DP3T is at https://github.com/DP-3T/documents. Please refer to the technical documents and whitepapers for a description of the implementation.

A description of the usage of the Apple Exposure Notifcation API can be found [here](https://github.com/DP-3T/dp3t-sdk-ios/blob/master/EXPOSURE_NOTIFICATION_API_USAGE.md).


## Installation and Building

The project should be opened with the Xcode 11.7 or newer. Dependencies are managed with [Swift Package Manager](https://swift.org/package-manager), no further setup is needed.

### Provisioning

The project is configured for a specific provisioning profile. To install the app on your own device, you will have to update the settings using your own provisioning profile.

Apple's ExposureNotification Framework requires an entitlement (`com.apple.developer.exposure-notification`) that is only be available to public health authorities. You will find more information in the [Exposure Notification Addendum](https://developer.apple.com/contact/request/download/Exposure_Notification_Addendum.pdf) and you can request the entitlement [here](https://developer.apple.com/contact/request/exposure-notification-entitlement).

## License
This project is licensed under the terms of the MPL 2 license. See the [LICENSE](LICENSE) file.

<h1 align="center">SwissCovid iOS App</h1>
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

SwissCovid is the official contact tracing app of Switzerland. The app can be installed from the [App Store](https://apps.apple.com/ch/app/swisscovid/id1509275381). The SwissCovid 2.0 app uses two types of contact tracing to prevent the spread of COVID-19.

With proximity tracing close contacts are detected using the bluetooth technology. For this the [DP3T iOS SDK](https://github.com/DP-3T/dp3t-sdk-ios) is used that builds on top of the Google & Apple Exposure Notifications. This feature is called SwissCovid encounters.

With presence tracing people that are at the same venue at the same time are detected. For this the [CrowdNotifier iOS SDK](https://github.com/CrowdNotifier/crowdnotifier-sdk-ios) is used that provides a secure, decentralized, privacy-preserving presence tracing system. This feature is called SwissCovid Check-in.

Please see the [SwissCovid documentation repository](https://github.com/SwissCovid/swisscovid-doc) for more details.

## Contribution Guide

This project is truly open-source and we welcome any feedback on the code regarding both the implementation and security aspects.

Bugs or potential problems should be reported using Github issues. We welcome all pull requests that improve the quality the source code. 

Please note that the app will be available with approved translations in English, German, French, Italian, Romansh, Albanian, Bosnian, Croatian, Portuguese, Serbian and Spanish. Pull requests for additional translations currently won't be merged.

Platform independent UX and design discussions should be reported in [dp3t-ux-screenflows-ch](https://github.com/DP-3T/dp3t-ux-screenflows-ch)

## Repositories
* Android App: [swisscovid-app-android](https://github.com/SwissCovid/swisscovid-app-android)
* iOS App: [swisscovid-app-ios](https://github.com/SwissCovid/swisscovid-app-ios)
* CovidCode Web-App: [CovidCode-UI](https://github.com/admin-ch/CovidCode-UI)
* CovidCode Backend: [CovidCode-Service](https://github.com/admin-ch/CovidCode-service)
* Config Backend: [swisscovid-config-backend](https://github.com/SwissCovid/swisscovid-config-backend)
* Additional Info Backend: [swisscovid-additionalinfo-backend](https://github.com/SwissCovid/swisscovid-additionalinfo-backend)
* QR Code Landingpage: [swisscovid-qr-landingpage](https://github.com/SwissCovid/swisscovid-qr-landingpage)
* DP3T Android SDK & Calibration app: [dp3t-sdk-android](https://github.com/DP-3T/dp3t-sdk-android)
* DP3T iOS SDK & Calibration app: [dp3t-sdk-ios](https://github.com/DP-3T/dp3t-sdk-ios)
* DP3T Backend SDK: [dp3t-sdk-backend](https://github.com/DP-3T/dp3t-sdk-backend)
* CrowdNotifier Android SDK: [crowdnotifier-sdk-android](https://github.com/CrowdNotifier/crowdnotifier-sdk-android)
* CrowdNotifier iOS SDK: [crowdnotifier-sdk-ios](https://github.com/CrowdNotifier/crowdnotifier-sdk-ios)
* CrowdNotifier Backend: [swisscovid-cn-backend](https://github.com/SwissCovid/swisscovid-cn-backend)


## Installation and Building

The project should be opened with the Xcode 11.7 or newer. Dependencies are managed with [Swift Package Manager](https://swift.org/package-manager), no further setup is needed.

### Provisioning

The project is configured for a specific provisioning profile. To install the app on your own device, you will have to update the settings using your own provisioning profile.

Apple's ExposureNotification Framework requires an entitlement (`com.apple.developer.exposure-notification`) that is only be available to public health authorities. You will find more information in the [Exposure Notification Addendum](https://developer.apple.com/contact/request/download/Exposure_Notification_Addendum.pdf) and you can request the entitlement [here](https://developer.apple.com/contact/request/exposure-notification-entitlement).

## License
This project is licensed under the terms of the MPL 2 license. See the [LICENSE](LICENSE) file.

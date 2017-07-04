## Spreadbot_iOS

Spreadbot client for iOS/OS X

- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [License](#license)

## Requirements

- iOS 9.0+
- Xcode 8.0+
- Swift 3.0+

## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

> CocoaPods 1.1.0+ is required to build Spreadbot_iOS 1.0.0+.

To integrate Spreadbot_iOS into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.1'
use_frameworks!

pod 'Spreadbot_iOS', '~> 1.0.0'
```

Then, run the following command:

```bash
$ pod install
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that automates the process of adding frameworks to your Cocoa application.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate Spreadbot_iOS into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "Spreadbot_iOS/Spreadbot_iOS" ~> 1.0.0
```
### Swift Package Manager

To use Spreadbot_iOS as a [Swift Package Manager](https://swift.org/package-manager/) package just add the following in your Package.swift file.

``` swift
import PackageDescription

let package = Package(
    name: "HelloSpreadbot_iOS",
    dependencies: [
        .Package(url: "https://github.com/Spreadbot/Spreadbot_iOS.git", "1.0.0")
    ]
)
```

### Manually

If you prefer not to use either of the aforementioned dependency managers, you can integrate Spreadbot_iOS into your project manually.

#### Git Submodules

- Open up Terminal, `cd` into your top-level project directory, and run the following command "if" your project is not initialized as a git repository:

```bash
$ git init
```

- Add Spreadbot_iOS as a git [submodule](http://git-scm.com/docs/git-submodule) by running the following command:

```bash
$ git submodule add https://github.com/Spreadbot/Spreadbot_iOS.git
$ git submodule update --init --recursive
```

- Open the new `Spreadbot_iOS` folder, and drag the `Spreadbot_iOS.xcodeproj` into the Project Navigator of your application's Xcode project.

    > It should appear nested underneath your application's blue project icon. Whether it is above or below all the other Xcode groups does not matter.

- Select the `Spreadbot_iOS.xcodeproj` in the Project Navigator and verify the deployment target matches that of your application target.
- Next, select your application project in the Project Navigator (blue project icon) to navigate to the target configuration window and select the application target under the "Targets" heading in the sidebar.
- In the tab bar at the top of that window, open the "General" panel.
- Click on the `+` button under the "Embedded Binaries" section.
- You will see two different `Spreadbot_iOS.xcodeproj` folders each with two different versions of the `Spreadbot_iOS.framework` nested inside a `Products` folder.

    > It does not matter which `Products` folder you choose from.

- Select the `Spreadbot_iOS.framework`.

- And that's it!

> The `Spreadbot_iOS.framework` is automagically added as a target dependency, linked framework and embedded framework in a copy files build phase which is all you need to build on the simulator and a device.

#### Embeded Binaries

- Download the latest release from https://github.com/Spreadbot/Spreadbot_iOS/releases
- Next, select your application project in the Project Navigator (blue project icon) to navigate to the target configuration window and select the application target under the "Targets" heading in the sidebar.
- In the tab bar at the top of that window, open the "General" panel.
- Click on the `+` button under the "Embedded Binaries" section.
- Add the downloaded `Spreadbot_iOS.framework`.
- And that's it!

## Usage



## License

Spreadbot_iOS is released under the MIT license. See [LICENSE](https://github.com/Spreadbot/Spreadbot_iOS/blob/master/LICENSE) for details.

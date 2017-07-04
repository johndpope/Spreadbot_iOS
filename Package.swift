//
//  Spreadbot_iOS
//
//  Created by Bob on 02/07/2017.
//  Copyright © 2017 Spreadbot. All rights reserved.
//

import PackageDescription

let package = Package(
    name: "Spreadbot_iOS",
    targets: [],
    dependencies: [
        .Package(url: "https://github.com/Alamofire/Alamofire.git",
                 majorVersion: 4),
        .Package(url: "https://github.com/ReactiveX/RxSwift.git",
                 majorVersion: 3),
        .Package(url: "https://github.com/RxSwiftCommunity/RxSwiftExt.git",
                 majorVersion: 2),
		.Package(url: "https://github.com/matthewpalmer/Locksmith.git",
                 majorVersion: 2),
		.Package(url: "https://github.com/socketio/socket.io-client-swift.git"
                 majorVersion: 10),
		.Package(url: "https://github.com/ashleymills/Reachability.swift.git",
                 majorVersion: 3),
    ],
    exclude: ["Spreadbot_iOSTests"]
)
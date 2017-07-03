Pod::Spec.new do |s|
 s.name = 'Spreadbot_iOS'
 s.version = "0.0.1"
 s.license = { :type => "MIT", :file => "LICENSE" }
 s.summary = 'Spreadbot client for iOS/OS X'
 s.homepage = 'http://www.spreadbot.io'
 s.social_media_url = 'https://twitter.com/spreadbotHQ'
 s.authors = { "Spreadbot" => "contact@spreadbot.io" }
 s.source = { :git => "https://github.com/Spreadbot/Spreadbot_iOS.git", :tag => "v"+s.version.to_s, submodules: true }
 s.platforms     = { :ios => "9.0", :osx => "10.10" }
 s.requires_arc = true
 s.platform = :ios, "9.1"
 s.source_files = "Spreadbot_iOS/**/*.{h,swift}"

 s.dependency "Alamofire"
 s.dependency "RxSwift"
 s.dependency "RxSwiftExt"
 s.dependency "Locksmith"
 s.dependency "Socket.IO-Client-Swift"
 s.dependency "Reachability"
end

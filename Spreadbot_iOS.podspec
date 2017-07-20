Pod::Spec.new do |s|
 s.name = 'Spreadbot_iOS'
 s.version = "1.0.0"
 s.license = { :type => "MIT", :file => "LICENSE" }
 s.summary = 'Spreadbot client for iOS/OS X'
 s.homepage = 'http://www.spreadbot.io'
 s.social_media_url = 'https://twitter.com/spreadbotHQ'
 s.authors = { "Spreadbot" => "contact@spreadbot.io" }
 s.source = { :git => "https://github.com/Spreadbot/Spreadbot_iOS.git", :tag => "v"+s.version.to_s, submodules: true }
 s.platforms = { :ios => "9.1" }
 s.requires_arc = true
 s.source_files = "Sources/*.{h,swift}"

 s.dependency "Alamofire", '~> 4.5'
 s.dependency "RxSwift", '~> 3.5'
 s.dependency "RxSwiftExt", '~> 2.5'
 s.dependency "Socket.IO-Client-Swift", '~> 10.0'
end
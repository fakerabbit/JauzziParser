#
# Be sure to run `pod lib lint JauzziParser.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
s.name             = 'JauzziParser'
s.version          = '0.3.0'
s.summary          = 'An RSS feed parser written in Swift 3.0.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

s.description      = <<-DESC
An RSS feed parser written in Swift 3.0.
It uses Alamofire for fetching the url and it uses Google's feed api to parse the feed.

Sample usage:

import JauzziParser

JauzziParser.sharedInstance.fetchRss(url: "https://news.google.com/?output=rss") { [weak self] entries in
print(entries)
}


DESC

s.homepage         = 'https://github.com/fakerabbit/JauzziParser'
# s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
s.license          = { :type => 'MIT', :file => 'LICENSE' }
s.author           = { 'Mirko Justiniano' => 'mirkoj@gmail.com' }
s.source           = { :git => 'https://github.com/fakerabbit/JauzziParser.git', :tag => s.version.to_s }
# s.social_media_url = 'https://twitter.com/mirkoj'

s.ios.deployment_target = '9.0'

s.source_files = 'JauzziParser/**/*.{swift}'

# s.resource_bundles = {
#   'JauzziParser' => ['JauzziParser/Assets/*.png']
# }

# s.public_header_files = 'Pod/Classes/**/*.h'
# s.frameworks = 'UIKit', 'MapKit'
s.dependency 'Alamofire', '~> 4.0'
end

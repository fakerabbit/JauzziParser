# JauzziParser

An RSS Feed Parser written in Swift.

[![cocoapods compatible](https://img.shields.io/badge/cocoapods-compatible-brightgreen.svg)](https://cocoapods.org/pods/JauzziParser)
[![cocoapods compatible](https://img.shields.io/badge/pod-v0.4.0-green.svg)](https://cocoapods.org/pods/JauzziParser)
[![language](https://img.shields.io/badge/swift-v3.0-orange.svg)](https://swift.org)

## Requirements

![ios](https://img.shields.io/badge/iOS-9.0-red.svg)
![xcode](https://img.shields.io/badge/XCode-8.1-blue.svg)

## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Swift and Objective-C Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate `JauzziParser` into your Xcode project, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
use_frameworks!

target 'MyApp' do
  pod 'JauzziParser'
end
```

Then, run the following command:

```bash
$ pod install
```

## Usage
    
```swift
import JauzziParser

JauzziParser.sharedInstance.fetchRss(url: "https://news.google.com/?output=rss") { [weak self] entries in
                print(entries)
            }
```

### Entry Model

```swift

for entry:JEntry in entries {
  print(entry.link) // The entry url as a string
  print(entry.title) // The entry title as a string
  print(entry.contentSnippet) // The entry summary/snippet as a string
  print(entry.pubDate) // The entry published date as a string
  print(entry.publishedDate) // Then entry published date as a Date
  print(entry.htmlContent) // Then entry's html content as a string
  print(entry.author) // The entry's author as a string
  print(entry.categories) // The entry's categories tag as an array of strings [String]
  print(entry.mediaGroups) // The entry's images and media as a [[String : AnyObject]]
  print(entry.images) // The entry's images as an array of url strings [String]
  
  // Get entry hero image:
  print(entry.images[0]?)
  
  // How to access entry's mediaGroups:
  for var content:[String : AnyObject] in entry.mediaGroups {
                    if let contents:[[String : AnyObject]] = content["contents"] as! [[String : AnyObject]] {
                        print(contents)
                        for var c:[String : AnyObject] in contents {
                            if let media:String = c["medium"] as? String {
                                if media == "image" {
                                    if let url:String = c["url"] as? String {
                                        print(c)
                                    }
                                }
                            }
                        }
                    }
                }
}
```   
## License

JauzziParser is released under the MIT license. See [LICENSE](https://github.com/fakerabbit/JauzziParser/blob/master/LICENSE) for details.



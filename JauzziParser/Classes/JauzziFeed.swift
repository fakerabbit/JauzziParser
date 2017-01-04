//
//  JauzziParser.swift
//
//  Copyright © 2017 Mirko Justiniano.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Foundation
import Alamofire

// MARK:- Entry

/// JEntry: Model entry used by JauzziParser
public struct JEntry {
    /// author: entry's author
    public var author: String?
    /// categories: entry's tags as an array of strings
    public var categories: [String]?
    /// htmlContent: entry's content html as a string
    public var htmlContent: String?
    /// link: entry's url link
    public var link: String?
    /// mediaGroups: entry's media groups as a JSON array
    public var mediaGroups: [[String : AnyObject]]?
    /// publishedDate: entry's published date as a Date object
    public var publishedDate: Date?
    /// title: entry's title
    public var title: String?
    /// contentSnippet: entry's content snippet as a string
    public var contentSnippet: String?
    /// isFav: boolean used to check if entry is a favorite. Default is false.
    public var isFav: Bool?
    /// pubDate: entry's published date as a string.
    public var pubDate: String?
    /// images: an array of image urls found in the entry
    public var images: [String]?
}

// MARK:- Parser

/// JauzziParser: the RSS Feed parser
/// ```swift
///    JauzziParser.sharedInstance.fetchRss(url: "http://www.theverge.com/rss/index.xml") { [weak self] entries in
///    print(entries)
///    }
public class JauzziParser {
    
    /// sharedInstance: the JauzziParser singleton
    public static let sharedInstance = JauzziParser()
    
    let GOOGLE_FEED_API_URL = "https://ajax.googleapis.com/ajax/services/feed/load?v=1.0&num=-1&q="
    
    /// JauzziParserCallback: the callback used by fetchRss.
    /// - Returns: an array of JEntry objects
    public typealias JauzziParserCallback = ([JEntry]) -> Void
    
    /// fetchRss(url: String, callback: JauzziParserCallback): Parses a feed url and returns an array of entries
    /// - Parameter url: string url of the RSS Feed
    /// - Returns: an array of JEntry objects
    public func fetchRss(url: String, callback: @escaping JauzziParserCallback) {
        
        let reqUrl = GOOGLE_FEED_API_URL + url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlPathAllowed)!
        
        Alamofire.request(reqUrl).responseJSON { response in
            //print(response.request)  // original URL request
            //print(response.response) // HTTP URL response
            //print(response.data)     // server data
            //print(response.result)   // result of response serialization
            
            if let JSON = response.result.value {
                //print("JSON: \(JSON)")
                if let responseData = (JSON as! NSDictionary).object(forKey: "responseData") {
                    if let feed = (responseData as! NSDictionary).object(forKey: "feed") {
                        if let entries: [NSDictionary] = (feed as! NSDictionary).object(forKey: "entries") as! [NSDictionary]? {
                            //print(entries[0])
                            var jEntries:[JEntry] = []
                            for var entry in entries {
                                var author:String = ""
                                if entry.object(forKey: "author") != nil {
                                    author = entry.object(forKey: "author") as! String
                                }
                                var categories:[String]?
                                if entry.object(forKey: "categories") != nil {
                                    categories = entry.object(forKey: "categories") as! [String]
                                }
                                var content:String?
                                if entry.object(forKey: "content") != nil {
                                    content = entry.object(forKey: "content") as! String
                                }
                                var link:String = ""
                                if entry.object(forKey: "link") != nil {
                                    link = entry.object(forKey: "link") as! String
                                }
                                var mediaGroups:[[String : AnyObject]]?
                                var images:[String] = []
                                if entry.object(forKey: "mediaGroups") != nil {
                                    if let mg:[[String : AnyObject]] = entry.object(forKey: "mediaGroups") as! [[String : AnyObject]] {
                                        mediaGroups = mg
                                        for var content:[String : AnyObject] in mediaGroups! {
                                            if let contents:[[String : AnyObject]] = content["contents"] as! [[String : AnyObject]] {
                                                for var c:[String : AnyObject] in contents {
                                                    if let media:String = c["medium"] as? String {
                                                        if media == "image" {
                                                            if let url:String = c["url"] as? String {
                                                                images.append(url)
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                let stringDate:String = entry.object(forKey: "publishedDate") as! String
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "E, d MMM yyyy HH:mm:ss Z"
                                let pubDate:Date? = dateFormatter.date(from: stringDate)
                                let title:String = entry.object(forKey: "title") as! String
                                var contentSnippet: String?
                                if entry.object(forKey: "contentSnippet") != nil {
                                    contentSnippet = entry.object(forKey: "contentSnippet") as! String
                                }
                                let jEntry = JEntry(author: author, categories: categories, htmlContent: content, link: link, mediaGroups: mediaGroups, publishedDate: pubDate, title: title, contentSnippet: contentSnippet, isFav: false, pubDate: stringDate, images: images)
                                //print(jEntry)
                                jEntries.append(jEntry)
                            }
                            callback(jEntries)
                        }
                    }
                }
            }
            else {
                callback([])
            }
        }
    }
}


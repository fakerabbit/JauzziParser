//
//  JauzziFeed.swift
//  SenalesDelFin
//
//  Created by Mirko Justiniano on 1/3/17.
//  Copyright © 2017 SF. All rights reserved.
//

import Foundation
import Alamofire

// MARK:- Feed

struct JEntry {
    var author: String
    var categories: [String]
    var htmlContent: String
    var link: String
    var mediaGroups: [[String : AnyObject]]
    var publishedDate: Date?
    var title: String
    var contentSnippet: String
    var isFav: Bool
    var pubDate: String
}

public class JauzziFeed {
    
    static let shared = JauzziFeed()
    
    let GOOGLE_FEED_API_URL = "https://ajax.googleapis.com/ajax/services/feed/load?v=1.0&num=-1&q="
    
    typealias JauzziParserCallback = ([JEntry]) -> Void
    
    func fetchRss(url: String, callback: @escaping JauzziParserCallback) {
        
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
                                let author:String = entry.object(forKey: "author") as! String
                                let categories:[String] = entry.object(forKey: "categories") as! [String]
                                let content:String = entry.object(forKey: "content") as! String
                                let link:String = entry.object(forKey: "link") as! String
                                let mediaGroups:[[String : AnyObject]] = entry.object(forKey: "mediaGroups") as! [[String : AnyObject]]
                                let stringDate:String = entry.object(forKey: "publishedDate") as! String
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "E, d MMM yyyy HH:mm:ss Z"
                                let pubDate:Date? = dateFormatter.date(from: stringDate)
                                let title:String = entry.object(forKey: "title") as! String
                                let contentSnippet: String = entry.object(forKey: "contentSnippet") as! String
                                let jEntry = JEntry(author: author, categories: categories, htmlContent: content, link: link, mediaGroups: mediaGroups, publishedDate: pubDate, title: title, contentSnippet: contentSnippet, isFav: false, pubDate: stringDate)
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


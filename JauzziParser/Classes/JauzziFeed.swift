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
    /// title: entry's title
    public var title: String?
    /// description: entry's description
    public var description: String?
    /// link: entry's url link
    public var link: String?
    /// categories: entry's tags as an array of array of strings
    public var categories: [String]?
    /// pubDate: entry's published date as a string.
    public var pubDate: String?
    /// publishedDate: entry's published date as a Date object
    public var publishedDate: Date?
    /// mediaContent: entry's hero image url
    public var mediaContent: String?
    /// isFav: boolean used to check if entry is a favorite. Default is false.
    public var isFav: Bool?
}

// MARK:- Alamofire extension
extension Alamofire.DataRequest {
    static func xmlResponseSerializer() -> DataResponseSerializer<XMLDocument> {
        return DataResponseSerializer { request, response, data, error in
            // Pass through any underlying URLSession error to the .network case.
            guard error == nil else { return .failure(BackendError.network(error: error!)) }
            
            // Use Alamofire's existing data serializer to extract the data, passing the error as nil, as it has
            // already been handled.
            let result = Request.serializeResponseData(response: response, data: data, error: nil)
            
            guard case let .success(validData) = result else {
                return .failure(BackendError.dataSerialization(error: result.error! as! AFError))
            }
            
            do {
                let xml = try XMLDocument(data: validData)
                return .success(xml)
            } catch {
                return .failure(BackendError.xmlSerialization(error: error))
            }
        }
    }
    
    @discardableResult
    func responseXMLDocument(
        queue: DispatchQueue? = nil,
        completionHandler: @escaping (DataResponse<XMLDocument>) -> Void)
        -> Self
    {
        return response(
            queue: queue,
            responseSerializer: DataRequest.xmlResponseSerializer(),
            completionHandler: completionHandler
        )
    }
}

enum BackendError: Error {
    case network(error: Error) // Capture any underlying Error from the URLSession API
    case dataSerialization(error: Error)
    case jsonSerialization(error: Error)
    case xmlSerialization(error: Error)
    case objectSerialization(reason: String)
}

// MARK:- Parser

/// JauzziParser: the RSS Feed parser
/// ```swift
///    JauzziParser.sharedInstance.fetchRss(url: "http://www.senalesdelfin.com/rss/") { [weak self] entries in
///    print(entries)
///    }
public class JauzziParser {
    
    /// sharedInstance: the JauzziParser singleton
    public static let sharedInstance = JauzziParser()
    
    /// JauzziParserCallback: the callback used by fetchRss.
    /// - Returns: an array of JEntry objects
    public typealias JauzziParserCallback = ([JEntry]) -> Void
    
    /// fetchRss(url: String, callback: JauzziParserCallback): Parses a feed url and returns an array of entries
    /// - Parameter url: string url of the RSS Feed
    /// - Returns: an array of JEntry objects
    public func fetchRss(url: String, callback: @escaping JauzziParserCallback) {
        
        Alamofire.request(url).responseXMLDocument { (response: DataResponse<XMLDocument>) in
            //debugPrint(response)
            
            // Parse xml document:
            var titles:[XMLElement] = []
            var descriptions:[XMLElement] = []
            var links:[XMLElement] = []
            var categories:[[XMLElement]] = []
            var pubDates:[XMLElement] = []
            var mediaContents:[XMLElement] = []
            
            if response.result != nil && response.result.value != nil {
                if let document = response.result.value! as? XMLDocument {
                    //debugPrint(document.root?.childNodes(ofTypes: [.Element, .Text, .Comment]) ?? "nada")
                    if let root = document.root {
                        for element in root.children {
                            //debugPrint(element)
                            for node in element.children {
                                //debugPrint(node)
                                titles.append(contentsOf: node.children(tag: "title"))
                                descriptions.append(contentsOf: node.children(tag: "description"))
                                links.append(contentsOf: node.children(tag: "link"))
                                let category:[XMLElement] = node.children(tag: "category")
                                if category.count > 0 {
                                    categories.append(category)
                                }
                                pubDates.append(contentsOf: node.children(tag: "pubDate"))
                                mediaContents.append(contentsOf: node.children(tag: "media:content"))
                                if let media:XMLElement = node.firstChild(xpath: "media:content") {
                                    mediaContents.append(media)
                                }
                            }
                        }
                    }
                }
            }
            
            // Create entries
            var entries:[JEntry] = []
            var wordpressRss:Bool = false
            
            for i in 0 ..< links.count {
                
                var title:String = ""
                if titles.count > i {
                    let t:XMLElement? = titles[i]
                    title = (t?.stringValue)!
                    
                    if title == "Estudia La Biblia" {
                        wordpressRss = true
                    }
                }
                
                if title != "Estudia La Biblia" {
                    var description:String = ""
                    if descriptions.count > i {
                        let d:XMLElement? = descriptions[i]
                        description = (d?.stringValue)!
                    }
                    
                    var link:String = ""
                    if links.count > i {
                        let l:XMLElement? = links[i]
                        link = (l?.stringValue)!
                    }
                    
                    var catStrings:[String] = []
                    if categories.count > i {
                        let cats:[XMLElement]? = categories[i]
                        for var catElement:XMLElement in cats! {
                            catStrings.append(catElement.stringValue)
                        }
                    }
                    
                    var pubDate:String = ""
                    var publishedDate:Date?
                    if pubDates.count > i {
                        let p:XMLElement? = pubDates[i]
                        pubDate = (p?.stringValue)!
                        let dateFormatter = DateFormatter()
                        dateFormatter.timeZone = NSTimeZone.local
                        dateFormatter.locale = NSLocale.current
                        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss ZZZ"
                        dateFormatter.formatterBehavior = DateFormatter.defaultFormatterBehavior
                        publishedDate = dateFormatter.date(from: pubDate)
                    }
                    
                    var mediaContent:String = ""
                    if wordpressRss {
                        if mediaContents.count > i-1 {
                            let m:XMLElement? = mediaContents[i-1]
                            mediaContent = (m?.attr("url"))!
                        }
                    }
                    else {
                        if mediaContents.count > i-1 {
                            let m:XMLElement? = mediaContents[i-1 >= 0 ? i-1 : i]
                            mediaContent = (m?.attr("url"))!
                        }
                    }
                    
                    let entry = JEntry(title: title, description: description, link: link, categories: catStrings, pubDate: pubDate, publishedDate: publishedDate, mediaContent: mediaContent, isFav: false)
                    entries.append(entry)
                    //debugPrint(entry)
                    //debugPrint("********************************")
                }
            }
            
            callback(entries)
        }
    }
}


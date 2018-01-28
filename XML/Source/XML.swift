//
//  XML.swift
//  XML
//
//  Created by Carlos Rodríguez Domínguez on 26/1/18.
//  Copyright © 2018 Everyware. All rights reserved.
//

import Foundation

class XML: CustomStringConvertible {
    fileprivate(set) var entityName: String = ""
    fileprivate(set) var attributes: [String: String] = [:]
    fileprivate(set) var children: [XML] = []
    fileprivate(set) var content: String? = nil
    fileprivate(set) var parent: XML? = nil
    
    private var parserDelegate: ParserDelegate? = nil
    
    init?(path: URL) {
        guard let parser = XMLParser(contentsOf: path) else {
            return nil
        }
        
        self.parserDelegate = ParserDelegate(xml: self)
        parser.delegate = parserDelegate!
        if !parser.parse() {
            return nil
        }
        else {
            self.parserDelegate = nil
        }
    }
    
    init?(contents: String) {
        let parser = XMLParser(data: contents.data(using: .utf8)!)
        
        self.parserDelegate = ParserDelegate(xml: self)
        parser.delegate = parserDelegate!
        if !parser.parse() {
            return nil
        }
        else {
            self.parserDelegate = nil
        }
    }
    
    init(entityName: String, attributes: [String: String] = [:], children: [XML] = []) {
        self.entityName = entityName
        self.attributes = attributes
        self.children = children
    }
    
    subscript(position: Int) -> XML {
        return children[position]
    }
    
    subscript(_ entityName: String) -> XML? {
        for child in children {
            if child.entityName == entityName {
                return child
            }
        }
        
        return nil
    }
    
    var description: String {
        var result = "<\(entityName)"
        
        for (key, value) in attributes {
            result += " \(key)=\"\(value)\""
        }
        
        result += ">\(content ?? "")"
        
        for child in children {
            result += child.description+"\n"
        }
        
        result += "</\(entityName)>"
        
        return result
    }
}

fileprivate class ParserDelegate : NSObject, XMLParserDelegate {
    private var xml: XML
    private var currentXML: XML? = nil
    
    init(xml: XML) {
        self.xml = xml
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if self.currentXML == nil {
            xml.entityName = elementName
            xml.attributes = attributeDict
            
            self.currentXML = xml
        }
        else {
            let newXML = XML(entityName: elementName, attributes: attributeDict)
            newXML.parent = self.currentXML
            
            self.currentXML?.children.append(newXML)
            self.currentXML = newXML
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if self.currentXML?.parent != nil {
            self.currentXML = self.currentXML?.parent
        }
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print(parseError.localizedDescription)
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        self.currentXML?.content = string
    }
}

//
//  RecTimer.swift
//  Qoperation
//
//  Created by Michael Chirico on 12/15/18.
//  Copyright © 2018 Michael Chirico. All rights reserved.
//

import Foundation
extension String {
  func mins() -> [Int?] {
    if let regex = try? NSRegularExpression(pattern: "[a-z0-9]+ mins",
                                            options: .caseInsensitive) {
      let string = self as NSString
      
      return regex.matches(in: self, options: [], range: NSRange(location: 0, length: string.length)).map {
        Int(string.substring(with: $0.range).replacingOccurrences(of: " mins", with: ""))
      }
    }
    
    return []
  }
}

class RecTimer {
  var date: Date?
  
  var timeInitial=0
  var miliSeconds=0
  var seconds=0
  var minutes=0
  var hours=0
  
  var delay=0
  func delay(string: String?) {
    
    if let string = string {
      
      if string.mins().count == 0 {
        self.delay = 0
        return
      }
      
      if let delay = string.mins()[0] {
        self.delay = delay
      } else {
        delay = 0
      }
    } else {
      delay = 0
    }
    
  }
  
  func stringTime(string: String) {
    
    let date = Date()
    let dateFormatter = DateFormatter()
    
    dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ssa" // Output Format
    dateFormatter.dateFormat = "yyyy-MM-dd" // Output Format
    dateFormatter.timeZone = TimeZone.current
    let ds = dateFormatter.string(from: date)
    
    let dateString = "\(ds) \(string)"
    dateFormatter.dateFormat = "yyyy-MM-dd h:mma" //Input Format
    dateFormatter.timeZone = TimeZone.current
    let enterDate = dateFormatter.date(from: dateString)
    
    timeInitial = NSInteger((enterDate?.timeIntervalSinceNow)!)
    miliSeconds = timeInitial * 1000
    seconds = timeInitial % 60
    minutes = (timeInitial / 60) % 60 + delay
    hours = (timeInitial / 3600)
    
  }
  
}

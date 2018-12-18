//
//  Sparse.swift
//  Qoperation
//
//  Created by Michael Chirico on 12/15/18.
//  Copyright © 2018 Michael Chirico. All rights reserved.
//

import Foundation

class Sparse {
  
  var date: Date?
  var stringDate: String?
  var orig: String = ""
  
  var offset: Int?
  
  var json: String = "{}"
  
  func secondsFromGMT() -> Int {
    return Int(TimeZone.current.secondsFromGMT())
  }
  
  func process(stringInput: String) {
    getTime(stringInput: stringInput)
    makeValidJSON(stringInput: stringInput)
  }
  
  func getTime(stringInput: String) {
    
    orig = String(stringInput)
    
    var startOfpt = stringInput.firstIndex(of: ":")!
    var endOfpt = stringInput.firstIndex(of: "[")!
    
    let sampleString = stringInput[startOfpt...endOfpt]
    
    startOfpt = sampleString.firstIndex(of: " ")!
    endOfpt = sampleString.firstIndex(of: "\"")!
    
    startOfpt = sampleString.index(startOfpt, offsetBy: 1)
    endOfpt = sampleString.index(endOfpt, offsetBy: -1)
    
    let time = sampleString[startOfpt...endOfpt]
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMMM d, yyyy, m:mm a"
    //dateFormatter.timeZone =  TimeZone(identifier: "EDT")
    
    date = dateFormatter.date(from: String(time))
    offset = Int(date?.timeIntervalSinceNow ?? 0)
    
    date = date?.addingTimeInterval(TimeInterval(secondsFromGMT()))
    stringDate =  String(time)

  }
  
  func makeValidJSON(stringInput: String) {
    json = String(stringInput)
    let startOfpt = json.firstIndex(of: "\"")!
    let endOfpt = json.firstIndex(of: "[")!
    json.replaceSubrange(startOfpt..<endOfpt, with: "\"Depart\":")
    
  }
  
}

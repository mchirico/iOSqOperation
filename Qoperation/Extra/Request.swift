//
//  Requests.swift
//  Qoperation
//
//  Created by Michael Chirico on 12/15/18.
//  Copyright © 2018 Michael Chirico. All rights reserved.
//

import Foundation

protocol ActionProtocol {
  var currentResult: String {get set}
  var previousResult: String {get set}
  var data: Data? {get set}
  var response: URLResponse? {get set}
  var error: Error? {get set}
  func actionAfterResult()
}

protocol ResultProtocol {
  func doneAction()
}

class Request {
  
  var contents = ""
  var action: ActionProtocol?
  
  func assignAction(action: ActionProtocol) {
    self.action = action
  }
  
  func post(url: String, _ locationFile: String, data: Data) {
    
    let TOKEN="abc"
    let size=data.count
    
    let request = NSMutableURLRequest(url: URL(string: url)!)
    
    request.httpMethod = "POST"
    request.setValue("Bearer \(TOKEN)", forHTTPHeaderField: "Authorization")
    request.setValue("{\"path\": \"\(locationFile)\",\"mode\": \"overwrite\",\"autorename\": true,\"mute\": false}", forHTTPHeaderField: "Dropbox-API-Arg")
    
    request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
    request.setValue("\(size)", forHTTPHeaderField: "Content-Length")
    request.setValue("100-continue", forHTTPHeaderField: "Expect")
    request.httpBody = data
    
    let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
      
      if error != nil {
        let defaultMessage = "error: URLSession.shared.dataTask"
        print("error=\(error ?? defaultMessage as! Error)")
        return
      }
      
      print("response = \(String(describing: response))")
      
      let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
      print("responseString = \(String(describing: responseString))")
    })
    task.resume()
    
  }
  
  func getURLAction(url: String, timeoutInterval: Double = 8.3) {
    
    if self.action == nil { return }
    
    let request = NSMutableURLRequest(url: URL(string: url)!)
    request.httpMethod = "GET"
    request.timeoutInterval = timeoutInterval
    
    let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
      
      self.action?.data = data
      self.action?.response = response
      self.action?.error  = error
      
      if error == nil {
        self.action?.currentResult = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)! as String
      }
      self.action?.actionAfterResult()
      
    })
    task.resume()
    
  }
  
  func getURL(url: String) {
    
    // Maybe
    // https://developer.apple.com/documentation/foundation/url_loading_system/fetching_website_data_into_memory
    // Also
    // https://www.raywenderlich.com/567-urlsession-tutorial-getting-started
    
    if let url = URL(string: url) {
      
      do {
        contents = try String(contentsOf: url)
      } catch {
        print("Contents could not be loaded")
      }
    } else {
      print("The URL was bad")
    }
  }
  
}

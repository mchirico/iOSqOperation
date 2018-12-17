/*
 https://www3.septa.org/hackathon/NextToArrive/?req1=Suburban%20Station&req2=Elkins%20Park&req3=40
 */

import Foundation

protocol SeptaJSON {
  func getURL(url: String)
  func parseString(data: String)
}

// Clean this up ... idea
protocol ActionResultProtocol {
  var callActionRstatus: Bool { get set }
  
  func callActionR(input: String, completion:
    @escaping (_ result: String) -> Bool )
}

class Travel {
  let sts = [StationToStation(), StationToStation()]
  let recTimer = [RecTimer(), RecTimer()]
  
  init() {
    refresh()
  }
  
  func refresh() {
    var url = "https://www3.septa.org/hackathon/NextToArrive/?req1=Elkins%20Park&req2=Suburban%20Station&req3=14"
    
    sts[0].getURL(url: url)
    sts[0].parseString(data: sts[0].urlResults)
    
    recTimer[0].stringTime(string: (sts[0].records?.sts[0].orig_departure_time)!)
    
    url = "https://www3.septa.org/hackathon/NextToArrive/?req1=Suburban%20Station&req2=Elkins%20Park&req3=14"
    
    sts[1].getURL(url: url)
    sts[1].parseString(data: sts[1].urlResults)
    
    recTimer[1].stringTime(string: (sts[1].records?.sts[0].orig_departure_time)!)
  }
  
  func getMinutes() -> [Int] {
    
    var min0 = 3600
    var min1 = 3600
    
    if recTimer[0].hours == 0 {
      
      recTimer[0].delay(string: (sts[0].records?.sts[0].orig_delay))
      min0 = recTimer[0].minutes
    }
    
    if recTimer[1].hours == 0 {
      recTimer[1].delay(string: (sts[1].records?.sts[0].orig_delay))
      min1 = recTimer[1].minutes
    }
    
    return [min0, min1]
    
  }
  
  func count(index: Int) -> Int {
    if let count = sts[index].records?.sts.count {
      return count
    }
    return 0
    
  }
  
  func msg(index: Int, row: Int) -> String {
    if let depart = sts[index].records?.sts[row].orig_departure_time,
      let train = sts[index].records?.sts[row].orig_train,
      let delay = sts[index].records?.sts[row].orig_delay {
      
      let txt = "\(train):  \(depart)  \(delay)"
      
      return txt
    }
    return "No data"
  }
  
}

/*
 let url = """
 https://www3.septa.org/hackathon/NextToArrive/?req1=Suburban%20Station&req2=Elkins%20Park&req3=40
 """
 */

class StationAction: ActionProtocol, ActionResultProtocol {

  var callActionRstatus = false
  
  var callAfterDone: (() -> Bool)?
  var callAfterDoneResult = false
  var sts: StationToStation?
  var count = 0
  var currentResult: String = "" {
    willSet {
      previousResult = currentResult
      count += 1
    }
  }
  var previousResult: String = ""
  var data: Data?
  var response: URLResponse?
  var error: Error?
  
  func callActionR(input: String, completion: @escaping (String) -> Bool) {
    if let sts = sts {
      sts.urlResults = currentResult
      sts.cleanUpUrlResults()
      sts.parseString(data: sts.urlResults)
      
      if let callAfterDone = callAfterDone {
        callAfterDoneResult = callAfterDone()
      }
      
      callActionRstatus = completion(sts.urlResults)
      
    }
  }
  
  func actionAfterResult() {
    if let sts = sts {
      sts.urlResults = currentResult
      sts.cleanUpUrlResults()
      sts.parseString(data: sts.urlResults)
      
      if let callAfterDone = callAfterDone {
        callAfterDoneResult = callAfterDone()
      }
    }
  }
}

class StationToStation: SeptaJSON {
  var stationAction: StationAction?
  
  struct S2S: Decodable {
    let sts: [Trains]
  }
  
  struct Trains: Decodable {
    let orig_train: String
    let orig_line: String
    let orig_departure_time: String
    let orig_arrival_time: String
    let orig_delay: String
    let isdirect: String
  }
  
  var urlResults: String = ""
  var records: S2S?
  
  func assignStationAction(stationAction: StationAction) {
    self.stationAction = stationAction
    self.stationAction!.sts = self
  }
  
  func updateResults(input: String) {
    
    self.urlResults = input
    
    let startOfpt = urlResults.startIndex
    
    if let endOfpt = urlResults.firstIndex(of: "[") {
      
      urlResults.replaceSubrange(startOfpt..<endOfpt, with: "{\"sts\":")
      urlResults += "}"
      
    }
  }
  
  func cleanUpUrlResults() {
    let startOfpt = urlResults.startIndex
    
    if let endOfpt = urlResults.firstIndex(of: "[") {
      urlResults.replaceSubrange(startOfpt..<endOfpt, with: "{\"sts\":")
      urlResults += "}"
    }
  }
  
  func getURL(url: String) {
    let r = Request()
    r.getURL(url: url)
    
    urlResults = String(r.contents)
    
    let startOfpt = urlResults.startIndex
    
    if let endOfpt = urlResults.firstIndex(of: "[") {
      urlResults.replaceSubrange(startOfpt..<endOfpt, with: "{\"sts\":")
      urlResults += "}"
    }
  }
  
  func parseString(data: String) {
    
    do {
      self.records = try JSONDecoder().decode(S2S.self, from: data.data(using: .utf8)!)
      
    } catch {
      print("Error:", error.localizedDescription)
    }
    
  }
  
}

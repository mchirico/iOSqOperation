//
//  Oper.swift
//  Qoperation
//
//  Created by Michael Chirico on 12/14/18.
//  Copyright © 2018 Michael Chirico. All rights reserved.
//

import Foundation

protocol SomeProtocol {
  var resultStore: String {get set}
  func result()
}

class Runner {
  let queue = OperationQueue()
  func run(operation: Operation) {
    queue.addOperation(operation)
  }
}

class Some: SomeProtocol {
  var resultStore: String = ""
  
  func result() {
    for index in 1...100_000 {
      print(index)
      usleep(useconds_t(2000))
    }
  }
}

class Oper: Operation {
  
  var someProto: SomeProtocol?
  override func main() {
    if let someProto = someProto {
      someProto.result()
    }
    
  }
}

//
//  ViewController.swift
//  Qoperation
//
//  Created by Michael Chirico on 12/14/18.
//  Copyright © 2018 Michael Chirico. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }
  
  func test() {
    let some = Some()
    let runner = Runner()
    
    let oper = Oper()
    oper.someProto = some
    runner.run(operation: oper)
  }
  
}

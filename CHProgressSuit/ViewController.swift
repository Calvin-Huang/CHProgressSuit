//
//  ViewController.swift
//  CHProgressSuit
//
//  Created by Calvin on 6/26/16.
//  Copyright © 2016 CapsLock. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var circularProgress: CircularProgress!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Reset proress to zero
        circularProgress.progress = 0
    }
    
    //MARK: - IBActions
    @IBAction func resetButtonClicked(_: AnyObject) {
        circularProgress.progress = 0
    }
    
    @IBAction func add2ButtonClicked(_: AnyObject) {
        circularProgress.progress += 0.02
    }
    
    @IBAction func add10ButtonClicked(_: AnyObject) {
        circularProgress.progress += 0.1
    }
    
    @IBAction func reduce2ButtonClicked(_: AnyObject) {
        circularProgress.progress -= 0.02
    }
    
    @IBAction func reduce10ButtonClicked(_: AnyObject) {
        circularProgress.progress -= 0.1
    }
}


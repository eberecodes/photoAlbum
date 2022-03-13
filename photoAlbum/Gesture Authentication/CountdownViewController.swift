//
//  CountdownViewController.swift
//  testVision
//
//  Created by Ebere Anukem on 28/01/2022.
//

import UIKit

class CountdownViewController: UIViewController {

    @IBOutlet weak var countdownLabel: UILabel!
    
    var password: String? = nil //for testing with segue
    
    var currSeconds = 5
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Countdown start from 5
        //currSeconds = 5
        
        //startCountdown()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        startCountdown()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Countdown start from 5
        currSeconds = 5
        
        //startCountdown()
    }
    
  
    func startCountdown(){
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(CountdownViewController.updateCountdown)), userInfo: nil, repeats: true)
    }
    
    @objc func updateCountdown(){
        currSeconds = currSeconds-1
        countdownLabel.text = "\(currSeconds)"
        
        if (currSeconds==0){
            timer.invalidate() //stop the timer
            self.performSegue(withIdentifier: "toPasswordPerform", sender: nil)
            
        }
    }
   
    //This is for testing purposes, the password would really be stored securely
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "toPasswordPerform"){
            let settingsDetail = segue.destination as? CameraViewController
            settingsDetail!.password = password
            
        }
    }

}

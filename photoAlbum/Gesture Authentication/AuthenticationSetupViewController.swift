//
//  AuthenticationSetupViewController.swift
//  testVision
//

import UIKit

//TODO: You can't use the same gesture in a row
class AuthenticationSetupViewController: UIViewController {
 
    //Variables storing the password that was entered
    private var passwordEntered:String!
    private var passwordEntered2:String!
    private var enteredCount:Int!
    
    //Keeps track of individual gesture that has been selected
    //private var entered: String = ""
    
    @IBOutlet weak var setupDescription: UITextView!
    
    @IBOutlet weak var requirementsTextview: UITextView!
    
    
    
    @IBAction func thumbButton(_ sender: Any) {
       passwordEntered = passwordEntered+"👍"
    }
    
    
    @IBAction func hornsButton(_ sender: Any) {
        passwordEntered = passwordEntered+"🤘"
    }
    
    
    @IBAction func fistButton(_ sender: Any) {
        passwordEntered = passwordEntered+"✊"
    }
    
    
    @IBAction func peaceButton(_ sender: Any) {
        passwordEntered = passwordEntered+"✌️"
    }
    
    @IBAction func openButton(_ sender: Any) {
        passwordEntered = passwordEntered+"✋"
    }
    
    
    @IBAction func okayButton(_ sender: Any) {
        passwordEntered = passwordEntered+"👌"
    }
    
    
    @IBAction func loveButton(_ sender: Any) {
        passwordEntered = passwordEntered+"🤟"
    }
    
    
    @IBAction func crossedButton(_ sender: Any) {
        passwordEntered = passwordEntered+"🤞"
    }
    
    
    @IBAction func callButton(_ sender: Any) {
        passwordEntered = passwordEntered+"🤙"
    }
    
    
    
    @IBAction func confirmButton(_ sender: Any) {
        print(passwordEntered!)
        enteredCount+=1
        
        if (enteredCount == 1) && (passwordEntered != "") && (passwordEntered.count >= 3){
            //New alert created to prompted re-entry of password
            let confirmAlert = UIAlertController(title: "Confirm Gesture Password", message: "Re-enter gesture selection", preferredStyle: .alert)
            
            confirmAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
                print("Alert closed")
            }))
            
            self.present(confirmAlert, animated: true, completion: nil)
            
            //Store the password first entered in passwordEntered 2 variable
            passwordEntered2 = passwordEntered
            
            //Reset passwordEntered variable
            passwordEntered = ""
        }
        else if (passwordEntered.count < 3){ //OR consecutive chars
            let lengthAlert = UIAlertController(title: "Weak Gesture Password", message: "Gesture password does not meet requirements, make a new gesture selection.", preferredStyle: .alert)
            lengthAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
                print("Alert closed")
            }))
            self.present(lengthAlert, animated: true, completion: nil)
            //Reset password entered variable
            passwordEntered = ""
            
            //Reset enteredCount variable
            enteredCount = 0
        }
        else if (passwordEntered == ""){
            //Alert created for when no password has been entered.
            let passwordAlert = UIAlertController(title: "No Password Entered", message: "You must make a gesture selection", preferredStyle: .alert)
            
            passwordAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
                print("Alert closed")
            }))
            
            self.present(passwordAlert, animated: true, completion: nil)
            
            
            //Reset enteredCount variable
            enteredCount = 0
        }
        else {
            //Perform segue to next screen
            if (passwordEntered == passwordEntered2){
                
                //Save gesture password securely
                let gesturesSaved:Bool = KeychainWrapper.standard.set(passwordEntered, forKey: "gesturePassword")
                
                if(gesturesSaved){
                    print("Password has been succesfully saved")
                }
                else{
                    print("Issue saving password")
                }
                
                self.performSegue(withIdentifier: "toCountdown", sender: nil)
            }
            
            else{
                //Create an alert that makes users restart the password selection process
                let incorrectAlert = UIAlertController(title: "Incorrect Password", message: "The gesture password you entered does not match. Try gesture selection again...", preferredStyle: .alert)
                
                incorrectAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
                    print("Alert closed")
                }))
                
                self.present(incorrectAlert, animated: true, completion: nil)
                
                //Reset the variables
                passwordEntered = ""
                passwordEntered2 = ""
                enteredCount = 0
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Authentication Setup"
        
        passwordEntered = ""
        passwordEntered2 = ""
        enteredCount = 0
    }
 
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        passwordEntered = ""
        passwordEntered2 = ""
        enteredCount = 0
    }
        


}

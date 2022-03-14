//
//  FeedbackViewController.swift
//  photoAlbum
//

import UIKit
import MessageUI
import AVFoundation

class FeedbackViewController: UIViewController, MFMailComposeViewControllerDelegate {

    //outlet for the feedback message text field
    @IBOutlet weak var feedbackMessage: UITextField!
    
    ///Function is activated when submit button is clicked, it then launches the mail app and fills with here response
    @IBAction func submitButton(_ sender: Any) {
        //Used my univerity email for it to sent to
        let email = "sgdanuke@liverpool.ac.uk"
        let subject = "Feedback"
        let message = feedbackMessage.text //text from textfield
        
        //Check the user has the mail app set up
        if(MFMailComposeViewController.canSendMail()){
            let mailVC = MFMailComposeViewController()
            mailVC.mailComposeDelegate = self
            mailVC.setToRecipients([email])
            mailVC.setSubject(subject)
            mailVC.setMessageBody(message ?? "", isHTML: false) //provided a default value
                            
            present(mailVC, animated: true)
        }
        
        else {
            print("Can't open mail app")
        }
        
    }
    
    //result of mail being sent
    func mailComposeController(controller: MFMailComposeViewController,
                               didFinishWithResult result: MFMailComposeResult, error: NSError?) {
     
        // Dismiss the mail view controller.
        controller.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Feedback"

    }
    



}

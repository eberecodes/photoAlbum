//
//  FeedbackViewController.swift
//  photoAlbum
//

import UIKit
import MessageUI
import AVFoundation

class FeedbackViewController: UIViewController, MFMailComposeViewControllerDelegate {

    //Outlet for the feedback message text field
    @IBOutlet weak var feedbackMessage: UITextField!
    
    //Makes it scrollable
    @IBOutlet weak var feedbackTextView: UITextView!
    
    /// Function is activated when submit button is clicked, it then launches the mail app and fills with here response
    @IBAction func submitButton(_ sender: Any) {
        //Used my univerity email for it to sent to
        let email = "sgdanuke@liverpool.ac.uk"
        let subject = "Feedback"
        let message = feedbackTextView.text //text from text view
        
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
    
    //Result of mail being sent
    private func mailComposeController(controller: MFMailComposeViewController,
                               didFinishWithResult result: MFMailComposeResult, error: NSError?) {
     
        // Dismiss the mail view controller.
        controller.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Feedback"

    }
    



}

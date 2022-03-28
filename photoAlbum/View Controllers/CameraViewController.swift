//
//  CameraViewController.swift
//  testVision
//

//Imports
import UIKit
import AVFoundation
import Vision
import CoreML

//All the hand gestures as cases
enum Poses:String{
    case background = ""
    case raisedFist = "✊"
    case peaceSign = "✌️"
    case callSign = "🤙"
    case thumbUp = "👍"
    case crossedFingers = "🤞"
    case hornsSign = "🤘"
    case loveYou = "🤟"
    case raisedHand = "✋"
    case okaySign = "👌"
}


class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    //Persistent storage
    let userDefaults = UserDefaults.standard
    
    //IBOutlet for back button
    @IBOutlet weak var backButton: UINavigationItem!
    
    //Keeps track of which gesture was entered
    private var previous: String = ""
    var authenticated = false
    
    //MARK: Landmark points
    //Thumb landmarks
    private var thumbTip: CGPoint?
    private var thumbIp: CGPoint?
    private var thumbMp: CGPoint?
    private var thumbCmc: CGPoint?
    
    //Index landmarks
    private var indexTip: CGPoint?
    private var indexDip: CGPoint?
    private var indexPip: CGPoint?
    private var indexMcp: CGPoint?
    
    //Middle finger landmarks
    private var middleTip: CGPoint?
    private var middleDip: CGPoint?
    private var middlePip: CGPoint?
    private var middleMcp: CGPoint?
    
    //Ring finger landmarks
    private var ringTip: CGPoint?
    private var ringDip: CGPoint?
    private var ringPip: CGPoint?
    private var ringMcp: CGPoint?
    
    //Pinkie finger landmarks
    private var pinkieTip: CGPoint?
    private var pinkieDip: CGPoint?
    private var pinkiePip: CGPoint?
    private var pinkieMcp: CGPoint?
    
    //Wrist landmarks
    private var wrist: CGPoint?
    
    //Stores recent poses
    private var poseBuffer = [Poses]()
    
    //A computed property
    var currentPose:Poses = .background{ //initialise to background
        didSet {  //every time currentPose changes
            poseBuffer.append(currentPose)
            if (poseBuffer.count == 3){ //Checks the number of recent poses is 3
                if (poseBuffer.filter({$0 == currentPose}).count == 3){ //Checks if they are all the same pose
                    enterPasswordPose(pose: currentPose)
                }
                poseBuffer.removeAll() //Reset buffer when 3 poses have been collected
            }
        }
    }
    
    //Another computer property, listens for when this is changed
    private var handRecognised:Bool = false {
        didSet {
            if (!handRecognised){
                DispatchQueue.main.sync {
                    self.convertPoints([], .clear) //no longer see overlay points
                }
            }
        }
    }
    
    //MARK: Vision Request
    //Vision hand pose request
    private var poseRequest = VNDetectHumanHandPoseRequest()
    
    //Store whether or not password must be incorrect based on input
    private var incorrectLimit = false
    
    //Stores password
    private var password: String? = nil
    
    //Password that has been eneterd so far
    private var passwordEntered: String = ""
   
    //Setting up camera properties
    let cameraSession = AVCaptureSession()
    var cameraDevice:AVCaptureDevice!
    var devicePosition:AVCaptureDevice.Position = .front
    
    //Variable for camera preview
    private var previewView: PreviewView { view as! PreviewView }
    
    ///Function for when user wants to restart their password entry
    @IBAction func restartButton(_ sender: Any) {
        //Go to previous view controller
        navigationController?.popViewController(animated: true)
    }
    
    ///Function for loading the preview of the camera
    override func loadView() {
        view = PreviewView()
         
    }
     
    ///Function gets called once the view controller's view has been loaded into memory
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Hide original back button so we can customise it
        backButton.hidesBackButton = true
        
        //get the gesture password that was stored securely in keychain
        let retrievedGestures: String? = KeychainWrapper.standard.string(forKey: "gesturePassword")
        
        //assign retrived gestures to the password variable
        password = retrievedGestures
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)
      
      //assign the video preview layer to the camera session
      self.previewView.videoPreviewLayer.session = self.cameraSession
  
    }
    
    ///Function converts the cgpoints so they can be displayed on the screen
    func convertPoints(_ fingers: [CGPoint],_ colour: UIColor) {
        //Convert each of the points to a point on the layer object
        let convertedPoints = fingers.map {
            previewView.videoPreviewLayer.layerPointConverted(fromCaptureDevicePoint: $0)
        }
        
        //Display the points on the screen
        previewView.showPoints(points: convertedPoints, color: colour)
    }
   
    
    func session(_ pixelBuffer: CMSampleBuffer){
        
        //Request is only for one hand
        poseRequest.maximumHandCount = 1

        //Create request handler
        let requestHandler = VNImageRequestHandler(cmSampleBuffer: pixelBuffer, orientation: .up, options: [:])
        
        do {
            //MARK: Perform Request
            try requestHandler.perform([poseRequest])
            guard let observations = poseRequest.results?.first, !poseRequest.results!.isEmpty else {
                    handRecognised = false
                return
            }
            //A hand has been recognised
            handRecognised = true
            
            //if observation was made for each finger and wrist assign the recognised points
            let thumb = try observations.recognizedPoints(.thumb)
            let indexFinger = try observations.recognizedPoints(.indexFinger)
            let middleFinger = try observations.recognizedPoints(.middleFinger)
            let ringFinger = try observations.recognizedPoints(.ringFinger)
            let pinkieFinger = try observations.recognizedPoints(.littleFinger)
            let wristPoints = try observations.recognizedPoints(.all)
            
            //Get the individual landmarks for each finger
            guard let thumbTipPoint = thumb[.thumbTip], let thumbIpPoint = thumb[.thumbIP], let thumbMpPoint = thumb[.thumbMP], let thumbCMCPoint = thumb[.thumbCMC] else { return }
            guard let indexTipPoint = indexFinger[.indexTip], let indexDipPoint = indexFinger[.indexDIP], let indexPipPoint = indexFinger[.indexPIP], let indexMcpPoint = indexFinger[.indexMCP] else { return }
            guard let middleTipPoint = middleFinger[.middleTip], let middleDipPoint = middleFinger[.middleDIP], let middlePipPoint = middleFinger[.middlePIP], let middleMcpPoint = middleFinger[.middleMCP] else { return }
            guard let ringTipPoint = ringFinger[.ringTip], let ringDipPoint = ringFinger[.ringDIP], let ringPipPoint = ringFinger[.ringPIP], let ringMcpPoint = ringFinger[.ringMCP] else { return }
            guard let pinkieTipPoint = pinkieFinger[.littleTip], let pinkieDipPoint = pinkieFinger[.littleDIP], let pinkiePipPoint = pinkieFinger[.littlePIP], let pinkieMcpPoint = pinkieFinger[.littleMCP] else { return }
            guard let wristPoint = wristPoints[.wrist] else { return }
                
            let minConfidence:Float = 0.4
            
            //Return if the confidence of the recognise points aren't at mininum 0.4
            guard thumbTipPoint.confidence > minConfidence, thumbIpPoint.confidence > minConfidence, thumbMpPoint.confidence > minConfidence, thumbCMCPoint.confidence > minConfidence else { return }
            guard indexTipPoint.confidence > minConfidence, indexDipPoint.confidence > minConfidence, indexPipPoint.confidence > minConfidence, indexMcpPoint.confidence > minConfidence else { return }
            guard middleTipPoint.confidence > minConfidence, middleDipPoint.confidence > minConfidence, middlePipPoint.confidence > minConfidence, middleMcpPoint.confidence > minConfidence else { return }
            guard ringTipPoint.confidence > minConfidence, ringDipPoint.confidence > minConfidence, ringPipPoint.confidence > minConfidence, ringMcpPoint.confidence > minConfidence else { return }
            guard pinkieTipPoint.confidence > minConfidence, pinkieDipPoint.confidence > minConfidence, pinkiePipPoint.confidence > minConfidence, pinkieMcpPoint.confidence > minConfidence else { return }
            guard wristPoint.confidence > minConfidence else { return }
                
            //Converting thumb points from Vision to AVFoundation coordinates.
            thumbTip = CGPoint(x: thumbTipPoint.location.x, y: 1 - thumbTipPoint.location.y)
            thumbIp = CGPoint(x: thumbIpPoint.location.x, y: 1 - thumbIpPoint.location.y)
            thumbMp = CGPoint(x: thumbMpPoint.location.x, y: 1 - thumbMpPoint.location.y)
            thumbCmc = CGPoint(x: thumbCMCPoint.location.x, y: 1 - thumbCMCPoint.location.y)
            
            //Converting index finger points from Vision to AVFoundation coordinates
            indexTip = CGPoint(x: indexTipPoint.location.x, y: 1 - indexTipPoint.location.y)
            indexDip = CGPoint(x: indexDipPoint.location.x, y: 1 - indexDipPoint.location.y)
            indexPip = CGPoint(x: indexPipPoint.location.x, y: 1 - indexPipPoint.location.y)
            indexMcp = CGPoint(x: indexMcpPoint.location.x, y: 1 - indexMcpPoint.location.y)
            
            //Converting middle finger points from Vision to AVFoundation coordinates
            middleTip = CGPoint(x: middleTipPoint.location.x, y: 1 - middleTipPoint.location.y)
            middleDip = CGPoint(x: middleDipPoint.location.x, y: 1 - middleDipPoint.location.y)
            middlePip = CGPoint(x: middlePipPoint.location.x, y: 1 - middlePipPoint.location.y)
            middleMcp = CGPoint(x: middleMcpPoint.location.x, y: 1 - middleMcpPoint.location.y)
            
            //Converting ring finger finger points from Vision to AVFoundation coordinates
            ringTip = CGPoint(x: ringTipPoint.location.x, y: 1 - ringTipPoint.location.y)
            ringDip = CGPoint(x: ringDipPoint.location.x, y: 1 - ringDipPoint.location.y)
            ringPip = CGPoint(x: ringPipPoint.location.x, y: 1 - ringPipPoint.location.y)
            ringMcp = CGPoint(x: ringMcpPoint.location.x, y: 1 - ringMcpPoint.location.y)
            
            //Converting pinkie finger points from Vision to AVFoundation coordinates
            pinkieTip = CGPoint(x: pinkieTipPoint.location.x, y: 1 - pinkieTipPoint.location.y)
            pinkieDip = CGPoint(x: pinkieDipPoint.location.x, y: 1 - pinkieDipPoint.location.y)
            pinkiePip = CGPoint(x: pinkiePipPoint.location.x, y: 1 - pinkiePipPoint.location.y)
            pinkieMcp = CGPoint(x: pinkieMcpPoint.location.x, y: 1 - pinkieMcpPoint.location.y)
            
            //Converting wrist point from Vision to AVFoundation coordinates
            wrist = CGPoint(x: wristPoint.location.x, y: 1 - wristPoint.location.y)
                
            //Add these to array
            let handPoint = [thumbTip!, thumbIp!, thumbMp!, thumbCmc!,indexTip!,indexDip!, indexMcp!, indexPip!, middleTip!, middleDip!, middlePip!, middleMcp!, ringTip!,
                                 ringDip!,ringPip!,ringMcp!,pinkieTip!,pinkieDip!, pinkiePip!, pinkieMcp!, wrist!]
            
            //Blocks the main thread until this task is finished
            DispatchQueue.main.sync {
                //Dispay points on the screen
                self.convertPoints(handPoint, .systemYellow)
            }
                    
            //Stores the key points from the observations
            guard let keyPointsMultiArray = try? observations.keypointsMultiArray() else {fatalError()}
             
            //MARK: Pose Classifier Model
            do {
                //Initialise pose classifier model
                let model: poseClassifier = try poseClassifier(configuration: .init())
                  
                //Stores the computed predictions
                let posePrediction = try model.prediction(poses: keyPointsMultiArray)
                let confidence =  posePrediction.labelProbabilities[posePrediction.label]!
                
                //Only enter the pose into the password entry if confidence is minimum of 0.7
                if (confidence > 0.7) {
                    switchPose(pose: posePrediction.label)
                }
                        
            } catch {
                #if DEBUG
                print(error)
                #endif
            }
                
        } catch {
            #if DEBUG
            print(error)
            #endif
        }
    }

    
    func switchPose(pose: String){
        //Updates current pose based on what is recognised
        switch pose {
        case "background":
            currentPose = .background
        case "raisedFist":
            currentPose = .raisedFist
        case "peaceSign":
            currentPose = .peaceSign
        case "callSign":
            currentPose = .callSign
        case "thumbUp":
            currentPose = .thumbUp
        case "crossedFingers":
            currentPose = .crossedFingers
        case "hornsSign":
            currentPose = .hornsSign
        case "loveYou":
            currentPose = .loveYou
        case "raisedHand":
            currentPose = .raisedHand
        case "okaySign":
            currentPose = .okaySign
        default:
            currentPose = .background
        }
       
    }
    
    //MARK: Enter Password
    func enterPasswordPose(pose: Poses){
        
        //Ignore consecutive repeated gestures
        if (pose.rawValue != previous){
            passwordEntered = passwordEntered+pose.rawValue
        }
        
        //Checks password matches retrieved password
        if (password == passwordEntered) {
            //Stop the camera and close the view from the camera
            self.cameraSession.stopRunning()
            closeCameraView()
        }
        
        //When the password they entered is double the length of the original password, automatically timeout
        if ((passwordEntered.count) == (password!.count)*2){
            incorrectLimit = true
            //Stop the camera and close the view from the camera
            self.cameraSession.stopRunning()
            closeCameraView()
        }
        
        previous = pose.rawValue //Update previous pose
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prepareCamera()
        
        //UI - Get navigation bar to blend with current background
        let navAppearance = UINavigationBarAppearance()
        navAppearance.backgroundColor = .black
        navigationController?.navigationBar.scrollEdgeAppearance = navAppearance
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //UI - return navigation bar to standard appearance
        let navAppearance = UINavigationBarAppearance()
        navAppearance.backgroundColor = .systemYellow
        navigationController?.navigationBar.scrollEdgeAppearance = navAppearance
        
    }
    
    func closeCameraView(){
        DispatchQueue.main.async {
            //Set the layer to nothing
            self.previewView.layer.sublayers = nil
            
            //MARK: Authenticated
            if (!self.incorrectLimit) {
                let authenticatedAlert = UIAlertController(title: "AUTHENTICATED", message: nil, preferredStyle: .alert)
                let imageView = UIImageView(frame: CGRect(x: 10, y: 50, width: 200, height: 210))
                
                //Unlocked image added to alert image view
                imageView.image = UIImage(systemName: "lock.open")
                imageView.tintColor = .systemYellow
                authenticatedAlert.view.addSubview(imageView)
                
                //determ ine and height and width constraints from size of alert
                let height = NSLayoutConstraint(item: authenticatedAlert.view!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 320)
                let width = NSLayoutConstraint(item: authenticatedAlert.view!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 250)
                authenticatedAlert.view.addConstraint(height)
                authenticatedAlert.view.addConstraint(width)
                
                //OK action
                authenticatedAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                    #if DEBUG
                    print("Ok clicked")
                    #endif
                    
                    self.authenticated = true
                    self.performSegue(withIdentifier: "gestureUnwind", sender: self)
                    //what if i pop to root view and then to specific gallery screen
                    //self.navigationController!.popToRootViewController(animated: true)
                }))
                self.present(authenticatedAlert, animated: true, completion: nil)
                
                //Update user defaults - gesture password has been set up
                self.userDefaults.set(true, forKey: "gestureSetup")
            }
            
            //When the entry has timed-out, the gesture password hasn't been recognise
            else {
                let tryAgainAlert = UIAlertController(title: "Gestures Not Recognised", message: "Try Again", preferredStyle: .alert)
                
                tryAgainAlert.addAction(UIAlertAction(title: "Try Gestures Again", style: .default, handler: { action in
                    
                    //Return to countdown screen
                    self.navigationController?.popViewController(animated: true)
                }))
                
                //Cancel action
                tryAgainAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
                    print("Cancel clicked")
                    
                    //Return to album screen
                    self.navigationController?.popToRootViewController(animated: true)
                }))
                self.present(tryAgainAlert, animated: true, completion: nil)
            }
        }
    }
    
    //MARK: Camera Setup
    func prepareCamera(){
        let devicesAvailable = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back).devices
        cameraDevice = devicesAvailable.first
        beginSession()
    }
    
    ///Function begins the camera sesion
    func beginSession(){
        
        do {
            let cameraDeviceInput = try AVCaptureDeviceInput(device: cameraDevice) //try to access user device
            cameraSession.addInput(cameraDeviceInput)
        }catch{
            #if DEBUG
            print("Problem creating device input")
            #endif
            
            return
        }
        
        //Sort camera setting
        cameraSession.beginConfiguration()
        cameraSession.sessionPreset = .vga640x480
        
        let cameraOutput = AVCaptureVideoDataOutput()
        cameraOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String:
            Int(kCVPixelFormatType_420YpCbCr8PlanarFullRange)]
        cameraOutput.alwaysDiscardsLateVideoFrames = true
        
        if cameraSession.canAddOutput(cameraOutput){
            cameraSession.addOutput(cameraOutput)
        }
        cameraSession.commitConfiguration()
        
        //Display camera view to user
        let cameraQueue = DispatchQueue(label: "camera queue")
        cameraOutput.setSampleBufferDelegate(self, queue: cameraQueue)
        cameraSession.startRunning()
    }
    
    ///Function sorts device orientation
    public func exifOrientationFromDeviceOrientation() -> CGImagePropertyOrientation {
            let curDeviceOrientation = UIDevice.current.orientation
            let exifOrientation: CGImagePropertyOrientation
            
            switch curDeviceOrientation {
            case UIDeviceOrientation.portraitUpsideDown:
                exifOrientation = .left
            case UIDeviceOrientation.landscapeLeft:
                exifOrientation = .upMirrored
            case UIDeviceOrientation.landscapeRight:
                exifOrientation = .down
            case UIDeviceOrientation.portrait:
                exifOrientation = .up
            default:
                exifOrientation = .up
            }
            return exifOrientation
        }
    
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        //call session which will make the Vision request
        session(sampleBuffer)
      
    }

    ///Prepare for segue to next screen
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let status = authenticated
        authenticated = status
    }
}


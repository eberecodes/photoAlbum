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
enum poses:String{
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
    private var poseBuffer = [poses]()
    //A computed property
    var currentPose:poses = .background{ //initialise to background
        didSet {  //every time currentPose changes
            poseBuffer.append(currentPose)
            if (poseBuffer.count == 3){ //Checks the number of recent poses is 3
                if (poseBuffer.filter({$0 == currentPose}).count == 3){ //Checks if they are all the same pose
                    enterPasswordPose(pose: currentPose)
                }
                poseBuffer.removeAll() //Reset buffer when 3 poses have been collecttect
            }
        }
    }
    
    //Another computer property, listens for when this is changed
    private var handRecognised:Bool = false {
        didSet {
            if (!handRecognised){
                DispatchQueue.main.async {
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
        
        let retrievedGestures: String? = KeychainWrapper.standard.string(forKey: "gesturePassword")
        
        password = retrievedGestures
        //set value of password so it can be compared, to that is stored
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)
      self.previewView.videoPreviewLayer.session = self.cameraSession
  
    }
    
    ///Function converts the cgpoints so they can be displayed on the screen
    func convertPoints(_ fingers: [CGPoint],_ colour: UIColor) {
        let convertedPoints = fingers.map {
            previewView.videoPreviewLayer.layerPointConverted(fromCaptureDevicePoint: $0)
        }
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
            
            //Checks if observation was made for each finger and wrist
            let thumbPoints = try observations.recognizedPoints(.thumb)
            let indexFingerPoints = try observations.recognizedPoints(.indexFinger)
            let middleFingerPoints = try observations.recognizedPoints(.middleFinger)
            let ringFingerPoints = try observations.recognizedPoints(.ringFinger)
            let pinkieFingerPoints = try observations.recognizedPoints(.littleFinger)
            let wristPoints = try observations.recognizedPoints(.all)
                
                
            guard let thumbTipPoint = thumbPoints[.thumbTip],
                  let thumbIpPoint = thumbPoints[.thumbIP],
                  let thumbMpPoint = thumbPoints[.thumbMP],
                  let thumbCMCPoint = thumbPoints[.thumbCMC] else { return }
                
            guard let indexTipPoint = indexFingerPoints[.indexTip],
                  let indexDipPoint = indexFingerPoints[.indexDIP],
                  let indexPipPoint = indexFingerPoints[.indexPIP],
                  let indexMcpPoint = indexFingerPoints[.indexMCP] else { return }
                
            guard let middleTipPoint = middleFingerPoints[.middleTip],
                  let middleDipPoint = middleFingerPoints[.middleDIP],
                  let middlePipPoint = middleFingerPoints[.middlePIP],
                  let middleMcpPoint = middleFingerPoints[.middleMCP] else { return }
                
            guard let ringTipPoint = ringFingerPoints[.ringTip],
                  let ringDipPoint = ringFingerPoints[.ringDIP],
                  let ringPipPoint = ringFingerPoints[.ringPIP],
                  let ringMcpPoint = ringFingerPoints[.ringMCP] else { return }
                
            guard let pinkieTipPoint = pinkieFingerPoints[.littleTip],
                  let pinkieDipPoint = pinkieFingerPoints[.littleDIP],
                  let pinkiePipPoint = pinkieFingerPoints[.littlePIP],
                  let pinkieMcpPoint = pinkieFingerPoints[.littleMCP] else { return }
                
            guard let wristPoint = wristPoints[.wrist] else { return }
                
            let minConfidence:Float = 0.3
            //Don't include low confidence points
            guard thumbTipPoint.confidence > minConfidence,
                  thumbIpPoint.confidence > minConfidence,
                  thumbMpPoint.confidence > minConfidence,
                  thumbCMCPoint.confidence > minConfidence else { return }
                
            guard indexTipPoint.confidence > minConfidence,
                  indexDipPoint.confidence > minConfidence,
                  indexPipPoint.confidence > minConfidence,
                  indexMcpPoint.confidence > minConfidence else { return }
                
            guard middleTipPoint.confidence > minConfidence,
                  middleDipPoint.confidence > minConfidence,
                  middlePipPoint.confidence > minConfidence,
                  middleMcpPoint.confidence > minConfidence else { return }
                
            guard ringTipPoint.confidence > minConfidence,
                  ringDipPoint.confidence > minConfidence,
                  ringPipPoint.confidence > minConfidence,
                  ringMcpPoint.confidence > minConfidence else { return }
                
            guard pinkieTipPoint.confidence > minConfidence,
                  pinkieDipPoint.confidence > minConfidence,
                  pinkiePipPoint.confidence > minConfidence,
                  pinkieMcpPoint.confidence > minConfidence else { return }
                
            guard wristPoint.confidence > minConfidence else { return }
                
            //Conversion from Vision coordinates to AVFoundation coordinates.
            thumbTip = CGPoint(x: thumbTipPoint.location.x, y: 1 - thumbTipPoint.location.y)
            thumbIp = CGPoint(x: thumbIpPoint.location.x, y: 1 - thumbIpPoint.location.y)
            thumbMp = CGPoint(x: thumbMpPoint.location.x, y: 1 - thumbMpPoint.location.y)
            thumbCmc = CGPoint(x: thumbCMCPoint.location.x, y: 1 - thumbCMCPoint.location.y)
                
            indexTip = CGPoint(x: indexTipPoint.location.x, y: 1 - indexTipPoint.location.y)
            indexDip = CGPoint(x: indexDipPoint.location.x, y: 1 - indexDipPoint.location.y)
            indexPip = CGPoint(x: indexPipPoint.location.x, y: 1 - indexPipPoint.location.y)
            indexMcp = CGPoint(x: indexMcpPoint.location.x, y: 1 - indexMcpPoint.location.y)
                
            middleTip = CGPoint(x: middleTipPoint.location.x, y: 1 - middleTipPoint.location.y)
            middleDip = CGPoint(x: middleDipPoint.location.x, y: 1 - middleDipPoint.location.y)
            middlePip = CGPoint(x: middlePipPoint.location.x, y: 1 - middlePipPoint.location.y)
            middleMcp = CGPoint(x: middleMcpPoint.location.x, y: 1 - middleMcpPoint.location.y)
                
            ringTip = CGPoint(x: ringTipPoint.location.x, y: 1 - ringTipPoint.location.y)
            ringDip = CGPoint(x: ringDipPoint.location.x, y: 1 - ringDipPoint.location.y)
            ringPip = CGPoint(x: ringPipPoint.location.x, y: 1 - ringPipPoint.location.y)
            ringMcp = CGPoint(x: ringMcpPoint.location.x, y: 1 - ringMcpPoint.location.y)
                
            pinkieTip = CGPoint(x: pinkieTipPoint.location.x, y: 1 - pinkieTipPoint.location.y)
            pinkieDip = CGPoint(x: pinkieDipPoint.location.x, y: 1 - pinkieDipPoint.location.y)
            pinkiePip = CGPoint(x: pinkiePipPoint.location.x, y: 1 - pinkiePipPoint.location.y)
            pinkieMcp = CGPoint(x: pinkieMcpPoint.location.x, y: 1 - pinkieMcpPoint.location.y)
                
            wrist = CGPoint(x: wristPoint.location.x, y: 1 - wristPoint.location.y)
                
            //Add these to array
            let handPoint = [thumbTip!, thumbIp!, thumbMp!, thumbCmc!,indexTip!,indexDip!, indexMcp!, indexPip!, middleTip!, middleDip!, middlePip!, middleMcp!, ringTip!,
                                 ringDip!,ringPip!,ringMcp!,pinkieTip!,pinkieDip!, pinkiePip!, pinkieMcp!, wrist!]

            DispatchQueue.main.sync {
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
                        
                if (confidence > 0.7) { //I set the minimum confidence to 0.7
                    switchPose(pose: posePrediction.label)
                }
                        
            } catch {
                print(error)
            }
                
        } catch {
            print(error)
        }
        
    }

    
    func switchPose(pose: String){
        print(pose)
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
    func enterPasswordPose(pose: poses){
        
        if (pose.rawValue != previous){ //Ignore consecutive repeated gestures
            //Don't add to password entered
            passwordEntered = passwordEntered+pose.rawValue
        }
        
        //Checks password matches stores password
        if (password == passwordEntered) {
            self.cameraSession.stopRunning()
            print("stop running camera session")
            self.cameraSession.stopRunning()
            closeCameraView()
        }
        
        //When the password they entered is double the length of the original password, automatically timeout
        if ((passwordEntered.count) == (password!.count)*2){
            incorrectLimit = true
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
            //self.PreviewView.videoPreviewLayer.removeFromSuperlayer()
            self.previewView.layer.sublayers = nil
            
            //MARK: Authenticated
            if (!self.incorrectLimit) {
                let authenticatedAlert = UIAlertController(title: "AUTHENTICATED", message: nil, preferredStyle: .alert)
                let imageView = UIImageView(frame: CGRect(x: 10, y: 50, width: 250, height: 230))
                
                //Unlock image added to alert
                imageView.image = UIImage(systemName: "lock.open")
                imageView.tintColor = .systemYellow
                authenticatedAlert.view.addSubview(imageView)
                
                let height = NSLayoutConstraint(item: authenticatedAlert.view!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 320)
                let width = NSLayoutConstraint(item: authenticatedAlert.view!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 250)
                authenticatedAlert.view.addConstraint(height)
                authenticatedAlert.view.addConstraint(width)
                
                authenticatedAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                    print("Ok clicked")
                   
                    self.authenticated = true
                    self.performSegue(withIdentifier: "gestureUnwind", sender: self)
                    //what if i pop to root view and then to specific gallery screen
                    //self.navigationController!.popToRootViewController(animated: true)
                }))
                self.present(authenticatedAlert, animated: true, completion: nil)
                
                //Update user defaults - gesture password has been set up
                self.userDefaults.set(true, forKey: "gestureSetup")
            }
            
            else {
                let tryAgainAlert = UIAlertController(title: "Gestures Not Recognised", message: "Try Again", preferredStyle: .alert)
                
                tryAgainAlert.addAction(UIAlertAction(title: "Try Gestures Again", style: .default, handler: { action in
                    print("Try again clicked")
                    
                    //Return to countdown screen
                    self.navigationController?.popViewController(animated: true)
                }))
                
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
            print("Problem creating device input")
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
 
        session(sampleBuffer)
      
    }

    //prepare for segue to next screen
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let status = authenticated
        authenticated = status
    }
}


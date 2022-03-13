//
//  CameraViewController.swift
//  testVision
//
//  Created by Ebere Anukem on 25/01/2022.
//

import UIKit
import Vision
import AVFoundation
import CoreML

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


//TODO: Complete machine learning model
//TODO: Improve performance of ml model in app

//replace password with gesture saved

class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    let userDefaults = UserDefaults.standard
    
    @IBOutlet weak var backButton: UINavigationItem!
    
    var authenticated = false
    
    let bufferSize = 3
    var poseBuffer = [poses]()
    
    //A computed property
    var currentPose:poses = .background{
        didSet {  //every time currentPose changes
            poseBuffer.append(currentPose)
            if (poseBuffer.count == bufferSize){
                if (poseBuffer.filter({$0 == currentPose}).count == bufferSize){
                    enterPasswordPose(pose: currentPose)
                    //maybe update UI too
                }
                poseBuffer.removeAll()
            }
        }
    }
    
    //Another computer property, listens for when this is changed
    var handRecognised:Bool = false {
        didSet {
            DispatchQueue.main.async {
                self.convertPoints([], .clear)
            }
        }
    }
    
    //Vision hand pose request
    private var poseRequest = VNDetectHumanHandPoseRequest()
    
    //Store whether or not password must be incorrect based on input
    private var incorrectLimit = false
    
    //TODO: Store this password persistently + securely
    var password: String? = nil //for testing with segue
    
    //Password that has been eneterd so far
    var passwordEntered: String = ""
   
    //Setting up camera properties
    let cameraSession = AVCaptureSession()
    var cameraDevice:AVCaptureDevice!
    var devicePosition:AVCaptureDevice.Position = .front
    
    //Variable for camera preview
    private var PreviewView: previewView { view as! previewView} //new
    
    ///Function for when user wants to restart their password entry
    @IBAction func restartButton(_ sender: Any) {
        //Go to previous view controller
        navigationController?.popViewController(animated: true)
    }
    
    ///Function for loading the preview of the camera
    override func loadView() {
        view = previewView()
         
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prepareCamera()
    }
    
    override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)
      self.PreviewView.videoPreviewLayer.session = self.cameraSession
  
    }
    
    //MARK: Trying to overlay points
    func pointsOverlay(_ observation: VNHumanHandPoseObservation){

    }
    
    func convertPoints(_ fingers: [CGPoint],_ colour: UIColor) {
        let convertedPoints = fingers.map {
            PreviewView.videoPreviewLayer.layerPointConverted(fromCaptureDevicePoint: $0)
        }

        PreviewView.showPoints(convertedPoints, color: colour)
    
    }
   
    
    func session(_ pixelBuffer: CMSampleBuffer){
        //MARK: Variables for overlaying points
        var thumbTip: CGPoint?
        var thumbIp: CGPoint?
        var thumbMp: CGPoint?
        var thumbCmc: CGPoint?
        
        var indexTip: CGPoint?
        var indexDip: CGPoint?
        var indexPip: CGPoint?
        var indexMcp: CGPoint?
        
        var middleTip: CGPoint?
        var middleDip: CGPoint?
        var middlePip: CGPoint?
        var middleMcp: CGPoint?
        
        var ringTip: CGPoint?
        var ringDip: CGPoint?
        var ringPip: CGPoint?
        var ringMcp: CGPoint?
        
        var littleTip: CGPoint?
        var littleDip: CGPoint?
        var littlePip: CGPoint?
        var littleMcp: CGPoint?
        
        var wrist: CGPoint?
        

        //MARK: Hand pose ml approach
        
        poseRequest.maximumHandCount = 1
       
        poseRequest.usesCPUOnly = true //checked to see if this helps

        let requestHandler = VNImageRequestHandler(cmSampleBuffer: pixelBuffer, orientation: .up, options: [:])
        
        do {
            try requestHandler.perform([poseRequest])
            guard let observations = poseRequest.results?.first, !poseRequest.results!.isEmpty else {
                handRecognised = false
                return
            }
            //A hand has been recognised
            handRecognised = true
      
        
            //MARK: POINTS OVERLAY
            let thumbPoints = try observations.recognizedPoints(.thumb)
            let indexFingerPoints = try observations.recognizedPoints(.indexFinger)
            let middleFingerPoints = try observations.recognizedPoints(.middleFinger)
            let ringFingerPoints = try observations.recognizedPoints(.ringFinger)
            let littleFingerPoints = try observations.recognizedPoints(.littleFinger)
            let wristPoints = try observations.recognizedPoints(.all)
            
            // Look for tip points.
            guard let thumbTipPoint = thumbPoints[.thumbTip],
                  let thumbIpPoint = thumbPoints[.thumbIP],
                  let thumbMpPoint = thumbPoints[.thumbMP],
                  let thumbCMCPoint = thumbPoints[.thumbCMC] else {
                return
            }
            
            guard let indexTipPoint = indexFingerPoints[.indexTip],
                  let indexDipPoint = indexFingerPoints[.indexDIP],
                  let indexPipPoint = indexFingerPoints[.indexPIP],
                  let indexMcpPoint = indexFingerPoints[.indexMCP] else {
                return
            }
            
            guard let middleTipPoint = middleFingerPoints[.middleTip],
                  let middleDipPoint = middleFingerPoints[.middleDIP],
                  let middlePipPoint = middleFingerPoints[.middlePIP],
                  let middleMcpPoint = middleFingerPoints[.middleMCP] else {
                return
            }
            
            guard let ringTipPoint = ringFingerPoints[.ringTip],
                  let ringDipPoint = ringFingerPoints[.ringDIP],
                  let ringPipPoint = ringFingerPoints[.ringPIP],
                  let ringMcpPoint = ringFingerPoints[.ringMCP] else {
                return
            }
            
            guard let littleTipPoint = littleFingerPoints[.littleTip],
                  let littleDipPoint = littleFingerPoints[.littleDIP],
                  let littlePipPoint = littleFingerPoints[.littlePIP],
                  let littleMcpPoint = littleFingerPoints[.littleMCP] else {
                return
            }
            
            guard let wristPoint = wristPoints[.wrist] else {
                return
            }
            
            let minimumConfidence: Float = 0.3
            //Don't include low confidence points
            guard thumbTipPoint.confidence > minimumConfidence,
                  thumbIpPoint.confidence > minimumConfidence,
                  thumbMpPoint.confidence > minimumConfidence,
                  thumbCMCPoint.confidence > minimumConfidence else {
                return
            }
            
            guard indexTipPoint.confidence > minimumConfidence,
                  indexDipPoint.confidence > minimumConfidence,
                  indexPipPoint.confidence > minimumConfidence,
                  indexMcpPoint.confidence > minimumConfidence else {
                return
            }
            
            guard middleTipPoint.confidence > minimumConfidence,
                  middleDipPoint.confidence > minimumConfidence,
                  middlePipPoint.confidence > minimumConfidence,
                  middleMcpPoint.confidence > minimumConfidence else {
                return
            }
            
            guard ringTipPoint.confidence > minimumConfidence,
                  ringDipPoint.confidence > minimumConfidence,
                  ringPipPoint.confidence > minimumConfidence,
                  ringMcpPoint.confidence > minimumConfidence else {
                return
            }
            
            guard littleTipPoint.confidence > minimumConfidence,
                  littleDipPoint.confidence > minimumConfidence,
                  littlePipPoint.confidence > minimumConfidence,
                  littleMcpPoint.confidence > minimumConfidence else {
                return
            }
            
            guard wristPoint.confidence > minimumConfidence else {
                return
            }
            
            //Converting from Vision coordinates to AVFoundation coordinates.
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
            
            littleTip = CGPoint(x: littleTipPoint.location.x, y: 1 - littleTipPoint.location.y)
            littleDip = CGPoint(x: littleDipPoint.location.x, y: 1 - littleDipPoint.location.y)
            littlePip = CGPoint(x: littlePipPoint.location.x, y: 1 - littlePipPoint.location.y)
            littleMcp = CGPoint(x: littleMcpPoint.location.x, y: 1 - littleMcpPoint.location.y)
            
            wrist = CGPoint(x: wristPoint.location.x, y: 1 - wristPoint.location.y)
            
            //Add these to array
            let handPoint = [thumbTip!, thumbIp!, thumbMp!, thumbCmc!,indexTip!,indexDip!, indexMcp!, indexPip!, middleTip!, middleDip!, middlePip!, middleMcp!, ringTip!,
                             ringDip!,ringPip!,ringMcp!,littleTip!,littleDip!, littlePip!, littleMcp!, wrist!]

            DispatchQueue.main.sync {
                self.convertPoints(handPoint, .systemYellow)
            }
                
            //ADDED INITAL ML APPROACH IN HERE
            //MARK: Initial ML approach
            guard let keyPointsMultiArray = try? observations.keypointsMultiArray() else {fatalError()}
                
            do {
                let model: GestureClassifier = try GestureClassifier(configuration: .init())
                // let model: GestureClassifier = try GestureClassifier(configuration: MLModelConfiguration())
                    
                let posePrediction = try model.prediction(poses: keyPointsMultiArray)
                let confidence =  posePrediction.labelProbabilities[posePrediction.label]!
                    
                print("\(posePrediction.label) : \(confidence)")
                    
                if (confidence > 0.8) {
                    switchPose(pose: posePrediction.label)
                    print(confidence)
                }
                    
            } catch {
                print(error)
            }
            
    } catch {
        print(error)
    }
        
        
    }

    
    //MARK: Initial ML approach
    func switchPose(pose: String){
        print(pose)
        switch pose {
        case "background":
            currentPose = .background
           // print("Background")
        case "raisedFist":
            currentPose = .raisedFist

            //print("Raised Fist")
        case "peaceSign":
            currentPose = .peaceSign
            
           // print("Peace sign")
        case "callSign":
            currentPose = .callSign

            //print("Call sign")
        case "thumbUp":
            currentPose = .thumbUp

            //print("Thumb up")
        case "crossedFingers":
            currentPose = .crossedFingers
 
            //print("Crossed fingers")
        case "hornsSign":
            currentPose = .hornsSign

           //print("Horns sign")
        case "loveYou":
            currentPose = .loveYou

            //print("Love you")
        case "raisedHand":
            currentPose = .raisedHand
            
           // print("Raised hand")
        case "okaySign":
            currentPose = .okaySign

            //print("okaySign")
        default:
            currentPose = .background

            //print("default")
        }
       
    }
    
    func enterPasswordPose(pose: poses){
   
        passwordEntered = passwordEntered+pose.rawValue

        print(passwordEntered)
        //print(password!)
        
        
        if (password == passwordEntered) {
            self.cameraSession.stopRunning()
            print("stop running camera session")
         
            closeCameraView()
            
            //Save gesture password securely, once user has been able to succesfully perform gesture password
           
        }
        //When the password they entered is triple the length of the original password, automatically timeout
        if ((passwordEntered.count) == (password!.count)*3){
            incorrectLimit = true
            self.cameraSession.stopRunning()
            closeCameraView()
        }
        
    }
    
    func closeCameraView(){
        DispatchQueue.main.async {
            //self.PreviewView.videoPreviewLayer.removeFromSuperlayer()
            self.PreviewView.layer.sublayers = nil
            
            //MARK: Authenticated
            if (!self.incorrectLimit) {
                let authenticatedAlert = UIAlertController(title: "AUTHENTICATED", message: nil, preferredStyle: .alert)
                let imageView = UIImageView(frame: CGRect(x: 10, y: 50, width: 250, height: 230))
                
                //Unclock image added to alert
                imageView.image = UIImage(named: "lock.open.fill")
                authenticatedAlert.view.addSubview(imageView)
                let height = NSLayoutConstraint(item: authenticatedAlert.view!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 320)
                let width = NSLayoutConstraint(item: authenticatedAlert.view!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 250)
                authenticatedAlert.view.addConstraint(height)
                authenticatedAlert.view.addConstraint(width)
                
                authenticatedAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                    print("Ok clicked")
                    //TODO: Segue to relevant screen - Album page - TEST THIS
                    /*let viewControllers: [UIViewController] = self.navigationController!.viewControllers
                    for vc in viewControllers {
                        if vc.isKind(of:galleryVC.self)
                        {
                            self.navigationController!.popToViewController(vc, animated: true)
                            break
                       }
                    }*/
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
    
    //MARK: Camera set up
    func prepareCamera(){
        let devicesAvailable = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back).devices
        cameraDevice = devicesAvailable.first
        beginSession()
    }
    
    func beginSession(){
        do {
            let cameraDeviceInput = try AVCaptureDeviceInput(device: cameraDevice)
            cameraSession.addInput(cameraDeviceInput)
        }catch{
            print("Problem creating device input")
            return
        }
        
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
        
        let cameraQueue = DispatchQueue(label: "camera queue")
        cameraOutput.setSampleBufferDelegate(self, queue: cameraQueue)
        cameraSession.startRunning()
    }
    
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

    //MARK: Prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let status = authenticated
        authenticated = status
    }
}


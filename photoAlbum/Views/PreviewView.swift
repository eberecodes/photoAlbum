//
//  PreviewView.swift
//  testVision
//


import UIKit
import AVFoundation

class PreviewView: UIView {
    
    //allows me to draw the path between points
    private var path = UIBezierPath()
    //allows for drawing of fingers shape
    private var fingersLayer = CAShapeLayer()
    
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    //Create video preview layer
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    ///required function
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        if layer == videoPreviewLayer {
            fingersLayer.frame = layer.bounds
        }
    }
    
    //Adds overlaying layer
   /* private func setupOverlay() {
        videoPreviewLayer.addSublayer(fingersLayer)
    }*/
    
    ///Takes the array of point and shows it on view
    func showPoints(points: [CGPoint], color: UIColor) {
        path.removeAllPoints() //always start by removing point so it adjusts to new points given
        for point in points {
            path.move(to: point)
            //Add an arch for the finhger points
            path.addArc(withCenter: point, radius: 5, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
        }
        
        if points.count > 1 {
            //draws the thumb connections
            path.move(to: points[0]) //the start point for the first thumb point
            path.addLine(to: points[1])
            path.move(to: points[1]) //the start point for next thumb point
            path.addLine(to: points[2])
            path.move(to: points[2])
            path.addLine(to: points[3])
            path.move(to: points[3])
            path.addLine(to: points.last!)
            
            //Draws the index finger connections
            path.move(to: points[4]) //the start point for the first index point
            path.addLine(to: points[5])
            path.move(to: points[5]) //the start point for next index point
            path.addLine(to: points[6])
            path.move(to: points[6])
            path.addLine(to: points[7])
            path.move(to: points[7])
            path.addLine(to: points.last!)
            
            //Draws the middle finger connections
            path.move(to: points[8])
            path.addLine(to: points[9])
            path.move(to: points[9])
            path.addLine(to: points[10])
            path.move(to: points[10])
            path.addLine(to: points[11])
            path.move(to: points[11])
            path.addLine(to: points.last!)
            
            //draws the ring finger gonnections
            path.move(to: points[12])
            path.addLine(to: points[13])
            path.move(to: points[13])
            path.addLine(to: points[14])
            path.move(to: points[14])
            path.addLine(to: points[15])
            path.move(to: points[15])
            path.addLine(to: points.last!)
            
            // Draw pinkieFinger bones
            path.move(to: points[16])
            path.addLine(to: points[17])
            path.move(to: points[17])
            path.addLine(to: points[18])
            path.move(to: points[18])
            path.addLine(to: points[19])
            path.move(to: points[19])
            path.addLine(to: points.last!)
        }
        
        //Set the colour and line settings
        fingersLayer.fillColor = color.cgColor
        fingersLayer.strokeColor = color.cgColor
        fingersLayer.lineWidth = 3.0
        fingersLayer.lineCap = .square
        
        //begin new transaction for current thread
        CATransaction.begin()
        //disable CA layer property animations
        CATransaction.setDisableActions(true)
       
        //set the path
        fingersLayer.path = path.cgPath
        CATransaction.commit()
        
        //Adds fingers layer
        videoPreviewLayer.addSublayer(fingersLayer)
    }

}

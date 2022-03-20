//
//  PreviewView.swift
//  testVision
//


import UIKit
import AVFoundation

class PreviewView: UIView {

    private var pointsPath = UIBezierPath()
    private var overlayLayer = CAShapeLayer()
    
    
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    //Create video preview layer
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupOverlay()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupOverlay()
    }
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        if layer == videoPreviewLayer {
            overlayLayer.frame = layer.bounds
        }
    }
    
    //Adds overlaying layer
    private func setupOverlay() {
        videoPreviewLayer.addSublayer(overlayLayer)
    }
    
    ///Takes the array of point and shows it on view
    func showPoints(points: [CGPoint], color: UIColor) {
        pointsPath.removeAllPoints() //always start by removing point so it adjusts to new points given
        for point in points {
            pointsPath.move(to: point)
            pointsPath.addArc(withCenter: point, radius: 5, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
        }
        
        if points.count > 1 {
            //draws the thumb connections
            pointsPath.move(to: points[0])
            pointsPath.addLine(to: points[1])
            pointsPath.move(to: points[1])
            pointsPath.addLine(to: points[2])
            pointsPath.move(to: points[2])
            pointsPath.addLine(to: points[3])
            pointsPath.move(to: points[3])
            pointsPath.addLine(to: points.last!)
            
            //draws the index finger connections
            pointsPath.move(to: points[4])
            pointsPath.addLine(to: points[5])
            pointsPath.move(to: points[5])
            pointsPath.addLine(to: points[6])
            pointsPath.move(to: points[6])
            pointsPath.addLine(to: points[7])
            pointsPath.move(to: points[7])
            pointsPath.addLine(to: points.last!)
            
            //draws the middle finger connections
            pointsPath.move(to: points[8])
            pointsPath.addLine(to: points[9])
            pointsPath.move(to: points[9])
            pointsPath.addLine(to: points[10])
            pointsPath.move(to: points[10])
            pointsPath.addLine(to: points[11])
            pointsPath.move(to: points[11])
            pointsPath.addLine(to: points.last!)
            
            //draws the ring finger bgonnections
            pointsPath.move(to: points[12])
            pointsPath.addLine(to: points[13])
            pointsPath.move(to: points[13])
            pointsPath.addLine(to: points[14])
            pointsPath.move(to: points[14])
            pointsPath.addLine(to: points[15])
            pointsPath.move(to: points[15])
            pointsPath.addLine(to: points.last!)
            
            // Draw pinkieFinger bones
            pointsPath.move(to: points[16])
            pointsPath.addLine(to: points[17])
            pointsPath.move(to: points[17])
            pointsPath.addLine(to: points[18])
            pointsPath.move(to: points[18])
            pointsPath.addLine(to: points[19])
            pointsPath.move(to: points[19])
            pointsPath.addLine(to: points.last!)
        }
        
        //Set the colour and line settings
        overlayLayer.fillColor = color.cgColor
        overlayLayer.strokeColor = color.cgColor
        overlayLayer.lineWidth = 3.0
        overlayLayer.lineCap = .round
        
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        overlayLayer.path = pointsPath.cgPath
        CATransaction.commit()
    }

}

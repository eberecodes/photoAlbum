//
//  PreviewView.swift
//  testVision
//
//  Created by Ebere Anukem on 27/01/2022.
//

import UIKit
import AVFoundation

class PreviewView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    private var pointsPath = UIBezierPath()
    private var overlayLayer = CAShapeLayer()
    
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
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

    private func setupOverlay() {
        videoPreviewLayer.addSublayer(overlayLayer)
    }
    
    func showPoints(_ points: [CGPoint], color: UIColor) {
        pointsPath.removeAllPoints()
        for point in points {
            pointsPath.move(to: point)
            pointsPath.addArc(withCenter: point, radius: 5, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
        }
        
        if points.count > 1 {
            // Draw thumb bones
            pointsPath.move(to: points[0])
            pointsPath.addLine(to: points[1])
            pointsPath.move(to: points[1])
            pointsPath.addLine(to: points[2])
            pointsPath.move(to: points[2])
            pointsPath.addLine(to: points[3])
            pointsPath.move(to: points[3])
            pointsPath.addLine(to: points.last!)
            
            // Draw indexFinger bones
            pointsPath.move(to: points[4])
            pointsPath.addLine(to: points[5])
            pointsPath.move(to: points[5])
            pointsPath.addLine(to: points[6])
            pointsPath.move(to: points[6])
            pointsPath.addLine(to: points[7])
            pointsPath.move(to: points[7])
            pointsPath.addLine(to: points.last!)
            
            // Draw middleFinger bones
            pointsPath.move(to: points[8])
            pointsPath.addLine(to: points[9])
            pointsPath.move(to: points[9])
            pointsPath.addLine(to: points[10])
            pointsPath.move(to: points[10])
            pointsPath.addLine(to: points[11])
            pointsPath.move(to: points[11])
            pointsPath.addLine(to: points.last!)
            
            // Draw ringFinger bones
            pointsPath.move(to: points[12])
            pointsPath.addLine(to: points[13])
            pointsPath.move(to: points[13])
            pointsPath.addLine(to: points[14])
            pointsPath.move(to: points[14])
            pointsPath.addLine(to: points[15])
            pointsPath.move(to: points[15])
            pointsPath.addLine(to: points.last!)
            
            // Draw littleFinger bones
            pointsPath.move(to: points[16])
            pointsPath.addLine(to: points[17])
            pointsPath.move(to: points[17])
            pointsPath.addLine(to: points[18])
            pointsPath.move(to: points[18])
            pointsPath.addLine(to: points[19])
            pointsPath.move(to: points[19])
            pointsPath.addLine(to: points.last!)
        }
        
        overlayLayer.fillColor = color.cgColor
        overlayLayer.strokeColor = color.cgColor
        overlayLayer.lineWidth = 5.0
        overlayLayer.lineCap = .round
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        overlayLayer.path = pointsPath.cgPath
        CATransaction.commit()
    }

}

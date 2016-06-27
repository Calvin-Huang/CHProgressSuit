//
//  CircularProgress.swift
//  CHProgressSuit
//
//  Created by Calvin on 6/26/16.
//  Copyright © 2016 CapsLock. All rights reserved.
//

import UIKit

@IBDesignable class CircularProgress: UIView {
    @IBInspectable var progressBarColor: UIColor = UIColor(red: 33/255.0, green: 150/255.0, blue: 243/255.0, alpha: 1) {
        didSet {
            progressBar.strokeColor = progressBarColor.CGColor
        }
    }
    @IBInspectable var progressRingColor: UIColor = UIColor(red: 187/255.0, green: 222/255.0, blue: 251/255.0, alpha: 1) {
        didSet {
            progressRing.strokeColor = progressRingColor.CGColor
        }
    }
    @IBInspectable var fillColor: UIColor = UIColor.clearColor() {
        didSet {
            fillBackground.fillColor = fillColor.CGColor
        }
    }
    @IBInspectable var textColor: UIColor = UIColor(red: 47/255.0, green: 125/255.0, blue: 183/255.0, alpha: 1) {
        didSet {
            progressText.foregroundColor = textColor.CGColor
        }
    }
    @IBInspectable var progress: CGFloat = 0 {
        didSet {
            var currentProgress = progress
            if progress > 1 {
                currentProgress = 1
            } else if progress < 0 {
                currentProgress = 0
            }
            
            progressBar.strokeEnd = currentProgress
            progressText.string = "\((Int)(currentProgress * 100))"
        }
    }
    
    private let progressBar = CAShapeLayer()
    private let progressRing = CAShapeLayer()
    private let fillBackground = CAShapeLayer()
    private let progressText = CATextLayer()
    private let fontWeightMedium: CGFloat = 0.230000004172325
    
    // Default style is designed in width 168
    private var scaleRate: CGFloat {
        return self.bounds.width / 168
    }
    private var progressWidth: CGFloat {
        return 20 * scaleRate
    }
    private var progressLength: CGFloat {
        return min(self.bounds.width - progressWidth, self.bounds.height - progressWidth)
    }
    private var fontSize: CGFloat {
        return 72 * scaleRate
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.initUI()
    }
    
    // MARK: - Override Methods
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let rectInCenter = CGRect(origin: CGPoint(x: progressWidth / 2, y: progressWidth / 2), size: CGSize(width: progressLength, height: progressLength))
        progressRing.frame = rectInCenter
        progressBar.frame = rectInCenter
        fillBackground.frame = rectInCenter
        
        progressRing.lineWidth = progressWidth
        progressBar.lineWidth = progressWidth
        
        let circularPath = UIBezierPath(roundedRect: progressRing.bounds, cornerRadius: progressLength / 2).CGPath
        progressRing.path = circularPath
        progressBar.path = circularPath
        fillBackground.path = circularPath
        
        // Unwarp variables
        guard let progressString = progressText.string else { return }
        let font = UIFont.systemFontOfSize(fontSize, weight: fontWeightMedium)
        let textSize = progressString.sizeWithAttributes([NSFontAttributeName: font])
        
        progressText.font = font
        progressText.fontSize = fontSize
        progressText.frame = CGRect(origin: CGPoint(x: 0, y: self.bounds.height / 2 - textSize.height / 2), size: CGSize(width: self.bounds.width, height: textSize.height))
    }
    
    // MARK: - Private Methods
    private func initUI() {
        // Assign Default values manully
        progressBar.strokeColor = progressBarColor.CGColor
        progressRing.strokeColor = progressRingColor.CGColor
        progressText.foregroundColor = textColor.CGColor
        progressBar.fillColor = UIColor.clearColor().CGColor
        progressRing.fillColor = UIColor.clearColor().CGColor
        fillBackground.fillColor = fillColor.CGColor
        progressBar.strokeEnd = progress
        progressText.string = "\((Int)(progress * 100))"
        
        progressText.contentsScale = UIScreen.mainScreen().scale
        progressText.alignmentMode = kCAAlignmentCenter
        
        self.layer.addSublayer(fillBackground)
        self.layer.addSublayer(progressRing)
        self.layer.addSublayer(progressBar)
        self.layer.addSublayer(progressText)
    }
}

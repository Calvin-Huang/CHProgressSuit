//
//  CircularProgress.swift
//  CHProgressSuit
//
//  Created by Calvin on 6/26/16.
//  Copyright © 2016 CapsLock. All rights reserved.
//

import UIKit
import CHCubicBezier

@IBDesignable
public class CircularProgress: UIView {
    @IBInspectable public var progressBarColor: UIColor! {
        didSet {
            progressBar.strokeColor = progressBarColor.CGColor
        }
    }
    @IBInspectable public var progressRingColor: UIColor! {
        didSet {
            progressRing.strokeColor = progressRingColor.CGColor
        }
    }
    @IBInspectable public var fillColor: UIColor! {
        didSet {
            fillBackground.fillColor = fillColor.CGColor
        }
    }
    @IBInspectable public var textColor: UIColor! {
        didSet {
            progressText.foregroundColor = textColor.CGColor
        }
    }
    @IBInspectable public var progress: CGFloat = 0 {
        didSet {
            var targetProgress = progress
            if progress > 1 {
                targetProgress = 1
            } else if progress < 0 {
                targetProgress = 0
            }
            
            progress = targetProgress
            
            progressAnimation.values = [currentProgress, targetProgress]
            progressAnimation.keyTimes = [0, 1]
            
            let controlPoints: (Float, Float, Float, Float) = (Float(cubicBezier.controlPoints.x1), Float(cubicBezier.controlPoints.x2), Float(cubicBezier.controlPoints.y1), Float(cubicBezier.controlPoints.y2))
            
            progressAnimation.timingFunction = CAMediaTimingFunction(controlPoints: controlPoints.0, controlPoints.2, controlPoints.1, controlPoints.3)
            progressBar.addAnimation(progressAnimation, forKey: nil)
            
            countingStartTime = NSDate.timeIntervalSinceReferenceDate()
            countingStartValue = currentProgress
            
            if displayLink == nil {
                displayLink = CADisplayLink(target: self, selector: #selector(updateProgress))
                displayLink?.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
            }
        }
    }
    @IBInspectable var duration: Double = 0.25 {
        didSet {
            progressAnimation.duration = duration
        }
    }
    public var easing: CubicBezier.Easing! {
        didSet {
            cubicBezier = CubicBezier(easing: easing)
        }
    }
    
    public var animateCompletion: ((progress: CGFloat) -> ())?
    
    private let progressBar = CAShapeLayer()
    private let progressRing = CAShapeLayer()
    private let fillBackground = CAShapeLayer()
    private let progressText = CATextLayer()
    private let progressAnimation = CAKeyframeAnimation(keyPath: "strokeEnd")
    
    private var cubicBezier: CubicBezier!
    
    private var displayLink: CADisplayLink?
    private var countingStartTime: NSTimeInterval!
    private var countingStartValue: CGFloat = 0
    private var currentProgress: CGFloat = 0
    
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
    
    convenience public init(progress: CGFloat) {
        self.init(frame: CGRectZero)
        
        self.progress = progress
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.initPropertiesDefaultValue()
        self.initUI()
        self.configure()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.initPropertiesDefaultValue()
        self.initUI()
        self.configure()
    }
    
    // MARK: - Override Methods
    override public func layoutSubviews() {
        
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
        
        // This code is only availble for iOS 8.4+.
        // However, our company project supports iOS 8, I need to use APIs availble in iOS 8
        // let font = UIFont.systemFontOfSize(fontSize, weight: UIFontWeightMedium)
        let font = UIFont(name: "HelveticaNeue-Medium", size: fontSize)!
        let textSize = progressString.sizeWithAttributes([NSFontAttributeName: font])
        
        progressText.font = font
        progressText.fontSize = fontSize
        progressText.frame = CGRect(origin: CGPoint(x: 0, y: self.bounds.height / 2 - textSize.height / 2), size: CGSize(width: self.bounds.width, height: textSize.height))
    }
    
    // MARK: - Selectors
    func updateProgress() {
        let nowTime = NSDate.timeIntervalSinceReferenceDate()
        let changeTime = nowTime - countingStartTime
        
        if changeTime > Double(duration) {
            displayLink?.invalidate()
            displayLink = nil
            
            animateCompletion?(progress: progress)
            
        } else {
            let changeValue = progress - countingStartValue
            var t = changeTime / duration
            
            if t > 0.91 {
                t = 1
            }
            
            currentProgress = (countingStartValue + changeValue * CGFloat(cubicBezier.easing(t)))
            progressText.string = "\((Int)(currentProgress * 100))"
        }
    }
    
    // MARK: - Private Methods
    private func initPropertiesDefaultValue() {
        progressBarColor = UIColor(red: 33/255.0, green: 150/255.0, blue: 243/255.0, alpha: 1)
        progressRingColor = UIColor(red: 187/255.0, green: 222/255.0, blue: 251/255.0, alpha: 1)
        fillColor = UIColor.clearColor()
        textColor = UIColor(red: 47/255.0, green: 125/255.0, blue: 183/255.0, alpha: 1)
        duration = 0.25
        easing = CubicBezier.Easing.EaseInOut
    }
    
    private func initUI() {
        progressBar.fillColor = UIColor.clearColor().CGColor
        progressRing.fillColor = UIColor.clearColor().CGColor
        
        progressBar.strokeEnd = progress
        
        // Disable implict animation
        progressText.actions = ["contents": NSNull()]
        
        progressText.contentsScale = UIScreen.mainScreen().scale
        progressText.alignmentMode = kCAAlignmentCenter
        progressText.string = "\((Int)(progress))"
        
        self.layer.addSublayer(fillBackground)
        self.layer.addSublayer(progressRing)
        self.layer.addSublayer(progressBar)
        self.layer.addSublayer(progressText)
    }
    
    private func configure() {
        progressAnimation.timingFunction = CAMediaTimingFunction(controlPoints: 0.42, 0, 0.58, 1)
        progressAnimation.removedOnCompletion = false
        progressAnimation.fillMode = kCAFillModeForwards
    }
}

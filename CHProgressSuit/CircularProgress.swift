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
open class CircularProgress: UIView {
    @IBInspectable open var progressBarColor: UIColor! {
        didSet {
            progressBar.strokeColor = progressBarColor.cgColor
        }
    }
    @IBInspectable open var progressRingColor: UIColor! {
        didSet {
            progressRing.strokeColor = progressRingColor.cgColor
        }
    }
    @IBInspectable open var fillColor: UIColor! {
        didSet {
            fillBackground.fillColor = fillColor.cgColor
        }
    }
    @IBInspectable open var textColor: UIColor! {
        didSet {
            progressText.foregroundColor = textColor.cgColor
        }
    }
    @IBInspectable open var progress: CGFloat = 0 {
        didSet {
            var targetProgress = progress
            if progress > 1 {
                targetProgress = 1
            } else if progress < 0 {
                targetProgress = 0
            }
            
            progress = targetProgress
            
            progressAnimation.fromValue = currentProgress
            progressAnimation.toValue = targetProgress
            progressBar.add(progressAnimation, forKey: nil)
            
            countingStartTime = Date.timeIntervalSinceReferenceDate
            countingStartValue = currentProgress
            
            if displayLink == nil {
                displayLink = CADisplayLink(target: self, selector: #selector(updateProgress))
                displayLink?.add(to: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
            }
        }
    }
    @IBInspectable var duration: Double = 0.25 {
        didSet {
            progressAnimation.duration = duration
        }
    }
    open var easing: CubicBezier.Easing! {
        didSet {
            cubicBezier = CubicBezier(easing: easing)
        }
    }
    
    open var animateCompletion: ((_ progress: CGFloat) -> ())?
    
    fileprivate let progressBar = CAShapeLayer()
    fileprivate let progressRing = CAShapeLayer()
    fileprivate let fillBackground = CAShapeLayer()
    fileprivate let progressText = CATextLayer()
    fileprivate let progressAnimation = CABasicAnimation(keyPath: "strokeEnd")
    
    fileprivate var cubicBezier: CubicBezier!
    
    fileprivate var displayLink: CADisplayLink?
    fileprivate var countingStartTime: TimeInterval!
    fileprivate var countingStartValue: CGFloat = 0
    fileprivate var currentProgress: CGFloat = 0
    
    // Default style is designed in width 168
    fileprivate var scaleRate: CGFloat {
        return self.bounds.width / 168
    }
    fileprivate var progressWidth: CGFloat {
        return 20 * scaleRate
    }
    fileprivate var progressLength: CGFloat {
        return min(self.bounds.width - progressWidth, self.bounds.height - progressWidth)
    }
    fileprivate var fontSize: CGFloat {
        return 72 * scaleRate
    }
    
    convenience public init(progress: CGFloat) {
        self.init(frame: CGRect.zero)
        
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
    override open func layoutSubviews() {
        
        super.layoutSubviews()
        
        let rectInCenter = CGRect(origin: CGPoint(x: progressWidth / 2, y: progressWidth / 2), size: CGSize(width: progressLength, height: progressLength))
        progressRing.frame = rectInCenter
        progressBar.frame = rectInCenter
        fillBackground.frame = rectInCenter
        
        progressRing.lineWidth = progressWidth
        progressBar.lineWidth = progressWidth
        
        let circularPath = UIBezierPath(roundedRect: progressRing.bounds, cornerRadius: progressLength / 2).cgPath
        progressRing.path = circularPath
        progressBar.path = circularPath
        fillBackground.path = circularPath
        
        // Unwarp variables
        guard let progressString = progressText.string else { return }
        
        // This code is only availble for iOS 8.4+.
        // However, our company project supports iOS 8, I need to use APIs availble in iOS 8
        // let font = UIFont.systemFontOfSize(fontSize, weight: UIFontWeightMedium)
        let font = UIFont(name: "HelveticaNeue-Medium", size: fontSize)!
        let textSize = (progressString as AnyObject).size(attributes: [NSFontAttributeName: font])
        
        progressText.font = font
        progressText.fontSize = fontSize
        progressText.frame = CGRect(origin: CGPoint(x: 0, y: self.bounds.height / 2 - textSize.height / 2), size: CGSize(width: self.bounds.width, height: textSize.height))
    }
    
    // MARK: - Selectors
    func updateProgress() {
        let nowTime = Date.timeIntervalSinceReferenceDate
        print("\(Date.timeIntervalSinceReferenceDate), \(Date().timeIntervalSince1970)")
        let changeTime = nowTime - countingStartTime
        
        if changeTime > Double(duration) {
            displayLink?.invalidate()
            displayLink = nil
            
            animateCompletion?(progress)
            
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
    
    // MARK: - Public Methods
    open func reset() {
    }
    
    // MARK: - Private Methods
    fileprivate func initPropertiesDefaultValue() {
        progressBarColor = UIColor(red: 33/255.0, green: 150/255.0, blue: 243/255.0, alpha: 1)
        progressRingColor = UIColor(red: 187/255.0, green: 222/255.0, blue: 251/255.0, alpha: 1)
        fillColor = UIColor.clear
        textColor = UIColor(red: 47/255.0, green: 125/255.0, blue: 183/255.0, alpha: 1)
        duration = 0.25
        easing = CubicBezier.Easing.easeInOut
    }
    
    fileprivate func initUI() {
        progressBar.fillColor = UIColor.clear.cgColor
        progressRing.fillColor = UIColor.clear.cgColor
        
        progressBar.strokeEnd = progress
        
        // Disable implict animation
        progressText.actions = ["contents": NSNull()]
        
        progressText.contentsScale = UIScreen.main.scale
        progressText.alignmentMode = kCAAlignmentCenter
        progressText.string = "\((Int)(progress))"
        
        self.layer.addSublayer(fillBackground)
        self.layer.addSublayer(progressRing)
        self.layer.addSublayer(progressBar)
        self.layer.addSublayer(progressText)
    }
    
    fileprivate func configure() {
        progressAnimation.timingFunction = CAMediaTimingFunction(controlPoints: 0.42, 0, 0.58, 1)
        progressAnimation.isRemovedOnCompletion = false
        progressAnimation.fillMode = kCAFillModeForwards
    }
}

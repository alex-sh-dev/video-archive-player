//
//  TimeScaleView.swift
//  VideoArchivePlayer
//
//  Created by dev on 1/23/26.
//

import UIKit

private struct Constants {
    static let kMinTimeScaleValue: Int = 0
    static let kMaxTimeScaleValue: Int = 24
    
    static let kTimeScaleDistance: CGFloat = 2
    static let kScaleLineWidth: CGFloat = 1
    
    static let kTickWidth: CGFloat = 2
    static let kTickHeight: CGFloat = 6
    
    static let kTextFont: UIFont = UIFont(name: "Helvetica", size: 12)!
    static let kMaxNumberPattern: String = "99"
    static let kNumberStingFormat: String = "%02d"
    
    static let kShowAllNumbersFactor: CGFloat = 1.2
    
    static let kNumberColor = UIColor.white
    static let kTickColor = UIColor.white
    static let kScaleLineColor = UIColor.lightGray
    
    static let kSlidingTimeBackroundColor = UIColor.black.withAlphaComponent(0.5)
    static let kSlidingTimeTextColor = UIColor.white
    static let kSlidingTimeCornerRadius = 5.0
}

final class TimeScaleView: UIView, StepSliderDelegate {
    // MARK: public outlets
    
    @IBOutlet weak var timeSlider: TimeSlider! {
        didSet {
            timeSlider.setRelativeViewForGestureRecognizing(self)
            timeSlider.delegate = self
        }
    }
    
    @IBOutlet weak var slidingTimeLabel: UILabel! {
        didSet {
            self.slidingTimeLabel.textAlignment = .center
            self.slidingTimeLabel.backgroundColor = Constants.kSlidingTimeBackroundColor
            self.slidingTimeLabel.textColor = Constants.kSlidingTimeTextColor
            self.slidingTimeLabel.layer.cornerRadius = Constants.kSlidingTimeCornerRadius
            self.slidingTimeLabel.clipsToBounds = true
        }
    }
    @IBOutlet weak var timeLabel: UILabel!
    
    // MARK: public properties
    
    weak var delegate: TimeScaleViewDelegate?
    
    // MARK: private properties
    
    private let _timeSliderValueSetQueue = OperationQueue()
    
    // MARK: init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        customInit()
    }
    
    // MARK: private functions
    
    private func customInit() {
        _timeSliderValueSetQueue.maxConcurrentOperationCount = 1
    }
    
    private func timeSliderSetEventToQueue(value: NSNumber) {
        _timeSliderValueSetQueue.cancelAllOperations()
        self.timeSlider.userData = value
        _timeSliderValueSetQueue.addOperation(
            ViewDelayedOperation({
                guard let savedValue = self.timeSlider.userData as? NSNumber else {
                    return
                }
                self.delegate?.timeSliderSetValueAfterDelay(slider: self.timeSlider, value: savedValue.uintValue)
            }))
    }
    
    // MARK: public functions
    
    override func draw(_ rect: CGRect) {
        guard let context: CGContext = UIGraphicsGetCurrentContext() else {
            return
        }
        
        let timeSliderFrame: CGRect = self.timeSlider.frame
        let w: Int = Int(timeSliderFrame.size.width.rounded(.up))
        
        let segment: CGFloat = CGFloat(w) / CGFloat(Constants.kMaxTimeScaleValue)
        
        let scaleLineWidth = Constants.kScaleLineWidth
        let distance = Constants.kTimeScaleDistance
        let scaleHeight = rect.size.height - self.timeSlider.frame.size.height
        let yOffsetForScale = scaleHeight - Constants.kTickHeight - scaleLineWidth - distance
        
        context.setFillColor(Constants.kTickColor.cgColor)
        
        let nameParagrapStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        nameParagrapStyle.lineBreakMode = .byClipping
        nameParagrapStyle.alignment = .center
        
        let nameAttrs = [NSAttributedString.Key.font : Constants.kTextFont,
                         NSAttributedString.Key.paragraphStyle : nameParagrapStyle,
                         NSAttributedString.Key.foregroundColor : Constants.kNumberColor,
                         NSAttributedString.Key.backgroundColor : UIColor.clear]
        
        let maxNumberTextSize = CGRectIntegral(rectBuilt(fromText: Constants.kMaxNumberPattern,
                                                         font: Constants.kTextFont))
        let f: CGFloat = segment / maxNumberTextSize.width
        var shouldShowAllNumbers = true
        if f < Constants.kShowAllNumbersFactor {
            shouldShowAllNumbers = false
        }
        
        let min = Constants.kMinTimeScaleValue
        let max = Constants.kMaxTimeScaleValue
        
        for i in min...max {
            let r = CGRect(x: timeSliderFrame.origin.x + (CGFloat(i) * segment) - TimeSlider.kThumbWidth / 2.0,
                           y: yOffsetForScale,
                           width: Constants.kTickWidth,
                           height: Constants.kTickHeight)
            context.fill(r)
            let numberString = String(format: Constants.kNumberStingFormat, i)
            let s = CGRectIntegral(rectBuilt(fromText: numberString, font: Constants.kTextFont)).size
            
            var shouldShowNumber = shouldShowAllNumbers
            if !shouldShowNumber {
                if i == min || i == max {
                    shouldShowNumber = true
                } else if i % 2 == 0 {
                    shouldShowNumber = true
                }
            }
            
            if shouldShowNumber {
                let drawRect = CGRect(x: r.origin.x - s.width / 2.0 + Constants.kTickWidth / 2.0,
                                  y: yOffsetForScale - s.height - distance,
                                  width: s.width, height: s.height)
                
                NSString(string: numberString).draw(with: drawRect, options: [NSStringDrawingOptions.usesLineFragmentOrigin], attributes: nameAttrs, context: nil)
            }
        }
        
        context.setLineWidth(scaleLineWidth)
        context.setStrokeColor(Constants.kScaleLineColor.cgColor)
        let yForLine: CGFloat = scaleHeight - distance - scaleLineWidth
        context.move(to: CGPoint(x: 0, y: yForLine))
        context.addLine(to: CGPoint(x: rect.size.width, y: yForLine))
        context.strokePath()
    }
    
    override func setNeedsDisplay() {
        if self.timeSlider != nil {
            self.timeSlider.setNeedsDisplay()
        }
        super.setNeedsDisplay()
    }
    
    func setTimeSliderValue(_ value: NSNumber, animated: Bool = false,
                            delayedEventStart: Bool = false) {
        self.timeSlider.setValue(value, animated: animated)
        if delayedEventStart {
            timeSliderSetEventToQueue(value: value)
        }
    }
    
    // MARK: StepSliderDelegate
    
    func stepSlider(_ slider: StepSlider, didChangeValue value: NSNumber) {
        timeSliderSetEventToQueue(value: value)
    }
    
    func stepSlider(_ slider: StepSlider, didUpdateValue value: NSNumber) {
        self.timeLabel.text = TimeScaleView.text(forValue: value)
    }
    
    func stepSlider(_ slider: StepSlider, thumbPanGestureBeganAt p: CGPoint, withValue value: NSNumber) {
        self.slidingTimeLabel.isHidden = false
        var newRect = self.slidingTimeLabel.frame
        newRect.origin.y = -self.slidingTimeLabel.frame.size.height - 4
        self.slidingTimeLabel.frame = newRect
        self.slidingTimeLabel.text = TimeScaleView.text(forValue: value)
    }
    
    func stepSlider(_ slider: StepSlider, thumbPanGestureChangedAt p: CGPoint, withValue value: NSNumber) {
        let text = TimeScaleView.text(forValue: value)
        var newSize = rectBuilt(fromText: text, font: self.slidingTimeLabel.font).size
        newSize.width = newSize.width + 4
        
        var newRect = self.slidingTimeLabel.frame
        newRect.size.height = newSize.height
        newRect.size.width = newSize.width
        var newOriginX: CGFloat = p.x + slider.frame.origin.x - newSize.width / 2.0
        let xOffset: CGFloat = 2.0
        if newOriginX < xOffset {
            newOriginX = xOffset
        } else if newOriginX + newSize.width + xOffset > self.frame.size.width {
            newOriginX = self.frame.size.width - newSize.width - xOffset
        }
        newRect.origin.x = newOriginX
        
        self.slidingTimeLabel.frame = newRect
        self.slidingTimeLabel.text = text
    }
    
    func stepSlider(_ slider: StepSlider, thumbPanGestureEndedAt p: CGPoint, withValue value: NSNumber) {
        self.slidingTimeLabel.isHidden = true
    }
}

extension TimeScaleView {
    private static let kSiH: Int = 3600
    private static let kSiM: Int = 60
    private static let kTimeStringFormat = "%02d:%02d:%02d"
    
    static func text(forValue value: NSNumber) -> String {
        var val = value.intValue
        if val < TimeSlider.kMinValue {
            val = TimeSlider.kMinValue
        } else if val >= TimeSlider.kMaxValue {
            val = TimeSlider.kMaxValue
        }
        
        let h = val / kSiH
        let m = (val - h * kSiH) / kSiM
        let s = val - h * kSiH - m * kSiM
        
        return String(format: kTimeStringFormat, h, m, s)
    }
}

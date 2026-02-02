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

final class TimeScaleView: UIView {
    // MARK: public outlets
    
    @IBOutlet weak var timeSlider: TimeSlider! {
        didSet {
            timeSlider.setRelativeViewForGestureRecognizing(self)
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
}

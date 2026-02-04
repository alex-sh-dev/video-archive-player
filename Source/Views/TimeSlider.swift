//
//  TimeSlider.swift
//  VideoArchivePlayer
//
//  Created by dev on 1/23/26.
//

import UIKit

struct TimeInterval {
    var start: UInt = 0
    var length: UInt = 0
    
    init(start: UInt, length: UInt) {
        self.start = start
        self.length = length
    }
}

private struct Constants {
    static let kThumbColor = UIColor(hex: 0xf9825e)
    static let kVLinesColor = UIColor(hex: 0x26cfc9)
    
    static let kOffsetForScale: CGFloat = 3.0
}

final class TimeSlider: StepSlider {
    var timeIntervals: [TimeInterval]?
    var userData: Any?
    
    static let kThumbWidth: CGFloat = 2
    static let kMinValue: Int = 0
    static let kMaxValue: Int = 86400
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        customInit()
    }
    
    private func customInit() {
        self.minimumValue = NSNumber(value: TimeSlider.kMinValue)
        self.maximumValue = NSNumber(value: TimeSlider.kMaxValue)
        self.value = self.minimumValue
        self.adjustedThumbRectRelativelyTrack = true
        let thumbView = UIView(frame: CGRect(x: 0, y: 0, width: TimeSlider.kThumbWidth, height: 0))
        thumbView.backgroundColor = Constants.kThumbColor
        self.thumbView = thumbView
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context: CGContext = UIGraphicsGetCurrentContext() else {
            return
        }
        
        context.saveGState()
        
        let w: Int = Int((UIScreen.main.scale * rect.size.width).rounded(.up))
        
        if let intervals = self.timeIntervals {
            var states: [Bool] = Array(repeating: false, count: w)
            let len = TimeSlider.kMaxValue
            for i in 0..<intervals.count {
                let ti = intervals[i]
                if ti.start >= len {
                    continue
                }
                let startX: Int = (Int(ti.start) * w) / len
                var endX: Int = (Int(ti.start + ti.length) * w) / len
                if endX > w {
                    endX = w
                }
                states[startX] = true
                var j = startX + 1
                while j < endX {
                    states[j] = true
                    j += 1
                }
            }
        
            context.setLineWidth(1 / UIScreen.main.scale)
            context.setStrokeColor(Constants.kVLinesColor.cgColor)
            for i in 1...states.count {
                if states[i - 1] {
                    let x: CGFloat = CGFloat(i) / UIScreen.main.scale
                    context.move(to: CGPoint(x: x, y: Constants.kOffsetForScale))
                    context.addLine(to: CGPoint(x: x, y: rect.size.height - Constants.kOffsetForScale))
                    context.strokePath()
                }
            }
        }
        context.restoreGState()
    }
}

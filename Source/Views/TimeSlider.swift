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

final class TimeSlider: StepSlider {
    
}

//
//  TimeScaleViewDelegate.swift
//  VideoArchivePlayer
//
//  Created by dev on 2/3/26.
//

import UIKit

protocol TimeScaleViewDelegate: AnyObject {
    func timeSliderSetValueAfterDelay(slider: TimeSlider, value: UInt)
}

extension TimeScaleViewDelegate {
    func timeSliderSetValueAfterDelay(slider: TimeSlider, value: UInt) {}
}

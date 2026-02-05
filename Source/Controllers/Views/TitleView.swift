//
//  TitleView.swift
//  VideoArchivePlayer
//
//  Created by dev on 2/5/26.
//

import UIKit

final class TitleView: UIStackView {
    private var _title: String = ""
    private var _subtitle: String = ""
    
    convenience init(title: String, subtitle: String) {
        self.init(frame: .zero)
        _title = title
        _subtitle = subtitle
        customInit()
    }
    
    private func customInit() {
        self.spacing = 0
        self.axis = .vertical
        
        let title = UILabel(frame: .zero)
        title.textAlignment = .center
        title.font = UIFont.boldSystemFont(ofSize: title.font.pointSize)
        title.text = _title
        title.frame = rectBuilt(fromText: title.text!, font: title.font).integral

        let subtitle = UILabel(frame: .zero)
        subtitle.textAlignment = .center
        subtitle.text = _subtitle
        subtitle.font = UIFont.systemFont(ofSize: subtitle.font.pointSize - 2)
        subtitle.frame = rectBuilt(fromText: subtitle.text!, font: subtitle.font).integral
        
        self.addArrangedSubview(title)
        self.addArrangedSubview(subtitle)

        let w = CGFloat.maximum(title.frame.width, subtitle.frame.width)
        let h = title.frame.height + subtitle.frame.height
        self.frame = CGRect(x: 0, y: 0, width: w, height: h)
    }
}

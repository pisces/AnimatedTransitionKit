//
//  UIMaskedImageView.swift
//  Pods
//
//  Created by Minwoo on 9/3/25.
//

import UIKit

class UIMaskedImageView: UIImageView {
    override func layoutSubviews() {
        super.layoutSubviews()

        if let animation = layer.animation(forKey: "bounds") {
            CATransaction.begin()
            CATransaction.setAnimationDuration(animation.duration)
        }

        layer.mask?.bounds = layer.bounds

        if let _ = layer.animation(forKey: "bounds") {
            CATransaction.commit()
        }
    }
}

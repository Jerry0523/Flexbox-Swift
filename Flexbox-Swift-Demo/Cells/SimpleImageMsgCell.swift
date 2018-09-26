//
//  SimpleImageMsgCell.swift
//  Flexbox-Swift
//
//  Created by Jerry on 2018/6/26.
//  Copyright © 2018年 com.jerry. All rights reserved.
//

import UIKit
import Flexbox

class SimpleImageMsgCell: SimpleTextMsgCell {
    
    let galleryBox = { () -> FlexboxTransformView in
        let galleryBox = FlexboxTransformView()
        galleryBox.flexbox.flexWrap = .wrap
        return galleryBox
    }()
    
    override func configArrangedSubViews() {
        super.configArrangedSubViews()
        infoBox.addSubview(galleryBox)
    }
    
    override func update(_ model: MsgModel) {
        if let images = model.images {
            galleryBox.isHidden = false
            galleryBox.subviews.forEach{ $0.removeFromSuperview() }
            images.map {
                let imgView = UIImageView(image: UIImage(named: $0))
                imgView.flexMargin = FlexboxInsets(top: 5, left: 0, bottom: 0, right: 5)
                return imgView
            }.forEach( galleryBox.addSubview )
        } else {
            galleryBox.isHidden = true
        }
        super.update(model)
    }

}

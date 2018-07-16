//
//  SimpleTextMsgCell.swift
//  Flexbox-Swift
//
//  Created by Jerry on 2018/6/22.
//  Copyright © 2018年 com.jerry. All rights reserved.
//

import UIKit

class SimpleTextMsgCell: AbstractMsgCell {
    
    let nameLabel = { () -> UILabel in
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.textColor = UIColor(red: 16.0 / 255.0, green: 70.0 / 255.0, blue: 130.0 / 255.0, alpha: 1.0)
        return label
    }()
    
    let contentLabel = { () -> UILabel in
        let label = UILabel()
        label.numberOfLines = 0
        label.flexMargin = FlexboxInsets(top: 6, left: 0, bottom: 0, right: 0)
        label.textColor = UIColor(white: 0.2, alpha: 1.0)
        label.font = UIFont.systemFont(ofSize: 14.0)
        return label
    }()

    override func configArrangedSubViews() {
        infoBox.addSubview(nameLabel)
        infoBox.addSubview(contentLabel)
    }
    
    override func update(_ model: MsgModel) {
        nameLabel.text = model.content.author
        if let content = model.content.content {
            contentLabel.text = content
            contentLabel.isHidden = false
        } else {
            contentLabel.isHidden = true
        }
        super.update(model)
    }
    
}

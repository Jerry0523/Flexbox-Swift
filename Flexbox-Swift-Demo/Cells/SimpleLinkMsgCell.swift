//
//  SimpleLinkMsgCell.swift
//  Flexbox-Swift
//
//  Created by Jerry on 2018/6/26.
//  Copyright © 2018年 com.jerry. All rights reserved.
//

import UIKit

class SimpleLinkMsgCell: SimpleTextMsgCell {

    let linkImageView = UIImageView(image: #imageLiteral(resourceName: "github"))
    
    let linkTitleLabel = { () -> UILabel in
        let label = UILabel()
        label.numberOfLines = 0
        label.flexMargin = FlexboxInsets(top: 0, left: 5.0, bottom: 0, right: 0)
        label.textColor = UIColor(white: 0.2, alpha: 1.0)
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.flexGrow = 1.0
        return label
    }()
    
    let linkBox = { () -> FlexboxView in
        let linkBox = FlexboxView()
        linkBox.flexShrink = 0
        linkBox.flexbox.debugTag = "link"
        linkBox.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        linkBox.flexbox.alignItems = .center
        linkBox.flexMargin = FlexboxInsets(top: 8.0, left: 0, bottom: 0, right: 0)
        linkBox.layoutMargins = UIEdgeInsets(top: 4.5, left: 5, bottom: 6, right: 5)
        return linkBox
    }()
    
    override func configArrangedSubViews() {
        super.configArrangedSubViews()
        contentLabel.textColor = UIColor.blue
        linkBox.addSubview(linkImageView)
        linkBox.addSubview(linkTitleLabel)
        infoBox.addSubview(linkBox)
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        linkBox.backgroundColor = UIColor(white: highlighted ? 0.96 : 0.95, alpha: 1.0)
    }
    
    override func update(_ model: MsgModel) {
        if let linkImageName = model.linkImageName, let linkInfo = model.linkInfo {
            linkBox.isHidden = false
            linkImageView.image = UIImage(named: linkImageName)
            linkTitleLabel.text = linkInfo
        } else {
            linkBox.isHidden = true
        }
        super.update(model)
    }
}

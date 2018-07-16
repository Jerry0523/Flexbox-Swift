//
//  MsgBottomToolbar.swift
//  Flexbox-Swift
//
//  Created by Jerry on 2018/6/26.
//  Copyright © 2018年 com.jerry. All rights reserved.
//

import UIKit

class MsgBottomToolbar: FlexboxTransformView {
    
    let dateLabel = { () -> UILabel in
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12.0)
        label.textColor = UIColor(white: 0.4, alpha: 1.0)
        label.flexGrow = 1
        return label
    }()
    
    let sourceLabel = { () -> UILabel in
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12.0)
        label.textColor = UIColor(white: 0.5, alpha: 1.0)
        label.flexMargin = FlexboxInsets(top: 0, left: 10.0, bottom: 0, right: 0)
        label.flexGrow = Float(Int.max)
        return label
    }()
    
    let dislikeButton = { () -> UIButton in
        let button = UIButton()
        button.setBackgroundImage(#imageLiteral(resourceName: "dislike"), for: .normal)
        button.flexMargin = FlexboxInsets(top: 0, left: 10.0, bottom: 0, right: 0)
        return button
    }()
    
    let likeButton = { () -> UIButton in
        let button = UIButton()
        button.setBackgroundImage(#imageLiteral(resourceName: "like"), for: .normal)
        button.flexMargin = FlexboxInsets(top: 0, left: 10.0, bottom: 0, right: 0)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        flexbox.alignItems = .end
        addSubview(dateLabel)
        addSubview(sourceLabel)
        addSubview(dislikeButton)
        addSubview(likeButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MsgBottomToolbar: MsgElement {
    
    func update(_ model: MsgModel) {
        dateLabel.text = model.date
        if let source = model.source {
            sourceLabel.text = source
            sourceLabel.isHidden = false
        } else {
            sourceLabel.isHidden = true
        }
    }
    
}

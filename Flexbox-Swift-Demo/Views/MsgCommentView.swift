//
//  MsgCommentView.swift
//  Flexbox-Swift
//
//  Created by Jerry on 2018/7/15.
//  Copyright © 2018年 com.jerry. All rights reserved.
//

import UIKit

class MsgCommentView: FlexboxView {
    
    let peopleWhoLike = { () -> UILabel in
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12.0)
        label.textColor = themeColor
        label.flexMargin = FlexboxInsets(top: 0, left: 0, bottom: 2, right: 0)
        return label
    }()
    
    let commentBox = { () -> FlexboxTransformView in
        let infoBox = FlexboxTransformView()
        infoBox.flexbox.flexDirection = .column
        infoBox.flexbox.justifyContent = .center
        return infoBox
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layoutMargins = UIEdgeInsets(top: 2, left: 4, bottom: 2, right: 4)
        backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        flexbox.flexDirection = .column
        flexbox.debugTag = "comment"
        addSubview(peopleWhoLike)
        addSubview(commentBox)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension MsgCommentView: MsgElement {
    
    func update(_ model: MsgModel) {
        if let peopleWhoLikes = model.peopleWhoLikes, peopleWhoLikes.count > 0 {
            peopleWhoLike.isHidden = false
            
            let attachment = NSTextAttachment.init(data: nil, ofType: nil)
            attachment.image = #imageLiteral(resourceName: "heart")
            
            let attributedText = NSMutableAttributedString(attributedString: NSAttributedString(attachment: attachment))
            attributedText.insert(NSAttributedString(string: " "), at: 0)
            attributedText.append(NSAttributedString(string: " "))
            peopleWhoLikes.enumerated().forEach { (offset, element) in
                if offset > 0 {
                    attributedText.append(NSAttributedString(string: ", ", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12.0)]))
                }
                attributedText.append(NSAttributedString(string: element, attributes: [NSAttributedString.Key.foregroundColor: themeColor, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12.0)]))
            }
            peopleWhoLike.attributedText = attributedText
            
        } else {
            peopleWhoLike.isHidden = true
        }
        
        if let comments = model.comments, comments.count > 0 {
            commentBox.isHidden = false
            commentBox.subviews.forEach{ $0.removeFromSuperview() }
            comments.enumerated().forEach { (offset, commentModel) in
                let label = UILabel()
                label.numberOfLines = 0
                let attributedText = NSMutableAttributedString()
                attributedText.append(NSAttributedString(string: commentModel.author, attributes: [NSAttributedString.Key.foregroundColor: themeColor, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12.0)]))
                attributedText.append(NSAttributedString(string: ": ", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12.0)]))
                attributedText.append(NSAttributedString(string: commentModel.content ?? "", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12.0)]))
                label.attributedText = attributedText
                if offset > 0 {
                    label.flexMargin = FlexboxInsets(top: 2, left: 0, bottom: 0, right: 0)
                }
                commentBox.addSubview(label)
            }
        } else {
            commentBox.isHidden = true
        }
        
        isHidden = (model.peopleWhoLikes?.count ?? 0) <= 0 && (model.comments?.count ?? 0) <= 0
    }
    
    
}

let themeColor = UIColor(red: 16.0 / 255.0, green: 70.0 / 255.0, blue: 130.0 / 255.0, alpha: 1.0)

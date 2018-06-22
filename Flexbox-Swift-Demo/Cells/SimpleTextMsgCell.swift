//
//  SimpleTextMsgCell.swift
//  Flexbox-Swift
//
//  Created by 王杰 on 2018/6/22.
//  Copyright © 2018年 com.jerry. All rights reserved.
//

import UIKit

class SimpleTextMsgCell: UITableViewCell {

    let avatarImageView = { () -> UIImageView in
        let imageView = UIImageView(image: UIImage(named: "avator"))
        imageView.flexBasis = .pixel(50)
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 25.0
        return imageView
    }()
    
    let nameLabel = { () -> UILabel in
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.textColor = UIColor(white: 0.3, alpha: 1.0)
        label.flexGrow = 1.0
        label.text = "Jerry Wong"
        return label
    }()
    
    let dateLabel = { () -> UILabel in
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12.0)
        label.textColor = UIColor(white: 0.3, alpha: 1.0)
        label.text = "2018-06-22"
        return label
    }()
    
    let contentLabel = { () -> UILabel in
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "Hello world.\n Tomorrow is another day."
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let titleBox = FlexboxTransformView()
        titleBox.addSubview(nameLabel)
        titleBox.addSubview(dateLabel)
        
        let infoBox = FlexboxTransformView()
        infoBox.addSubview(titleBox)
        infoBox.addSubview(contentLabel)
        contentLabel.flexMargin = FlexboxInsets(top: 5, left: 0, bottom: 0, right: 0)
        
        infoBox.flexbox.flexDirection = .column
        infoBox.flexbox.justifyContent = .center
        infoBox.flexGrow = 1.0
        infoBox.flexMargin = FlexboxInsets(top: 0, left: 10, bottom: 0, right: 0)
        
        let contentBox = FlexboxTransformView()
        contentBox.addSubview(avatarImageView)
        contentBox.addSubview(infoBox)
        contentView.addSubview(contentBox)
        contentBox.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        contentBox.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([contentBox.leftAnchor.constraint(equalTo: contentView.leftAnchor),
                                     contentBox.rightAnchor.constraint(equalTo: contentView.rightAnchor),
                                     contentBox.topAnchor.constraint(equalTo: contentView.topAnchor),
                                     contentBox.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}

//
//  Flexbox+CocoaTouchContainer.swift
//  Flexbox-Swift
//
//  Created by 王杰 on 2018/9/26.
//  Copyright © 2018年 com.jerry. All rights reserved.
//

import UIKit

protocol AnyFlexboxContainer {
    
    var flexboxContentView: FlexboxTransformView { get }
    
    var contentView: UIView { get }
    
}

class FlexboxTableViewCell : UITableViewCell, AnyFlexboxContainer {
    
    let flexboxContentView = FlexboxTransformView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addFlexboxContentView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}

class FlexboxCollectionViewCell : UICollectionViewCell, AnyFlexboxContainer {
    
    let flexboxContentView = FlexboxTransformView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addFlexboxContentView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}

extension AnyFlexboxContainer {
    
    func addFlexboxContentView() {
        contentView.addSubview(flexboxContentView)
        flexboxContentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([flexboxContentView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
                                     flexboxContentView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
                                     flexboxContentView.topAnchor.constraint(equalTo: contentView.topAnchor),
                                     flexboxContentView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)])
    }
}

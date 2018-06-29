//
//  AbstractMsgCell.swift
//  Flexbox-Swift
//
//  Created by Jerry on 2018/6/26.
//  Copyright © 2018年 com.jerry. All rights reserved.
//

import UIKit

protocol MsgElement: class {
    
    func update(_ model: MsgModel)
}

struct MsgModel: Codable {
    
    var avatarImageName: String
    
    var author: String
    
    var content: String?
    
    var date: String
    
    var source: String?
    
    var linkImageName: String?
    
    var linkInfo: String?
    
    var images: [String]?
    
    var type: Int
    
    var cellClass: AnyClass {
        get {
            guard let modelType = MsgModelType(rawValue: type) else {
                fatalError()
            }
            return modelType.cellClass
        }
    }
    
    var reuseIdentifier: String {
        get {
            guard let modelType = MsgModelType(rawValue: type) else {
                fatalError()
            }
            return modelType.identifier
        }
    }
}

#if swift(>=4.2)

#else
public protocol CaseIterable {
    associatedtype AllCases: Collection where AllCases.Element == Self
    static var allCases: AllCases { get }
}

extension CaseIterable where Self: Hashable {
    static var allCases: [Self] {
        return [Self](AnySequence { () -> AnyIterator<Self> in
            var raw = 0
            var first: Self?
            return AnyIterator {
                let current = withUnsafeBytes(of: &raw) { $0.load(as: Self.self) }
                if raw == 0 {
                    first = current
                } else if current == first {
                    return nil
                }
                raw += 1
                return current
            }
        })
    }
}
#endif

enum MsgModelType: Int, CaseIterable {
    
    case text = 0
    
    case gallery = 1
    
    case link = 2
    
    var cellClass: AnyClass {
        switch self {
        case .text:
            return SimpleTextMsgCell.self
        case .gallery:
            return SimpleImageMsgCell.self
        case .link:
            return SimpleLinkMsgCell.self
        }
    }
    
    var identifier: String {
        switch self {
        case .text:
            return "text"
        case .gallery:
            return "gallery"
        case .link:
            return "link"
        }
    }
}

class AbstractMsgCell: UITableViewCell, MsgElement {
    
    let avatarImageView = { () -> UIImageView in
        let imageView = UIImageView()
        imageView.flexBasis = .pixel(30)
        imageView.flexShrink = 0
        imageView.alignSelf = .start
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 15.0
        return imageView
    }()
    
    //the info box, right beside the avater image view
    let infoBox = { () -> FlexboxTransformView in
        let infoBox = FlexboxTransformView()
        infoBox.flexbox.debugTag = "info"
        
        infoBox.flexbox.flexDirection = .column
        infoBox.flexbox.justifyContent = .center
        infoBox.flexGrow = 1.0
        infoBox.flexMargin = FlexboxInsets(top: 0, left: 10, bottom: 0, right: 0)
        return infoBox
    }()
    
    //the content box
    let contentBox = { () -> FlexboxTransformView in
        let contentBox = FlexboxTransformView()
        contentBox.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        contentBox.flexbox.alignItems = .center
        contentBox.flexbox.debugTag = "content"
        contentBox.flexGrow = 1.0
        contentBox.translatesAutoresizingMaskIntoConstraints = false
        return contentBox
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configArrangedSubViews()
        
        contentBox.addSubview(avatarImageView)
        contentBox.addSubview(infoBox)
        contentView.addSubview(contentBox)
        
        NSLayoutConstraint.activate([contentBox.leftAnchor.constraint(equalTo: contentView.leftAnchor),
                                     contentBox.rightAnchor.constraint(equalTo: contentView.rightAnchor),
                                     contentBox.topAnchor.constraint(equalTo: contentView.topAnchor),
                                     contentBox.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)])
    }
    
    //for subclasses to override
    func configArrangedSubViews() {
        
    }
    
    func update(_ model: MsgModel) {
        avatarImageView.image = UIImage(named: model.avatarImageName)
        contentBox.invalidateIntrinsicContentSize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

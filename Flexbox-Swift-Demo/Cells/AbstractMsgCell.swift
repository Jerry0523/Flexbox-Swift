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

struct ContentModel: Codable {
    
    var author: String
    
    var content: String?
    
}

struct MsgModel: Codable {
    
    var avatarImageName: String
    
    var content: ContentModel
    
    var date: String
    
    var source: String?
    
    var linkImageName: String?
    
    var linkInfo: String?
    
    var images: [String]?
    
    var peopleWhoLikes: [String]?
    
    var comments: [ContentModel]?
    
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

class AbstractMsgCell: FlexboxTableViewCell, MsgElement {
    
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
    let containerBox = { () -> FlexboxTransformView in
        let infoBox = FlexboxTransformView()
        infoBox.flexbox.debugTag = "container"
        
        infoBox.flexbox.flexDirection = .column
        infoBox.flexbox.justifyContent = .center
        infoBox.flexGrow = 1.0
        infoBox.flexMargin = FlexboxInsets(top: 0, left: 10, bottom: 0, right: 0)
        return infoBox
    }()
    
    let infoBox = { () -> FlexboxTransformView in
        let infoBox = FlexboxTransformView()
        infoBox.flexbox.debugTag = "info"
        
        infoBox.flexbox.flexDirection = .column
        infoBox.flexbox.justifyContent = .center
        return infoBox
    }()
    
    let accessoryBox = { () -> FlexboxTransformView in
        let infoBox = FlexboxTransformView()
        infoBox.flexbox.debugTag = "accessory"
        
        infoBox.flexbox.flexDirection = .column
        infoBox.flexbox.justifyContent = .center
        return infoBox
    }()
    
    let toolbar = { () -> MsgBottomToolbar in
        let toolbar = MsgBottomToolbar()
        toolbar.flexMargin = FlexboxInsets(top: 6, left: 0, bottom: 0, right: 0)
        return toolbar
    }()
    
    let commentView = { () -> MsgCommentView in
        let commentView = MsgCommentView()
        commentView.flexMargin = FlexboxInsets(top: 6, left: 0, bottom: 0, right: 0)
        return commentView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        flexboxContentView.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        flexboxContentView.flexbox.alignItems = .center
        flexboxContentView.flexbox.debugTag = "content"
        
        configArrangedSubViews()
        
        accessoryBox.addSubview(toolbar)
        accessoryBox.addSubview(commentView)
        
        containerBox.addSubview(infoBox)
        containerBox.addSubview(accessoryBox)
        
        flexboxContentView.addSubview(avatarImageView)
        flexboxContentView.addSubview(containerBox)
    }
    
    //for subclasses to override
    func configArrangedSubViews() {
        
    }
    
    func update(_ model: MsgModel) {
        toolbar.update(model)
        commentView.update(model)
        avatarImageView.image = UIImage(named: model.avatarImageName)
        flexboxContentView.invalidateIntrinsicContentSize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

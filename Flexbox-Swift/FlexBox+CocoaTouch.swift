//
//  UIView+FlexBox.swift
//  Flexbox-Swift
//
//  Created by Jerry on 2018/5/22.
//  Copyright © 2018年 com.jerry. All rights reserved.
//

import UIKit

class FlexboxView: UIView, FlexboxDelegate {
    
    private(set) lazy var flexbox = Flexbox(delegate: self)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layoutMargins = UIEdgeInsets.zero
//        preservesSuperviewLayoutMargins = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        flexbox.layout(subviews.map{ $0.flexboxItem }, size: FlexboxSize(w: Float(frame.width - layoutMargins.left - layoutMargins.right), h: Float(frame.height - layoutMargins.top - layoutMargins.bottom)))
        mIntrinsicSize = flexbox.intrinsicSize.cgSize
        self.subviews.forEach { $0.frame = $0.flexFrame?.offsetBy(dx: Float(layoutMargins.left), dy: Float(layoutMargins.top)) ?? CGRect.zero }
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        flexbox.layout(subviews.map { $0.flexboxItem }, size: FlexboxSize(size))
        mIntrinsicSize = flexbox.intrinsicSize.cgSize
        return CGSize(width: mIntrinsicSize.width + layoutMargins.left + layoutMargins.right, height: mIntrinsicSize.height + layoutMargins.top + layoutMargins.bottom)
    }
    
    override var intrinsicContentSize: CGSize {
        get {
            return sizeThatFits(frame.size)
        }
    }
    
    private var mIntrinsicSize = CGSize.zero {
        didSet {
            if mIntrinsicSize != oldValue {
                invalidateIntrinsicContentSize()
            }
        }
    }
}

class FlexboxTransformView: FlexboxView {
    
    override class var layerClass: Swift.AnyClass {
        get {
            return TransformLayer.self
        }
    }
    
    class TransformLayer: CATransformLayer {
        override var isOpaque: Bool {
            set {
                
            }
            
            get {
                return false
            }
        }
        
        override var backgroundColor: CGColor? {
            set {
                
            }
            
            get {
                return nil
            }
        }
    }
}

extension UIView {
    
    var flexboxItem: FlexboxItem {
        get {
            var item = objc_getAssociatedObject(self, &UIView.flexboxItemKey) as? FlexboxItem
            if item == nil {
                item = FlexboxItem(delegate: self)
                objc_setAssociatedObject(self, &UIView.flexboxItemKey, item, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            return item!
            
        }
    }
    
    var flex: (flexGrow: Float, flexShrink: Float, flexBasis: FlexboxItem.FlexBasis) {
        get {
            return flexboxItem.flex
        }
        
        set {
            flexboxItem.flex = newValue
        }
    }
    
    var flexOrder: Int {
        get {
            return flexboxItem.flexOrder
        }
        
        set {
            flexboxItem.flexOrder = newValue
        }
    }
    
    var flexGrow: Float {
        get {
            return flexboxItem.flexGrow
        }
        
        set {
            flexboxItem.flexGrow = newValue
        }
    }
    
    var flexShrink: Float {
        get {
            return flexboxItem.flexShrink
        }
        
        set {
            flexboxItem.flexShrink = newValue
        }
    }
    
    var flexBasis: FlexboxItem.FlexBasis {
        get {
            return flexboxItem.flexBasis
        }
        
        set {
            flexboxItem.flexBasis = newValue
        }
    }
    
    var flexMargin: FlexboxInsets {
        get {
            return flexboxItem.flexMargin
        }
        set {
            flexboxItem.flexMargin = newValue
        }
    }
    
    var flexFrame: FlexboxRect? {
        get {
            return flexboxItem.flexFrame
        }
        set {
            flexboxItem.flexFrame = newValue
        }
    }
    
    var alignSelf: Flexbox.AlignSelf {
        get {
            return flexboxItem.alignSelf
        }
        
        set {
            flexboxItem.alignSelf = newValue
        }
    }
    
    private static var flexboxItemKey: Void?
    
}

extension UIView: FlexboxItemDelegate {
    
    func onMeasure(_ size: FlexboxSize) -> FlexboxSize {
        if constraints.count > 0 {
            return FlexboxSize(systemLayoutSizeFitting(size.cgSize))
        } else {
            return FlexboxSize(sizeThatFits(size.cgSize))
        }
    }
}

extension FlexboxRect {
    
    func offsetBy(dx: Float, dy: Float) -> CGRect {
        var rect = self
        rect.x += dx
        rect.y += dy
        return rect.cgRect
    }
    
    var cgRect: CGRect {
        return CGRect(x: Int(ceil(x)), y: Int(ceil(y)), width: Int(ceil(w)), height: Int(ceil(h)))
    }
}

extension FlexboxSize {
    
    init(_ cgSize: CGSize) {
        w = Float(cgSize.width)
        h = Float(cgSize.height)
    }
    
    var cgSize: CGSize {
        return CGSize(width: Int(ceil(w)), height: Int(ceil(h)))
    }
}

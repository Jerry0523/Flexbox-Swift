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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        flexbox.layout(subviews, size: FlexboxSize(w: Float(frame.width - layoutMargins.left - layoutMargins.right), h: Float(frame.height - layoutMargins.top - layoutMargins.bottom)))
        mIntrinsicSize = flexbox.intrinsicSize.cgSize
        self.subviews.forEach { $0.frame = $0.flexFrame?.offsetBy(dx: Float(layoutMargins.left), dy: Float(layoutMargins.top)) ?? CGRect.zero }
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        flexbox.layout(self.subviews, size: FlexboxSize(size))
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

extension UIView: FlexboxItem {
    
    func measure(_ size: FlexboxSize) -> FlexboxSize {
        if constraints.count > 0 {
            return FlexboxSize(systemLayoutSizeFitting(size.cgSize))
        } else {
            return FlexboxSize(sizeThatFits(size.cgSize))
        }
    }
    
    var flex: (flexGrow: Float, flexShrink: Float, flexBasis: Float?) {
        get {
            return (flexGrow, flexShrink, flexBasis)
        }
        
        set {
            flexGrow = newValue.flexGrow
            flexShrink = newValue.flexShrink
            flexBasis = newValue.flexBasis
        }
    }
    
    var flexOrder: Int {
        get {
            return objc_getAssociatedObject(self, &UIView.flexOrderKey) as? Int ?? 0
        }
        
        set {
            objc_setAssociatedObject(self, &UIView.flexOrderKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var flexGrow: Float {
        get {
            return objc_getAssociatedObject(self, &UIView.flexGrowKey) as? Float ?? 0
        }
        
        set {
            objc_setAssociatedObject(self, &UIView.flexGrowKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var flexShrink: Float {
        get {
            return objc_getAssociatedObject(self, &UIView.flexShrinkKey) as? Float ?? 1.0
        }
        
        set {
            objc_setAssociatedObject(self, &UIView.flexShrinkKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var flexBasis: Float? {
        get {
            return objc_getAssociatedObject(self, &UIView.flexBasisKey) as? Float
        }
        
        set {
            objc_setAssociatedObject(self, &UIView.flexBasisKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var flexMargin: FlexboxInsets {
        get {
            return objc_getAssociatedObject(self, &UIView.flexMarginKey) as? FlexboxInsets ?? FlexboxInsets.zero
        }
        set {
            objc_setAssociatedObject(self, &UIView.flexMarginKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var flexFrame: FlexboxRect? {
        get {
            return objc_getAssociatedObject(self, &UIView.flexFrameKey) as? FlexboxRect
        }
        set {
            objc_setAssociatedObject(self, &UIView.flexFrameKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var alignSelf: Flexbox.AlignSelf {
        get {
            return objc_getAssociatedObject(self, &UIView.alignSelfKey) as? Flexbox.AlignSelf ?? .auto
        }
        
        set {
            objc_setAssociatedObject(self, &UIView.alignSelfKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private static var flexOrderKey: Void?
    
    private static var flexGrowKey: Void?
    
    private static var flexShrinkKey: Void?
    
    private static var flexBasisKey: Void?
    
    private static var flexMarginKey: Void?
    
    private static var flexFrameKey: Void?
    
    private static var alignSelfKey: Void?
    
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

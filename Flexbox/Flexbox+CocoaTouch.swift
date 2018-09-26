//
//  Flexbox+CocoaTouch.swift
//  Flexbox-Swift
//
//  Created by Jerry on 2018/5/22.
//  Copyright © 2018年 com.jerry. All rights reserved.
//

import UIKit

open class FlexboxView: UIView, FlexboxDelegate {
    
    open private(set) lazy var flexbox = Flexbox(delegate: self)
    
    var visibleSubViews: [UIView] {
        get {
            return subviews.compactMap { $0.isHidden ? nil : $0 }
        }
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        layoutMargins = UIEdgeInsets.zero
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        if frame == CGRect.zero {
            return
        }
        var layoutItems = visibleSubViews.map{ $0.flexboxItem }
        layoutItems = flexbox.layout(layoutItems, size: FlexboxSize(w: Float(frame.width - layoutMargins.left - layoutMargins.right), h: Float(frame.height - layoutMargins.top - layoutMargins.bottom)))
        mIntrinsicSize = flexbox.intrinsicSize.cgSize
        visibleSubViews.enumerated().forEach { (offset, subView) in
            subView.flexboxItem = layoutItems[offset]
            subView.frame = subView.flexFrame?.offsetBy(dx: Float(layoutMargins.left), dy: Float(layoutMargins.top)) ?? CGRect.zero
        }
    }
    
    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        var layoutItems = visibleSubViews.map{ $0.flexboxItem }
        layoutItems = flexbox.layout(layoutItems, size: FlexboxSize(CGSize(width: size.width - layoutMargins.left - layoutMargins.right, height: size.height - layoutMargins.top - layoutMargins.bottom)), isMeasuring: true)
        mIntrinsicSize = flexbox.intrinsicSize.cgSize
        return CGSize(width: mIntrinsicSize.width + layoutMargins.left + layoutMargins.right, height: mIntrinsicSize.height + layoutMargins.top + layoutMargins.bottom)
    }
    
    override open var intrinsicContentSize: CGSize {
        get {
            var size = frame.size
            var mSuperView = superview
            while size == CGSize.zero && mSuperView != nil {
                size = mSuperView!.frame.size
                mSuperView = mSuperView?.superview
            }
            return sizeThatFits(size)
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

open class FlexboxTransformView: FlexboxView {
    
    override open class var layerClass: Swift.AnyClass {
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

public extension UIView {
    
    public var flexboxItem: FlexboxItem {
        get {
            var item = objc_getAssociatedObject(self, &UIView.flexboxItemKey) as? FlexboxItem
            if item == nil {
                item = FlexboxItem(onMeasure: self.onMeasure)
                objc_setAssociatedObject(self, &UIView.flexboxItemKey, item, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            return item!
        }
        set {
            objc_setAssociatedObject(self, &UIView.flexboxItemKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public var flex: (flexGrow: Float, flexShrink: Float, flexBasis: FlexboxItem.FlexBasis) {
        get {
            return flexboxItem.flex
        }
        
        set {
            flexboxItem.flex = newValue
        }
    }
    
    public var flexOrder: Int {
        get {
            return flexboxItem.flexOrder
        }
        
        set {
            flexboxItem.flexOrder = newValue
        }
    }
    
    public var flexGrow: Float {
        get {
            return flexboxItem.flexGrow
        }
        
        set {
            flexboxItem.flexGrow = newValue
        }
    }
    
    public var flexShrink: Float {
        get {
            return flexboxItem.flexShrink
        }
        
        set {
            flexboxItem.flexShrink = newValue
        }
    }
    
    public var flexBasis: FlexboxItem.FlexBasis {
        get {
            return flexboxItem.flexBasis
        }
        
        set {
            flexboxItem.flexBasis = newValue
        }
    }
    
    public var flexMargin: FlexboxInsets {
        get {
            return flexboxItem.flexMargin
        }
        set {
            flexboxItem.flexMargin = newValue
        }
    }
    
    public var flexFrame: FlexboxRect? {
        get {
            return flexboxItem.flexFrame
        }
        set {
            flexboxItem.flexFrame = newValue
        }
    }
    
    public var alignSelf: Flexbox.AlignSelf {
        get {
            return flexboxItem.alignSelf
        }
        
        set {
            flexboxItem.alignSelf = newValue
        }
    }
    
    private static var flexboxItemKey: Void?
    
}

extension UIView {
    
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
        return CGRect(x: CGFloat(ceil(x)), y: CGFloat(ceil(y)), width: CGFloat(ceil(w)), height: CGFloat(ceil(h)))
    }
}

extension FlexboxSize {
    
    init(_ cgSize: CGSize) {
        w = Float(cgSize.width)
        h = Float(cgSize.height)
    }
    
    var cgSize: CGSize {
        return CGSize(width: CGFloat(ceil(w)), height: CGFloat(ceil(h)))
    }
}

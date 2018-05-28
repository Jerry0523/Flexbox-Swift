//
//  FlexboxItem.swift
//  Flexbox-Swift
//
//  Created by Jerry on 2018/5/24.
//  Copyright © 2018年 com.jerry. All rights reserved.
//

class FlexboxItem {
    
    init(delegate: FlexboxItemDelegate) {
        self.delegate = delegate
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
    
    var flexOrder = 0
    
    var flexGrow = Float(0)
    
    var flexShrink = Float(1.0)
    
    var flexBasis: Float?
    
    var alignSelf = Flexbox.AlignSelf.auto
    
    var flexMargin =  FlexboxInsets.zero
    
    var flexFrame: FlexboxRect?
    
    weak var delegate: FlexboxItemDelegate?

}

extension FlexboxItem {
    
    var flexWidth: Float {
        get {
            return (flexFrame?.w ?? 0) + flexMargin.left + flexMargin.right
        }
    }
    
    var flexHeight: Float {
        get {
            return (flexFrame?.h ?? 0) + flexMargin.top + flexMargin.bottom
        }
    }
    
    func onMeasure(direction: Flexbox.Direction) {
        var size = FlexboxSize.zero
        if let basis = flexBasis {
            switch direction {
            case .row, .rowReverse:
                size = delegate?.onMeasure(FlexboxSize(w: Float(basis), h: 0)) ?? FlexboxSize.zero
                size.w = max(size.w, Float(basis))
            case .column, .columnReverse:
                size = delegate?.onMeasure(FlexboxSize(w: 0, h: Float(basis))) ?? FlexboxSize.zero
                size.h = max(size.h, Float(basis))
            }
            
        } else {
            size = delegate?.onMeasure(FlexboxSize.zero) ?? FlexboxSize.zero
        }
        flexFrame = FlexboxRect(x: 0, y: 0, w: size.w, h: size.h)
    }
}

extension FlexboxItem {
    
    func fixAlignmentInCross(direction: Flexbox.Direction, alignItems: Flexbox.AlignItems, cursor: FlexboxPoint, dimensionOfCross: Float) {
        let alignment = alignSelf.toAlignItems() ?? alignItems
        switch direction {
        case .row, .rowReverse:
            switch alignment {
            case .start: break
            case .end:
                let offsetY = cursor.y + dimensionOfCross - flexMargin.bottom - (flexFrame?.h ?? 0)
                flexFrame?.y = offsetY
            case .center:
                let offsetY = cursor.y + (dimensionOfCross - flexHeight) * 0.5 + flexMargin.top
                flexFrame?.y = offsetY
            case .stretch:
                let offsetH = dimensionOfCross - flexMargin.top - flexMargin.bottom
                flexFrame?.h = offsetH
            case .baseline:break
            }
        case .column, .columnReverse:
            switch alignment {
            case .start: break
            case .end:
                let offsetX = cursor.x + dimensionOfCross - flexMargin.right - (flexFrame?.w ?? 0)
                flexFrame?.x = offsetX
            case .center:
                let offsetX = cursor.x + (dimensionOfCross - flexWidth) * 0.5 + flexMargin.left
                flexFrame?.x = offsetX
            case .stretch:
                let offsetW = dimensionOfCross - flexMargin.left - flexMargin.right
                flexFrame?.w = offsetW
            case .baseline:break
            }
        }
    }
}

extension Array where Element == FlexboxItem {
    
    func fixDistributionInAxis(direction: Flexbox.Direction, justifyContent: Flexbox.JustifyContent, containerDimension: FlexboxSize, axisDimension: Float) {
        if justifyContent == .start {
            return
        }
        
        var mFlexJustifyConent = justifyContent
        if count == 1 && (mFlexJustifyConent == .spaceBetween || mFlexJustifyConent == .spaceAround) {
            mFlexJustifyConent = .center
        }
        
        enumerated().forEach { (index, item) in
            switch direction {
            case .row, .rowReverse:
                switch mFlexJustifyConent {
                case .end:
                    item.flexFrame?.x += containerDimension.w - axisDimension
                case .center:
                    item.flexFrame?.x += (containerDimension.w - axisDimension) * 0.5
                case .spaceBetween:
                    item.flexFrame?.x += (containerDimension.w - axisDimension) * Float(index) / Float(count - 1)
                case .spaceAround:
                    item.flexFrame?.x += (containerDimension.w - axisDimension) * (Float(index) + 0.5) / Float(count)
                case .start: break
                }
            case .column, .columnReverse:
                switch mFlexJustifyConent {
                case .end:
                    item.flexFrame?.y += containerDimension.h - axisDimension
                case .center:
                    item.flexFrame?.y += (containerDimension.h - axisDimension) * 0.5
                case .spaceBetween:
                    item.flexFrame?.y += (containerDimension.h - axisDimension) * Float(index) / Float(count - 1)
                case .spaceAround:
                    item.flexFrame?.y += (containerDimension.h - axisDimension) * (Float(index) + 0.5) / Float(count)
                case .start: break
                }
            }
        }
    }
}

protocol FlexboxItemDelegate: class {
    
    func onMeasure(_ size: FlexboxSize) -> FlexboxSize
    
}

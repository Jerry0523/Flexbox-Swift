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
    
    func fixGrowAndShrinkInAxis(arrangement: FlexboxArrangement, growOffset: Float?, shrinkOffset: Float?, fixedAxisOffset: inout Float) {
        if arrangement.isHorizontal {
            if let growOffset = growOffset {
                flexFrame?.w += growOffset
                fixedAxisOffset += growOffset
            } else if let shrinkOffset = shrinkOffset {
                flexFrame?.w -= shrinkOffset
                fixedAxisOffset -= shrinkOffset
            }
        } else {
            if let growOffset = growOffset {
                flexFrame?.h += growOffset
                fixedAxisOffset += growOffset
            } else if let shrinkOffset = shrinkOffset {
                flexFrame?.h -= shrinkOffset
                fixedAxisOffset -= shrinkOffset
            }
        }
    }
    
    func fixAlignmentInCross(arrangement: FlexboxArrangement, alignItems: Flexbox.AlignItems, dimensionOfCross: Float) {
        if flexFrame == nil {
            return
        }
        
        let alignment = alignSelf.toAlignItems() ?? alignItems
        if arrangement.isHorizontal {
            fixHorizontalAlignmentInCross(alignItems: alignment, dimensionOfCross: dimensionOfCross)
        } else {
            fixVerticalAlignmentInCross(alignItems: alignment, dimensionOfCross: dimensionOfCross)
        }
    }
    
    private func fixVerticalAlignmentInCross(alignItems: Flexbox.AlignItems, dimensionOfCross: Float) {
        switch alignItems {
        case .start: break
        case .end:
            let offsetX = flexFrame!.x - flexMargin.left + dimensionOfCross - flexMargin.right - flexFrame!.w
            flexFrame?.x = offsetX
        case .center:
            let offsetX = flexFrame!.x - flexMargin.left + (dimensionOfCross - flexWidth) * 0.5 + flexMargin.left
            flexFrame?.x = offsetX
        case .stretch:
            let offsetW = dimensionOfCross - flexMargin.left - flexMargin.right
            flexFrame?.w = offsetW
        case .baseline:break
        }
    }
    
    private func fixHorizontalAlignmentInCross(alignItems: Flexbox.AlignItems, dimensionOfCross: Float) {
        switch alignItems {
        case .start: break
        case .end:
            let offsetY = flexFrame!.y - flexMargin.top + dimensionOfCross - flexMargin.bottom - flexFrame!.h
            flexFrame?.y = offsetY
        case .center:
            let offsetY = flexFrame!.y - flexMargin.top + (dimensionOfCross - flexHeight) * 0.5 + flexMargin.top
            flexFrame?.y = offsetY
        case .stretch:
            let offsetH = dimensionOfCross - flexMargin.top - flexMargin.bottom
            flexFrame?.h = offsetH
        case .baseline:break
        }
    }
    
    fileprivate func fixHorizontalDistributionInAxis(justifyContent: Flexbox.JustifyContent, axisDimension: Float, containerDimension: FlexboxSize, itemIndex: Int, itemCount: Int) {
        switch justifyContent {
        case .end:
            flexFrame?.x += containerDimension.w - axisDimension
        case .center:
            flexFrame?.x += (containerDimension.w - axisDimension) * 0.5
        case .spaceBetween:
            flexFrame?.x += (containerDimension.w - axisDimension) * Float(itemIndex) / Float(itemCount - 1)
        case .spaceAround:
            flexFrame?.x += (containerDimension.w - axisDimension) * (Float(itemIndex) + 0.5) / Float(itemCount)
        case .start: break
        }
    }
    
    fileprivate func fixVerticalDistributionInAxis(justifyContent: Flexbox.JustifyContent, axisDimension: Float, containerDimension: FlexboxSize, itemIndex: Int, itemCount: Int) {
        switch justifyContent {
        case .end:
            flexFrame?.y += containerDimension.h - axisDimension
        case .center:
            flexFrame?.y += (containerDimension.h - axisDimension) * 0.5
        case .spaceBetween:
            flexFrame?.y += (containerDimension.h - axisDimension) * Float(itemIndex) / Float(itemCount - 1)
        case .spaceAround:
            flexFrame?.y += (containerDimension.h - axisDimension) * (Float(itemIndex) + 0.5) / Float(itemCount)
        case .start: break
        }
    }
}

extension Array where Element == FlexboxItem {
    
    func fixDistributionInCross(arrangement: FlexboxArrangement, alignContent: Flexbox.AlignContent, alignItems: Flexbox.AlignItems, dimensionsOfCross: [Float], flexContainerDimension: FlexboxSize, dimensionOfCurrentCross: Float, indexesOfAxisForItems: [Int: Int]) {
        if arrangement.isHorizontal {
            fixHorizontalDistributionInCross(arrangement: arrangement, alignContent: alignContent, alignItems: alignItems, dimensionsOfCross: dimensionsOfCross, flexContainerDimension: flexContainerDimension, dimensionOfCurrentCross: dimensionOfCurrentCross, indexesOfAxisForItems: indexesOfAxisForItems)
        } else {
            fixVerticalDistributionInCross(arrangement: arrangement, alignContent: alignContent, alignItems: alignItems, dimensionsOfCross: dimensionsOfCross, flexContainerDimension: flexContainerDimension, dimensionOfCurrentCross: dimensionOfCurrentCross, indexesOfAxisForItems: indexesOfAxisForItems)
        }
    }
    
    func fixDistributionInAxis(arrangement: FlexboxArrangement, justifyContent: Flexbox.JustifyContent, containerDimension: FlexboxSize, axisDimension: Float) {
        if justifyContent == .start {
            return
        }
        
        var mFlexJustifyConent = justifyContent
        if count == 1 && (mFlexJustifyConent == .spaceBetween || mFlexJustifyConent == .spaceAround) {
            mFlexJustifyConent = .center
        }
        
        enumerated().forEach { (index, item) in
            if arrangement.isHorizontal {
                item.fixHorizontalDistributionInAxis(justifyContent: mFlexJustifyConent, axisDimension: axisDimension, containerDimension: containerDimension, itemIndex: index, itemCount: count)
            } else {
                item.fixVerticalDistributionInAxis(justifyContent: mFlexJustifyConent, axisDimension: axisDimension, containerDimension: containerDimension, itemIndex: index, itemCount: count)
            }
        }
    }
    
    private func fixHorizontalDistributionInCross(arrangement: FlexboxArrangement, alignContent: Flexbox.AlignContent, alignItems: Flexbox.AlignItems, dimensionsOfCross: [Float], flexContainerDimension: FlexboxSize, dimensionOfCurrentCross: Float, indexesOfAxisForItems: [Int: Int]) {
        var mAlignContent = alignContent
        if dimensionsOfCross.count == 1 {
            mAlignContent = .center
        }
        if !(mAlignContent == .start && alignItems == .start) {
            let contentHeight = dimensionsOfCross.reduce(0, +)
            enumerated().forEach { (offset, item) in
                guard let lineIndex = indexesOfAxisForItems[offset] else {
                    return
                }
                var dimensionOfCross = dimensionsOfCross[lineIndex]
                switch mAlignContent {
                case .start:
                    if arrangement.isCrossReverse {
                        item.flexFrame?.y += flexContainerDimension.h - contentHeight
                    }
                case .end:
                    if arrangement.isCrossReverse {
                        item.flexFrame?.y -= flexContainerDimension.h - contentHeight
                    } else {
                        item.flexFrame?.y += flexContainerDimension.h - contentHeight
                    }
                case .center:
                    if arrangement.isCrossReverse {
                        item.flexFrame?.y -= (flexContainerDimension.h - contentHeight) * 0.5
                    } else {
                        item.flexFrame?.y += (flexContainerDimension.h - contentHeight) * 0.5
                    }
                case .spaceBetween:
                    if arrangement.isCrossReverse {
                        item.flexFrame?.y -= (flexContainerDimension.h - contentHeight) * Float(lineIndex) / Float(dimensionsOfCross.count - 1)
                    } else {
                        item.flexFrame?.y += (flexContainerDimension.h - contentHeight) * Float(lineIndex) / Float(dimensionsOfCross.count - 1)
                    }
                case .spaceAround:
                    if arrangement.isCrossReverse {
                        item.flexFrame?.y -= (flexContainerDimension.h - contentHeight) * (Float(lineIndex) + 0.5) / Float(dimensionsOfCross.count)
                    } else {
                        item.flexFrame?.y += (flexContainerDimension.h - contentHeight) * (Float(lineIndex) + 0.5) / Float(dimensionsOfCross.count)
                    }
                    
                case .stretch:
                    var stretchOffsetY = Float(0)
                    for stretchLineIndex in 0..<lineIndex {
                        stretchOffsetY += dimensionsOfCross[stretchLineIndex]
                    }
                    dimensionOfCross += (flexContainerDimension.h - contentHeight) * (dimensionOfCross / contentHeight)
                    if arrangement.isCrossReverse {
                        item.flexFrame?.y -= (stretchOffsetY * flexContainerDimension.h / contentHeight - stretchOffsetY)
                    } else {
                        item.flexFrame?.y += (stretchOffsetY * flexContainerDimension.h / contentHeight - stretchOffsetY)
                    }
                }
                item.fixAlignmentInCross(arrangement: arrangement, alignItems: alignItems, dimensionOfCross: dimensionOfCross)
            }
        }
    }
    
    private func fixVerticalDistributionInCross(arrangement: FlexboxArrangement, alignContent: Flexbox.AlignContent, alignItems: Flexbox.AlignItems, dimensionsOfCross: [Float], flexContainerDimension: FlexboxSize, dimensionOfCurrentCross: Float, indexesOfAxisForItems: [Int: Int]) {
        var mAlignContent = alignContent
        if dimensionsOfCross.count == 1 {
            mAlignContent = .center
        }
        if !(mAlignContent == .start && alignItems == .start) {
            let contentWidth = dimensionsOfCross.reduce(0, +)
            enumerated().forEach { (offset, item) in
                guard let lineIndex = indexesOfAxisForItems[offset] else {
                    return
                }
                var dimensionOfCross = dimensionsOfCross[lineIndex]
                switch mAlignContent {
                case .start: break
                case .end:
                    item.flexFrame?.x += flexContainerDimension.w - contentWidth
                case .center:
                    item.flexFrame?.x += (flexContainerDimension.w - contentWidth) * 0.5
                case .spaceBetween:
                    item.flexFrame?.x += (flexContainerDimension.w - contentWidth) * Float(lineIndex) / Float(dimensionsOfCross.count - 1)
                case .spaceAround:
                    item.flexFrame?.x += (flexContainerDimension.w - contentWidth) * (Float(lineIndex) + 0.5) / Float(dimensionsOfCross.count)
                case .stretch:
                    var stretchOffsetX = Float(0)
                    for stretchLineIndex in 0..<lineIndex {
                        stretchOffsetX += dimensionsOfCross[stretchLineIndex]
                    }
                    dimensionOfCross += (flexContainerDimension.w - contentWidth) * (dimensionOfCross / contentWidth)
                    item.flexFrame?.x += (stretchOffsetX * flexContainerDimension.w / contentWidth - stretchOffsetX)
                }
                item.fixAlignmentInCross(arrangement: arrangement, alignItems: alignItems, dimensionOfCross: dimensionOfCross)
            }
        }
    }
}

protocol FlexboxItemDelegate: class {
    
    func onMeasure(_ size: FlexboxSize) -> FlexboxSize
    
}

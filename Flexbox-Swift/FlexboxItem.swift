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
    
    var flex: (flexGrow: Float, flexShrink: Float, flexBasis: FlexBasis) {
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
    
    var flexBasis = FlexBasis.auto
    
    var alignSelf = Flexbox.AlignSelf.auto
    
    var flexMargin =  FlexboxInsets.zero
    
    var flexFrame: FlexboxRect?
    
    weak var delegate: FlexboxItemDelegate?
    
    enum FlexBasis {
        
        case auto
        
        case ratio(Float)
        
        case pixel(Float)
    }

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
    
    func onMeasure(direction: Flexbox.Direction, containerDimension: FlexboxSize) {
        var size = FlexboxSize.zero
        switch flexBasis {
        case .auto:
            switch direction {
            case .row, .rowReverse:
                size = delegate?.onMeasure(containerDimension) ?? FlexboxSize.zero
            case .column, .columnReverse:
                size = delegate?.onMeasure(containerDimension) ?? FlexboxSize.zero
            }
        case .ratio(let val):
            switch direction {
            case .row, .rowReverse:
                let reference = val * containerDimension.w
                size = delegate?.onMeasure(FlexboxSize(w: reference , h: 0)) ?? FlexboxSize.zero
                size.w = max(size.w, reference)
            case .column, .columnReverse:
                let reference = val * containerDimension.h
                size = delegate?.onMeasure(FlexboxSize(w: 0, h: reference)) ?? FlexboxSize.zero
                size.h = max(size.h, reference)
            }
        case .pixel(let val):
            switch direction {
            case .row, .rowReverse:
                size = delegate?.onMeasure(FlexboxSize(w: val, h: 0)) ?? FlexboxSize.zero
                size.w = max(size.w, val)
            case .column, .columnReverse:
                size = delegate?.onMeasure(FlexboxSize(w: 0, h: val)) ?? FlexboxSize.zero
                size.h = max(size.h, val)
            }
        }
        flexFrame = FlexboxRect(x: 0, y: 0, w: size.w, h: size.h)
    }
    
    func reMeasure() {
        if let size = delegate?.onMeasure(flexFrame?.size ?? FlexboxSize.zero) {
            flexFrame?.size = size
        }
    }
}

extension FlexboxItem: CustomDebugStringConvertible {
    
    var debugDescription: String {
        return "flexOrder: \(flexOrder)\nflexGrow: \(flexGrow)\nflexShrink: \(flexShrink)\nflexBasis: \(String(describing: flexBasis))\nflexMargin: (\(flexMargin.top),\(flexMargin.left),\(flexMargin.bottom),\(flexMargin.right))\nflexFrame: (\(flexFrame?.x ?? 0),\(flexFrame?.y ?? 0),\(flexFrame?.w ?? 0),\(flexFrame?.h ?? 0))"
    }
    
}

extension FlexboxItem {
    
    func fixGrowAndShrinkInAxis(arrangement: FlexboxArrangement, growOffset: Float?, shrinkOffset: Float?, fixedAxisOffset: inout Float, fixedCrossDimension: inout Float) {
        if arrangement.isHorizontal {
            if let growOffset = growOffset {
                flexFrame?.w += growOffset
                if arrangement.isAxisReverse {
                    flexFrame?.x -= growOffset
                }
                fixedAxisOffset += arrangement.axisRatio * growOffset
            } else if let shrinkOffset = shrinkOffset {
                let ow = flexFrame?.w ?? 0
                flexFrame?.w -= shrinkOffset
                reMeasure()
                if flexFrame?.w ?? 0 < ow - shrinkOffset {
                    flexFrame?.w = ow - shrinkOffset
                }
                let deltaOffset = ow - (flexFrame?.w ?? 0)
                fixedCrossDimension = max(fixedCrossDimension, flexFrame?.h ?? 0)
                if arrangement.isAxisReverse {
                    flexFrame?.x += deltaOffset
                }
                fixedAxisOffset -= arrangement.axisRatio * deltaOffset
            }
        } else {
            if let growOffset = growOffset {
                flexFrame?.h += growOffset
                if arrangement.isAxisReverse {
                    flexFrame?.y -= growOffset
                }
                fixedAxisOffset += arrangement.axisRatio * growOffset
            } else if let shrinkOffset = shrinkOffset {
                let oh = flexFrame?.h ?? 0
                flexFrame?.h -= shrinkOffset
                reMeasure()
                if flexFrame?.h ?? 0 < oh - shrinkOffset {
                    flexFrame?.h = oh - shrinkOffset
                }
                let deltaOffset = oh - (flexFrame?.h ?? 0)
                fixedCrossDimension = max(fixedCrossDimension, flexFrame?.w ?? 0)
                if arrangement.isAxisReverse {
                    flexFrame?.y += deltaOffset
                }
                fixedAxisOffset -= arrangement.axisRatio * deltaOffset
            }
        }
    }
    
    func fixAlignmentInCross(arrangement: FlexboxArrangement, alignItems: Flexbox.AlignItems, dimensionOfCross: Float) {
        if flexFrame == nil {
            return
        }
        
        let alignment = alignSelf.toAlignItems() ?? alignItems
        if arrangement.isHorizontal {
            fixHorizontalAlignmentInCross(alignItems: alignment, dimensionOfCross: dimensionOfCross, isReverse: arrangement.isCrossReverse)
        } else {
            fixVerticalAlignmentInCross(alignItems: alignment, dimensionOfCross: dimensionOfCross, isReverse: arrangement.isCrossReverse)
        }
    }
    
    private func fixVerticalAlignmentInCross(alignItems: Flexbox.AlignItems, dimensionOfCross: Float, isReverse: Bool) {
        switch alignItems {
        case .start:
            if isReverse {
                let offsetX = flexFrame!.x - flexMargin.left + dimensionOfCross - flexMargin.right - flexFrame!.w
                flexFrame?.x = offsetX
            }
        case .end:
            if !isReverse {
                let offsetX = flexFrame!.x - flexMargin.left + dimensionOfCross - flexMargin.right - flexFrame!.w
                flexFrame?.x = offsetX
            }
        case .center:
            let offsetX = flexFrame!.x - flexMargin.left + (dimensionOfCross - flexWidth) * 0.5 + flexMargin.left
            flexFrame?.x = offsetX
        case .stretch:
            let offsetW = dimensionOfCross - flexMargin.left - flexMargin.right
            flexFrame?.w = offsetW
        case .baseline:break
        }
    }
    
    private func fixHorizontalAlignmentInCross(alignItems: Flexbox.AlignItems, dimensionOfCross: Float, isReverse: Bool) {
        switch alignItems {
        case .start:
            if isReverse {
                let offsetY = flexFrame!.y - flexMargin.top + dimensionOfCross - flexMargin.bottom - flexFrame!.h
                flexFrame?.y = offsetY
            }
        case .end:
            if !isReverse {
                let offsetY = flexFrame!.y - flexMargin.top + dimensionOfCross - flexMargin.bottom - flexFrame!.h
                flexFrame?.y = offsetY
            }
        case .center:
            let offsetY = flexFrame!.y - flexMargin.top + (dimensionOfCross - flexHeight) * 0.5 + flexMargin.top
            flexFrame?.y = offsetY
        case .stretch:
            let offsetH = dimensionOfCross - flexMargin.top - flexMargin.bottom
            flexFrame?.h = offsetH
        case .baseline:break
        }
    }
    
    fileprivate func fixHorizontalDistributionInAxis(justifyContent: Flexbox.JustifyContent, axisDimension: Float, containerDimension: FlexboxSize, itemIndex: Int, itemCount: Int, arrangement: FlexboxArrangement) {
        switch justifyContent {
        case .end:
            flexFrame?.x += arrangement.axisRatio * (containerDimension.w - axisDimension)
        case .center:
            flexFrame?.x += arrangement.axisRatio * (containerDimension.w - axisDimension) * 0.5
        case .spaceBetween:
            flexFrame?.x += arrangement.axisRatio * ((containerDimension.w - axisDimension) * Float(itemIndex) / Float(itemCount - 1))
        case .spaceAround:
            flexFrame?.x += arrangement.axisRatio * ((containerDimension.w - axisDimension) * (Float(itemIndex) + 0.5) / Float(itemCount))
        case .start: break
        }
    }
    
    fileprivate func fixVerticalDistributionInAxis(justifyContent: Flexbox.JustifyContent, axisDimension: Float, containerDimension: FlexboxSize, itemIndex: Int, itemCount: Int, arrangement: FlexboxArrangement) {
        switch justifyContent {
        case .end:
            flexFrame?.y += arrangement.axisRatio * (containerDimension.h - axisDimension)
        case .center:
            flexFrame?.y += arrangement.axisRatio * (containerDimension.h - axisDimension) * 0.5
        case .spaceBetween:
            flexFrame?.y += arrangement.axisRatio * ((containerDimension.h - axisDimension) * Float(itemIndex) / Float(itemCount - 1))
        case .spaceAround:
            flexFrame?.y += arrangement.axisRatio * ((containerDimension.h - axisDimension) * (Float(itemIndex) + 0.5) / Float(itemCount))
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
                item.fixHorizontalDistributionInAxis(justifyContent: mFlexJustifyConent, axisDimension: axisDimension, containerDimension: containerDimension, itemIndex: index, itemCount: count, arrangement: arrangement)
            } else {
                item.fixVerticalDistributionInAxis(justifyContent: mFlexJustifyConent, axisDimension: axisDimension, containerDimension: containerDimension, itemIndex: index, itemCount: count, arrangement: arrangement)
            }
        }
    }
    
    private func fixHorizontalDistributionInCross(arrangement: FlexboxArrangement, alignContent: Flexbox.AlignContent, alignItems: Flexbox.AlignItems, dimensionsOfCross: [Float], flexContainerDimension: FlexboxSize, dimensionOfCurrentCross: Float, indexesOfAxisForItems: [Int: Int]) {
        if !(alignContent == .start && alignItems == .start) {
            var mAlignContent = alignContent
            if (mAlignContent == .spaceBetween || mAlignContent == .spaceAround) && dimensionsOfCross.count == 1 {
                mAlignContent = .center
            }
            let contentHeight = dimensionsOfCross.reduce(0, +)
            enumerated().forEach { (offset, item) in
                guard let lineIndex = indexesOfAxisForItems[offset] else {
                    return
                }
                var dimensionOfCross = dimensionsOfCross[lineIndex]
                if arrangement.isCrossReverse {
                    let reverseOffsetY = dimensionOfCross - (item.flexFrame?.h ?? 0) - item.flexMargin.top
                    item.flexFrame?.y -= reverseOffsetY
                }
                
                switch mAlignContent {
                case .start: break
                case .end:
                    item.flexFrame?.y += arrangement.crossRatio * (flexContainerDimension.h - contentHeight)
                case .center:
                    item.flexFrame?.y += arrangement.crossRatio * ((flexContainerDimension.h - contentHeight) * 0.5)
                case .spaceBetween:
                    item.flexFrame?.y += arrangement.crossRatio * ((flexContainerDimension.h - contentHeight) * Float(lineIndex) / Float(dimensionsOfCross.count - 1))
                case .spaceAround:
                    item.flexFrame?.y += arrangement.crossRatio * ((flexContainerDimension.h - contentHeight) * (Float(lineIndex) + 0.5) / Float(dimensionsOfCross.count))
                case .stretch:
                    var stretchOffsetY = Float(0)
                    for stretchLineIndex in 0..<(arrangement.isCrossReverse ? lineIndex + 1 : lineIndex) {
                        stretchOffsetY += dimensionsOfCross[stretchLineIndex]
                    }
                    item.flexFrame?.y += arrangement.crossRatio * (stretchOffsetY * flexContainerDimension.h / contentHeight - stretchOffsetY)
                    dimensionOfCross += (flexContainerDimension.h - contentHeight) * (dimensionOfCross / contentHeight)
                }
                item.fixAlignmentInCross(arrangement: arrangement, alignItems: alignItems, dimensionOfCross: dimensionOfCross)
            }
        }
    }
    
    private func fixVerticalDistributionInCross(arrangement: FlexboxArrangement, alignContent: Flexbox.AlignContent, alignItems: Flexbox.AlignItems, dimensionsOfCross: [Float], flexContainerDimension: FlexboxSize, dimensionOfCurrentCross: Float, indexesOfAxisForItems: [Int: Int]) {
        if !(alignContent == .start && alignItems == .start) {
            var mAlignContent = alignContent
            if (mAlignContent == .spaceBetween || mAlignContent == .spaceAround) && dimensionsOfCross.count == 1 {
                mAlignContent = .center
            }
            let contentWidth = dimensionsOfCross.reduce(0, +)
            enumerated().forEach { (offset, item) in
                guard let lineIndex = indexesOfAxisForItems[offset] else {
                    return
                }
                var dimensionOfCross = dimensionsOfCross[lineIndex]
                if arrangement.isCrossReverse {
                    let reverseOffsetX = dimensionOfCross - (item.flexFrame?.w ?? 0) - item.flexMargin.left
                    item.flexFrame?.x -= reverseOffsetX
                }
                
                switch mAlignContent {
                case .start: break
                case .end:
                    item.flexFrame?.x += arrangement.crossRatio * (flexContainerDimension.w - contentWidth)
                case .center:
                    item.flexFrame?.x += arrangement.crossRatio * ((flexContainerDimension.w - contentWidth) * 0.5)
                case .spaceBetween:
                    item.flexFrame?.x += arrangement.crossRatio * ((flexContainerDimension.w - contentWidth) * Float(lineIndex) / Float(dimensionsOfCross.count - 1))
                case .spaceAround:
                    item.flexFrame?.x += arrangement.crossRatio * ((flexContainerDimension.w - contentWidth) * (Float(lineIndex) + 0.5) / Float(dimensionsOfCross.count))
                case .stretch:
                    var stretchOffsetX = Float(0)
                    for stretchLineIndex in 0..<(arrangement.isCrossReverse ? lineIndex + 1 : lineIndex) {
                        stretchOffsetX += dimensionsOfCross[stretchLineIndex]
                    }
                    item.flexFrame?.x += arrangement.crossRatio * (stretchOffsetX * flexContainerDimension.w / contentWidth - stretchOffsetX)
                    dimensionOfCross += (flexContainerDimension.w - contentWidth) * (dimensionOfCross / contentWidth)
                }
                item.fixAlignmentInCross(arrangement: arrangement, alignItems: alignItems, dimensionOfCross: dimensionOfCross)
            }
        }
    }
}

protocol FlexboxItemDelegate: class {
    
    func onMeasure(_ size: FlexboxSize) -> FlexboxSize
}

//
//  FlexboxItem.swift
//  Flexbox-Swift
//
//  Created by Jerry on 2018/5/24.
//  Copyright © 2018年 com.jerry. All rights reserved.
//

struct FlexboxItem {
    
    init(onMeasure: ((FlexboxSize) -> FlexboxSize)?) {
        self.onMeasure = onMeasure
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
    
    var onMeasure: ((FlexboxSize) -> FlexboxSize)?
    
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
    
    func onMeasure(direction: Flexbox.Direction, containerDimension: FlexboxSize) -> FlexboxSize {
        var size = FlexboxSize.zero
        switch flexBasis {
        case .auto:
            switch direction {
            case .row, .rowReverse:
                size = onMeasure?(containerDimension) ?? FlexboxSize.zero
            case .column, .columnReverse:
                size = onMeasure?(containerDimension) ?? FlexboxSize.zero
            }
        case .ratio(let val):
            switch direction {
            case .row, .rowReverse:
                let reference = val * containerDimension.w
                size = onMeasure?(FlexboxSize(w: reference , h: 0)) ?? FlexboxSize.zero
                size.w = max(size.w, reference)
            case .column, .columnReverse:
                let reference = val * containerDimension.h
                size = onMeasure?(FlexboxSize(w: 0, h: reference)) ?? FlexboxSize.zero
                size.h = max(size.h, reference)
            }
        case .pixel(let val):
            switch direction {
            case .row, .rowReverse:
                size = onMeasure?(FlexboxSize(w: val, h: 0)) ?? FlexboxSize.zero
                size.w = max(size.w, val)
            case .column, .columnReverse:
                size = onMeasure?(FlexboxSize(w: 0, h: val)) ?? FlexboxSize.zero
                size.h = max(size.h, val)
            }
        }
        return size
    }
    
    func reMeasure() -> FlexboxItem {
        var ret = self
        if let size = onMeasure?(flexFrame?.size ?? FlexboxSize.zero) {
            ret.flexFrame?.size = size
        }
        return ret
    }
}

extension FlexboxItem: CustomDebugStringConvertible {
    
    var debugDescription: String {
        return "{flexOrder: \(flexOrder), flexGrow: \(flexGrow), flexShrink: \(flexShrink), flexBasis: \(String(describing: flexBasis)), flexMargin: (\(flexMargin.top),\(flexMargin.left),\(flexMargin.bottom),\(flexMargin.right)), flexFrame: (\(flexFrame?.x ?? 0),\(flexFrame?.y ?? 0),\(flexFrame?.w ?? 0),\(flexFrame?.h ?? 0))}"
    }
    
}

extension FlexboxItem {
    
    func fixGrowAndShrinkInAxis(arrangement: FlexboxArrangement, growOffset: Float?, shrinkOffset: Float?, fixedAxisOffset: inout Float, fixedCrossDimension: inout Float) -> FlexboxItem {
        var ret = self
        if arrangement.isHorizontal {
            if let growOffset = growOffset {
                ret.flexFrame?.w += growOffset
                if arrangement.isAxisReverse {
                    ret.flexFrame?.x -= growOffset
                }
                fixedAxisOffset += arrangement.axisRatio * growOffset
            } else if let shrinkOffset = shrinkOffset {
                let ow = flexFrame?.w ?? 0
                ret.flexFrame?.w -= shrinkOffset
                ret = ret.reMeasure()
                if ret.flexFrame?.w ?? 0 < ow - shrinkOffset {
                    ret.flexFrame?.w = ow - shrinkOffset
                }
                let deltaOffset = ow - (ret.flexFrame?.w ?? 0)
                fixedCrossDimension = max(fixedCrossDimension, ret.flexFrame?.h ?? 0)
                if arrangement.isAxisReverse {
                    ret.flexFrame?.x += deltaOffset
                }
                fixedAxisOffset -= arrangement.axisRatio * deltaOffset
            }
        } else {
            if let growOffset = growOffset {
                ret.flexFrame?.h += growOffset
                if arrangement.isAxisReverse {
                    ret.flexFrame?.y -= growOffset
                }
                fixedAxisOffset += arrangement.axisRatio * growOffset
            } else if let shrinkOffset = shrinkOffset {
                let oh = flexFrame?.h ?? 0
                ret.flexFrame?.h -= shrinkOffset
                ret = ret.reMeasure()
                if ret.flexFrame?.h ?? 0 < oh - shrinkOffset {
                    ret.flexFrame?.h = oh - shrinkOffset
                }
                let deltaOffset = oh - (ret.flexFrame?.h ?? 0)
                fixedCrossDimension = max(fixedCrossDimension, ret.flexFrame?.w ?? 0)
                if arrangement.isAxisReverse {
                    ret.flexFrame?.y += deltaOffset
                }
                fixedAxisOffset -= arrangement.axisRatio * deltaOffset
            }
        }
        return ret
    }
    
    func fixAlignmentInCross(arrangement: FlexboxArrangement, alignItems: Flexbox.AlignItems, dimensionOfCross: Float) -> FlexboxItem {
        if flexFrame == nil {
            return self
        }
        
        let alignment = alignSelf.toAlignItems() ?? alignItems
        return arrangement.isHorizontal
            ?
                fixHorizontalAlignmentInCross(alignItems: alignment, dimensionOfCross: dimensionOfCross, isReverse: arrangement.isCrossReverse)
            :
                fixVerticalAlignmentInCross(alignItems: alignment, dimensionOfCross: dimensionOfCross, isReverse: arrangement.isCrossReverse)
    }
    
    private func fixVerticalAlignmentInCross(alignItems: Flexbox.AlignItems, dimensionOfCross: Float, isReverse: Bool) -> FlexboxItem {
        var ret = self
        switch alignItems {
        case .start:
            if isReverse {
                let offsetX = flexFrame!.x - flexMargin.left + dimensionOfCross - flexMargin.right - flexFrame!.w
                ret.flexFrame?.x = offsetX
            }
        case .end:
            if !isReverse {
                let offsetX = flexFrame!.x - flexMargin.left + dimensionOfCross - flexMargin.right - flexFrame!.w
                ret.flexFrame?.x = offsetX
            }
        case .center:
            let offsetX = flexFrame!.x - flexMargin.left + (dimensionOfCross - flexWidth) * 0.5 + flexMargin.left
            ret.flexFrame?.x = offsetX
        case .stretch:
            let offsetW = dimensionOfCross - flexMargin.left - flexMargin.right
            ret.flexFrame?.w = offsetW
        case .baseline:break
        }
        return ret
    }
    
    private func fixHorizontalAlignmentInCross(alignItems: Flexbox.AlignItems, dimensionOfCross: Float, isReverse: Bool) -> FlexboxItem {
        var ret = self
        switch alignItems {
        case .start:
            if isReverse {
                let offsetY = flexFrame!.y - flexMargin.top + dimensionOfCross - flexMargin.bottom - flexFrame!.h
                ret.flexFrame?.y = offsetY
            }
        case .end:
            if !isReverse {
                let offsetY = flexFrame!.y - flexMargin.top + dimensionOfCross - flexMargin.bottom - flexFrame!.h
                ret.flexFrame?.y = offsetY
            }
        case .center:
            let offsetY = flexFrame!.y - flexMargin.top + (dimensionOfCross - flexHeight) * 0.5 + flexMargin.top
            ret.flexFrame?.y = offsetY
        case .stretch:
            let offsetH = dimensionOfCross - flexMargin.top - flexMargin.bottom
            ret.flexFrame?.h = offsetH
        case .baseline:break
        }
        return ret
    }
    
    fileprivate func fixDistributionInAxis(direction: Flexbox.Direction, justifyContent: Flexbox.JustifyContent, axisDimension: Float, containerDimension: FlexboxSize, itemIndex: Int, itemCount: Int, arrangement: FlexboxArrangement) -> FlexboxItem {
        guard var origin = flexFrame?.origin else {
            return self
        }
        var ret = self
        Flexbox.Context.direction = direction
        
        let originAxisDim = origin.axisVal
        let containerDim = containerDimension.axisVal
        
        switch justifyContent {
        case .end:
            origin.axisVal = originAxisDim + arrangement.axisRatio * (containerDim - axisDimension)
        case .center:
            origin.axisVal = originAxisDim + arrangement.axisRatio * (containerDim - axisDimension) * 0.5
        case .spaceBetween:
            origin.axisVal = originAxisDim + arrangement.axisRatio * (containerDim - axisDimension) * Float(itemIndex) / Float(itemCount - 1)
        case .spaceAround:
            origin.axisVal = originAxisDim + arrangement.axisRatio * (containerDim - axisDimension) * (Float(itemIndex) + 0.5) / Float(itemCount)
        case .start: break
        }
        ret.flexFrame?.origin = origin
        return ret
    }
}

extension Array where Element == FlexboxItem {
    
    func fixDistributionInCross(arrangement: FlexboxArrangement, alignContent: Flexbox.AlignContent, alignItems: Flexbox.AlignItems, dimensionsOfCross: [Float], flexContainerDimension: FlexboxSize, dimensionOfCurrentCross: Float, indexesOfAxisForItems: [Int: Int]) -> Array {
        return arrangement.isHorizontal
            ?
                fixHorizontalDistributionInCross(arrangement: arrangement, alignContent: alignContent, alignItems: alignItems, dimensionsOfCross: dimensionsOfCross, flexContainerDimension: flexContainerDimension, dimensionOfCurrentCross: dimensionOfCurrentCross, indexesOfAxisForItems: indexesOfAxisForItems)
            :
                fixVerticalDistributionInCross(arrangement: arrangement, alignContent: alignContent, alignItems: alignItems, dimensionsOfCross: dimensionsOfCross, flexContainerDimension: flexContainerDimension, dimensionOfCurrentCross: dimensionOfCurrentCross, indexesOfAxisForItems: indexesOfAxisForItems)
    }
    
    func fixDistributionInAxis(arrangement: FlexboxArrangement, justifyContent: Flexbox.JustifyContent, containerDimension: FlexboxSize, axisDimension: Float) -> Array {
        if justifyContent == .start {
            return self
        }
        
        var mFlexJustifyConent = justifyContent
        if count == 1 && (mFlexJustifyConent == .spaceBetween || mFlexJustifyConent == .spaceAround) {
            mFlexJustifyConent = .center
        }
        
        return enumerated().map {
            $0.element.fixDistributionInAxis(direction: arrangement.direction, justifyContent: mFlexJustifyConent, axisDimension: axisDimension, containerDimension: containerDimension, itemIndex: $0.offset, itemCount: count, arrangement: arrangement)
        }
    }
    
    private func fixHorizontalDistributionInCross(arrangement: FlexboxArrangement, alignContent: Flexbox.AlignContent, alignItems: Flexbox.AlignItems, dimensionsOfCross: [Float], flexContainerDimension: FlexboxSize, dimensionOfCurrentCross: Float, indexesOfAxisForItems: [Int: Int]) -> Array {
        var ret = self
        if !(alignContent == .start && alignItems == .start) {
            var mAlignContent = alignContent
            if (mAlignContent == .spaceBetween || mAlignContent == .spaceAround) && dimensionsOfCross.count == 1 {
                mAlignContent = .center
            }
            let contentHeight = dimensionsOfCross.reduce(0, +)
            if contentHeight != 0 {
                ret = enumerated().map { (offset, item) -> Element in
                    guard let lineIndex = indexesOfAxisForItems[offset] else {
                        return item
                    }
                    var mItem = item
                    var dimensionOfCross = dimensionsOfCross[lineIndex]
                    if arrangement.isCrossReverse {
                        let reverseOffsetY = dimensionOfCross - (mItem.flexFrame?.h ?? 0) - mItem.flexMargin.top
                        mItem.flexFrame?.y -= reverseOffsetY
                    }
                    
                    switch mAlignContent {
                    case .start: break
                    case .end:
                        mItem.flexFrame?.y += arrangement.crossRatio * (flexContainerDimension.h - contentHeight)
                    case .center:
                        mItem.flexFrame?.y += arrangement.crossRatio * ((flexContainerDimension.h - contentHeight) * 0.5)
                    case .spaceBetween:
                        mItem.flexFrame?.y += arrangement.crossRatio * ((flexContainerDimension.h - contentHeight) * Float(lineIndex) / Float(dimensionsOfCross.count - 1))
                    case .spaceAround:
                        mItem.flexFrame?.y += arrangement.crossRatio * ((flexContainerDimension.h - contentHeight) * (Float(lineIndex) + 0.5) / Float(dimensionsOfCross.count))
                    case .stretch:
                        var stretchOffsetY = Float(0)
                        for stretchLineIndex in 0..<(arrangement.isCrossReverse ? lineIndex + 1 : lineIndex) {
                            stretchOffsetY += dimensionsOfCross[stretchLineIndex]
                        }
                        mItem.flexFrame?.y += arrangement.crossRatio * (stretchOffsetY * flexContainerDimension.h / contentHeight - stretchOffsetY)
                        dimensionOfCross += (flexContainerDimension.h - contentHeight) * (dimensionOfCross / contentHeight)
                    }
                    return mItem.fixAlignmentInCross(arrangement: arrangement, alignItems: alignItems, dimensionOfCross: dimensionOfCross)
                }
            }
        }
        return ret
    }
    
    private func fixVerticalDistributionInCross(arrangement: FlexboxArrangement, alignContent: Flexbox.AlignContent, alignItems: Flexbox.AlignItems, dimensionsOfCross: [Float], flexContainerDimension: FlexboxSize, dimensionOfCurrentCross: Float, indexesOfAxisForItems: [Int: Int]) -> Array {
        var ret = self
        if !(alignContent == .start && alignItems == .start) {
            var mAlignContent = alignContent
            if (mAlignContent == .spaceBetween || mAlignContent == .spaceAround) && dimensionsOfCross.count == 1 {
                mAlignContent = .center
            }
            let contentWidth = dimensionsOfCross.reduce(0, +)
            if contentWidth != 0 {
                ret = enumerated().map({ (offset, item) -> Element in
                    guard let lineIndex = indexesOfAxisForItems[offset] else {
                        return item
                    }
                    var mItem = item
                    var dimensionOfCross = dimensionsOfCross[lineIndex]
                    if arrangement.isCrossReverse {
                        let reverseOffsetX = dimensionOfCross - (mItem.flexFrame?.w ?? 0) - mItem.flexMargin.left
                        mItem.flexFrame?.x -= reverseOffsetX
                    }
                    
                    switch mAlignContent {
                    case .start: break
                    case .end:
                        mItem.flexFrame?.x += arrangement.crossRatio * (flexContainerDimension.w - contentWidth)
                    case .center:
                        mItem.flexFrame?.x += arrangement.crossRatio * ((flexContainerDimension.w - contentWidth) * 0.5)
                    case .spaceBetween:
                        mItem.flexFrame?.x += arrangement.crossRatio * ((flexContainerDimension.w - contentWidth) * Float(lineIndex) / Float(dimensionsOfCross.count - 1))
                    case .spaceAround:
                        mItem.flexFrame?.x += arrangement.crossRatio * ((flexContainerDimension.w - contentWidth) * (Float(lineIndex) + 0.5) / Float(dimensionsOfCross.count))
                    case .stretch:
                        var stretchOffsetX = Float(0)
                        for stretchLineIndex in 0..<(arrangement.isCrossReverse ? lineIndex + 1 : lineIndex) {
                            stretchOffsetX += dimensionsOfCross[stretchLineIndex]
                        }
                        mItem.flexFrame?.x += arrangement.crossRatio * (stretchOffsetX * flexContainerDimension.w / contentWidth - stretchOffsetX)
                        dimensionOfCross += (flexContainerDimension.w - contentWidth) * (dimensionOfCross / contentWidth)
                    }
                    return mItem.fixAlignmentInCross(arrangement: arrangement, alignItems: alignItems, dimensionOfCross: dimensionOfCross)
                })
            }
        }
        return ret
    }
}

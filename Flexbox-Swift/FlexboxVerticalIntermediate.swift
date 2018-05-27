//
//  FlexboxVerticalIntermediate.swift
//  Flexbox-Swift
//
//  Created by Jerry on 2018/5/24.
//  Copyright © 2018年 com.jerry. All rights reserved.
//

struct FlexboxVerticalIntermediate {
    
    let flexContainerDimension: FlexboxSize
    
    let flexWrap: Flexbox.Wrap
    
    let flexAlignItems: Flexbox.AlignItems
    
    let flexAlignContent: Flexbox.AlignContent
    
    let flexJustifyContent: Flexbox.JustifyContent
    
    var cursor = FlexboxPoint.zero
    
    var dimensionOfCurrentCross = Float(0)
    
    var indexOfItemsInCurrentAxis = -1
    
    var growOfItemsInCurrentAxis = [Int: Float]()
    
    var shrinkOfItemsInCurrentAxis = [Int: Float]()
    
    var indexesOfAxisForItems = [Int: Int]()
    
    var dimensionsOfCross = [Float]()
    
    init(alignItems: Flexbox.AlignItems, alignContent: Flexbox.AlignContent, wrap: Flexbox.Wrap, justifyContent: Flexbox.JustifyContent, containerSize: FlexboxSize) {
        flexAlignItems = alignItems
        flexAlignContent = alignContent
        flexWrap = wrap
        flexContainerDimension = containerSize
        flexJustifyContent = justifyContent
    }
    
    mutating func prepare(_ item: FlexboxItem) -> Bool {
        indexOfItemsInCurrentAxis += 1
        measure(item)
        let shouldWrap = flexWrap.isWrapEnabled && cursor.y + item.flexHeight > flexContainerDimension.h
        if shouldWrap {
            dimensionsOfCross.append(dimensionOfCurrentCross)
        }
        return shouldWrap && indexOfItemsInCurrentAxis > 0
    }
    
    mutating func wrap() {
        cursor.x += dimensionOfCurrentCross
        indexOfItemsInCurrentAxis = 0
        dimensionOfCurrentCross = Float(0)
        cursor.y = Float(0)
        growOfItemsInCurrentAxis.removeAll()
        shrinkOfItemsInCurrentAxis.removeAll()
    }
    
    mutating func move(_ item: FlexboxItem) {
        item.flexFrame!.x = cursor.x + item.flexMargin.left
        item.flexFrame!.y = cursor.y + item.flexMargin.top
        
        cursor.y += item.flexHeight
        dimensionOfCurrentCross = max(dimensionOfCurrentCross, item.flexWidth)
        
        if item.flexGrow > 0 {
            growOfItemsInCurrentAxis[indexOfItemsInCurrentAxis] = item.flexGrow
        }
        if item.flexShrink > 0 {
            shrinkOfItemsInCurrentAxis[indexOfItemsInCurrentAxis] = item.flexShrink
        }
    }
    
    func fix(_ items: [FlexboxItem]) {
        let growAndShrinkVal = calculateGrowAndShrink()
        var fixedAxisOffset = Float(0)
        var itemsAxisDimension = Float(0)
        items.enumerated().forEach { (index, item) in
            item.flexFrame?.y += fixedAxisOffset
            fixCrossAlignmentForItem(item)
            if let growOffset = growAndShrinkVal.growValInLine?[index] {
                item.flexFrame?.h += growOffset
                fixedAxisOffset += growOffset
            } else if let shrinkOffset = growAndShrinkVal.shrinkValInLine?[index] {
                item.flexFrame?.h -= shrinkOffset
                fixedAxisOffset -= shrinkOffset
            }
            itemsAxisDimension += item.flexHeight
        }
        if growAndShrinkVal.growValInLine == nil && growAndShrinkVal.shrinkValInLine == nil {
            fixAxisDistributionForItems(items, axisDimension: itemsAxisDimension)
        }
    }
    
    mutating func finalize(_ items: [FlexboxItem]) {
        dimensionsOfCross.append(dimensionOfCurrentCross)
        if dimensionsOfCross.count == 1 {
            items.forEach { item in
                item.flexFrame?.x += (flexContainerDimension.w - dimensionOfCurrentCross) * 0.5
            }
        } else if flexAlignContent != .start {
            let contentWidth = dimensionsOfCross.reduce(0, +)
            items.enumerated().forEach { (offset, item) in
                switch flexAlignContent {
                case .start: break
                case .end:
                    item.flexFrame?.x += flexContainerDimension.w - contentWidth
                case .center:
                    item.flexFrame?.x += (flexContainerDimension.w - contentWidth) * 0.5
                case .spaceBetween:
                    if let lineIndex = indexesOfAxisForItems[offset] {
                        item.flexFrame?.x += (flexContainerDimension.w - contentWidth) * Float(lineIndex) / Float(dimensionsOfCross.count - 1)
                    }
                case .spaceAround:
                    if let lineIndex = indexesOfAxisForItems[offset] {
                        item.flexFrame?.x += (flexContainerDimension.w - contentWidth) * (Float(lineIndex) + 0.5) / Float(dimensionsOfCross.count)
                    }
                case .stretch:
                    if let lineIndex = indexesOfAxisForItems[offset] {
                        var stretchOffsetX = Float(0)
                        for stretchLineIndex in 0..<lineIndex {
                            stretchOffsetX += dimensionsOfCross[stretchLineIndex]
                        }
                        item.flexFrame?.x += (stretchOffsetX * flexContainerDimension.w / contentWidth - stretchOffsetX)
                    }
                }
            }
        }
    }
}

extension FlexboxVerticalIntermediate {
    
    private func fixCrossAlignmentForItem(_ item: FlexboxItem) {
        let alignment = item.alignSelf.toAlignItems() ?? flexAlignItems
        switch alignment {
        case .start: break
        case .end: item.flexFrame!.x = cursor.x + dimensionOfCurrentCross - item.flexMargin.right - item.flexFrame!.w
        case .center: item.flexFrame!.x = cursor.x + (dimensionOfCurrentCross - item.flexWidth) * 0.5 + item.flexMargin.left
        case .stretch: item.flexFrame!.w = dimensionOfCurrentCross - item.flexMargin.left - item.flexMargin.right
        case .baseline:break
        }
    }
    
    private func measure(_ item: FlexboxItem) {
        var size = FlexboxSize.zero
        if let basis = item.flexBasis {
            size = item.onMeasure(FlexboxSize(w: 0, h: Float(basis)))
            size.h = max(size.h, Float(basis))
        } else {
            size = item.onMeasure(FlexboxSize.zero)
        }
        item.flexFrame = FlexboxRect(x: 0, y: 0, w: size.w, h: size.h)
    }
    
    private func calculateGrowAndShrink()  -> (growValInLine: [Int: Float]?, shrinkValInLine: [Int: Float]?){
        var growValInLine: [Int: Float]? = nil
        var shrinkValInLine: [Int: Float]? = nil
        
        let lengthToFix = cursor.y - flexContainerDimension.h
        if lengthToFix > 0 {
            let shrinkSum = shrinkOfItemsInCurrentAxis.reduce(0, {$0 + $1.value})
            if shrinkSum > 0 {
                shrinkValInLine = shrinkOfItemsInCurrentAxis.reduce(into: [Int: Float](), { $0[$1.key] = $1.value * lengthToFix / shrinkSum})
            }
        } else if lengthToFix < 0 {
            let growSum = growOfItemsInCurrentAxis.reduce(0, {$0 + $1.value})
            if growSum > 0 {
                growValInLine = growOfItemsInCurrentAxis.reduce(into: [Int: Float](), { $0[$1.key] = $1.value * (-lengthToFix) / growSum})
            }
        }
        return (growValInLine, shrinkValInLine)
    }
    
    private func fixAxisDistributionForItems(_ items: [FlexboxItem], axisDimension: Float) {
        if flexJustifyContent == .start {
            return
        }
        
        var mFlexJustifyConent = flexJustifyContent
        if items.count == 1 && (mFlexJustifyConent == .spaceBetween || mFlexJustifyConent == .spaceAround) {
            mFlexJustifyConent = .center
        }
        
        items.enumerated().forEach { (index, item) in
            switch mFlexJustifyConent {
            case .end:
                item.flexFrame?.y += flexContainerDimension.h - axisDimension
            case .center:
                item.flexFrame?.y += (flexContainerDimension.h - axisDimension) * 0.5
            case .spaceBetween:
                item.flexFrame?.y += (flexContainerDimension.h - axisDimension) * Float(index) / Float(items.count - 1)
            case .spaceAround:
                item.flexFrame?.y += (flexContainerDimension.h - axisDimension) * (Float(index) + 0.5) / Float(items.count)
            case .start: break
            }
        }
    }
}

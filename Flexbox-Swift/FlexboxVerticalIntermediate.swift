//
//  FlexboxVerticalIntermediate.swift
//  Flexbox-Swift
//
//  Created by Jerry on 2018/5/24.
//  Copyright © 2018年 com.jerry. All rights reserved.
//

struct FlexboxVerticalIntermediate: FlexboxIntermediate {
    
    var flexDirection = Flexbox.Direction.column
    
    var flexContainerDimension = FlexboxSize.zero
    
    var flexWrap = Flexbox.Wrap.nowrap
    
    var flexAlignItems = Flexbox.AlignItems.stretch
    
    var flexAlignContent = Flexbox.AlignContent.start
    
    var flexJustifyContent = Flexbox.JustifyContent.start
    
    var cursor = FlexboxPoint.zero
    
    var dimensionOfCurrentCross = Float(0)
    
    var indexOfItemsInCurrentAxis = -1
    
    var growOfItemsInCurrentAxis = [Int: Float]()
    
    var shrinkOfItemsInCurrentAxis = [Int: Float]()
    
    var indexesOfAxisForItems = [Int: Int]()
    
    var dimensionsOfCross = [Float]()
    
    var intrinsicSize = FlexboxSize.zero
    
    var flexDebugTag: String?
    
    var flexIsMeasuring = false
    
    init() {}
    
    mutating func fixInAxis(_ items: [FlexboxItem], shouldAppendAxisDimension: Bool) {
        var itemsAxisDimension = Float(0)
        let growAndShrinkVal = calculateGrowAndShrink(dimensionToFix: { flexboxArrangement.isAxisReverse ? (-cursor.y) : (cursor.y - flexContainerDimension.h) })
        var fixedAxisOffset = Float(0)
        items.enumerated().forEach { (index, item) in
            item.flexFrame?.y += fixedAxisOffset
            item.fixGrowAndShrinkInAxis(arrangement: flexboxArrangement, growOffset: growAndShrinkVal.growValInLine?[index], shrinkOffset: growAndShrinkVal.shrinkValInLine?[index], fixedAxisOffset: &fixedAxisOffset, fixedCrossDimension: &dimensionOfCurrentCross)
            itemsAxisDimension += item.flexHeight
        }
        if growAndShrinkVal.growValInLine == nil && growAndShrinkVal.shrinkValInLine == nil && !flexIsMeasuring {
            items.fixDistributionInAxis(arrangement: flexboxArrangement, justifyContent: flexJustifyContent, containerDimension: flexContainerDimension, axisDimension: itemsAxisDimension)
        }
        
        if shouldAppendAxisDimension {
            dimensionsOfCross.append(dimensionOfCurrentCross)
        } else {
            dimensionsOfCross.removeLast()
            dimensionsOfCross.append(dimensionOfCurrentCross)
        }
        intrinsicSize.h = max(intrinsicSize.h, itemsAxisDimension)
    }
    
    mutating func fixInCross(_ items: [FlexboxItem]) {
        cursor.x += flexboxArrangement.crossRatio * dimensionOfCurrentCross
        if flexboxArrangement.isCrossReverse {
            if  let firstItem = items.first,
                let firstItemFrame = firstItem.flexFrame,
                let firstCrossDimension = dimensionsOfCross.first {
                intrinsicSize.w = firstItemFrame.x - firstItem.flexMargin.left + firstCrossDimension - cursor.x
            } else {
                intrinsicSize.w = 0
            }
        } else {
            intrinsicSize.w = cursor.x
        }
        if !flexIsMeasuring {
            items.fixDistributionInCross(arrangement: flexboxArrangement, alignContent: flexAlignContent, alignItems: flexAlignItems, dimensionsOfCross: dimensionsOfCross, flexContainerDimension: flexContainerDimension, dimensionOfCurrentCross: dimensionOfCurrentCross, indexesOfAxisForItems: indexesOfAxisForItems)
        }
    }
}

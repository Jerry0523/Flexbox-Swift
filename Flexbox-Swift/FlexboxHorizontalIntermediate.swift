//
//  FlexboxHorizontalIntermediate.swift
//  Flexbox-Swift
//
//  Created by Jerry on 2018/5/24.
//  Copyright © 2018年 com.jerry. All rights reserved.
//

struct FlexboxHorizontalIntermediate: FlexboxIntermediate {
    
    var flexDirection = Flexbox.Direction.row
    
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
        let growAndShrinkVal = calculateGrowAndShrink(dimensionToFix: { flexboxArrangement.isAxisReverse ? (-cursor.x) : (cursor.x - flexContainerDimension.w) })
        var fixedAxisOffset = Float(0)
        items.enumerated().forEach { (index, item) in
            item.flexFrame?.x += fixedAxisOffset
            item.fixGrowAndShrinkInAxis(arrangement: flexboxArrangement, growOffset: growAndShrinkVal.growValInLine?[index], shrinkOffset: growAndShrinkVal.shrinkValInLine?[index], fixedAxisOffset: &fixedAxisOffset, fixedCrossDimension: &dimensionOfCurrentCross)
            itemsAxisDimension += item.flexWidth
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
        intrinsicSize.w = max(intrinsicSize.w, itemsAxisDimension)
    }
    
    mutating func fixInCross(_ items: [FlexboxItem]) {
        cursor.y += flexboxArrangement.crossRatio * dimensionOfCurrentCross
        if flexboxArrangement.isCrossReverse {
            if  let firstItem = items.first,
                let firstItemFrame = firstItem.flexFrame,
                let firstCrossDimension = dimensionsOfCross.first {
                intrinsicSize.h = firstItemFrame.y - firstItem.flexMargin.top + firstCrossDimension - cursor.y
            } else {
                intrinsicSize.h = 0
            }
            
        } else {
            intrinsicSize.h = cursor.y
        }
        if !flexIsMeasuring {
            items.fixDistributionInCross(arrangement: flexboxArrangement, alignContent: flexAlignContent, alignItems: flexAlignItems, dimensionsOfCross: dimensionsOfCross, flexContainerDimension: flexContainerDimension, dimensionOfCurrentCross: dimensionOfCurrentCross, indexesOfAxisForItems: indexesOfAxisForItems)
        }
    }
}

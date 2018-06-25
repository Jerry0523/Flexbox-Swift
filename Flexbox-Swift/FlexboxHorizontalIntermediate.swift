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
    
    var flexboxArrangement: FlexboxArrangement {
        get {
            return FlexboxArrangement(isHorizontal: true, isAxisReverse: flexDirection == .rowReverse, isCrossReverse: flexWrap == .wrapReverse)
        }
    }
    
    var cursor = FlexboxPoint.zero
    
    var dimensionOfCurrentCross = Float(0)
    
    var indexOfItemsInCurrentAxis = -1
    
    var growOfItemsInCurrentAxis = [Int: Float]()
    
    var shrinkOfItemsInCurrentAxis = [Int: Float]()
    
    var indexesOfAxisForItems = [Int: Int]()
    
    var dimensionsOfCross = [Float]()
    
    var intrinsicSize = FlexboxSize.zero
    
    var flexDebuggable = false
    
    init() {}
    
    mutating func intermediateDidLoad() {
        if flexboxArrangement.isCrossReverse {
            cursor.y = flexContainerDimension.h
        }
        if flexboxArrangement.isAxisReverse {
            cursor.x = flexContainerDimension.w
        }
    }
    
    mutating func prepare(_ item: FlexboxItem) -> Bool {
        indexOfItemsInCurrentAxis += 1
        item.onMeasure(direction: .row, containerDimension: flexContainerDimension)
        var shouldWrap = flexWrap.isWrapEnabled
        if flexboxArrangement.isAxisReverse {
            shouldWrap = shouldWrap && cursor.x - item.flexWidth < Flexbox.dimensionThreshold
        } else {
            shouldWrap = shouldWrap && cursor.x + item.flexWidth - flexContainerDimension.w > Flexbox.dimensionThreshold
        }
        if shouldWrap {
            dimensionsOfCross.append(dimensionOfCurrentCross)
        }
        return shouldWrap && indexOfItemsInCurrentAxis > 0
    }
    
    mutating func wrap() {
        cursor.y += flexboxArrangement.crossRatio * dimensionOfCurrentCross
        indexOfItemsInCurrentAxis = 0
        dimensionOfCurrentCross = Float(0)
        if flexboxArrangement.isAxisReverse {
            cursor.x = flexContainerDimension.w
        } else {
            cursor.x = Float(0)
        }
        growOfItemsInCurrentAxis.removeAll()
        shrinkOfItemsInCurrentAxis.removeAll()
    }
    
    mutating func move(_ item: FlexboxItem) {
        if flexboxArrangement.isAxisReverse {
            item.flexFrame!.x = cursor.x - item.flexMargin.right - item.flexFrame!.w
        } else {
            item.flexFrame!.x = cursor.x + item.flexMargin.left
        }
        if flexboxArrangement.isCrossReverse {
            item.flexFrame!.y = cursor.y - item.flexMargin.bottom - item.flexFrame!.h
        } else {
            item.flexFrame!.y = cursor.y + item.flexMargin.top
        }
        cursor.x += flexboxArrangement.axisRatio * item.flexWidth
        dimensionOfCurrentCross = max(dimensionOfCurrentCross, item.flexHeight)
        
        if item.flexGrow > 0 {
            growOfItemsInCurrentAxis[indexOfItemsInCurrentAxis] = item.flexGrow
        }
        if item.flexShrink > 0 {
            shrinkOfItemsInCurrentAxis[indexOfItemsInCurrentAxis] = item.flexShrink
        }
    }
    
    mutating func fixInAxis(_ items: [FlexboxItem], shouldAppendAxisDimension: Bool) {
        let growAndShrinkVal = calculateGrowAndShrink(dimensionToFix: { flexboxArrangement.isAxisReverse ? (-cursor.x) : (cursor.x - flexContainerDimension.w) })
        var fixedAxisOffset = Float(0)
        var itemsAxisDimension = Float(0)
        items.enumerated().forEach { (index, item) in
            item.flexFrame?.x += fixedAxisOffset
            item.fixGrowAndShrinkInAxis(arrangement: flexboxArrangement, growOffset: growAndShrinkVal.growValInLine?[index], shrinkOffset: growAndShrinkVal.shrinkValInLine?[index], fixedAxisOffset: &fixedAxisOffset)
            itemsAxisDimension += item.flexWidth
        }
        if shouldAppendAxisDimension {
            dimensionsOfCross.append(dimensionOfCurrentCross)
        }
        intrinsicSize.w = max(intrinsicSize.w, itemsAxisDimension)
        if growAndShrinkVal.growValInLine == nil && growAndShrinkVal.shrinkValInLine == nil {
            items.fixDistributionInAxis(arrangement: flexboxArrangement, justifyContent: flexJustifyContent, containerDimension: flexContainerDimension, axisDimension: itemsAxisDimension)
        }
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
        items.fixDistributionInCross(arrangement: flexboxArrangement, alignContent: flexAlignContent, alignItems: flexAlignItems, dimensionsOfCross: dimensionsOfCross, flexContainerDimension: flexContainerDimension, dimensionOfCurrentCross: dimensionOfCurrentCross, indexesOfAxisForItems: indexesOfAxisForItems)
    }
}

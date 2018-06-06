//
//  FlexboxVerticalIntermediate.swift
//  Flexbox-Swift
//
//  Created by Jerry on 2018/5/24.
//  Copyright © 2018年 com.jerry. All rights reserved.
//

struct FlexboxVerticalIntermediate: FlexboxIntermediate {
    
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
    
    var flexboxArrangement: FlexboxArrangement {
        get {
            return FlexboxArrangement(isHorizontal: false, isAxisReverse: false, isCrossReverse: flexWrap.isReverse)
        }
    }
    
    var intrinsicSize = FlexboxSize.zero
    
    init() {}
    
    mutating func intermediateDidLoad() {
        if flexWrap.isReverse {
            cursor.x = flexContainerDimension.w
        }
    }
    
    mutating func prepare(_ item: FlexboxItem) -> Bool {
        indexOfItemsInCurrentAxis += 1
        item.onMeasure(direction: .column, containerDimension: flexContainerDimension)
        let shouldWrap = flexWrap.isWrapEnabled && cursor.y + item.flexHeight - flexContainerDimension.h > Flexbox.dimensionThreshold
        if shouldWrap {
            dimensionsOfCross.append(dimensionOfCurrentCross)
        }
        return shouldWrap && indexOfItemsInCurrentAxis > 0
    }
    
    mutating func wrap() {
        cursor.x += flexboxArrangement.crossRatio * dimensionOfCurrentCross
        indexOfItemsInCurrentAxis = 0
        dimensionOfCurrentCross = Float(0)
        cursor.y = Float(0)
        growOfItemsInCurrentAxis.removeAll()
        shrinkOfItemsInCurrentAxis.removeAll()
    }
    
    mutating func move(_ item: FlexboxItem) {
        if flexWrap.isReverse {
            item.flexFrame!.x = cursor.x - item.flexMargin.right - item.flexFrame!.w
        } else {
            item.flexFrame!.x = cursor.x + item.flexMargin.left
        }
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
    
    func fixInAxis(_ items: [FlexboxItem]) {
        let growAndShrinkVal = calculateGrowAndShrink(dimensionToFix: { cursor.y - flexContainerDimension.h })
        var fixedAxisOffset = Float(0)
        var itemsAxisDimension = Float(0)
        items.enumerated().forEach { (index, item) in
            item.flexFrame?.y += fixedAxisOffset
            item.fixGrowAndShrinkInAxis(arrangement: flexboxArrangement, growOffset: growAndShrinkVal.growValInLine?[index], shrinkOffset: growAndShrinkVal.shrinkValInLine?[index], fixedAxisOffset: &fixedAxisOffset)
            itemsAxisDimension += item.flexHeight
        }
        if growAndShrinkVal.growValInLine == nil && growAndShrinkVal.shrinkValInLine == nil {
            items.fixDistributionInAxis(arrangement: flexboxArrangement, justifyContent: flexJustifyContent, containerDimension: flexContainerDimension, axisDimension: itemsAxisDimension)
        }
    }
    
    mutating func fixInCross(_ items: [FlexboxItem]) {
        dimensionsOfCross.append(dimensionOfCurrentCross)
        cursor.x += flexboxArrangement.crossRatio * dimensionOfCurrentCross
        if flexWrap.isReverse {
            if  let firstItem = items.first,
                let firstItemFrame = firstItem.flexFrame,
                let firstCrossDimension = dimensionsOfCross.first {
                intrinsicSize = FlexboxSize(w:firstItemFrame.x - firstItem.flexMargin.left + firstCrossDimension - cursor.x, h: flexWrap.isWrapEnabled ? flexContainerDimension.h : cursor.y)
            } else {
                intrinsicSize = FlexboxSize.zero
            }
        } else {
            intrinsicSize = FlexboxSize(w:cursor.x, h: flexWrap.isWrapEnabled ? flexContainerDimension.h : cursor.y)
        }
        items.fixDistributionInCross(arrangement: flexboxArrangement, alignContent: flexAlignContent, alignItems: flexAlignItems, dimensionsOfCross: dimensionsOfCross, flexContainerDimension: flexContainerDimension, dimensionOfCurrentCross: dimensionOfCurrentCross, indexesOfAxisForItems: indexesOfAxisForItems)
    }
}

//
//  FlexboxHorizontalIntermediate.swift
//  Flexbox-Swift
//
//  Created by Jerry on 2018/5/24.
//  Copyright © 2018年 com.jerry. All rights reserved.
//

struct FlexboxHorizontalIntermediate: FlexboxIntermediate {
    
    var flexContainerDimension = FlexboxSize.zero
    
    var flexWrap = Flexbox.Wrap.nowrap
    
    var flexAlignItems = Flexbox.AlignItems.stretch
    
    var flexAlignContent = Flexbox.AlignContent.start
    
    var flexJustifyContent = Flexbox.JustifyContent.start
    
    var flexboxArrangement: FlexboxArrangement {
        get {
            return FlexboxArrangement(isHorizontal: true, isAxisReverse: false, isCrossReverse: flexWrap.isReverse)
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
    
    init() {}
    
    mutating func intermediateDidLoad() {
        if flexWrap.isReverse {
            cursor.y = flexContainerDimension.h
        }
    }
    
    mutating func prepare(_ item: FlexboxItem) -> Bool {
        indexOfItemsInCurrentAxis += 1
        item.onMeasure(direction: .row)
        let shouldWrap = flexWrap.isWrapEnabled && cursor.x + item.flexWidth > flexContainerDimension.w
        if shouldWrap {
            dimensionsOfCross.append(dimensionOfCurrentCross)
        }
        return shouldWrap && indexOfItemsInCurrentAxis > 0
    }
    
    mutating func wrap() {
        if flexWrap.isReverse {
            cursor.y -= dimensionOfCurrentCross
        } else {
            cursor.y += dimensionOfCurrentCross
        }
        indexOfItemsInCurrentAxis = 0
        dimensionOfCurrentCross = Float(0)
        cursor.x = Float(0)
        growOfItemsInCurrentAxis.removeAll()
        shrinkOfItemsInCurrentAxis.removeAll()
    }
    
    mutating func move(_ item: FlexboxItem) {
        item.flexFrame!.x = cursor.x + item.flexMargin.left
        if flexWrap.isReverse {
            item.flexFrame!.y = cursor.y - item.flexMargin.bottom - item.flexFrame!.h
        } else {
            item.flexFrame!.y = cursor.y + item.flexMargin.top
        }
        
        cursor.x += item.flexWidth
        dimensionOfCurrentCross = max(dimensionOfCurrentCross, item.flexHeight)
        
        if item.flexGrow > 0 {
            growOfItemsInCurrentAxis[indexOfItemsInCurrentAxis] = item.flexGrow
        }
        if item.flexShrink > 0 {
            shrinkOfItemsInCurrentAxis[indexOfItemsInCurrentAxis] = item.flexShrink
        }
    }
    
    func fixInAxis(_ items: [FlexboxItem]) {
        let growAndShrinkVal = calculateGrowAndShrink(dimensionToFix: { cursor.x - flexContainerDimension.w })
        var fixedAxisOffset = Float(0)
        var itemsAxisDimension = Float(0)
        items.enumerated().forEach { (index, item) in
            item.flexFrame?.x += fixedAxisOffset
            item.fixGrowAndShrinkInAxis(arrangement: flexboxArrangement, growOffset: growAndShrinkVal.growValInLine?[index], shrinkOffset: growAndShrinkVal.shrinkValInLine?[index], fixedAxisOffset: &fixedAxisOffset)
            itemsAxisDimension += item.flexWidth
        }
        if growAndShrinkVal.growValInLine == nil && growAndShrinkVal.shrinkValInLine == nil {
            items.fixDistributionInAxis(arrangement: flexboxArrangement, justifyContent: flexJustifyContent, containerDimension: flexContainerDimension, axisDimension: itemsAxisDimension)
        }
    }
    
    mutating func fixInCross(_ items: [FlexboxItem]) {
        dimensionsOfCross.append(dimensionOfCurrentCross)
        if flexWrap.isReverse {
            cursor.y -= dimensionOfCurrentCross
            intrinsicSize = FlexboxSize(w: flexWrap.isWrapEnabled ? flexContainerDimension.w : cursor.x , h: cursor.y)
        } else {
            cursor.y += dimensionOfCurrentCross
            intrinsicSize = FlexboxSize(w: flexWrap.isWrapEnabled ? flexContainerDimension.w : cursor.x , h: cursor.y)
        }
        
        items.fixDistributionInCross(arrangement: flexboxArrangement, alignContent: flexAlignContent, alignItems: flexAlignItems, dimensionsOfCross: dimensionsOfCross, flexContainerDimension: flexContainerDimension, dimensionOfCurrentCross: dimensionOfCurrentCross, indexesOfAxisForItems: indexesOfAxisForItems)
    }
}

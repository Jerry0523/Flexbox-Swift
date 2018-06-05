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
    
    var cursor = FlexboxPoint.zero
    
    var dimensionOfCurrentCross = Float(0)
    
    var indexOfItemsInCurrentAxis = -1
    
    var growOfItemsInCurrentAxis = [Int: Float]()
    
    var shrinkOfItemsInCurrentAxis = [Int: Float]()
    
    var indexesOfAxisForItems = [Int: Int]()
    
    var dimensionsOfCross = [Float]()
    
    var intrinsicSize = FlexboxSize.zero
    
    init() {}
    
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
        cursor.y += dimensionOfCurrentCross
        indexOfItemsInCurrentAxis = 0
        dimensionOfCurrentCross = Float(0)
        cursor.x = Float(0)
        growOfItemsInCurrentAxis.removeAll()
        shrinkOfItemsInCurrentAxis.removeAll()
    }
    
    mutating func move(_ item: FlexboxItem) {
        item.flexFrame!.x = cursor.x + item.flexMargin.left
        item.flexFrame!.y = cursor.y + item.flexMargin.top
        
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
            item.fixGrowAndShrinkInAxis(direction: .row, growOffset: growAndShrinkVal.growValInLine?[index], shrinkOffset: growAndShrinkVal.shrinkValInLine?[index], fixedAxisOffset: &fixedAxisOffset)
            itemsAxisDimension += item.flexWidth
        }
        if growAndShrinkVal.growValInLine == nil && growAndShrinkVal.shrinkValInLine == nil {
            items.fixDistributionInAxis(direction: .row, justifyContent: flexJustifyContent, containerDimension: flexContainerDimension, axisDimension: itemsAxisDimension)
        }
    }
    
    mutating func fixInCross(_ items: [FlexboxItem]) {
        dimensionsOfCross.append(dimensionOfCurrentCross)
        cursor.y += dimensionOfCurrentCross
        intrinsicSize = FlexboxSize(w: flexWrap.isWrapEnabled ? flexContainerDimension.w : cursor.x , h: cursor.y)
        items.fixDistributionInCross(direction: .row, alignContent: flexAlignContent, alignItems: flexAlignItems, dimensionsOfCross: dimensionsOfCross, flexContainerDimension: flexContainerDimension, dimensionOfCurrentCross: dimensionOfCurrentCross, indexesOfAxisForItems: indexesOfAxisForItems)
    }
}

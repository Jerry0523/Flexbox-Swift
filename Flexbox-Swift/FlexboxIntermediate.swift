//
//  FlexboxIntermediate.swift
//  Flexbox-Swift
//
//  Created by Jerry on 2018/6/5.
//  Copyright © 2018年 com.jerry. All rights reserved.
//

struct FlexboxIntermediate {
    
    var flexDirection: Flexbox.Direction
    
    var flexWrap: Flexbox.Wrap
    
    var flexAlignItems: Flexbox.AlignItems
    
    var flexAlignContent: Flexbox.AlignContent
    
    var flexJustifyContent: Flexbox.JustifyContent
    
    var cursor = FlexboxPoint.zero
    
    var flexContainerDimension = FlexboxSize.zero
    
    var dimensionOfCurrentCross = Float(0)
    
    var indexOfItemsInCurrentAxis = -1
    
    var growOfItemsInCurrentAxis = [Int: Float]()
    
    var shrinkOfItemsInCurrentAxis = [Int: Float]()
    
    var indexesOfAxisForItems = [Int: Int]()
    
    var dimensionsOfCross = [Float]()
    
    var intrinsicSize = FlexboxSize.zero
    
    var flexDebugTag: String?
    
    var flexIsMeasuring = false
    
    var flexboxArrangement: FlexboxArrangement {
        get {
            return FlexboxArrangement(direction: flexDirection, isCrossReverse: flexWrap == .wrapReverse)
        }
    }
    
    init(direction: Flexbox.Direction, alignItems: Flexbox.AlignItems, alignContent: Flexbox.AlignContent, wrap: Flexbox.Wrap, justifyContent: Flexbox.JustifyContent, containerDimension: FlexboxSize, debugTag: String?, isMeasuring: Bool) {
        
        flexDirection = direction
        flexAlignItems = alignItems
        flexAlignContent = alignContent
        flexWrap = wrap
        flexContainerDimension = containerDimension
        flexJustifyContent = justifyContent
        flexDebugTag = debugTag
        flexIsMeasuring = isMeasuring
        
        if flexboxArrangement.isCrossReverse {
            cursor.updateCrossDim(withRefrence: flexContainerDimension, inDirection: direction)
        }
        if flexboxArrangement.isAxisReverse {
            cursor.updateAxisDim(withRefrence: flexContainerDimension, inDirection: direction)
        }
    }
    
    mutating func layout(_ items: [FlexboxItem]) {
        
        items.enumerated().forEach { (idx, item) in
            if prepare(item) {
                fixInAxis(Array(items[(idx - indexOfItemsInCurrentAxis)..<idx]), shouldAppendAxisDimension: false)
                wrap()
            }
            move(item)
            let axisIndex = dimensionsOfCross.count
            indexesOfAxisForItems[idx] = axisIndex
        }
        
        fixInAxis(Array(items[(items.count - 1 - indexOfItemsInCurrentAxis)...items.count - 1]), shouldAppendAxisDimension: true)
        fixInCross(items)
    }
    
    mutating func prepare(_ item: FlexboxItem) -> Bool {
        indexOfItemsInCurrentAxis += 1
        item.onMeasure(direction: flexDirection, containerDimension: flexContainerDimension)
        var shouldWrap = flexWrap.isWrapEnabled
        if flexboxArrangement.isAxisReverse {
            shouldWrap = shouldWrap && cursor.axisDim(flexDirection) - item.axisDim(flexDirection) < Flexbox.dimensionThreshold
        } else {
            shouldWrap = shouldWrap && cursor.axisDim(flexDirection) + item.axisDim(flexDirection) - flexContainerDimension.axisDim(flexDirection) > Flexbox.dimensionThreshold
        }
        if shouldWrap {
            dimensionsOfCross.append(dimensionOfCurrentCross)
        }
        return shouldWrap && indexOfItemsInCurrentAxis > 0
    }
    
    mutating func wrap() {
        cursor.updateCrossDim(cursor.y + flexboxArrangement.crossRatio * dimensionOfCurrentCross, direction: flexDirection)
        indexOfItemsInCurrentAxis = 0
        dimensionOfCurrentCross = Float(0)
        if flexboxArrangement.isAxisReverse {
            cursor.updateAxisDim(withRefrence: flexContainerDimension, inDirection: flexDirection)
        } else {
            cursor.updateAxisDim(0, direction: flexDirection)
        }
        growOfItemsInCurrentAxis.removeAll()
        shrinkOfItemsInCurrentAxis.removeAll()
    }
    
    mutating func move(_ item: FlexboxItem) {
        if flexboxArrangement.isHorizontal {
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
            
        } else {
            if flexboxArrangement.isAxisReverse {
                item.flexFrame!.y = cursor.y + item.flexMargin.bottom - item.flexFrame!.h
            } else {
                item.flexFrame!.y = cursor.y + item.flexMargin.top
            }
            if flexboxArrangement.isCrossReverse {
                item.flexFrame!.x = cursor.x - item.flexMargin.right - item.flexFrame!.w
            } else {
                item.flexFrame!.x = cursor.x + item.flexMargin.left
            }
        }
        
        cursor.updateAxisDim(cursor.axisDim(flexDirection) + flexboxArrangement.axisRatio * item.axisDim(flexDirection) , direction: flexDirection)
        dimensionOfCurrentCross = max(dimensionOfCurrentCross, item.crossDim(flexDirection))
        
        if item.flexGrow > 0 {
            growOfItemsInCurrentAxis[indexOfItemsInCurrentAxis] = item.flexGrow
        }
        if item.flexShrink > 0 {
            shrinkOfItemsInCurrentAxis[indexOfItemsInCurrentAxis] = item.flexShrink
        }
    }
    
    mutating func fixInAxis(_ items: [FlexboxItem], shouldAppendAxisDimension: Bool) {
        var itemsAxisDimension = Float(0)
        let growAndShrinkVal = calculateGrowAndShrink(dimensionToFix: { flexboxArrangement.isAxisReverse ? (-cursor.axisDim(flexDirection)) : (cursor.axisDim(flexDirection) - flexContainerDimension.axisDim(flexDirection)) })
        var fixedAxisOffset = Float(0)
        items.enumerated().forEach { (index, item) in
            if var origin = item.flexFrame?.origin {
                origin.updateAxisDim(origin.axisDim(flexDirection) + fixedAxisOffset, direction: flexDirection)
                item.flexFrame?.origin = origin
            }
            item.fixGrowAndShrinkInAxis(arrangement: flexboxArrangement, growOffset: growAndShrinkVal.growValInLine?[index], shrinkOffset: growAndShrinkVal.shrinkValInLine?[index], fixedAxisOffset: &fixedAxisOffset, fixedCrossDimension: &dimensionOfCurrentCross)
            itemsAxisDimension += item.axisDim(flexDirection)
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
        intrinsicSize.updateAxisDim(max(intrinsicSize.axisDim(flexDirection), itemsAxisDimension), direction: flexDirection)
    }
    
    mutating func fixInCross(_ items: [FlexboxItem]) {
        cursor.updateCrossDim(cursor.crossDim(flexDirection) + flexboxArrangement.crossRatio * dimensionOfCurrentCross, direction: flexDirection)
        if flexboxArrangement.isCrossReverse {
            if  let firstItem = items.first,
                let firstItemFrame = firstItem.flexFrame,
                let firstCrossDimension = dimensionsOfCross.first {
                let marginVal = (flexDirection == .row || flexDirection == .rowReverse) ? firstItem.flexMargin.top : firstItem.flexMargin.left
                intrinsicSize.updateCrossDim(firstItemFrame.origin.crossDim(flexDirection) - marginVal + firstCrossDimension - cursor.crossDim(flexDirection), direction: flexDirection)
            } else {
                intrinsicSize.updateCrossDim(0, direction: flexDirection)
            }
        } else {
            intrinsicSize.updateCrossDim(withRefrence: cursor, inDirection: flexDirection)
        }
        if !flexIsMeasuring {
            items.fixDistributionInCross(arrangement: flexboxArrangement, alignContent: flexAlignContent, alignItems: flexAlignItems, dimensionsOfCross: dimensionsOfCross, flexContainerDimension: flexContainerDimension, dimensionOfCurrentCross: dimensionOfCurrentCross, indexesOfAxisForItems: indexesOfAxisForItems)
        }
    }
    
    func calculateGrowAndShrink(dimensionToFix: () -> Float)  -> (growValInLine: [Int: Float]?, shrinkValInLine: [Int: Float]?){
        var growValInLine: [Int: Float]? = nil
        var shrinkValInLine: [Int: Float]? = nil
        
        let lengthToFix = dimensionToFix()
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
    
}

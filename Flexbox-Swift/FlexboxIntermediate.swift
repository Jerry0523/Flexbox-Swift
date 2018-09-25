//
//  FlexboxIntermediate.swift
//  Flexbox-Swift
//
//  Created by Jerry on 2018/6/5.
//  Copyright © 2018年 com.jerry. All rights reserved.
//

class FlexboxIntermediate {
    
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
        
        FlexboxContext.direction = direction
        
        if flexboxArrangement.isCrossReverse {
            cursor.crossVal = flexContainerDimension.crossVal
        }
        if flexboxArrangement.isAxisReverse {
            cursor.axisVal = flexContainerDimension.axisVal
        }
    }
    
    func layout(_ items: [FlexboxItem]) -> [FlexboxItem] {
        if items.count == 0 {
            return items
        }
        var ret = [FlexboxItem]()
        items.enumerated().forEach { (idx, item) in
            var mItem = item
            let preparedVal = prepare(mItem)
            mItem = preparedVal.0
            if preparedVal.1 {
                var fixedItems = Array(ret[(idx - indexOfItemsInCurrentAxis)..<idx])
                fixedItems = fixInAxis(fixedItems, shouldAppendAxisDimension: false)
                ret.replaceSubrange((idx - indexOfItemsInCurrentAxis)..<idx, with: fixedItems)
                wrap()
            }
            mItem = move(mItem)
            let axisIndex = dimensionsOfCross.count
            indexesOfAxisForItems[idx] = axisIndex
            ret.append(mItem)
        }
        
        var fixedItems = Array(ret[(ret.count - 1 - indexOfItemsInCurrentAxis)...ret.count - 1])
        fixedItems = fixInAxis(fixedItems, shouldAppendAxisDimension: true)
        ret.replaceSubrange((ret.count - 1 - indexOfItemsInCurrentAxis)...ret.count - 1, with: fixedItems)
        ret = fixInCross(ret)
        return ret
    }
    
    func prepare(_ item: FlexboxItem) -> (FlexboxItem, Bool) {
        var ret = item
        indexOfItemsInCurrentAxis += 1
        let measuredSize = ret.onMeasure(direction: flexDirection, containerDimension: flexContainerDimension)
        ret.flexFrame = FlexboxRect(x: 0, y: 0, w: measuredSize.w, h: measuredSize.h)
        var shouldWrap = flexWrap.isWrapEnabled
        
        FlexboxContext.direction = flexDirection
        
        if flexboxArrangement.isAxisReverse {
            shouldWrap = shouldWrap && cursor.axisVal - ret.axisVal < Flexbox.dimensionThreshold
        } else {
            shouldWrap = shouldWrap && cursor.axisVal + ret.axisVal - flexContainerDimension.axisVal > Flexbox.dimensionThreshold
        }
        if shouldWrap {
            dimensionsOfCross.append(dimensionOfCurrentCross)
        }
        return (ret, shouldWrap && indexOfItemsInCurrentAxis > 0)
    }
    
    func wrap() {
        cursor.crossVal = cursor.y + flexboxArrangement.crossRatio * dimensionOfCurrentCross
        indexOfItemsInCurrentAxis = 0
        dimensionOfCurrentCross = Float(0)
        if flexboxArrangement.isAxisReverse {
            cursor.axisVal = flexContainerDimension.axisVal
        } else {
            cursor.axisVal = 0
        }
        growOfItemsInCurrentAxis.removeAll()
        shrinkOfItemsInCurrentAxis.removeAll()
    }
    
    func move(_ item: FlexboxItem) -> FlexboxItem {
        var ret = item
        if flexboxArrangement.isHorizontal {
            if flexboxArrangement.isAxisReverse {
                ret.flexFrame!.x = cursor.x - item.flexMargin.right - item.flexFrame!.w
            } else {
                ret.flexFrame!.x = cursor.x + item.flexMargin.left
            }
            if flexboxArrangement.isCrossReverse {
                ret.flexFrame!.y = cursor.y - item.flexMargin.bottom - item.flexFrame!.h
            } else {
                ret.flexFrame!.y = cursor.y + item.flexMargin.top
            }
            
        } else {
            if flexboxArrangement.isAxisReverse {
                ret.flexFrame!.y = cursor.y + item.flexMargin.bottom - item.flexFrame!.h
            } else {
                ret.flexFrame!.y = cursor.y + item.flexMargin.top
            }
            if flexboxArrangement.isCrossReverse {
                ret.flexFrame!.x = cursor.x - item.flexMargin.right - item.flexFrame!.w
            } else {
                ret.flexFrame!.x = cursor.x + item.flexMargin.left
            }
        }
        
        FlexboxContext.direction = flexDirection
        
        cursor.axisVal = cursor.axisVal + flexboxArrangement.axisRatio * item.axisVal
        dimensionOfCurrentCross = max(dimensionOfCurrentCross, item.crossVal)
        
        if item.flexGrow > 0 {
            growOfItemsInCurrentAxis[indexOfItemsInCurrentAxis] = item.flexGrow
        }
        if item.flexShrink > 0 {
            shrinkOfItemsInCurrentAxis[indexOfItemsInCurrentAxis] = item.flexShrink
        }
        return ret
    }
    
    func fixInAxis(_ items: [FlexboxItem], shouldAppendAxisDimension: Bool) -> [FlexboxItem] {
        var itemsAxisDimension = Float(0)
        FlexboxContext.direction = flexDirection
        let growAndShrinkVal = calculateGrowAndShrink(dimensionToFix: { flexboxArrangement.isAxisReverse ? (-cursor.axisVal) : (cursor.axisVal - flexContainerDimension.axisVal) })
        var fixedAxisOffset = Float(0)
        var ret = items.enumerated().map { (index, item) -> FlexboxItem in
            var mItem = item
            if var origin = mItem.flexFrame?.origin {
                origin.axisVal = origin.axisVal + fixedAxisOffset
                mItem.flexFrame?.origin = origin
            }
            mItem = mItem.fixGrowAndShrinkInAxis(arrangement: flexboxArrangement, growOffset: growAndShrinkVal.growValInLine?[index], shrinkOffset: growAndShrinkVal.shrinkValInLine?[index], fixedAxisOffset: &fixedAxisOffset, fixedCrossDimension: &dimensionOfCurrentCross)
            FlexboxContext.direction = flexDirection
            itemsAxisDimension += mItem.axisVal
            return mItem
        }
        
        if growAndShrinkVal.growValInLine == nil && growAndShrinkVal.shrinkValInLine == nil && !flexIsMeasuring {
            ret = ret.fixDistributionInAxis(arrangement: flexboxArrangement, justifyContent: flexJustifyContent, containerDimension: flexContainerDimension, axisDimension: itemsAxisDimension)
        }
        
        if shouldAppendAxisDimension {
            dimensionsOfCross.append(dimensionOfCurrentCross)
        } else {
            dimensionsOfCross.removeLast()
            dimensionsOfCross.append(dimensionOfCurrentCross)
        }
        intrinsicSize.axisVal = max(intrinsicSize.axisVal, itemsAxisDimension)
        return ret
    }
    
    func fixInCross(_ items: [FlexboxItem]) -> [FlexboxItem] {
        FlexboxContext.direction = flexDirection
        cursor.crossVal = cursor.crossVal + flexboxArrangement.crossRatio * dimensionOfCurrentCross
        if flexboxArrangement.isCrossReverse {
            if  let firstItem = items.first,
                let firstItemFrame = firstItem.flexFrame,
                let firstCrossDimension = dimensionsOfCross.first {
                let marginVal = (flexDirection == .row || flexDirection == .rowReverse) ? firstItem.flexMargin.top : firstItem.flexMargin.left
                intrinsicSize.crossVal = firstItemFrame.origin.crossVal - marginVal + firstCrossDimension - cursor.crossVal
            } else {
                intrinsicSize.crossVal = 0
            }
        } else {
            intrinsicSize.crossVal = cursor.crossVal
        }
        return flexIsMeasuring ? items :
                    items.fixDistributionInCross(arrangement: flexboxArrangement, alignContent: flexAlignContent, alignItems: flexAlignItems, dimensionsOfCross: dimensionsOfCross, flexContainerDimension: flexContainerDimension, dimensionOfCurrentCross: dimensionOfCurrentCross, indexesOfAxisForItems: indexesOfAxisForItems)
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

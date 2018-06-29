//
//  FlexboxIntermediate.swift
//  Flexbox-Swift
//
//  Created by Jerry on 2018/6/5.
//  Copyright © 2018年 com.jerry. All rights reserved.
//

protocol FlexboxIntermediate {
    
    var flexDirection: Flexbox.Direction { get set }
    
    var flexContainerDimension: FlexboxSize { get set }
    
    var flexWrap: Flexbox.Wrap { get set }
    
    var flexAlignItems: Flexbox.AlignItems { get set }
    
    var flexAlignContent: Flexbox.AlignContent { get set }
    
    var flexJustifyContent: Flexbox.JustifyContent { get set }
    
    var cursor: FlexboxPoint { get set }
    
    var dimensionOfCurrentCross: Float { get set }
    
    var indexOfItemsInCurrentAxis: Int { get set }
    
    var growOfItemsInCurrentAxis: [Int: Float] { get set }
    
    var shrinkOfItemsInCurrentAxis: [Int: Float] { get set }
    
    var indexesOfAxisForItems: [Int: Int] { get set }
    
    var dimensionsOfCross: [Float] { get set }
    
    var intrinsicSize: FlexboxSize { get set }
    
    var flexDebugTag: String? { get set }
    
    var flexIsMeasuring: Bool { get set }
    
    init()
    
    mutating func fixInCross(_ items: [FlexboxItem])
    
    mutating func fixInAxis(_ items: [FlexboxItem], shouldAppendAxisDimension: Bool)
}

extension FlexboxIntermediate {
    
    var flexboxArrangement: FlexboxArrangement {
        get {
            return FlexboxArrangement(direction: flexDirection, isCrossReverse: flexWrap == .wrapReverse)
        }
    }
    
    init(direction: Flexbox.Direction, alignItems: Flexbox.AlignItems, alignContent: Flexbox.AlignContent, wrap: Flexbox.Wrap, justifyContent: Flexbox.JustifyContent, containerDimension: FlexboxSize, debugTag: String?, isMeasuring: Bool) {
        self.init()
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

protocol AnyDirectionalDimension {
    
    func axisDim(_ direction: Flexbox.Direction) -> Float
    
    func crossDim(_ direction: Flexbox.Direction) -> Float
    
    mutating func updateAxisDim(_ newValue: Float, direction: Flexbox.Direction)
    
    mutating func updateCrossDim(_ newValue: Float, direction: Flexbox.Direction)
}

extension AnyDirectionalDimension {
    
    mutating func updateAxisDim(withRefrence: AnyDirectionalDimension, inDirection: Flexbox.Direction) {
        updateAxisDim(withRefrence.axisDim(inDirection), direction: inDirection)
    }
    
    mutating func updateCrossDim(withRefrence: AnyDirectionalDimension, inDirection: Flexbox.Direction) {
        updateCrossDim(withRefrence.crossDim(inDirection), direction: inDirection)
    }
}

extension FlexboxSize: AnyDirectionalDimension {
   
    func axisDim(_ direction: Flexbox.Direction) -> Float {
        switch direction {
        case .row, .rowReverse:
            return w
        case .column, .columnReverse:
            return h
        }
    }
    
    func crossDim(_ direction: Flexbox.Direction) -> Float {
        switch direction {
        case .row, .rowReverse:
            return h
        case .column, .columnReverse:
            return w
        }
    }
    
    mutating func updateAxisDim(_ newValue: Float, direction: Flexbox.Direction) {
        switch direction {
        case .row, .rowReverse:
            w = newValue
        case .column, .columnReverse:
            h = newValue
        }
    }
    
    mutating func updateCrossDim(_ newValue: Float, direction: Flexbox.Direction) {
        switch direction {
        case .row, .rowReverse:
            h = newValue
        case .column, .columnReverse:
            w = newValue
        }
    }
}

extension FlexboxPoint: AnyDirectionalDimension {
    
    func axisDim(_ direction: Flexbox.Direction) -> Float {
        switch direction {
        case .row, .rowReverse:
            return x
        case .column, .columnReverse:
            return y
        }
    }
    
    func crossDim(_ direction: Flexbox.Direction) -> Float {
        switch direction {
        case .row, .rowReverse:
            return y
        case .column, .columnReverse:
            return x
        }
    }
    
    mutating func updateAxisDim(_ newValue: Float, direction: Flexbox.Direction) {
        switch direction {
        case .row, .rowReverse:
            x = newValue
        case .column, .columnReverse:
            y = newValue
        }
    }
    
    mutating func updateCrossDim(_ newValue: Float, direction: Flexbox.Direction) {
        switch direction {
        case .row, .rowReverse:
            y = newValue
        case .column, .columnReverse:
            x = newValue
        }
    }
}

extension FlexboxInsets: AnyDirectionalDimension {
    
    func axisDim(_ direction: Flexbox.Direction) -> Float {
        switch direction {
        case .row, .rowReverse:
            return left + right
        case .column, .columnReverse:
            return top + bottom
        }
    }
    
    func crossDim(_ direction: Flexbox.Direction) -> Float {
        switch direction {
        case .row, .rowReverse:
            return top + bottom
        case .column, .columnReverse:
            return left + right
        }
    }
    
    func axisDim(_ direction: Flexbox.Direction) -> (Float, Float) {
        switch direction {
        case .row:
            return (left, right)
        case .rowReverse:
            return (right, left)
        case .column:
            return (top, bottom)
        case .columnReverse:
            return (bottom, top)
        }
    }
    
    func crossDim(_ direction: Flexbox.Direction) -> (Float, Float) {
        switch direction {
        case .row:
            return (top, bottom)
        case .rowReverse:
            return (bottom, top)
        case .column:
            return (left, right)
        case .columnReverse:
            return (right, left)
        }
    }
    
    mutating func updateAxisDim(_ newValue: Float, direction: Flexbox.Direction) {
        fatalError("unsupported")
    }
    
    mutating func updateCrossDim(_ newValue: Float, direction: Flexbox.Direction) {
        fatalError("unsupported")
    }
}

extension FlexboxItem: AnyDirectionalDimension {
    
    func axisDim(_ direction: Flexbox.Direction) -> Float {
        switch direction {
        case .row, .rowReverse:
            return flexWidth
        case .column, .columnReverse:
            return flexHeight
        }
    }
    
    func crossDim(_ direction: Flexbox.Direction) -> Float {
        switch direction {
        case .row, .rowReverse:
            return flexHeight
        case .column, .columnReverse:
            return flexWidth
        }
    }
    
    func updateAxisDim(_ newValue: Float, direction: Flexbox.Direction) {
        fatalError("unsupported")
    }
    
    func updateCrossDim(_ newValue: Float, direction: Flexbox.Direction) {
        fatalError("unsupported")
    }
}


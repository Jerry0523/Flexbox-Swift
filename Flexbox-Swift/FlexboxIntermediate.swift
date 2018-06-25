//
//  FlexboxIntermediate.swift
//  Flexbox-Swift
//
//  Created by 王杰 on 2018/6/5.
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
    
    var flexDebuggable: Bool { get set }
    
    init()
    
    mutating func intermediateDidLoad()
    
    mutating func prepare(_ item: FlexboxItem) -> Bool
    
    mutating func wrap()
    
    mutating func move(_ item: FlexboxItem)
    
    mutating func fixInCross(_ items: [FlexboxItem])
    
    mutating func fixInAxis(_ items: [FlexboxItem], shouldAppendAxisDimension: Bool)
}

extension FlexboxIntermediate {
    
    init(direction: Flexbox.Direction, alignItems: Flexbox.AlignItems, alignContent: Flexbox.AlignContent, wrap: Flexbox.Wrap, justifyContent: Flexbox.JustifyContent, containerDimension: FlexboxSize, debuggable: Bool) {
        self.init()
        flexDirection = direction
        flexAlignItems = alignItems
        flexAlignContent = alignContent
        flexWrap = wrap
        flexContainerDimension = containerDimension
        flexJustifyContent = justifyContent
        flexDebuggable = debuggable
        intermediateDidLoad()
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

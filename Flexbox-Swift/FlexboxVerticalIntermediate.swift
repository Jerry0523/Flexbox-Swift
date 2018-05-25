//
//  FlexboxVerticalIntermediate.swift
//  Flexbox-Swift
//
//  Created by Jerry on 2018/5/24.
//  Copyright © 2018年 com.jerry. All rights reserved.
//

struct FlexboxVerticalIntermediate {
    
    let flexContainerSize: FlexboxSize
    
    let flexWrap: Flexbox.Wrap
    
    let flexAlignItems: Flexbox.AlignItems
    
    let flexAlignContent: Flexbox.AlignContent
    
    let flexJustifyContent: Flexbox.JustifyContent
    
    var offsetX = Float(0)
    
    var offsetY = Float(0)
    
    var lineHeight = Float(0)
    
    var indexInLine = -1
    
    var growInLine = [Int: Float]()
    
    var shrinkInLine = [Int: Float]()
    
    var itemsInLineIndex = [Int: Int]()
    
    var lineHeights = [Float]()
    
    init(alignItems: Flexbox.AlignItems, alignContent: Flexbox.AlignContent, wrap: Flexbox.Wrap, justifyContent: Flexbox.JustifyContent, containerSize: FlexboxSize) {
        flexAlignItems = alignItems
        flexAlignContent = alignContent
        flexWrap = wrap
        flexContainerSize = containerSize
        flexJustifyContent = justifyContent
    }
    
    mutating func prepare(_ item: FlexboxItem) -> Bool {
        indexInLine += 1
        measure(item)
        let shouldWrap = flexWrap.isWrapEnabled && offsetY + item.flexHeight > flexContainerSize.h
        if shouldWrap {
            lineHeights.append(lineHeight)
        }
        return shouldWrap && indexInLine > 0
    }
    
    mutating func wrap() {
        offsetX += lineHeight
        indexInLine = 0
        lineHeight = Float(0)
        offsetY = Float(0)
        growInLine.removeAll()
        shrinkInLine.removeAll()
    }
    
    mutating func move(_ item: FlexboxItem) {
        item.flexFrame!.x = offsetX + item.flexMargin.left
        item.flexFrame!.y = offsetY + item.flexMargin.top
        
        offsetY += item.flexHeight
        lineHeight = max(lineHeight, item.flexWidth)
        
        if item.flexGrow > 0 {
            growInLine[indexInLine] = item.flexGrow
        }
        if item.flexShrink > 0 {
            shrinkInLine[indexInLine] = item.flexShrink
        }
    }
    
    func fix(_ items: [FlexboxItem]) {
        let growAndShrinkVal = calculateGrowAndShrink()
        var fixedAxisOffset = Float(0)
        var itemsContentLength = Float(0)
        items.enumerated().forEach { (index, item) in
            item.flexFrame?.y += fixedAxisOffset
            fixAlignment(item)
            if let growOffset = growAndShrinkVal.growValInLine?[index] {
                item.flexFrame?.h += growOffset
                fixedAxisOffset += growOffset
            } else if let shrinkOffset = growAndShrinkVal.shrinkValInLine?[index] {
                item.flexFrame?.h -= shrinkOffset
                fixedAxisOffset -= shrinkOffset
            }
            itemsContentLength += item.flexHeight
        }
        if growAndShrinkVal.growValInLine == nil && growAndShrinkVal.shrinkValInLine == nil {
            fixJustifyContent(items, contentLength: itemsContentLength)
        }
    }
    
    mutating func finalize(_ items: [FlexboxItem]) {
        lineHeights.append(lineHeight)
        if lineHeights.count == 1 {
            items.forEach { item in
                item.flexFrame?.x += (flexContainerSize.w - lineHeight) * 0.5
            }
        } else if flexAlignContent != .start {
            let contentWidth = lineHeights.reduce(0, +)
            items.enumerated().forEach { (offset, item) in
                switch flexAlignContent {
                case .start: break
                case .end:
                    item.flexFrame?.x += flexContainerSize.w - contentWidth
                case .center:
                    item.flexFrame?.x += (flexContainerSize.w - contentWidth) * 0.5
                case .spaceBetween:
                    if let lineIndex = itemsInLineIndex[offset] {
                        item.flexFrame?.x += (flexContainerSize.w - contentWidth) * Float(lineIndex) / Float(lineHeights.count - 1)
                    }
                case .spaceAround:
                    if let lineIndex = itemsInLineIndex[offset] {
                        item.flexFrame?.x += (flexContainerSize.w - contentWidth) * (Float(lineIndex) + 0.5) / Float(lineHeights.count)
                    }
                case .stretch:
                    if let lineIndex = itemsInLineIndex[offset] {
                        var stretchOffsetX = Float(0)
                        for stretchLineIndex in 0..<lineIndex {
                            stretchOffsetX += lineHeights[stretchLineIndex]
                        }
                        item.flexFrame?.x += (stretchOffsetX * flexContainerSize.w / contentWidth - stretchOffsetX)
                    }
                }
            }
        }
    }
}

extension FlexboxVerticalIntermediate {
    
    private func fixAlignment(_ item: FlexboxItem) {
        let alignment = item.alignSelf.toAlignItems() ?? flexAlignItems
        switch alignment {
        case .start: break
        case .end: item.flexFrame!.x = offsetX + lineHeight - item.flexMargin.right - item.flexFrame!.w
        case .center: item.flexFrame!.x = offsetX + (lineHeight - item.flexWidth) * 0.5 + item.flexMargin.left
        case .stretch: item.flexFrame!.w = lineHeight - item.flexMargin.left - item.flexMargin.right
        case .baseline:break
        }
    }
    
    private func measure(_ item: FlexboxItem) {
        var size = FlexboxSize.zero
        if let basis = item.flexBasis {
            size = item.measure(FlexboxSize(w: 0, h: Float(basis)))
            size.h = max(size.h, Float(basis))
        } else {
            size = item.measure(FlexboxSize.zero)
        }
        item.flexFrame = FlexboxRect(x: 0, y: 0, w: size.w, h: size.h)
    }
    
    private func calculateGrowAndShrink()  -> (growValInLine: [Int: Float]?, shrinkValInLine: [Int: Float]?){
        var growValInLine: [Int: Float]? = nil
        var shrinkValInLine: [Int: Float]? = nil
        
        let lengthToFix = offsetY - flexContainerSize.h
        if lengthToFix > 0 {
            let shrinkSum = shrinkInLine.reduce(0, {$0 + $1.value})
            if shrinkSum > 0 {
                shrinkValInLine = shrinkInLine.reduce(into: [Int: Float](), { $0[$1.key] = $1.value * lengthToFix / shrinkSum})
            }
        } else if lengthToFix < 0 {
            let growSum = growInLine.reduce(0, {$0 + $1.value})
            if growSum > 0 {
                growValInLine = growInLine.reduce(into: [Int: Float](), { $0[$1.key] = $1.value * (-lengthToFix) / growSum})
            }
        }
        return (growValInLine, shrinkValInLine)
    }
    
    private func fixJustifyContent(_ items: [FlexboxItem], contentLength: Float) {
        if flexJustifyContent == .start {
            return
        }
        
        var mFlexJustifyConent = flexJustifyContent
        if items.count == 1 && (mFlexJustifyConent == .spaceBetween || mFlexJustifyConent == .spaceAround) {
            mFlexJustifyConent = .center
        }
        
        items.enumerated().forEach { (index, item) in
            switch mFlexJustifyConent {
            case .end:
                item.flexFrame?.y += flexContainerSize.h - contentLength
            case .center:
                item.flexFrame?.y += (flexContainerSize.h - contentLength) * 0.5
            case .spaceBetween:
                item.flexFrame?.y += (flexContainerSize.h - contentLength) * Float(index) / Float(items.count - 1)
            case .spaceAround:
                item.flexFrame?.y += (flexContainerSize.h - contentLength) * (Float(index) + 0.5) / Float(items.count)
            case .start: break
            }
        }
    }
}

//
//  Flexbox.swift
//  Flexbox-Swift
//
//  Created by Jerry on 2018/5/22.
//  Copyright © 2018年 com.jerry. All rights reserved.
//

class Flexbox {
    
    init(delegate: FlexboxDelegate) {
        self.delegate = delegate
    }
    
    private func layoutHorizontally(_ items: [FlexboxItem], size: FlexboxSize) {
        var intermediate = FlexboxHorizontalIntermediate(alignItems: alignItems, alignContent:alignContent, wrap: flexWrap, justifyContent: justifyContent, containerDimension: size)
        
        items.enumerated().forEach { (idx, item) in
            if intermediate.prepare(item) {
                intermediate.fix(Array(items[(idx - intermediate.indexOfItemsInCurrentAxis)..<idx]))
                intermediate.wrap()
            }
            intermediate.move(item)
            intermediate.indexesOfAxisForItems[idx] = intermediate.dimensionsOfCross.count
        }
        
        intermediate.fix(Array(items[(items.count - 1 - intermediate.indexOfItemsInCurrentAxis)...items.count - 1]))
        intermediate.cursor.y += intermediate.dimensionOfCurrentCross
        intrinsicSize = FlexboxSize(w: flexWrap.isWrapEnabled ? size.w : intermediate.cursor.x , h: intermediate.cursor.y)
        intermediate.finalize(items)
    }
    
    private func layoutVertically(_ items: [FlexboxItem], size: FlexboxSize) {
        var intermediate = FlexboxVerticalIntermediate(alignItems: alignItems, alignContent:alignContent, wrap: flexWrap, justifyContent: justifyContent, containerSize: size)
        
        items.enumerated().forEach { (idx, item) in
            if intermediate.prepare(item) {
                intermediate.fix(Array(items[(idx - intermediate.indexOfItemsInCurrentAxis)..<idx]))
                intermediate.wrap()
            }
            intermediate.move(item)
            intermediate.indexesOfAxisForItems[idx] = intermediate.dimensionsOfCross.count
        }
        
        intermediate.fix(Array(items[(items.count - 1 - intermediate.indexOfItemsInCurrentAxis)...items.count - 1]))
        intermediate.cursor.x += intermediate.dimensionOfCurrentCross
        intrinsicSize = FlexboxSize(w:intermediate.cursor.x, h: flexWrap.isWrapEnabled ? size.h : intermediate.cursor.y)
        intermediate.finalize(items)
    }
    
    func layout(_ items: [FlexboxItem], size: FlexboxSize) {
        let sortedItems = items.sorted { $0.flexOrder < $1.flexOrder }
        switch flexDirection {
        case .row, .rowReverse:
            layoutHorizontally(sortedItems, size: size)
        case .column, .columnReverse:
            layoutVertically(sortedItems, size: size)
        }
    }
    
    var flexFlow:(direction: Direction, wrap: Wrap) {
        get {
            return (flexDirection, flexWrap)
        }
        
        set {
            flexDirection = newValue.direction
            flexWrap = newValue.wrap
        }
    }
    
    weak var delegate: FlexboxDelegate?
    
    private(set) var intrinsicSize = FlexboxSize.zero {
        didSet {
            if oldValue != intrinsicSize {
                delegate?.invalidateIntrinsicContentSize()
            }
        }
    }
    
    var flexDirection = Direction.row {
        didSet {
            if oldValue != flexDirection {
                delegate?.setNeedsLayout()
            }
        }
    }
    
    var flexWrap = Wrap.nowrap {
        didSet {
            if oldValue != flexWrap {
                delegate?.setNeedsLayout()
            }
        }
    }
    
    var justifyContent = JustifyContent.start {
        didSet {
            if oldValue != justifyContent {
                delegate?.setNeedsLayout()
            }
        }
    }
    
    var alignItems = AlignItems.stretch {
        didSet {
            if oldValue != alignItems {
                delegate?.setNeedsLayout()
            }
        }
    }
    
    var alignContent = AlignContent.stretch {
        didSet {
            if oldValue != alignContent {
                delegate?.setNeedsLayout()
            }
        }
    }
    
    enum Direction {
        
        case row
        
        @available(*, unavailable)
        case rowReverse
        
        case column
        
        @available(*, unavailable)
        case columnReverse
        
    }
    
    enum Wrap {
        
        case nowrap
        
        case wrap
        
        @available(*, unavailable)
        case wrapReverse
        
        var isWrapEnabled: Bool{
            get {
                return self != .nowrap
            }
        }
        
    }
    
    enum JustifyContent {
        
        case start
        
        case end
        
        case center
        
        case spaceBetween
        
        case spaceAround
        
    }
    
    enum AlignItems {
        
        case start
        
        case end
        
        case center
        
        @available(*, unavailable)
        case baseline
        
        case stretch
        
    }
    
    enum AlignContent {
        
        case start
        
        case end
        
        case center
        
        case spaceBetween
        
        case spaceAround
        
        case stretch
        
    }
    
    enum AlignSelf {
        
        case auto
        
        case start
        
        case end
        
        case center
        
        @available(*, unavailable)
        case baseline
        
        case stretch
        
        func toAlignItems() -> AlignItems? {
            switch self {
            case .auto: return nil
            case .start: return .start
            case .end: return .end
            case .center: return .center
            case .stretch: return .stretch
            default: return nil
            }
        }
    }
}

protocol FlexboxDelegate: class {
    
    func setNeedsLayout()
    
    func invalidateIntrinsicContentSize()
    
}

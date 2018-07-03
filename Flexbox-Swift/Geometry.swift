//
//  Geometry.swift
//  Flexbox-Swift
//
//  Created by Jerry on 2018/5/28.
//  Copyright © 2018年 com.jerry. All rights reserved.
//

struct FlexboxPoint: Equatable {
    
    var x: Float
    
    var y: Float
    
    static let zero = FlexboxPoint(x: 0, y: 0)
}

struct FlexboxSize: Equatable {
    
    var w: Float
    
    var h: Float
    
    static let zero = FlexboxSize(w: 0, h: 0)
}

struct FlexboxRect: Equatable {
    
    var x: Float
    
    var y: Float
    
    var w: Float
    
    var h: Float
    
    var size: FlexboxSize {
        get {
            return FlexboxSize(w: w, h: h)
        }
        
        set {
            self.w = newValue.w
            self.h = newValue.h
        }
    }
    
    var origin: FlexboxPoint {
        get {
            return FlexboxPoint(x: x, y: y)
        }
        
        set {
            self.x = newValue.x
            self.y = newValue.y
        }
    }
    
    static let zero = FlexboxRect(x: 0, y: 0, w: 0, h: 0)
}

struct FlexboxInsets: Equatable {
    
    var top: Float
    
    var left: Float
    
    var bottom: Float
    
    var right: Float
    
    static let zero = FlexboxInsets(top: 0, left: 0, bottom: 0, right: 0)
}

struct FlexboxArrangement {
    
    let direction: Flexbox.Direction
    
    let isCrossReverse: Bool
    
    var isAxisReverse: Bool {
        return direction == .rowReverse || direction == .columnReverse
    }
    
    var isHorizontal: Bool {
        return direction == .row || direction == .rowReverse
    }
    
    var axisRatio: Float {
        get {
            if isAxisReverse {
                return -1.0
            } else {
                return 1.0
            }
        }
    }
    
    var crossRatio: Float {
        get {
            if isCrossReverse {
                return -1.0
            } else {
                return 1.0
            }
        }
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

//
//  Geometry.swift
//  Flexbox-Swift
//
//  Created by Jerry on 2018/5/28.
//  Copyright © 2018年 com.jerry. All rights reserved.
//

public struct FlexboxPoint: Equatable {
    
    public var x: Float
    
    public var y: Float
    
    public static let zero = FlexboxPoint(x: 0, y: 0)
}

public struct FlexboxSize: Equatable {
    
    public var w: Float
    
    public var h: Float
    
    public static let zero = FlexboxSize(w: 0, h: 0)
}

public struct FlexboxRect: Equatable {
    
    public var x: Float
    
    public var y: Float
    
    public var w: Float
    
    public var h: Float
    
    public var size: FlexboxSize {
        get {
            return FlexboxSize(w: w, h: h)
        }
        
        set {
            self.w = newValue.w
            self.h = newValue.h
        }
    }
    
    public var origin: FlexboxPoint {
        get {
            return FlexboxPoint(x: x, y: y)
        }
        
        set {
            self.x = newValue.x
            self.y = newValue.y
        }
    }
    
    public static let zero = FlexboxRect(x: 0, y: 0, w: 0, h: 0)
}

public struct FlexboxInsets: Equatable {
    
    public var top: Float
    
    public var left: Float
    
    public var bottom: Float
    
    public var right: Float
    
    public init(top: Float, left: Float, bottom: Float, right: Float) {
        self.top = top
        self.left = left
        self.bottom = bottom
        self.right = right
    }
    
    public static let zero = FlexboxInsets(top: 0, left: 0, bottom: 0, right: 0)
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
    
    var axisVal: Float { get set }
    
    var crossVal: Float { get set }
    
}

extension FlexboxSize: AnyDirectionalDimension {
    
    var axisVal: Float {
        get {
            switch Flexbox.Context.direction {
            case .row, .rowReverse:
                return w
            case .column, .columnReverse:
                return h
            }
        }
        set {
            switch Flexbox.Context.direction {
            case .row, .rowReverse:
                w = newValue
            case .column, .columnReverse:
                h = newValue
            }
        }
    }
    
    var crossVal: Float {
        get {
            switch Flexbox.Context.direction {
            case .row, .rowReverse:
                return h
            case .column, .columnReverse:
                return w
            }
        }
        set {
            switch Flexbox.Context.direction {
            case .row, .rowReverse:
                h = newValue
            case .column, .columnReverse:
                w = newValue
            }
        }
        
    }
}

extension FlexboxPoint: AnyDirectionalDimension {
    
    var axisVal: Float {
        get {
            switch Flexbox.Context.direction {
            case .row, .rowReverse:
                return x
            case .column, .columnReverse:
                return y
            }
        }
        set {
            switch Flexbox.Context.direction {
            case .row, .rowReverse:
                x = newValue
            case .column, .columnReverse:
                y = newValue
            }
        }
    }
    
    var crossVal: Float {
        get {
            switch Flexbox.Context.direction {
            case .row, .rowReverse:
                return y
            case .column, .columnReverse:
                return x
            }
        }
        set {
            switch Flexbox.Context.direction {
            case .row, .rowReverse:
                y = newValue
            case .column, .columnReverse:
                x = newValue
            }
        }
    }
}

extension FlexboxInsets: AnyDirectionalDimension {
    
    var axisVal: Float {
        get {
            switch Flexbox.Context.direction {
            case .row, .rowReverse:
                return left + right
            case .column, .columnReverse:
                return top + bottom
            }
        }
        set {
            fatalError("unsupported")
        }
    }
    
    var crossVal: Float {
        get {
            switch Flexbox.Context.direction {
            case .row, .rowReverse:
                return top + bottom
            case .column, .columnReverse:
                return left + right
            }
        }
        set {
            fatalError("unsupported")
        }
    }
    
    var axisVals: (Float, Float) {
        switch Flexbox.Context.direction {
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
    
    var crossVals: (Float, Float) {
        switch Flexbox.Context.direction {
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
}

extension FlexboxItem: AnyDirectionalDimension {
    
    var axisVal: Float {
        get {
            switch Flexbox.Context.direction {
            case .row, .rowReverse:
                return flexWidth
            case .column, .columnReverse:
                return flexHeight
            }
        }
        set {
            fatalError("unsupported")
        }
    }
    
    var crossVal: Float {
        get {
            switch Flexbox.Context.direction {
            case .row, .rowReverse:
                return flexHeight
            case .column, .columnReverse:
                return flexWidth
            }
        }
        set {
            fatalError("unsupported")
        }
    }
}

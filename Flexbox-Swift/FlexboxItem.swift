//
//  FlexboxItem.swift
//  Flexbox-Swift
//
//  Created by Jerry on 2018/5/24.
//  Copyright © 2018年 com.jerry. All rights reserved.
//

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
    
    static let zero = FlexboxRect(x: 0, y: 0, w: 0, h: 0)
}

struct FlexboxInsets: Equatable {
    
    var top: Float
    
    var left: Float
    
    var bottom: Float
    
    var right: Float
    
    static let zero = FlexboxInsets(top: 0, left: 0, bottom: 0, right: 0)
}

protocol FlexboxItem: class {
    
    var flex: (flexGrow: Float, flexShrink: Float, flexBasis: Float?) { get set }
    
    var flexOrder: Int { get set }
    
    var flexGrow: Float { get set }
    
    var flexShrink: Float { get set }
    
    var flexBasis: Float? { get set }
    
    var alignSelf: Flexbox.AlignSelf { get set }
    
    var flexMargin: FlexboxInsets { get set }
    
    var flexFrame: FlexboxRect? { get set }
    
    func measure(_ size: FlexboxSize) -> FlexboxSize
    
}

extension FlexboxItem {
    
    var flexWidth: Float {
        get {
            return (flexFrame?.w ?? 0) + flexMargin.left + flexMargin.right
        }
    }
    
    var flexHeight: Float {
        get {
            return (flexFrame?.h ?? 0) + flexMargin.top + flexMargin.bottom
        }
    }
}

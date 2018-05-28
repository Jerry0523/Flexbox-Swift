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
    
    static let zero = FlexboxRect(x: 0, y: 0, w: 0, h: 0)
}

struct FlexboxInsets: Equatable {
    
    var top: Float
    
    var left: Float
    
    var bottom: Float
    
    var right: Float
    
    static let zero = FlexboxInsets(top: 0, left: 0, bottom: 0, right: 0)
}

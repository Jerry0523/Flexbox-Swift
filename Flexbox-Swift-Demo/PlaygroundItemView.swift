//
//  PlaygroundItemView.swift
//  Flexbox-Swift
//
//  Created by Jerry on 2018/5/24.
//  Copyright © 2018年 com.jerry. All rights reserved.
//

import UIKit

class PlaygroundItemView: UIView {
    
    @IBOutlet var contentView: UIStackView!
    
    @IBOutlet weak var growValLabel: UILabel!
    
    @IBOutlet weak var shrinkValLabel: UILabel!
    
    @IBOutlet weak var orderLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        Bundle.main.loadNibNamed("PlaygroundItemView", owner: self, options: nil)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        self.flexMargin = FlexboxInsets(top: 10, left: 10, bottom: 0, right: 0)
        self.backgroundColor = UIColor.white
        self.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: contentView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 8.0),
            NSLayoutConstraint(item: contentView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 8.0),
            NSLayoutConstraint(item: contentView, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: -8.0),
            NSLayoutConstraint(item: contentView, attribute: .bottom, relatedBy: .lessThanOrEqual, toItem: self, attribute: .bottom, multiplier: 1.0, constant: -8.0)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func notifyLayoutAnimated() {
        UIView.animate(withDuration: 0.25) {
            self.superview?.setNeedsLayout()
            self.superview?.layoutIfNeeded()
        }
    }
    
    @IBAction func didChangeAlignSelf(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            alignSelf = .auto
        case 1:
            alignSelf = .start
        case 2:
            alignSelf = .end
        case 3:
            alignSelf = .center
        default: break
        }
        notifyLayoutAnimated()
    }
    
    @IBAction func didChangeBasis(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            flexBasis = nil
        case 1:
            flexBasis = 120.0
        case 2:
            flexBasis = 240.0
        default: break
        }
        notifyLayoutAnimated()
    }
    
    @IBAction func didChangeShrink(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            flexShrink += 1
        } else {
            flexShrink -= 1
        }
        shrinkValLabel.text = String(format: "%.0f", flexShrink)
        sender.selectedSegmentIndex = UISegmentedControlNoSegment
        notifyLayoutAnimated()
    }
    
    @IBAction func didChangeGrow(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            flexGrow += 1
        } else {
            flexGrow -= 1
        }
        growValLabel.text = String(format: "%.0f", flexGrow)
        sender.selectedSegmentIndex = UISegmentedControlNoSegment
        notifyLayoutAnimated()
    }
}

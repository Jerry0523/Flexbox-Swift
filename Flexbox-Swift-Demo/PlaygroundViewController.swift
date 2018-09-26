//
//  PlaygroundViewController.swift
//  Flexbox-Swift
//
//  Created by Jerry on 2018/5/22.
//  Copyright © 2018年 com.jerry. All rights reserved.
//

import UIKit
import Flexbox

class PlaygroundViewController: UIViewController {

    @IBOutlet weak var flexboxView: FlexboxView!
    
    @IBOutlet weak var flexboxConfigView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        flexboxView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 10)
        
//        for i in 0..<4 {
//            let itemView = PlaygroundItemView()
//            itemView.flexOrder = i
//            itemView.orderLabel.text = "\(i)"
//            flexboxView.addSubview(itemView)
//        }
        
        ["Hello world \n I hate u, I love u",
         "Who are you",
         "Life sucks \n Just hold on",
         "I have a dream \n To grow up"].map { (text) -> UILabel in
            let label = UILabel()
            label.numberOfLines = 0
            label.text = text
            label.textColor = UIColor.darkText
            label.backgroundColor = UIColor.white
            label.flexMargin = FlexboxInsets(top: 10, left: 10, bottom: 0, right: 0)
            return label
        }.forEach ( flexboxView.addSubview )
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func notifyLayoutAnimated() {
        UIView.animate(withDuration: 0.25) {
            self.flexboxView.layoutIfNeeded()
        }
    }

    @IBAction func didChangeDirection(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            flexboxView.flexbox.flexDirection = .row
        case 1:
            flexboxView.flexbox.flexDirection = .rowReverse
        case 2:
            flexboxView.flexbox.flexDirection = .column
        case 3:
            flexboxView.flexbox.flexDirection = .columnReverse
        default: break
        }
        notifyLayoutAnimated()
    }
    
    @IBAction func didToggleConfigPannel(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        UIView.animate(withDuration: 0.25) {
            if sender.isSelected {
                sender.imageView?.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
                self.flexboxConfigView.transform = CGAffineTransform(translationX: 0 , y: self.flexboxConfigView.frame.height - 30.0)
            } else {
                sender.imageView?.transform = CGAffineTransform.identity
                self.flexboxConfigView.transform = CGAffineTransform.identity
            }
        }
    }
    
    @IBAction func didChangeWrap(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            flexboxView.flexbox.flexWrap = .nowrap
        case 1:
            flexboxView.flexbox.flexWrap = .wrap
        case 2:
            flexboxView.flexbox.flexWrap = .wrapReverse
        default: break
        }
        notifyLayoutAnimated()
    }
    
    @IBAction func didChangeJustifyContent(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            flexboxView.flexbox.justifyContent = .start
        case 1:
            flexboxView.flexbox.justifyContent = .end
        case 2:
            flexboxView.flexbox.justifyContent = .center
        case 3:
            flexboxView.flexbox.justifyContent = .spaceBetween
        case 4:
            flexboxView.flexbox.justifyContent = .spaceAround
        default: break
        }
        notifyLayoutAnimated()
    }
    
    @IBAction func didChangeAlignContent(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            flexboxView.flexbox.alignContent = .start
        case 1:
            flexboxView.flexbox.alignContent = .end
        case 2:
            flexboxView.flexbox.alignContent = .center
        case 3:
            flexboxView.flexbox.alignContent = .spaceBetween
        case 4:
            flexboxView.flexbox.alignContent = .spaceAround
        case 5:
            flexboxView.flexbox.alignContent = .stretch
        default:break
        }
        notifyLayoutAnimated()
    }
    
    @IBAction func didChangeAlignItems(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            flexboxView.flexbox.alignItems = .start
        case 1:
            flexboxView.flexbox.alignItems = .end
        case 2:
            flexboxView.flexbox.alignItems = .center
        case 3:
            flexboxView.flexbox.alignItems = .stretch
        default:break
        }
        notifyLayoutAnimated()
    }
}


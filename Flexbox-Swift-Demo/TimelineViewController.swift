//
//  TimelineViewController.swift
//  Flexbox-Swift
//
//  Created by Jerry on 2018/6/22.
//  Copyright © 2018年 com.jerry. All rights reserved.
//

import UIKit

extension Array {
    
    mutating func randamArray() -> Array {
        var list = self
        for index in 0..<list.count {
            let newIndex = Int(arc4random_uniform(UInt32(list.count-index))) + index
            if index != newIndex {
                list.swapAt(index, newIndex)
            }
        }
        self = list
        return list
    }
}

class TimelineViewController: UITableViewController {
    
    var data: [MsgModel]!

    @IBAction func didClickCloseItem(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MsgModelType.allCases.forEach { modelType in
            tableView.register(modelType.cellClass, forCellReuseIdentifier: modelType.identifier)
        }
        
        if  let plistURL = Bundle.main.url(forResource: "data", withExtension: "plist"),
            let plistData = try? Data(contentsOf: plistURL) {
            let decoder = PropertyListDecoder()
            data = try? decoder.decode([MsgModel].self, from: plistData)

            (0...5).forEach{ _ in data = data + data }
        }

        data = data.randamArray()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = data[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: model.reuseIdentifier, for: indexPath)
        if let modelCell = cell as? MsgElement {
            modelCell.update(model)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

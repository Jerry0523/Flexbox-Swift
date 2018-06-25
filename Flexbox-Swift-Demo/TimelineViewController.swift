//
//  TimelineViewController.swift
//  Flexbox-Swift
//
//  Created by 王杰 on 2018/6/22.
//  Copyright © 2018年 com.jerry. All rights reserved.
//

import UIKit

class TimelineViewController: UITableViewController {

    @IBAction func didClickCloseItem(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(SimpleTextMsgCell.self, forCellReuseIdentifier: "simple")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 30
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "simple", for: indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

//
//  ViewController.swift
//  BlogAnimatedArrow
//
//  Created by stephenw on 2016/11/21.
//  Copyright © 2016年 stephenw. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  @IBOutlet weak var tableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.tableView.showPullPromotion = true
    self.tableView.pullPromotionView?.refreshAction = { [weak self] in
      DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: { 
        self?.tableView.pullPromotionView?.stopAnimate()
      })
    }
    self.tableView.dataSource = self
    self.tableView.delegate = self
    self.tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "cell")
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 20
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
    cell?.textLabel?.text = "row \(indexPath.row)"
    return cell!
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 50
  }
  
}


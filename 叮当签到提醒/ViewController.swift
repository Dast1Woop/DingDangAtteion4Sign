//
//  ViewController.swift
//  叮当签到提醒
//
//  Created by 马玉龙 on 2016/10/25.
//  Copyright © 2016年 huatu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    let lBtn = UIButton()
    lBtn.setBackgroundImage(UIImage(named: "clannad3.jpg"), forState: .Normal)
    lBtn.setBackgroundImage(UIImage(named: "clannad.jpg"), forState: .Highlighted)
    
    lBtn.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height)
    
    view.addSubview(lBtn)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}


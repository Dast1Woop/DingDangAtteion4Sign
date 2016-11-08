//
//  ViewController.swift
//  叮当签到提醒
//
//  Created by 马玉龙 on 2016/10/25.
//  Copyright © 2016年 huatu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  private let lbl4ShowIbeaconMsg : UILabel = {
    let lbl = UILabel()
    lbl.numberOfLines = 0
    lbl.backgroundColor = UIColor.whiteColor()
    
    lbl.frame = CGRectMake(0, UIScreen.mainScreen().bounds.size.height - 200, UIScreen.mainScreen().bounds.size.width, 200)

    return lbl
  }()
  
  private var gTimer : NSTimer?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let lBtn = UIButton()
    lBtn.setBackgroundImage(UIImage(named: "clannad3.jpg"), forState: .Normal)
    lBtn.setBackgroundImage(UIImage(named: "clannad.jpg"), forState: .Highlighted)
    
    lBtn.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height)
    
    view.addSubview(lBtn)
    lBtn.userInteractionEnabled = false
    
    let lG4DoubleTap = UITapGestureRecognizer.init(target: self, action: #selector(m4DoubleTap))
    lG4DoubleTap.numberOfTapsRequired = 2
    view.addGestureRecognizer(lG4DoubleTap)
    
    /* swipe 跟tap有冲突，tap优先级高？！*/
    let lG4Swipe = UIPinchGestureRecognizer.init(target: self, action: #selector(m4Swipe2RmvLbl))
    view.addGestureRecognizer(lG4Swipe)
  }
  
  func m4DoubleTap(ges : UITapGestureRecognizer) {
   
    gTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(m4UpdateLbl), userInfo: nil, repeats: true)
    NSRunLoop.currentRunLoop().addTimer(gTimer!, forMode: NSRunLoopCommonModes)
 
    view.addSubview(lbl4ShowIbeaconMsg)
  }
  
  func m4Swipe2RmvLbl()  {
    lbl4ShowIbeaconMsg.removeFromSuperview()
    
    gTimer?.invalidate()
    gTimer = nil
  }
  
  func m4UpdateLbl()  {
    var  lStr4Show = ""
    for  lM in IbeaconTool.sharedIbeaconTool().beaconModelsArray {
      let lMajor = lM.xmajor.description
      let lMinor = lM.xminor.description
      let lRssi = "\(lM.xrssi)"
      lStr4Show +=  "     major = " + lMajor + "  " + "minor = " + lMinor + "  " + "rssi = " + lRssi + "\n"
    }
    
    lbl4ShowIbeaconMsg.text = lStr4Show

  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}


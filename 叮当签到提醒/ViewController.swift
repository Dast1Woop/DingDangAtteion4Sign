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
    lbl.backgroundColor = UIColor.white
    
    lbl.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height - 200, width: UIScreen.main.bounds.size.width, height: 200)

    return lbl
  }()
  
  private var gTimer : Timer?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .white
    let lBtn = UIButton()
    lBtn.setBackgroundImage(UIImage(named: "clannad3.jpg"), for: .normal)
    lBtn.setBackgroundImage(UIImage(named: "clannad.jpg"), for: .highlighted)
    
    lBtn.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
    
    view.addSubview(lBtn)
    lBtn.isUserInteractionEnabled = false
    
    let lG4DoubleTap = UITapGestureRecognizer.init(target: self, action: #selector(m4DoubleTap))
    lG4DoubleTap.numberOfTapsRequired = 2
    view.addGestureRecognizer(lG4DoubleTap)
    
    /* swipe 跟tap有冲突，tap优先级高？！*/
    let lG4LongPress = UILongPressGestureRecognizer.init(target: self, action: #selector(m4LongPress2RmvLbl))
    view.addGestureRecognizer(lG4LongPress)

  }
  
    @objc func m4DoubleTap(ges : UITapGestureRecognizer) {
    
    /* 已定时的话就不能再创建了！否则会同时存在多个定时器 */
    if gTimer != nil{
      return
    }
    
        gTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(m4UpdateLbl), userInfo: nil, repeats: true)
        RunLoop.current.add(gTimer!, forMode: RunLoop.Mode.common)
 
    view.addSubview(lbl4ShowIbeaconMsg)
  }
  
    @objc func m4LongPress2RmvLbl()  {
    lbl4ShowIbeaconMsg.removeFromSuperview()
    
    gTimer?.invalidate()
    gTimer = nil
  }
  
    @objc func m4UpdateLbl()  {
    var  lStr4Show = ""
        for  lM in IbeaconTool.shared().beaconModelsArray {
            let lMajor = (lM as AnyObject).xmajor.description
            let lMinor = (lM as AnyObject).xminor.description
            let lRssi = "\(String(describing: (lM as AnyObject).xrssi))"
      lStr4Show +=  "     major = " + lMajor + "  " + "minor = " + lMinor + "  " + "rssi = " + lRssi + "\n"
    }
    
    lbl4ShowIbeaconMsg.text = lStr4Show
    
    iConsole.info("ibeacons:\n%@", args: getVaList([lStr4Show as NSString]))
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}


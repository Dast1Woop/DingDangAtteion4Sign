//
//  IbeaconTool.h
//  iBeaconTest
//
//  Created by 马玉龙 on 16/3/9.
//  Copyright © 2016年 马玉龙. All rights reserved.

/** 使用注意：
 1 applicationWillTerminate里调这个方法 - (void)stopIBeacon；
 2.必须和BeaconModel一起使用
 3.info.plist 必须加入这个键：NSLocationAlwaysUsageDescription
 4.[CommonData sharedCommonData].xiBeaconsDetectedArr = self.beaconModelsArray;
    要用检测到且处理过的ibeacon数组时，可以用 = 左边的方法拿到。
 */

#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>

@interface IbeaconTool : NSObject

/** 扫描到的蓝牙数组 */
@property(nonatomic, copy) NSArray *beaconModelsArray;

/** 重写locationManager  get方法，并在里面做必要设置 */
- (CLLocationManager *)locationManager;

/** 开始更新位置、监听ibencon区域和扫描ibencon */
- (void)startIbeacon;

/** 重新创建管理员、清空之前相关数据并重新扫描ibeacon */
- (void)rescanIBeacon;

/** 停止ibencon区域监听、信号扫描；置空locationMng
 applicationWillTerminate里调这个方法
 */
- (void)stopIBeacon;

/**
 * 获取最强beaconModel，当模型数组不变化时，说明蓝牙关闭了或未检测到信号，返回nil
 */
- (BeaconModel *)getStrongestBeaconModelOrNil;

+ (instancetype)sharedIbeaconTool ;

@end

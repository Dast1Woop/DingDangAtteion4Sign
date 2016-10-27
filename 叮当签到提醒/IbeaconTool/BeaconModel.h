//
//  BeaconModle.h
//  iBeaconTest
//
//  Created by 马玉龙 on 16/3/9.
//  Copyright © 2016年 马玉龙. All rights reserved.

/** 使用注意：
 1 applicationWillTerminate里调这个方法 - (void)stopIBeacon；
 2.必须和BeaconModel一起使用
 3.info.plist 必须加入这个键：NSLocationAlwaysUsageDescription
 */

#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>

@interface BeaconModel : NSObject

/** BeaconModel UUID */
@property(nonatomic, strong) NSUUID *xproximityUUID;

/** BeaconModel major 2: 室内标签 */
@property(nonatomic, copy) NSNumber *xmajor;

/** BeaconModel minor 标签id */
@property(nonatomic, copy) NSNumber *xminor;

/** BeaconModel 距离 */
@property(readwrite, nonatomic) CLProximity xproximity;

/**信号强度，一般在 -90 - -20为正常，值越大信号越强（-30 > -40）。
   大于-5为无效，常见的是0，距离太远，信号极弱，显示为0。
不能设置为NSNumber，rssi系统用的是NSInteger，转的话，会fail
 */
@property(readwrite, nonatomic, assign) NSInteger xrssi;

/** 由本类对象组成的数组 执行sort时调的自定义排序方法；
 排序后，数组中元素按照rssi的值，由大到小（信号有强到弱）排序
 */
- (NSComparisonResult)compareRssi:(BeaconModel *)beacon;

@end

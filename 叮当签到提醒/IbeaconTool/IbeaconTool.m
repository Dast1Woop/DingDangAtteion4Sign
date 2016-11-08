//
//  IbeaconTool.m
//  iBeaconTest
//
//  Created by 马玉龙 on 16/3/9.
//  Copyright © 2016年 马玉龙. All rights reserved.

/** 注意：监听两个区域时，默认是间隔扫描输出结果。
 这1s扫华途的，下一秒就只扫云子！循环往复。 */

#import "叮当签到提醒-swift.h"
#import "BeaconModel.h"
#import "IbeaconTool.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKitDefines.h>

#define kHuaTuUUID @"FDA50693-A4E2-4FB1-AFCF-C6EB07647825"
#define kCleanBeaconModelsArrayWhenLargerThanThisNumber 80
#define kHuaTuIdentifier @"huatu"
#define kStartWorkingMsg @"知行合一，上班签到..."
#define kEndWorkingMsg @"锻炼走起，下班签到.............."

@interface IbeaconTool () <CLLocationManagerDelegate, CBCentralManagerDelegate>

/** 创建的被监视的 huatu标签区域对象 */
@property(nonatomic, strong) CLBeaconRegion *beaconRegionOfHuaTu;

/** 云子标签区域对象 */
@property(nonatomic, strong) CLBeaconRegion *beaconRegionOfSensorYunZi;

/** ibeacon定位管理员 */
@property(nonatomic, strong) CLLocationManager *locationManager;

/** 蓝牙 中心设备 管理员 */
@property(nonatomic, strong) CBCentralManager *centralManager;

/** (经实测:每两次数组数据一致),那就每两次更新下commonData中ibeacon数组 */
@property(nonatomic, assign) BOOL xstoreDifferentIbeaconArrFlag;

/** 为了解决旧的蓝牙模型在忽然检测不到蓝牙信号情况下仍然定位到上一位置的bug,
 对commonData中ibeacon数组进行曲线救国:
 播报取xiBeaconHandleArr第一个模型,当此数组(保存上次的ibeacon数组)与最新xibeaconArr一样
 时,置空此数组. */
@property(nonatomic, copy) NSArray *xiBeaconHandleArr; //立刻懒加载分配空间

@property(nonatomic, strong) NSMutableArray *gNowDetectedArrM;

@end

@implementation IbeaconTool
/** 注意位置 */

static id instance;


+ (instancetype)allocWithZone:(struct _NSZone *)zone{
static dispatch_once_t onceToken;
dispatch_once(&onceToken, ^{
instance = [super allocWithZone:zone];
});
return instance;
}
- (id)copyWithZone:(NSZone *)zone {
return self;
}
+ (instancetype)sharedIbeaconTool {
return [[self alloc] init];
}

#pragma mark - 公有方法
- (void)startIbeacon {
  [self locationManager];
}

- (void)rescanIBeacon {
  [self locationManager];
  //    self.nearlyStationBeacon = nil;
}

- (void)stopIBeacon {
  [self.locationManager stopMonitoringForRegion:self.beaconRegionOfHuaTu];
  [self.locationManager stopRangingBeaconsInRegion:self.beaconRegionOfHuaTu];

  /** 对云子也终止监听 */
  [self.locationManager stopMonitoringForRegion:self.beaconRegionOfSensorYunZi];
  [self.locationManager
      stopRangingBeaconsInRegion:self.beaconRegionOfSensorYunZi];

  [self.locationManager stopUpdatingLocation];
  self.locationManager = nil;

  /** delegate是weak or assign修饰，下一句没必要吧？ */
  self.locationManager.delegate = nil;
}

#pragma mark -  delegate

- (void)locationManager:(CLLocationManager *)manager
      didDetermineState:(CLRegionState)state
              forRegion:(CLRegion *)region {
  /** 老是提醒，好烦 */
  //  UILocalNotification *localNotification = [[UILocalNotification alloc]
  //  init];
  //  if (state == CLRegionStateInside) {
  //    localNotification.alertBody = @"您在蓝牙标签围栏内。";
  //
  //    /** 通过点击通知打开应用时的启动图片,这里使用程序启动图片 */
  //    localNotification.alertLaunchImage = @"Default";
  //
  //    /** 通知声音（需要真机才能听到声音） */
  //    localNotification.soundName = @"msg.caf";
  //  } else if (state == CLRegionStateOutside) {
  //    localNotification.alertBody = @"您在蓝牙标签围栏外！";
  //
  //    /** 通过点击通知打开应用时的启动图片,这里使用程序启动图片 */
  //    localNotification.alertLaunchImage = @"Default";
  //
  //    /** 通知声音（需要真机才能听到声音） */
  //    localNotification.soundName = @"msg.caf";
  //  } else {
  //    return;
  //  }
  //  [[UIApplication sharedApplication]
  //      presentLocalNotificationNow:localNotification];
}
/**
 *  当用户进入一个监控区域时调用。这个回调将为每个分配调用
 */
- (void)locationManager:(CLLocationManager *)manager
         didEnterRegion:(CLRegion *)region {

  [manager startRangingBeaconsInRegion:(CLBeaconRegion *)region];

  //在离开区域时，停止位置更新了，所以这里进入区域时，要重新开启。
  [self.locationManager startUpdatingLocation];

    if (0 == self.gNowDetectedArrM.count) {
      return;
    }
  
    UILocalNotification *localNotification = [[UILocalNotification alloc]
    init];
    localNotification.alertBody = kStartWorkingMsg;
  
    /** 通过点击通知打开应用时的启动图片,这里使用程序启动图片 */
    localNotification.alertLaunchImage = @"Default";
  
    /** 通知声音（需要真机才能听到声音） */
    localNotification.soundName = @"msg.caf";
    [[UIApplication sharedApplication]
        presentLocalNotificationNow:localNotification];
  
}

- (void)locationManager:(CLLocationManager *)manager
          didExitRegion:(CLRegion *)region {

  [manager stopRangingBeaconsInRegion:(CLBeaconRegion *)region];
  [self.locationManager stopUpdatingLocation];
  
  if (0 == self.gNowDetectedArrM.count) {
    return;
  }
  
    UILocalNotification *localNotification = [[UILocalNotification alloc]
    init];
    localNotification.alertBody = kEndWorkingMsg;
  
    /** 通过点击通知打开应用时的启动图片,这里使用程序启动图片 */
    localNotification.alertLaunchImage = @"Default";
  
    /** 通知声音（需要真机才能听到声音） */
    localNotification.soundName = @"msg.caf";
    [[UIApplication sharedApplication]
        presentLocalNotificationNow:localNotification];
}

- (void)locationManager:(CLLocationManager *)manager
        didRangeBeacons:(NSArray<CLBeacon *> *)beacons
               inRegion:(CLBeaconRegion *)region {
  /** 清空  上上一次存储的ibeacon模型数组（公司和云子间隔被检测到，每次用时1s。
   但是云子每次都是在公司标签被检测到0.1s后就被检测到然后调用此方法了。）
   不能清空：
   1.下面有重复时取平均值的方法
   （始终是两个相邻数取平均值，如果一个突变为0，下次-80，呵呵，平均下来
   -45！解决办法：下面方法中已经把 rssi大于-5 的beaconmodel给过滤了。）
   2.两种标签被监听着，清空会导致定位判断时始终只能检测到云子标签（发包频率高）。
   */

  /** 后台执行扫描:180s */
  //  NSLog(@"[UIApplication sharedApplication].backgroundTimeRemaining = %lf",
  //        [UIApplication sharedApplication].backgroundTim6eRemaining);
  
  if (self.beaconModelsArray.count >
      kCleanBeaconModelsArrayWhenLargerThanThisNumber) {
    self.beaconModelsArray = nil;
    self.beaconModelsArray = [NSArray array];
  }
  
  [self.gNowDetectedArrM removeAllObjects];
  
  //    NSLog(@"beacons = %@", beacons);
  
  if (beacons.count <= 0)
    return;

  /**遍历beacon，过滤掉 1.无效的 2.华途的、major不是2的。 */
  for (CLBeacon *beacon in beacons) {
    @autoreleasepool {
      /** 过滤掉无效信号，常见值：0 */
      if (beacon.rssi > -5) {
        continue;
      }

      /**
       * 不解密。返回beacon模型。
       */
      BeaconModel *beaconModel = [self getBeaconModelWithBeacon:beacon];

      /** 过滤掉非华途的，或  major不是当前地点的major数组中major的部分信号 */
      if (![[beaconModel.xproximityUUID UUIDString]
              isEqualToString:[kHuaTuUUID uppercaseString]]) {
        continue;
      }

      BOOL lIfNeedBool = [self justifyIfNeedThisBeacon:beaconModel];

      if (lIfNeedBool) {
        [self addAndGetAvgRssiOfSameBeaconInbeaconModelsArray:beaconModel];
      }
    }
  }

  /**
   * 排序：方法是数组中元素自定义的比较方法。自定义的compareRssi排序后，数组元素按照rssi强度有强到弱排好，最强信号的就是
   * self.beaconModelsArray[0] */
  [self.gNowDetectedArrM sortUsingSelector:@selector(compareRssi:)];

  /** 、需要检测 云子 时，才需要下面判断 */
//  if (!self.xstoreDifferentIbeaconArrFlag) {
////    [CommonData sharedCommonData].xiBeaconsDetectedArr = self.gNowDetectedArrM;
//    self.xstoreDifferentIbeaconArrFlag = YES;
//  } else {
//    self.xstoreDifferentIbeaconArrFlag = NO;
//    return;
//  }

  NSLog(@"解密ornot，并排序后--(数组共%zd个beaconModel)",
        self.gNowDetectedArrM.count);
  [self logBeaconModelsArr:self.gNowDetectedArrM];

  /** 记录扫描到的beaconModel 数组 */
  self.beaconModelsArray = [self.gNowDetectedArrM copy];

//  [[LocateTool sharedLocateTool] startLocateCalculate];
}

// TODO: 待完善
- (NSArray *)getCrtPlaceMajorArr
// WithAreaID:()//10078:辽宁major，只有这一个
{
  return @[ @888 ];
}

- (BOOL)justifyIfNeedThisBeacon:(BeaconModel *)bcModel {

  for (NSNumber *lMajorNum in [self getCrtPlaceMajorArr]) {
    if (bcModel.xmajor.intValue == lMajorNum.intValue) {
      return YES;
    }
  }

  return NO;
}

/** 0621,测试经纬度，反地理编码 */
//- (void)locationManager:(CLLocationManager *)manager
//    didUpdateToLocation:(CLLocation *)newLocation
//           fromLocation:(CLLocation *)oldLocation {
//  //  //经度
//  //  NSString *lLongitude =
//  //      [NSString stringWithFormat:@"%lf",
//  newLocation.coordinate.longitude];
//  //  //纬度
//  //  NSString *lLatitude =
//  //      [NSString stringWithFormat:@"%lf", newLocation.coordinate.latitude];
//
//  //  NSLog(@"经度 = %@,纬度 = %@", lLongitude, lLatitude);
//
//  // 获取当前所在的城市名
//  CLGeocoder *geocoder = [[CLGeocoder alloc] init];
//  //根据经纬度反向地理编译出地址信息
//  [geocoder reverseGeocodeLocation:newLocation
//                 completionHandler:^(NSArray *array, NSError *error) {
//                   if (array.count > 0) {
//                     //                     CLPlacemark *placemark = [array
//                     //                     objectAtIndex:0];
//                     //                     NSString *lLocation =
//                     //                     placemark.name;
//                     //                     NSLog(@"反地理编码信息 = %@",
//                     //                     lLocation);
//                     //                     NSString *city =
//                     placemark.locality;
//                     //                     //获取城市
//                     //                     if (!city) {
//                     //
//                     //四大直辖市的城市信息无法通过locality获得，只能通过获取省份的方法来获得（如果city为空，则可知为直辖市）
//                     //                       city =
//                     //                       placemark.administrativeArea;
//                     //                     }
//                     //                     NSLog(@"city = %@", city);
//                   } else if (error == nil && [array count] == 0) {
//                     NSLog(@"No results were returned.");
//                   } else if (error != nil) {
//                     NSLog(@"An error occurred = %@", error);
//                   }
//                 }];
//}

- (void)logBeaconModelsArr:(NSArray *)arr {
  for (int i = 0; i < arr.count; ++i) {
    BeaconModel *bm = arr[i];
    NSLog(@"xproximityUUID = %@, major = %@, minor = %@, rssi = %zd, proximity "
          @"= %zd",
          [bm.xproximityUUID UUIDString], bm.xmajor, bm.xminor, bm.xrssi,
          bm.xproximity);
  }
}

/**
 * ibeacon可能1s扫到两个包，此方法过滤掉重复的旧值，rssi未取平均值。
 */
//- (void)addAndRemoveOldSameModelInbeaconModelsArray:(BeaconModel *)beaconModel
//{
//  for (int i = 0; i < self.beaconModelsArray.count; ++i) {
//    @autoreleasepool {
//      BeaconModel *tempBeaconModel = self.beaconModelsArray[i];
//      if (tempBeaconModel.xminor.intValue == beaconModel.xminor.intValue) {
//        tempBeaconModel.xrssi = beaconModel.xrssi;
//        return;
//      }
//    }
//  }
//
//  [self.beaconModelsArray addObject:beaconModel];
//}

// TODO: 待封装为传入一个新检测到的数组，就输出一个处理过的想要的数组。
- (void)addAndGetAvgRssiOfSameBeaconInbeaconModelsArray:
    (BeaconModel *)beaconModel {

  /** 1.上次数组中有的模型，对rssi取平均值，加入新数组中
   2.新检测到上次数组中没有的，加入新数组
   最后返回新数组*/
  for (int i = 0; i < self.beaconModelsArray.count; ++i) {
    @autoreleasepool {
      BeaconModel *tempBeaconModel = self.beaconModelsArray[i];
      if (tempBeaconModel.xminor.intValue == beaconModel.xminor.intValue) {

        /** 取与上一次rssi的平均值。赋值给数组中旧的模型。然后结束 本方法。 */
        tempBeaconModel.xrssi =
            0.5 * (tempBeaconModel.xrssi + beaconModel.xrssi);

        [self.gNowDetectedArrM addObject:tempBeaconModel];
        return;
      }
    }
  }

  /**
   清空self.beaconModelsArray数组，重新赋值检测到的所有beacon有效信号平均值数组。
   以解决不再检测到信号时，之前某个点很强，就一直是数组中最强点的bug！*/
  [self.gNowDetectedArrM addObject:beaconModel];
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {

  //    typedef NS_ENUM(NSInteger, CBCentralManagerState) {
  //        CBCentralManagerStateUnknown = 0,
  //        CBCentralManagerStateResetting,
  //        CBCentralManagerStateUnsupported,
  //        CBCentralManagerStateUnauthorized,
  //        CBCentralManagerStatePoweredOff,
  //        CBCentralManagerStatePoweredOn,
  //    };
  switch (central.state) {
  case CBCentralManagerStateUnknown: {
    NSLog(@"CBCentralManagerStateUnknown");
    break;
  }
  case CBCentralManagerStateResetting: {
    NSLog(@"CBCentralManagerStateResetting");
    break;
  }
  case CBCentralManagerStateUnsupported: {
    NSLog(@"CBCentralManagerStateUnsupported");
    break;
  }
  case CBCentralManagerStateUnauthorized: {
    NSLog(@"CBCentralManagerStateUnauthorized");
    break;
  }
  case CBCentralManagerStatePoweredOff: {
    NSLog(@"CBCentralManagerStatePoweredOff");
    /**
     *ps：慎用！主动跳的话会导致
     定位界面被迫未选定就被挤开导致设置失败！影响以后地图定位需求的扩展。
     计步功能倒是默认选择了允许。

     下面代码不写系统检测到这个方法能执行却没有打开蓝牙的话会自动弹出警告框，让用户选择是否打开蓝牙。
     写的话有改善：1.对盲人来说，省去选择，自动跳到蓝牙设置界面。设置好后，系统状态栏下方会有返回到此app的状态栏。默认跳转是没有的。
     2.如果不自己通过代码跳过去设置蓝牙的话，当用户不小心关闭蓝牙时，不会自动跳到蓝牙设置界面
     */
    //    NSURL *url = [NSURL URLWithString:@"prefs:root=Bluetooth"];
    //    if ([[UIApplication sharedApplication] canOpenURL:url]) {
    //      [[UIApplication sharedApplication] openURL:url];
    //    }
    break;
  }
  case CBCentralManagerStatePoweredOn: {
    NSLog(@"蓝牙已开启");
    break;
  }
  }
  NSLog(@"%s", __func__);
}

#pragma mark -  error handing
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
  NSLog(@"%@", [error localizedDescription]);
}

- (void)locationManager:(CLLocationManager *)manager
    monitoringDidFailForRegion:(CLRegion *)region
                     withError:(NSError *)error {
  NSLog(@"%@", [error localizedDescription]);
}

- (void)locationManager:(CLLocationManager *)manager
    rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region
                         withError:(NSError *)error {
  NSLog(@"%@", [error localizedDescription]);
}

#pragma mark -  解密 or not
/**
 *
 1.HT:解密:解密之后才是0或4（车）、1（站台）、2（室内），扫描到的都是加密过的。并不是原始的数字！指定的话往往扫描不到想要的结果！
 2.sensor云子，不解密。
 */
- (BeaconModel *)getBeaconModelWithBeacon:(CLBeacon *)beacon {
  BeaconModel *beaconModel = [[BeaconModel alloc] init];

  //  if ([[beacon.proximityUUID UUIDString]
  //          isEqualToString:[kSensorUUID uppercaseString]]) {
  beaconModel.xmajor = beacon.major;
  beaconModel.xminor = beacon.minor;
  //  } else if ([[beacon.proximityUUID UUIDString]
  //                 isEqualToString:[kHuaTuUUID uppercaseString]]) {
  //    int major = [beacon.major intValue];
  //    int minor = [beacon.minor intValue];
  //
  //    Byte majorByte[2];
  //    Byte minorByte[2];
  //
  //    majorByte[1] = major;
  //    majorByte[0] = major >> 8;
  //
  //    minorByte[1] = minor;
  //    minorByte[0] = minor >> 8;
  //
  //    Byte origMajor[2];
  //    Byte origMinor[2];
  //
  //    Byte rngNum;
  //    Byte majorTemp[2];
  //    Byte minorTemp[2];
  //
  //    rngNum = (Byte)(((majorByte[0] >> 4) & 0x0f) | (majorByte[0] & 0xf0));
  //    majorTemp[0] = (Byte)(((majorByte[0] & 0x0f) - (rngNum & 0x0f)) & 0x0f);
  //    majorTemp[1] = (Byte)(majorByte[1] ^ rngNum);
  //
  //    minorTemp[0] = (Byte)((minorByte[0] - 0xA5) ^ rngNum);
  //    minorTemp[1] = (Byte)((minorByte[1] - 0x5A) ^ rngNum);
  //
  //    origMajor[0] = (Byte)((majorTemp[0] & 0x0f) | (rngNum & 0xf0));
  //    origMajor[1] =
  //        (Byte)(((majorTemp[1] << 4) & 0xf0) | ((majorTemp[1] >> 4) & 0x0f));
  //
  //    origMinor[0] = minorTemp[1];
  //    origMinor[1] = minorTemp[0];
  //
  //    int origMajorInt =
  //        (int)((((origMajor[0] & 0x07) << 3)) | ((origMajor[1] & 0xe0) >>
  //        5));
  //    int origMinorInt =
  //        (int)(((origMajor[1] & 0x1f) << 16) | ((origMinor[0] & 0xff) << 8) |
  //              (origMinor[1] & 0xff));
  //
  //    beaconModel.xmajor = [NSNumber numberWithInt:origMajorInt];
  //    beaconModel.xminor = [NSNumber numberWithInt:origMinorInt];
  //  }

  beaconModel.xproximity = beacon.proximity;
  beaconModel.xrssi = beacon.rssi;
  beaconModel.xproximityUUID = beacon.proximityUUID;

  return beaconModel;
}

#pragma mark -  action

//- (BeaconModel *)getStrongestBeaconModelOrNil {
//
//  /** 擦,经调试发现:self.xiBeaconHandleArr居然和[[CommonData
//   sharedCommonData].xiBeaconsDetectedArr能 保持同步更新!
//   因为:可变数组赋值给不可变数组时,如果数组数据不想保持同步,必须用 copy!
//   或者 @property中修饰NSArray用copy修饰.
//   否则因指针指向同一块空间,导致默认是同步的.
//   */
////  self.xiBeaconHandleArr =
////      [[CommonData sharedCommonData].xiBeaconsDetectedArr copy];
////  return self.xiBeaconHandleArr.firstObject;
//}

#pragma mark -  lazyLoad
- (CLLocationManager *)locationManager {

  /** 必须在界面显示前手动调用 centralManager，否则
   * 代理方法centralManagerDidUpdateState
   * 不会被触发,无法实现蓝牙状态的检测和跳转到蓝牙设计界面 */
  [self centralManager];

  /** 标准的懒加载，保证在本类中 _locationManager对象始终只有一个。 */
  if (!_locationManager) {
    /** authorizationStatus: Returns the current authorization status of the
     * calling application. */
    _locationManager = [[CLLocationManager alloc] init];

    if (([CLLocationManager authorizationStatus] !=
         kCLAuthorizationStatusAuthorizedAlways) &
        [_locationManager
            respondsToSelector:@selector(requestAlwaysAuthorization)]) {
      [_locationManager requestAlwaysAuthorization];
    }

    switch ([CLLocationManager authorizationStatus]) {
    case kCLAuthorizationStatusAuthorizedAlways:
      NSLog(@"Authorized Always");
      break;
    case kCLAuthorizationStatusAuthorizedWhenInUse:
      NSLog(@"Authorized when in use");
      break;
    case kCLAuthorizationStatusDenied:
      NSLog(@"Denied");
      break;
    case kCLAuthorizationStatusNotDetermined:
      NSLog(@"Not determined");
      break;
    case kCLAuthorizationStatusRestricted:
      NSLog(@"Restricted");
      break;

    default:
      break;
    }

    _locationManager.delegate = self;

    /** 默认是yes，改为no，保证任何时候都能更新位置 */
    _locationManager.pausesLocationUpdatesAutomatically = NO;

    //    默认就是best，可不设置
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;

    /** iOS9才有,必须判断是否响应！否则崩溃！这也是避免判断版本号的巧妙方法 */
    if ([self respondsToSelector:@selector(allowsBackgroundLocationUpdates)]) {
      _locationManager.allowsBackgroundLocationUpdates = YES;
    }

//    /** 添加云子区域对象 */
//    [_locationManager startMonitoringForRegion:self.beaconRegionOfSensorYunZi];
//    [_locationManager
//        startRangingBeaconsInRegion:self.beaconRegionOfSensorYunZi];

    /** 监视给定的条目 */
    [_locationManager startMonitoringForRegion:self.beaconRegionOfHuaTu];
    [_locationManager startRangingBeaconsInRegion:self.beaconRegionOfHuaTu];

    [_locationManager startUpdatingLocation];
  }
  return _locationManager;
}

- (CLBeaconRegion *)beaconRegionOfHuaTu {
  if (!_beaconRegionOfHuaTu) {
    NSUUID *beaconUUID =
        [[NSUUID alloc] initWithUUIDString:[kHuaTuUUID uppercaseString]];
    NSString *regionIdentifier = kHuaTuIdentifier;

    //!!!:创建时 不能 指定扫描区域的major，
    //!解密之后才是0或4（车）、1（站台）、2（室内），扫描到的都是加密过的。并不是原始的数字！指定的话往往扫描不到想要的结果！
    _beaconRegionOfHuaTu =
        [[CLBeaconRegion alloc] initWithProximityUUID:beaconUUID
                                           identifier:regionIdentifier];
  }
  return _beaconRegionOfHuaTu;
}

//- (CLBeaconRegion *)beaconRegionOfSensorYunZi {
//  if (!_beaconRegionOfSensorYunZi) {
//    NSUUID *beaconUUID =
//        [[NSUUID alloc] initWithUUIDString:[kSensorUUID uppercaseString]];
//    NSString *regionIdentifier = kSensorIdentifier;
//    _beaconRegionOfSensorYunZi =
//        [[CLBeaconRegion alloc] initWithProximityUUID:beaconUUID
//                                           identifier:regionIdentifier];
//  }
//  return _beaconRegionOfSensorYunZi;
//}

- (CBCentralManager *)centralManager {
  if (!_centralManager) {
    /**
     CBCentralManagerOptionShowPowerAlertKey:当键设置为此项时，如果用户在蓝牙开启状态下关闭蓝牙，会自动跳到蓝牙设置界面。
     A Boolean value that specifies whether the system should display a warning
     dialog to the user if Bluetooth is powered off when the central manager is
     instantiated.

     The value for this key is an NSNumber object. If the key is not specified,
     the default value is NO. */
    _centralManager = [[CBCentralManager alloc]
        initWithDelegate:self
                   queue:nil
                 options:@{
                   CBCentralManagerOptionShowPowerAlertKey : @(1)
                 }];
  }
  return _centralManager;
}

- (NSArray *)beaconModelsArray {
  if (!_beaconModelsArray) {
    _beaconModelsArray = [NSArray array];
  }
  return _beaconModelsArray;
}

- (NSArray *)xiBeaconHandleArr {
  if (!_xiBeaconHandleArr) {
    _xiBeaconHandleArr = [NSArray array];
  }
  return _xiBeaconHandleArr;
}

- (NSMutableArray *)gNowDetectedArrM {
  if (!_gNowDetectedArrM) {
    _gNowDetectedArrM = [NSMutableArray array];
  }
  return _gNowDetectedArrM;
}

@end

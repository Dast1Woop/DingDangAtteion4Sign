//
//  BeaconModle.m
//  iBeaconTest
//
//  Created by 马玉龙 on 16/3/9.
//  Copyright © 2016年 马玉龙. All rights reserved.
//

#import "BeaconModel.h"

@implementation BeaconModel

- (NSComparisonResult)compareRssi:(BeaconModel *)beacon {
  NSComparisonResult result;
  if (self.xrssi > beacon.xrssi) {
    result = NSOrderedAscending;
  } else if (self.xrssi < beacon.xrssi) {
    result = NSOrderedDescending;
  } else {
    result = NSOrderedSame;
  }
  return result;
}

@end

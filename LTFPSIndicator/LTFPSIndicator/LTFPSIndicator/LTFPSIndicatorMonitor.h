//
//  LTFPSIndicatorMonitor.h
//  LTFPSIndicator
//
//  Created by 李腾 on 2017/7/24.
//  Copyright © 2017年 lt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LTFPSIndicatorMonitor : NSObject

+ (instancetype)sharedInstance;

- (instancetype)init NS_DESIGNATED_INITIALIZER;

- (void)startMonitoring;

- (void)pauseMonitoring;

- (void)hideMonitoring;

- (void)stopMonitoring;

@end

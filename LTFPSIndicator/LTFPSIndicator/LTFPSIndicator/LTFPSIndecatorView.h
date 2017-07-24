//
//  LTFPSIndecatorView.h
//  LTFPSIndicator
//
//  Created by 李腾 on 2017/7/24.
//  Copyright © 2017年 lt. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LTMonitorDelegate;

@interface LTFPSIndecatorView : UIView

@property (nonatomic,weak)id<LTMonitorDelegate> delegate;

- (void)pauseMonitoring;

- (void)resumeMonitoringAndShowMonitoringView:(BOOL)showView;

- (void)hideMonitoring;

- (void)stopMonitoring;

@end

@protocol LTMonitorDelegate <NSObject>

- (void)monitorDidReportFPS:(int)fpsValue CPU:(float)cpuValue;

@end

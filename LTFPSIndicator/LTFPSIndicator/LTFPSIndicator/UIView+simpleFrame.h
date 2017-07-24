//
//  UIView+simpleFrame.h
//  LTFPSIndicator
//
//  Created by 李腾 on 2017/7/24.
//  Copyright © 2017年 lt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (simpleFrame)

#pragma mark - ************* get Frame
- (CGFloat)x;
- (CGFloat)y;
- (CGFloat)width;
- (CGFloat)height;

#pragma mark - ************* set Frame
- (void)x:(CGFloat)x;
- (void)y:(CGFloat)y;
- (void)setWidth:(CGFloat)width;
- (void)setHeight:(CGFloat)height;

@end

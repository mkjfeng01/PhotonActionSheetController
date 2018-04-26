//
//  UIColor+PhotonActionSheet.h
//  PhotonActionSheet
//
//  Created by bluestone on 2018/4/25.
//  Copyright © 2018年 bluestone. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (PhotonActionSheet)

+ (UIColor *)colorWithHex:(UInt32)hex andAlpha:(CGFloat)alpha;

+ (UIColor *)colorWithHex:(UInt32)hex;
+ (UIColor *)colorWithHexString:(id)input;

- (UInt32)hexValue;

@end

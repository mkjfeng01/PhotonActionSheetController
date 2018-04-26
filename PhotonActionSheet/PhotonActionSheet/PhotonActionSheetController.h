//
//  PhotonActionSheetController.h
//  PhotonActionSheet
//
//  Created by bluestone on 2018/4/26.
//  Copyright © 2018年 bluestone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class PhotonActionSheetItem;

@interface PhotonActionSheetController : NSObject

- (void)presentSheetWithTitle:(NSString *)title actions:(NSArray<NSArray<PhotonActionSheetItem *>*> *)actions on:(UIViewController<UIPopoverPresentationControllerDelegate> *)onViewController from:(UIView *)fromView supressPopover:(BOOL)supressPopover;


@end

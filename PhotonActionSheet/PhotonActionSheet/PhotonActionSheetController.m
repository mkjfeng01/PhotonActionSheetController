//
//  PhotonActionSheetController.m
//  PhotonActionSheet
//
//  Created by bluestone on 2018/4/26.
//  Copyright © 2018年 bluestone. All rights reserved.
//

#import "PhotonActionSheetController.h"
#import "PhotonActionSheet.h"
#import "UIColor+PhotonActionSheet.h"
#import "PhotonActionSheetAnimator.h"

@implementation PhotonActionSheetController

- (void)presentSheetWithTitle:(NSString *)title actions:(NSArray<NSArray<PhotonActionSheetItem *>*> *)actions on:(UIViewController<UIPopoverPresentationControllerDelegate> *)onViewController from:(UIView *)fromView supressPopover:(BOOL)supressPopover {
    PhotonActionSheetAnimator *animator = [[PhotonActionSheetAnimator alloc] init];
    PhotonActionSheet *sheet = [[PhotonActionSheet alloc] initWithTitle:title actions:actions];
    sheet.modalPresentationStyle = (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad && !supressPopover) ? UIModalPresentationPopover : UIModalPresentationOverCurrentContext;
    sheet.photonTransitionDelegate = animator;
    
//    UIPopoverPresentationController *popover = sheet.popoverPresentationController;
//    if (popover && sheet.modalPresentationStyle == UIModalPresentationPopover) {
//        popover.delegate = onViewController;
//        popover.sourceView = fromView;
//        popover.sourceRect = CGRectMake(fromView.frame.size.width/2, fromView.frame.size.height*0.75, 1, 1);
//        popover.permittedArrowDirections = UIPopoverArrowDirectionUp;
//        popover.backgroundColor = [[UIColor colorWithHex:0xf9f9fa] colorWithAlphaComponent:0.7];
//    }
    
    [onViewController presentViewController:sheet animated:YES completion:nil];
}

@end

//
//  PhotonActionSheetAnimator.m
//  PhotonActionSheet
//
//  Created by bluestone on 2018/4/25.
//  Copyright © 2018年 bluestone. All rights reserved.
//

#import "PhotonActionSheetAnimator.h"
#import "PhotonActionSheet.h"

static CGFloat const AnimationDuration = 0.4;

@interface PhotonActionSheetAnimator ()

@property (nonatomic, assign) BOOL presenting;

@property (nonatomic, strong) UIView *shadow;

@end

@implementation PhotonActionSheetAnimator

- (instancetype)init {
    if (self == [super init]) {
        _presenting = NO;
        _shadow = [[UIView alloc] init];
        _shadow.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    }
    return self;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *from = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *to = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    PhotonActionSheet *actionSheet = (PhotonActionSheet *)(self.presenting ? to : from);
    if (![actionSheet isKindOfClass:[PhotonActionSheet class]]) {
        return;
    }
    
    UIViewController *bottom = (self.presenting ? from : to);
    [self animateWithViewController:actionSheet PresentinViewController:bottom transitionContext:transitionContext];
}

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return AnimationDuration;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    _presenting = YES;
    
    return self;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    _presenting = NO;
    
    return self;
}

- (void)animateWithViewController:(PhotonActionSheet *)actionSheet PresentinViewController:(UIViewController *)viewController transitionContext:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIView *containerView = transitionContext.containerView;
    
    NSLog(@"😳");
    
    if (self.presenting) {
        self.shadow.frame = containerView.bounds;
        [containerView addSubview:self.shadow];
        actionSheet.view.frame = CGRectMake(0, containerView.frame.size.height, containerView.frame.size.width, containerView.frame.size.height);
        self.shadow.alpha = 0;
        [containerView addSubview:actionSheet.view];
        [actionSheet.view layoutIfNeeded];
        
        [UIView animateWithDuration:AnimationDuration delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0.3 options:0 animations:^{
            self.shadow.alpha = 1;
            actionSheet.view.frame = containerView.bounds;
            [actionSheet.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:finished];
        }];
    } else {
        [UIView animateWithDuration:AnimationDuration delay:0 usingSpringWithDamping:1.2 initialSpringVelocity:0 options:0 animations:^{
            self.shadow.alpha = 0;
            actionSheet.view.frame = CGRectMake(0, containerView.frame.size.height, containerView.frame.size.width, containerView.frame.size.height);
            [actionSheet.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            [actionSheet.view removeFromSuperview];
            [self.shadow removeFromSuperview];
            [transitionContext completeTransition:finished];
        }];
    }
}

@end

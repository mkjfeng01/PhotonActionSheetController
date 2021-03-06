//
//  ViewController.m
//  PhotonActionSheet
//
//  Created by bluestone on 2018/4/25.
//  Copyright © 2018年 bluestone. All rights reserved.
//

#import "ViewController.h"
#import "PhotonActionSheetController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (IBAction)show:(id)sender {
    PhotonActionSheetItem *first = [[PhotonActionSheetItem alloc] initWithTitle:@"1" text:nil iconString:@"menu-panel-TopSites" isEnabled:NO accessory:PhotonActionCellAccessoryNone accessoryText:nil bold:NO handler:^(PhotonActionSheetItem *item) {
        NSLog(@"%@", item.title);
    }];
    PhotonActionSheetItem *second = [[PhotonActionSheetItem alloc] initWithTitle:@"2" text:nil iconString:@"menu-panel-Bookmarks" isEnabled:NO accessory:PhotonActionCellAccessoryNone accessoryText:nil bold:NO handler:^(PhotonActionSheetItem *item) {
        
    }];
    PhotonActionSheetItem *third = [[PhotonActionSheetItem alloc] initWithTitle:@"3" text:nil iconString:@"menu-panel-History" isEnabled:NO accessory:PhotonActionCellAccessoryNone accessoryText:nil bold:NO handler:^(PhotonActionSheetItem *item) {
        
    }];
    PhotonActionSheetItem *forth = [[PhotonActionSheetItem alloc] initWithTitle:@"4" text:nil iconString:@"menu-panel-ReadingList" isEnabled:NO accessory:PhotonActionCellAccessoryNone accessoryText:nil bold:NO handler:^(PhotonActionSheetItem *item) {
        
    }];
    
    PhotonActionSheetController *sheet = [PhotonActionSheetController sheetControllerWithTitle:nil actions:@[@[first, second], @[third, forth]] supressPopover:YES];
    
    [self presentViewController:sheet animated:YES completion:nil];
}

@end

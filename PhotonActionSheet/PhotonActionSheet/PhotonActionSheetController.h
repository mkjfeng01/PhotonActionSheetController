//
//  PhotonActionSheet.h
//  PhotonActionSheet
//
//  Created by bluestone on 2018/4/25.
//  Copyright © 2018年 bluestone. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PhotonActionSheetItem;

typedef NS_ENUM(NSInteger, PhotonActionSheetPresentationStyle) {
    PhotonActionSheetPresentationCentered,
    PhotonActionSheetPresentationBottom
};

typedef NS_ENUM(NSInteger, PhotonActionCellAccessoryType) {
    PhotonActionCellAccessoryDisclosure,
    PhotonActionCellAccessorySwitch,
    PhotonActionCellAccessoryText,
    PhotonActionCellAccessoryNone
};

typedef void (^PhotonActionCellHandler)(PhotonActionSheetItem *item);

@interface PhotonActionSheetController : UIViewController

+ (instancetype)sheetControllerWithTitle:(NSString *)title actions:(NSArray<NSArray<PhotonActionSheetItem *>*> *)actions supressPopover:(BOOL)supressPopover;

- (instancetype)initWithTitle:(NSString *)title actions:(NSArray<NSArray<PhotonActionSheetItem *>*> *)actions;
- (instancetype)initWithActions:(NSArray<NSArray<PhotonActionSheetItem *>*> *)actions;

@end

@interface PhotonActionSheetItem : NSObject

- (instancetype)initWithTitle:(NSString *)title
                         text:(NSString *)text
                   iconString:(NSString *)iconString
                    isEnabled:(BOOL)isEnabled
                    accessory:(PhotonActionCellAccessoryType)accessory
                accessoryText:(NSString *)accessoryText
                         bold:(BOOL)bold
                      handler:(PhotonActionCellHandler)handler;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *iconString;
@property (nonatomic, assign) BOOL isEnabled;
@property (nonatomic, assign) PhotonActionCellAccessoryType accessory;
@property (nonatomic, copy) NSString *accessoryText;
@property (nonatomic, assign) BOOL bold;
@property (nonatomic, copy) PhotonActionCellHandler handler;

@end

@interface PhotonActionSheetTitleHeaderView: UITableViewHeaderFooterView

- (void)configureWithTitle:(NSString *)title;

@end

@interface PhotonActionSheetSeparator : UITableViewHeaderFooterView

@end

@interface PhotonActionSheetCell : UITableViewCell

- (void)configureWithAction:(PhotonActionSheetItem *)action;

@end

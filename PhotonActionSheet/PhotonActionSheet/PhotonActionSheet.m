//
//  PhotonActionSheet.m
//  PhotonActionSheet
//
//  Created by bluestone on 2018/4/25.
//  Copyright © 2018年 bluestone. All rights reserved.
//

#import "PhotonActionSheet.h"
#import "PhotonActionSheetAnimator.h"
#import "UIColor+PhotonActionSheet.h"
#import "UIImage+ImageEffects.h"

#if __has_include(<Masonry/Masonry.h>)
#import <Masonry/Masonry.h>
#else
#import "Masonry.h"
#endif

static CGFloat const MaxWidth = 414;
static CGFloat const Padding = 10;
static CGFloat const HeaderFooterHeight = 20;
static CGFloat const RowHeight = 50;
static UIColor * BorderColor = nil;
static CGFloat const CornerRadius = 10;
static CGSize IconSize;
static NSString * const SiteHeaderName = @"PhotonActionSheetSiteHeaderView";
static NSString * const TitleHeaderName = @"PhotonActionSheetTitleHeaderView";
static NSString * const CellName = @"PhotonActionSheetCell";
static CGFloat const CloseButtonHeight = 56;
static CGFloat const TablePadding = 6;

@implementation PhotonActionSheetItem

- (instancetype)initWithTitle:(NSString *)title text:(NSString *)text iconString:(NSString *)iconString isEnabled:(BOOL)isEnabled accessory:(PhotonActionCellAccessoryType)accessory accessoryText:(NSString *)accessoryText bold:(BOOL)bold handler:(PhotonActionCellHandler)handler {
    self = [super init];
    if (self) {
        _title = title;
        _text = text;
        _iconString = iconString;
        _isEnabled = isEnabled;
        _accessory = accessory;
        _accessoryText = accessoryText;
        _bold = bold;
        _handler = handler;
    }
    
    return self;
}

@end

@interface PhotonActionSheet () <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSArray <NSArray<PhotonActionSheetItem *>*> *actions;
@property (nonatomic, assign) PhotonActionSheetPresentationStyle style;
@property (nonatomic, strong) UIColor *tintColor;
@property (nonatomic, assign) BOOL showCloseButton;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer;
@property (nonatomic, strong) UIButton *closeButton;

@end

@implementation PhotonActionSheet

+ (void)load {
    BorderColor = [UIColor colorWithWhite:0 alpha:0.1];
    IconSize = CGSizeMake(24, 24);
}

- (instancetype)initWithTitle:(NSString *)title actions:(NSArray<NSArray<PhotonActionSheetItem *>*> *)actions {
    self = [super init];
    if (self) {
        self.title = title;
        _actions = actions;
        _style = PhotonActionSheetPresentationBottom;
    }
    
    return self;
}

- (instancetype)initWithActions:(NSArray<NSArray<PhotonActionSheetItem *>*> *)actions {
    return [self initWithTitle:nil actions:actions];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.style == PhotonActionSheetPresentationCentered) {
        self.tintColor = [UIColor colorWithHex:0x0a84ff];
    }
    
    [self.view addGestureRecognizer:self.tapRecognizer];
    [self.view addSubview:self.tableView];
    self.view.accessibilityIdentifier = @"Action Sheet";
    
    if (!self.popoverPresentationController) {
        self.tableView.backgroundColor = [[UIColor colorWithHex:0xf9f9fa] colorWithAlphaComponent:0.7];
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        self.tableView.backgroundView = blurEffectView;
    } else {
        self.tableView.backgroundColor = [UIColor clearColor];
    }
    
    CGFloat width = MIN(self.view.frame.size.width, MaxWidth) - Padding * 2;
    
    if (self.showCloseButton) {
        [self.view addSubview:self.closeButton];
        [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view.mas_centerX);
            make.width.mas_equalTo(width);
            make.height.mas_equalTo(CloseButtonHeight);
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).inset(Padding);
        }];
    }
    
    if (self.style == PhotonActionSheetPresentationBottom && self.modalPresentationStyle == UIModalPresentationPopover) {
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    } else {
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view.mas_centerX);
            switch (self.style) {
                case PhotonActionSheetPresentationBottom:
                    make.bottom.equalTo(self.closeButton.mas_top).offset(-Padding);
                    break;
                case PhotonActionSheetPresentationCentered:
                    make.centerY.equalTo(self.view.mas_centerY);
                    break;
            }
            make.width.mas_equalTo(width);
        }];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat maxHeight = self.view.frame.size.height - (self.showCloseButton ? CloseButtonHeight : 0);
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(MIN(self.tableView.contentSize.height, maxHeight * 0.8));
    }];
    
    if (self.style == PhotonActionSheetPresentationBottom && self.modalPresentationStyle == UIModalPresentationPopover) {
        self.preferredContentSize = self.tableView.contentSize;
    }
}

- (void)applyBackgroundBlur {
    UIGraphicsBeginImageContextWithOptions(self.view.frame.size, NO, [UIScreen mainScreen].scale);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImage *blurImage = [screenshot applyBlurWithRadius:5 tintColor:[[UIColor blackColor] colorWithAlphaComponent:0.2] saturationDeltaFactor:1.8 maskImage:nil];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:blurImage];
    [self.view addSubview:imageView];
}

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    
    if (self.traitCollection.verticalSizeClass != previousTraitCollection.verticalSizeClass || self.traitCollection.horizontalSizeClass != previousTraitCollection.horizontalSizeClass) {
        [self updateViewConstraints];
    }
}

- (void)setPhotonTransitionDelegate:(id<UIViewControllerTransitioningDelegate>)photonTransitionDelegate {
    self.transitioningDelegate = photonTransitionDelegate;
}

- (BOOL)showCloseButton {
    return self.style == PhotonActionSheetPresentationBottom && self.modalPresentationStyle != UIModalPresentationPopover;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (CGRectContainsPoint(self.tableView.frame, [touch locationInView:self.view])) {
        return NO;
    }
    
    return YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.actions.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.actions[section] count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PhotonActionSheetItem *action = self.actions[indexPath.section][indexPath.row];
    if (action.handler) {
        action.handler(action);
    }
    
    [self dismiss];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PhotonActionSheetCell *cell = [tableView dequeueReusableCellWithIdentifier:CellName forIndexPath:indexPath];
    PhotonActionSheetItem *action = self.actions[indexPath.section][indexPath.row];
    cell.tintColor = action.isEnabled ? [UIColor colorWithHex:0x0a84ff] : self.tintColor;
    [cell configureWithAction:action];
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section > 0) {
        return [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"SeparatorSectionHeader"];
    }
    
    if (self.title) {
        PhotonActionSheetTitleHeaderView *header = (PhotonActionSheetTitleHeaderView *)[tableView dequeueReusableHeaderFooterViewWithIdentifier:TitleHeaderName];
        header.tintColor = self.tintColor;
        [header configureWithTitle:self.title];
        return header;
    }
    
    UIView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"EmptyHeader"];
    if (view) {
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(1);
        }];
    }
    
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [self.tableView dequeueReusableHeaderFooterViewWithIdentifier:@"EmptyHeader"];
    if (view) {
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(1);
        }];
    }
    
    return view;
}

- (UITapGestureRecognizer *)tapRecognizer {
    if (!_tapRecognizer) {
        _tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
        _tapRecognizer.numberOfTapsRequired = 1;
        _tapRecognizer.cancelsTouchesInView = YES;
        _tapRecognizer.delegate = self;
    }
    
    return _tapRecognizer;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [[UIButton alloc] init];
        _closeButton.backgroundColor = [UIColor colorWithHex:0xf9f9fa];
        [_closeButton setTitle:@"关闭" forState:UIControlStateNormal];
        [_closeButton setTitleColor:[UIColor colorWithHex:0x0a84ff] forState:UIControlStateNormal];
        _closeButton.layer.cornerRadius = CornerRadius;
        _closeButton.titleLabel.font = [UIFont boldSystemFontOfSize:20];
        [_closeButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        _closeButton.accessibilityIdentifier = @"PhotonMenu.close";
    }
    
    return _closeButton;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.bounces = NO;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        [_tableView registerClass:[PhotonActionSheetCell class] forCellReuseIdentifier:CellName];
        [_tableView registerClass:[PhotonActionSheetTitleHeaderView class] forHeaderFooterViewReuseIdentifier:TitleHeaderName];
        [_tableView registerClass:[PhotonActionSheetSeparator class] forHeaderFooterViewReuseIdentifier:@"SeparatorSectionHeader"];
        [_tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"EmptyHeader"];
        _tableView.estimatedRowHeight = RowHeight;
        _tableView.estimatedSectionFooterHeight = HeaderFooterHeight;
        _tableView.estimatedSectionHeaderHeight = HeaderFooterHeight;
        _tableView.scrollEnabled = YES;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.layer.cornerRadius = CornerRadius;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.cellLayoutMarginsFollowReadableWidth = NO;
        _tableView.accessibilityIdentifier = @"Context Menu";
        UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, Padding)];
        _tableView.tableHeaderView = footer;
        _tableView.tableFooterView = footer;
    }
    
    return _tableView;
}

@end

@interface PhotonActionSheetTitleHeaderView ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *separatorView;

@end

@implementation PhotonActionSheetTitleHeaderView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        CGFloat Padding = 12;
        
        self.backgroundView = [[UIView alloc] init];
        self.backgroundView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.titleLabel];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.contentView).offset(Padding);
            make.trailing.equalTo(self.contentView);
            make.top.equalTo(self.contentView).offset(TablePadding);
        }];
        
        [self.contentView addSubview:self.separatorView];
        
        [self.separatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.and.trailing.equalTo(self);
            make.top.equalTo(self.titleLabel.mas_bottom).offset(TablePadding);
            make.bottom.equalTo(self.contentView).inset(TablePadding);
            make.height.mas_equalTo(0.5);
        }];
    }
    
    return self;
}

- (void)configureWithTitle:(NSString *)title {
    _titleLabel.text = title;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    _titleLabel.text = nil;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.numberOfLines = 1;
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.textColor = UIAccessibilityDarkerSystemColorsEnabled() ? [UIColor blackColor] : [UIColor lightGrayColor];
    }
    
    return _titleLabel;
}

- (UIView *)separatorView {
    if (!_separatorView) {
        _separatorView = [[UIView alloc] init];
        _separatorView.backgroundColor = [UIColor lightGrayColor];
    }
    
    return _separatorView;
}

@end

@interface PhotonActionSheetSeparator ()

@property (nonatomic, strong) UIView *separatorLineView;

@end

@implementation PhotonActionSheetSeparator

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundView = [[UIView alloc] init];
        self.backgroundView.backgroundColor = [UIColor clearColor];
        
        _separatorLineView = [[UIView alloc] init];
        _separatorLineView.backgroundColor = [UIColor lightGrayColor];
        [self.contentView addSubview:_separatorLineView];
        
        [self.separatorLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.and.trailing.equalTo(self);
            make.centerY.equalTo(self);
            make.height.mas_equalTo(0.5);
        }];
    }
    
    return self;
}

@end

static UIColor * CellLabelColor;
static UIColor * CellSelectedOverlayColor;
static CGFloat const CellCornerRadius = 3;
static CGFloat const CellPadding = 12;
static CGFloat CellVerticalPadding = 2;

@interface PhotonActionSheetCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UIImageView *statusIcon;
@property (nonatomic, strong) UILabel *disclosureLabel;
@property (nonatomic, strong) UIView *selectedOverlay;
@property (nonatomic, strong) UIImageView *disclosureIndicator;
@property (nonatomic, strong) UIStackView *stackView;
@property (nonatomic, assign) BOOL isSelected;

@end

@implementation PhotonActionSheetCell

+ (void)load {
    CellLabelColor = [UIColor colorWithHex:0x0a84ff];
    CellSelectedOverlayColor = [UIColor colorWithWhite:0 alpha:0.25];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.isAccessibilityElement = YES;
        [self.contentView addSubview:self.selectedOverlay];
        self.backgroundColor = [UIColor clearColor];
        
        [self.selectedOverlay mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
        }];
        
        UIStackView *textStackView = [[UIStackView alloc] initWithArrangedSubviews:@[self.titleLabel, self.subtitleLabel]];
        textStackView.spacing = CellVerticalPadding;
        [textStackView setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
        textStackView.alignment = UIStackViewAlignmentLeading;
        textStackView.axis = UILayoutConstraintAxisVertical;
        
        [self.stackView addArrangedSubview:self.statusIcon];
        [self.stackView addArrangedSubview:textStackView];
        [self.contentView addSubview:self.stackView];
        
        [self.stackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView).insets(UIEdgeInsetsMake(CellPadding/2, CellPadding, CellPadding/2, CellPadding));
        }];
    }
    
    return self;
}

- (void)configureWithAction:(PhotonActionSheetItem *)action {
    self.titleLabel.text = action.title;
    self.titleLabel.textColor = self.tintColor;
    self.titleLabel.textColor = (action.accessory == PhotonActionCellAccessoryText) ? [self.titleLabel.textColor colorWithAlphaComponent:0.6] : self.titleLabel.textColor;
    self.subtitleLabel.text = action.text;
    self.subtitleLabel.textColor = self.tintColor;
    self.disclosureLabel.text = action.accessoryText;
    self.disclosureLabel.textColor = self.titleLabel.textColor;
    
    self.titleLabel.font = action.bold ? [UIFont boldSystemFontOfSize:18] : [UIFont systemFontOfSize:18];
    self.disclosureLabel.font = action.bold ? [UIFont boldSystemFontOfSize:18] : [UIFont systemFontOfSize:18];
    
    self.accessibilityIdentifier = action.iconString;
    self.accessibilityLabel = action.title;
    self.selectionStyle = action.handler != nil ? UITableViewCellSelectionStyleDefault : UITableViewCellSelectionStyleNone;
    
    NSString *iconName = action.iconString;
    if (iconName) {
        UIImage *image = [[UIImage imageNamed:iconName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.statusIcon.image = image;
        self.statusIcon.tintColor = self.tintColor;
        if (self.superview) {
            [self.stackView insertArrangedSubview:self.statusIcon atIndex:0];
        }
    } else {
        [self.statusIcon removeFromSuperview];
    }
    
    switch (action.accessory) {
        case PhotonActionCellAccessoryText:
            [self.stackView addArrangedSubview:self.disclosureLabel];
            break;
        case PhotonActionCellAccessoryDisclosure:
            [self.stackView addArrangedSubview:self.disclosureIndicator];
            break;
        default:
            break;
    }
}

- (void)setIsSelected:(BOOL)isSelected {
    [_selectedOverlay setHidden:!isSelected];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    _statusIcon.image = nil;
    [_disclosureIndicator removeFromSuperview];
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:20];
        _titleLabel.minimumScaleFactor = 0.8;
        _titleLabel.textColor = CellLabelColor;
        [_titleLabel setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisVertical];
        _titleLabel.numberOfLines = 4;
        [_titleLabel adjustsFontSizeToFitWidth];
    }
    
    return _titleLabel;
}

- (UILabel *)subtitleLabel {
    if (!_subtitleLabel) {
        _subtitleLabel = [[UILabel alloc] init];
        _subtitleLabel.font = [UIFont systemFontOfSize:14];
        _subtitleLabel.minimumScaleFactor = 0.75;
        _subtitleLabel.textColor = CellLabelColor;
        [_subtitleLabel setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisVertical];
        _subtitleLabel.numberOfLines = 3;
        [_subtitleLabel adjustsFontSizeToFitWidth];
    }
    
    return _subtitleLabel;
}

- (UIImageView *)statusIcon {
    if (!_statusIcon) {
        _statusIcon = [[UIImageView alloc] init];
        _statusIcon.contentMode = UIViewContentModeScaleAspectFit;
        _statusIcon.clipsToBounds = YES;
        _statusIcon.layer.cornerRadius = CellCornerRadius;
        [_statusIcon setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    }
    
    return _statusIcon;
}

- (UILabel *)disclosureLabel {
    if (!_disclosureLabel) {
        _disclosureLabel = [[UILabel alloc] init];
    }
    
    return _disclosureLabel;
}

- (UIView *)selectedOverlay {
    if (!_selectedOverlay) {
        _selectedOverlay = [[UIView alloc] init];
        _selectedOverlay.backgroundColor = CellSelectedOverlayColor;
        _selectedOverlay.hidden = YES;
    }
    
    return _selectedOverlay;
}

- (UIImageView *)disclosureIndicator {
    if (!_disclosureIndicator) {
        _disclosureIndicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"menu-Disclosure"]];
        _disclosureIndicator.contentMode = UIViewContentModeScaleAspectFit;
        _disclosureIndicator.layer.cornerRadius = CellCornerRadius;
        [_disclosureIndicator setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    }
    
    return _disclosureIndicator;
}

- (UIStackView *)stackView {
    if (!_stackView) {
        _stackView = [[UIStackView alloc] init];
        _stackView.spacing = CellPadding;
        _stackView.alignment = UIStackViewAlignmentCenter;
        _stackView.axis = UILayoutConstraintAxisHorizontal;
     }
    
    return _stackView;
}

@end

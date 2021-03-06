//
//  JvFilterView.h
//  JvFilterViewDemo
//
//  Created by Jovi Du on 4/4/16.
//  Copyright © 2016 Jovi Du. All rights reserved.
//

#import <UIKit/UIKit.h>

#define JvTitlesContainerViewHeight 40
#define JvOptionCellWidth           69
#define JvOptionCellHeight          24
#define JvOptionCellMarginX         5
#define JvOptionCellMarginY         8

#define JvTitlesNormalColor         [UIColor colorWithWhite:0.2 alpha:1]
#define JvTitlesSelectedColor       [UIColor colorWithRed:0.73 green:0 blue:0 alpha:1]
#define JvOptionCellNormalBgColor   [UIColor colorWithRed:0.98 green:0.98 blue:0.98 alpha:1]
#define JvOptionCellSelectedBgColor [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1]


static NSString * const JvFilterTitle           = @"JvTitle";
static NSString * const JvFilterOptions         = @"JvOptions";
static NSString * const JvFilterOptionName      = @"JvOptionName";
static NSString * const JvFilterOptionId        = @"JvOptionId";

static NSString * JvFilterOptionAllName         = @"全部";
static NSString * JvFilterOptionAllId           = @"-1";

@interface JvFilterItem : NSObject
@property (copy, nonatomic) NSString *title;
@property (strong, nonatomic) NSMutableArray<NSDictionary *> *options;
@property (assign, nonatomic) NSInteger selectedOptionIndex;

/* 
 dict: @{JvFilterTitle:@"theTitle",
        JvFilterOptions:@[@{JvFilterOptionName:@"theName0", JvFilterOptionId:@"theId0"},
                          @{JvFilterOptionName:@"theName1", JvFilterOptionId:@"theId1"}
        ]}
 */
+ (instancetype)itemWithDict:(NSDictionary *)dict;
- (void)setupWithDict:(NSDictionary *)dict;
@end


@interface JvFilterOptionCell : UICollectionViewCell
@property (weak, nonatomic) NSDictionary *option;
@property (strong, nonatomic) UILabel *labName;
@end

@interface JvFilterOptionTableCell : UITableViewCell
@property (weak, nonatomic) NSDictionary *option;
@property (strong, nonatomic) UILabel *labName;
@end


@class JvFilterView;
@protocol JvFilterViewDelegate <NSObject>
@optional
- (void)jvFilterView:(JvFilterView *)jvFilterView didSelectItem:(JvFilterItem *)item option:(NSDictionary *)option;
- (void)jvFilterView:(JvFilterView *)jvFilterView didSelectOptionName:(NSString *)optionName optionId:(id)optionId;
- (BOOL)jvFilterView:(JvFilterView *)jvFilterView shouldExtendItem:(JvFilterItem *)item;
@end


@interface JvFilterView : UIView

- (instancetype)initWithStyle:(BOOL)isTableStyle;

@property (assign, nonatomic) BOOL isTableViewStyle;

@property (strong, nonatomic) UIView *titlesContainerView;
@property (strong, nonatomic) UICollectionView *optionsContainerView;
@property (strong, nonatomic) UITableView *optionsListView;
@property (strong, nonatomic) UIView *maskView;

@property (assign, nonatomic) CGFloat titlesContainerViewHeight;
@property (assign, nonatomic) CGRect extendedFrame;
@property (assign, nonatomic) CGRect retractedFrame;

@property (strong, nonatomic) NSArray<JvFilterItem *> *items;
@property (assign, nonatomic) NSInteger currentItemIndex;

- (void)resetTitleButtonOfItem:(JvFilterItem *)item;

@property (weak, nonatomic) id <JvFilterViewDelegate> delegate;

@end

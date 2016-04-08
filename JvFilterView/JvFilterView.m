//
//  JvFilterView.m
//  JvFilterViewDemo
//
//  Created by Jovi Du on 4/4/16.
//  Copyright © 2016 Jovi Du. All rights reserved.
//

#import "JvFilterView.h"

#pragma mark - JvFilterItem

@implementation JvFilterItem

+ (instancetype)itemWithDict:(NSDictionary *)dict {
    JvFilterItem *item = [[JvFilterItem alloc]init];
    if (item) {
        item.title = dict[JvFilterTitle];
        item.options = [NSMutableArray array];
        if (dict[JvFilterOptions] && [dict[JvFilterOptions] count]) {
            [item.options addObjectsFromArray:dict[JvFilterOptions]];
        }
        item.selectedOptionIndex = -1;
    }
    return item;
}

@end

#pragma mark - JvFilterOptionCell

@implementation JvFilterOptionCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (selected) {
        self.backgroundColor = JvOptionCellSelectedBgColor;
    }else{
        self.backgroundColor = JvOptionCellNormalBgColor;
    }
}

- (void)initUI {
    self.layer.cornerRadius = 3;
    self.backgroundColor = JvOptionCellNormalBgColor;
    
    self.labName = [[UILabel alloc]init];
    self.labName.font = [UIFont systemFontOfSize:13];
    self.labName.textColor = [UIColor colorWithWhite:0.2 alpha:1];
    self.labName.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.labName];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.labName.frame = self.bounds;
}

- (void)setOption:(NSDictionary *)option {
    _option = option;
    if (_option) {
        self.labName.text = _option[JvFilterOptionName];
    }
}

@end

#pragma mark - JvFilterView

static NSString * const JvOptionCellId = @"JvOptionCell";

@interface JvFilterView () <UICollectionViewDataSource, UICollectionViewDelegate>

@end

@implementation JvFilterView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    self.clipsToBounds = YES;
    
    self.maskView = [[UIView alloc]init];
    self.maskView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    self.maskView.hidden = YES;
    [self.maskView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(maskViewTapped:)]];
    [self addSubview:self.maskView];
    
    //optionsContainerView
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
    flowLayout.itemSize = CGSizeMake(JvOptionCellWidth, JvOptionCellHeight);
    flowLayout.minimumInteritemSpacing = JvOptionCellMarginX;
    flowLayout.minimumLineSpacing = JvOptionCellMarginY;
    flowLayout.sectionInset = UIEdgeInsetsMake(15, 15, 15, 15);
    
    self.optionsContainerView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 0) collectionViewLayout:flowLayout];
    self.optionsContainerView.backgroundColor = [UIColor whiteColor];
    self.optionsContainerView.hidden = YES;
    self.optionsContainerView.dataSource = self;
    self.optionsContainerView.delegate = self;
    [self.optionsContainerView registerClass:[JvFilterOptionCell class] forCellWithReuseIdentifier:JvOptionCellId];
    [self addSubview:self.optionsContainerView];
    
    
    //titlesContainerView
    
    self.titlesContainerView = [[UIView alloc]init];
    self.titlesContainerView.tag = -1;
    self.titlesContainerView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    [self addSubview:self.titlesContainerView];
    
}

- (void)setExtendedFrame:(CGRect)extendedFrame {
    _extendedFrame = extendedFrame;
    
    extendedFrame.size.height = JvTitlesContainerViewHeight;
    self.retractedFrame = extendedFrame;
}

- (void)setRetractedFrame:(CGRect)retractedFrame {
    _retractedFrame = retractedFrame;
    self.frame = _retractedFrame;
}

- (void)setItems:(NSMutableArray<JvFilterItem *> *)items {
    _items = items;
    [self setupTitleContainerView];
}

- (void)setupTitleContainerView {
    [self.titlesContainerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    UIFont *fontBtnTitle = [UIFont systemFontOfSize:14];
    UIColor *bgColorBtnTitle = [UIColor whiteColor];
    UIColor *normalColorBtnTitle = JvTitlesNormalColor;
    UIColor *selectedColorBtnTitle = JvTitlesSelectedColor;
    for (NSInteger i = 0; i < self.items.count; i ++) {
        JvFilterItem *item = self.items[i];
        UIButton *btnTitle = [UIButton buttonWithType:UIButtonTypeCustom];
        btnTitle.backgroundColor = bgColorBtnTitle;
        btnTitle.titleLabel.font = fontBtnTitle;
        btnTitle.tag = i;
        [btnTitle setTitleColor:normalColorBtnTitle forState:UIControlStateNormal];
        [btnTitle setTitleColor:selectedColorBtnTitle forState:UIControlStateSelected];
        [btnTitle setTitle:[self arrowTitle:item.title directionDown:YES] forState:UIControlStateNormal];
        [btnTitle setTitle:[self arrowTitle:item.title directionDown:NO] forState:UIControlStateSelected];
        [btnTitle addTarget:self action:@selector(btnTitlePressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.titlesContainerView addSubview:btnTitle];
    }
    [self setNeedsLayout];
}

- (NSString *)arrowTitle:(NSString *)aTitle directionDown:(BOOL)isDown{
    NSString *arrowTitle;
    if (isDown) {
        arrowTitle = [NSString stringWithFormat:@"%@ ∨", aTitle];
    }else{
        arrowTitle = [NSString stringWithFormat:@"%@ ∧", aTitle];
    }
    return arrowTitle;
}

- (void)btnTitlePressed:(UIButton *)sender {
    if (sender.selected) {
        sender.selected = NO;
        [self popOutOptionsView];
    }else{
        static UIButton *selectedBtnTitle = nil;
        if (selectedBtnTitle) {
            selectedBtnTitle.selected = NO;
        }
        sender.selected = YES;
        self.currentItemIndex = sender.tag;
        selectedBtnTitle = sender;
        [self popInOptionsView];
    }
}

- (void)maskViewTapped:(UIGestureRecognizer *)recognizer {
    for (UIButton *btn in self.titlesContainerView.subviews) {
        if (btn.selected) {
            btn.selected = NO;
            [self popOutOptionsView];
            return;
        }
    }
}

- (void)popInOptionsView {
    self.frame = self.extendedFrame;
    
    [self.optionsContainerView reloadData];
    self.optionsContainerView.hidden = NO;
    self.optionsContainerView.alpha = 0;
    self.optionsContainerView.frame = CGRectMake(0, CGRectGetMaxY(self.titlesContainerView.frame), self.frame.size.width, 0);
    self.maskView.hidden = NO;
    [UIView animateWithDuration:0.2 animations:^{
        self.optionsContainerView.alpha = 1;
        self.optionsContainerView.frame = CGRectMake(0, CGRectGetMaxY(self.titlesContainerView.frame), self.frame.size.width, [self calcOptionsViewHeight]);
        self.maskView.alpha = 1;
    }];
}

- (void)popOutOptionsView {
    [UIView animateWithDuration:0.2 animations:^{
        self.optionsContainerView.alpha = 0;
        self.optionsContainerView.frame = CGRectMake(0, CGRectGetMaxY(self.titlesContainerView.frame), self.frame.size.width, [self calcOptionsViewHeight] / 2);
        self.maskView.alpha = 0;
    } completion:^(BOOL finished) {
        self.optionsContainerView.hidden = YES;
        self.maskView.hidden = YES;
        
        self.frame = self.retractedFrame;
    }];
}

- (CGFloat)calcOptionsViewHeight {
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.optionsContainerView.collectionViewLayout;
    UIEdgeInsets sectionInset = flowLayout.sectionInset;
    
    CGFloat height = sectionInset.top + sectionInset.bottom;
    
    NSUInteger optionsCount = self.items[self.currentItemIndex].options.count;
    NSUInteger countInALine = (self.frame.size.width - (sectionInset.left + sectionInset.right)) / (flowLayout.itemSize.width + flowLayout.minimumInteritemSpacing);
    if (countInALine <= 0) {
        countInALine = 1;
    }
    NSUInteger countOfLines = (optionsCount - 1) / countInALine + 1;
    
    height += (flowLayout.itemSize.height + flowLayout.minimumLineSpacing) * countOfLines;
    
    CGFloat maxHeight = self.frame.size.height - self.titlesContainerView.frame.size.height;
    if (height > maxHeight) {
        height = maxHeight;
    }
    
    return height;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self layoutUI];
}

- (void)layoutUI {
    CGSize self_size = self.frame.size;
    
    self.maskView.frame = self.bounds;
    
    self.titlesContainerView.frame = CGRectMake(0, 0, self_size.width, JvTitlesContainerViewHeight);
    
    NSUInteger itemCount = self.items.count;
    CGSize btnTitleSize = CGSizeMake(self_size.width / itemCount, self.titlesContainerView.frame.size.height - 1);
    for (UIButton *btnTitle in self.titlesContainerView.subviews) {
        if (![btnTitle isKindOfClass:[UIButton class]]) {
            continue;
        }
        btnTitle.frame = CGRectMake(btnTitleSize.width * btnTitle.tag,
                                    0,
                                    (btnTitle.tag == itemCount - 1) ? btnTitleSize.width : btnTitleSize.width - 1,
                                    btnTitleSize.height);
    }
    
    CGFloat optionsContainerHeight = self.optionsContainerView.frame.size.height;
    self.optionsContainerView.frame = CGRectMake(0, CGRectGetMaxY(self.titlesContainerView.frame), self_size.width, optionsContainerHeight);
}


#pragma mark Collection DataSource & Delegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.items[self.currentItemIndex].options.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    JvFilterOptionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:JvOptionCellId forIndexPath:indexPath];
    [cell setOption:self.items[self.currentItemIndex].options[indexPath.row]];
    [cell setSelected:(indexPath.row == self.items[self.currentItemIndex].selectedOptionIndex)];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    static JvFilterOptionCell *s_selectedCell = nil;
    static NSIndexPath *s_selectedIndexPath = nil;
    
    JvFilterOptionCell *selectingCell = (JvFilterOptionCell *)[collectionView cellForItemAtIndexPath:indexPath];
    JvFilterItem *selectingItem = self.items[self.currentItemIndex];
    if (!(s_selectedIndexPath && [indexPath compare:s_selectedIndexPath] == NSOrderedSame)) {
        if (s_selectedIndexPath) {
            [collectionView deselectItemAtIndexPath:s_selectedIndexPath animated:NO];
        }
        s_selectedCell = selectingCell;
        s_selectedIndexPath = indexPath;
        selectingItem.selectedOptionIndex = indexPath.row;
    }
    
    if ([self.delegate respondsToSelector:@selector(jvFilterView:didSelectItem:option:)]) {
        [self.delegate jvFilterView:self didSelectItem:selectingItem option:selectingCell.option];
    }
    if ([self.delegate respondsToSelector:@selector(jvFilterView:didSelectOptionName:optionId:)]) {
        [self.delegate jvFilterView:self didSelectOptionName:selectingCell.option[JvFilterOptionName] optionId:selectingCell.option[JvFilterOptionId]];
    }
    
    UIButton *curBtnTitle = (UIButton *)[self.titlesContainerView viewWithTag:self.currentItemIndex];
    [curBtnTitle setTitle:[self arrowTitle:selectingCell.option[JvFilterOptionName] directionDown:YES] forState:UIControlStateNormal];
    [self btnTitlePressed:curBtnTitle];
}

@end

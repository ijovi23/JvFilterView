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
        [item setupWithDict:dict];
    }
    return item;
}

- (void)setupWithDict:(NSDictionary *)dict {
    self.title = dict[JvFilterTitle];
    self.options = [NSMutableArray array];
    if (dict[JvFilterOptions] && [dict[JvFilterOptions] count]) {
        [self.options addObjectsFromArray:dict[JvFilterOptions]];
    }
    self.selectedOptionIndex = -1;
    if ([self.options.lastObject[JvFilterOptionName] isEqualToString:JvFilterOptionAllName]) {
        self.selectedOptionIndex = self.options.count - 1;
    }
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

#pragma mark - JvFilterOptionTableCell

@implementation JvFilterOptionTableCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    self.backgroundColor = [UIColor whiteColor];
    
    self.labName = [[UILabel alloc]init];
    self.labName.font = [UIFont systemFontOfSize:13];
    self.labName.textColor = [UIColor colorWithWhite:0.2 alpha:1];
    self.labName.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:self.labName];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.labName.frame = CGRectMake(12, 0, self.contentView.bounds.size.width - 24, self.contentView.bounds.size.height);
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

@interface JvFilterView () <UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDataSource, UITableViewDelegate>

@end

@implementation JvFilterView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initUI];
    }
    return self;
}

- (instancetype)initWithStyle:(BOOL)isTableStyle {
    self = [super init];
    if (self) {
        self.isTableViewStyle = isTableStyle;
        [self initUI];
    }
    return self;
}

- (void)initUI {
    self.clipsToBounds = YES;
    
    if (self.titlesContainerViewHeight <= 0.001) {
        self.titlesContainerViewHeight = JvTitlesContainerViewHeight;
    }
    
    self.maskView = [[UIView alloc]init];
    self.maskView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    self.maskView.hidden = YES;
    [self.maskView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(maskViewTapped:)]];
    [self addSubview:self.maskView];
    
    if (self.isTableViewStyle) {
        
        //optionsListView
        
        self.optionsListView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 0)];
        self.optionsListView.backgroundColor = [UIColor whiteColor];
        self.optionsListView.tableFooterView = [[UIView alloc]init];
        self.optionsListView.hidden = YES;
        self.optionsListView.dataSource = self;
        self.optionsListView.delegate = self;
        [self.optionsListView registerClass:[JvFilterOptionTableCell class] forCellReuseIdentifier:JvOptionCellId];
        [self addSubview:self.optionsListView];
        
    }else{
        
        //optionsContainerView
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
        flowLayout.itemSize = CGSizeMake(JvOptionCellWidth, JvOptionCellHeight);
        flowLayout.minimumInteritemSpacing = JvOptionCellMarginX;
        flowLayout.minimumLineSpacing = JvOptionCellMarginY;
        flowLayout.sectionInset = UIEdgeInsetsMake(14, 14, 14, 14);
        
        self.optionsContainerView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 0) collectionViewLayout:flowLayout];
        self.optionsContainerView.backgroundColor = [UIColor whiteColor];
        self.optionsContainerView.hidden = YES;
        self.optionsContainerView.dataSource = self;
        self.optionsContainerView.delegate = self;
        [self.optionsContainerView registerClass:[JvFilterOptionCell class] forCellWithReuseIdentifier:JvOptionCellId];
        [self addSubview:self.optionsContainerView];
    }
    
    
    //titlesContainerView
    
    self.titlesContainerView = [[UIView alloc]init];
    self.titlesContainerView.tag = -1;
    self.titlesContainerView.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
    [self addSubview:self.titlesContainerView];
    
}

- (void)setExtendedFrame:(CGRect)extendedFrame {
    _extendedFrame = extendedFrame;
    
    CGRect retractedFrame = extendedFrame;
    if (retractedFrame.size.height > self.titlesContainerViewHeight) {
        retractedFrame.size.height = self.titlesContainerViewHeight;
    }
    self.retractedFrame = retractedFrame;
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
    self.titlesContainerView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    [self.titlesContainerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    UIFont *fontBtnTitle = [UIFont systemFontOfSize:14];
    UIColor *bgColorBtnTitle = [UIColor whiteColor];
    UIColor *normalColorBtnTitle = JvTitlesNormalColor;
    UIColor *selectedColorBtnTitle = JvTitlesSelectedColor;
    for (NSInteger i = 0; i < self.items.count; i ++) {
        JvFilterItem *item = self.items[i];
        UIButton *btnTitle = [UIButton buttonWithType:UIButtonTypeCustom];
        btnTitle.clipsToBounds = YES;
        btnTitle.backgroundColor = bgColorBtnTitle;
        btnTitle.titleLabel.font = fontBtnTitle;
        btnTitle.tag = i;
        [btnTitle setTitleColor:normalColorBtnTitle forState:UIControlStateNormal];
        [btnTitle setTitleColor:selectedColorBtnTitle forState:UIControlStateSelected];
        [btnTitle setTitle:[self arrowTitle:item.title directionDown:YES] forState:UIControlStateNormal];
        [btnTitle setTitle:[self arrowTitle:item.title directionDown:NO] forState:UIControlStateSelected];
        [btnTitle addTarget:self action:@selector(btnTitlePressed:) forControlEvents:UIControlEventTouchUpInside];
        
        UIImage *arrow_normal = [UIImage imageNamed:@"jv_arrow_down"];
        UIImage *arrow_selected = [UIImage imageNamed:@"jv_arrow_up"];
        [btnTitle setImage:arrow_normal forState:UIControlStateNormal];
        [btnTitle setImage:arrow_selected forState:UIControlStateSelected];
        
        [self.titlesContainerView addSubview:btnTitle];
    }
    [self setNeedsLayout];
}

- (void)resetTitleButtonOfItem:(JvFilterItem *)item {
    if (!item) {
        for (UIButton *btnTitle in self.titlesContainerView.subviews) {
            if ([btnTitle isKindOfClass:[UIButton class]]) {
                [btnTitle setTitle:[self arrowTitle:self.items[btnTitle.tag].title directionDown:YES] forState:UIControlStateNormal];
            }
        }
    }else{
        NSInteger index = [self.items indexOfObject:item];
        if (index != NSNotFound) {
            UIButton *btnTitle = (UIButton *)[self.titlesContainerView viewWithTag:index];
            [btnTitle setTitle:[self arrowTitle:item.title directionDown:YES] forState:UIControlStateNormal];
        }
    }
    
}

- (NSString *)arrowTitle:(NSString *)aTitle directionDown:(BOOL)isDown{
    NSString *arrowTitle;
    if (isDown) {
        arrowTitle = [NSString stringWithFormat:@"%@", aTitle];
    }else{
        arrowTitle = [NSString stringWithFormat:@"%@", aTitle];
    }
    return arrowTitle;
}

- (void)btnTitlePressed:(UIButton *)sender {
    if (sender.selected) {
        sender.selected = NO;
        [self popOutOptionsView];
    }else{
        if ([self.delegate respondsToSelector:@selector(jvFilterView:shouldExtendItem:)]) {
            if (![self.delegate jvFilterView:self shouldExtendItem:self.items[sender.tag]]) {
                return;
            }
        }
        
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
    
    if (self.optionsListView) {
        
        [self.optionsListView reloadData];
        self.optionsListView.hidden = NO;
        self.optionsListView.alpha = 0;
        self.optionsListView.frame = CGRectMake(0, CGRectGetMaxY(self.titlesContainerView.frame), self.frame.size.width, 0);
        [UIView animateWithDuration:0.2 animations:^{
            self.optionsListView.alpha = 1;
            self.optionsListView.frame = CGRectMake(0, CGRectGetMaxY(self.titlesContainerView.frame), self.frame.size.width, [self calcOptionsViewHeight]);
        }];
        
    }else if (self.optionsContainerView) {
        
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
}

- (void)popOutOptionsView {
    if (self.optionsListView) {
        [UIView animateWithDuration:0.2 animations:^{
            self.optionsListView.alpha = 0;
            self.optionsListView.frame = CGRectMake(0, CGRectGetMaxY(self.titlesContainerView.frame), self.frame.size.width, [self calcOptionsViewHeight] / 2);
        } completion:^(BOOL finished) {
            self.optionsListView.hidden = YES;
            self.frame = self.retractedFrame;
        }];
        
    }else if (self.optionsContainerView) {
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
}

- (CGFloat)calcOptionsViewHeight {
    CGFloat height;
    
    if (self.optionsListView) {
        NSUInteger optionsCount = self.items[self.currentItemIndex].options.count;
        CGFloat cellHeight = JvOptionCellHeight;
        height = cellHeight * optionsCount;
        
    }else if (self.optionsContainerView) {
        UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.optionsContainerView.collectionViewLayout;
        UIEdgeInsets sectionInset = flowLayout.sectionInset;
        
        height = sectionInset.top + sectionInset.bottom;
        
        NSUInteger optionsCount = self.items[self.currentItemIndex].options.count;
        NSUInteger countInALine = (self.frame.size.width - (sectionInset.left + sectionInset.right) + flowLayout.minimumInteritemSpacing) / (flowLayout.itemSize.width + flowLayout.minimumInteritemSpacing);
        if (countInALine <= 0) {
            countInALine = 1;
        }
        NSUInteger countOfLines = (optionsCount - 1) / countInALine + 1;
        
        height += (flowLayout.itemSize.height + flowLayout.minimumLineSpacing) * countOfLines;
        
    }
    
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
    
    self.titlesContainerView.frame = CGRectMake(0, 0, self_size.width, self.titlesContainerViewHeight);
    
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
        CGFloat imgWidth = btnTitle.imageView.frame.size.width;
        CGFloat labWidth = btnTitle.titleLabel.bounds.size.width;
        [btnTitle setTitleEdgeInsets:UIEdgeInsetsMake(0, - imgWidth, 0, imgWidth)];
        [btnTitle setImageEdgeInsets:UIEdgeInsetsMake(0, labWidth, 0, - labWidth)];
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
    NSString *newTitle;
    if ([selectingCell.option[JvFilterOptionName] isEqualToString:JvFilterOptionAllName]) {
        //selected 'All'
        newTitle = [self arrowTitle:selectingItem.title directionDown:YES];
    }else{
        newTitle = [self arrowTitle:selectingCell.option[JvFilterOptionName] directionDown:YES];
    }
    [curBtnTitle setTitle:newTitle forState:UIControlStateNormal];
    [self btnTitlePressed:curBtnTitle];
}

#pragma mark TableView DataSource & Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items[self.currentItemIndex].options.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return JvOptionCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    JvFilterOptionTableCell *cell = [tableView dequeueReusableCellWithIdentifier:JvOptionCellId forIndexPath:indexPath];
    [cell setOption:self.items[self.currentItemIndex].options[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    static JvFilterOptionTableCell *s_selectedCell = nil;
    static NSIndexPath *s_selectedIndexPath = nil;
    
    JvFilterOptionTableCell *selectingCell = (JvFilterOptionTableCell *)[tableView cellForRowAtIndexPath:indexPath];
    JvFilterItem *selectingItem = self.items[self.currentItemIndex];
    if (!(s_selectedIndexPath && [indexPath compare:s_selectedIndexPath] == NSOrderedSame)) {
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
    NSString *newTitle;
    if ([selectingCell.option[JvFilterOptionName] isEqualToString:JvFilterOptionAllName]) {
        //selected 'All'
        newTitle = [self arrowTitle:selectingItem.title directionDown:YES];
    }else{
        newTitle = [self arrowTitle:selectingCell.option[JvFilterOptionName] directionDown:YES];
    }
    [curBtnTitle setTitle:newTitle forState:UIControlStateNormal];
    [self btnTitlePressed:curBtnTitle];
}

@end

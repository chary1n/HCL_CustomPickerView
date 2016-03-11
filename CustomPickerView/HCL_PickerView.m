//
//  HCL_PickerView.m
//  CustomPickerView
//
//  Created by bryantcharyn on 16/3/10.
//  Copyright © 2016年 linkloving. All rights reserved.
//

#import "HCL_PickerView.h"
NSString *FONT_NAME = @"HelveticaNeue";

@interface HCL_ComponentTableView ()
@property (strong,nonatomic)NSArray *values;
@property (strong,nonatomic)UIFont *titleFont;
@end
@implementation HCL_ComponentTableView
#define Component_Width 90
#define CircleMargin 10
#define CircleRad Component_Width - CircleMargin
#define BAR_SEL_ORIGIN_Y self.frame.size.height/2.0-Component_Width/2.0


//Configure the tableView
- (id)initWithFrame:(CGRect)frame andValues:(NSArray *)arrayValues
      withTextAlign:(NSTextAlignment)align andTextSize:(float)txtSize {
    
    if(self = [super initWithFrame:frame]) {
        [self setScrollEnabled:YES];
        [self setShowsVerticalScrollIndicator:NO];
        [self setUserInteractionEnabled:YES];
        [self setBackgroundColor:[UIColor clearColor]];
        [self setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [self setContentInset:UIEdgeInsetsMake(BAR_SEL_ORIGIN_Y, 0.0, BAR_SEL_ORIGIN_Y, 0.0)];
        
        _titleFont = [UIFont fontWithName:FONT_NAME size:txtSize];
        
        if(arrayValues)
            _values = [arrayValues copy];
        }
    return self;
}

//Dehighlight the last cell
- (void)dehighlightLastCell {
    NSArray *paths = [NSArray arrayWithObjects:[NSIndexPath indexPathForRow:_tagLastSelected inSection:0], nil];
    [self setTagLastSelected:-1];
    [self beginUpdates];
    [self reloadRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationNone];
    [self endUpdates];
}


//Highlight a cell
- (void)highlightCellWithIndexPathRow:(NSUInteger)indexPathRow {
    [self setTagLastSelected:indexPathRow];
    NSArray *paths = [NSArray arrayWithObjects:[NSIndexPath indexPathForRow:_tagLastSelected inSection:0], nil];
    [self beginUpdates];
    [self reloadRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationNone];
    [self endUpdates];
}
-(void)setTagLastSelected:(NSInteger)tagLastSelected
{
    _tagLastSelected = tagLastSelected;
    NSLog(@"_tagLast:%ld",_tagLastSelected);
}
@end


@interface HCL_PickerView ()<UITableViewDelegate,UITableViewDataSource>
@property (strong,nonatomic)NSArray *hoursArr;
@property (strong,nonatomic)NSArray *minsArr;

@property (strong,nonatomic)HCL_ComponentTableView *hoursCom;
@property (strong,nonatomic)HCL_ComponentTableView *minCom;

@end
@implementation HCL_PickerView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        [self configUI];

    }
    return self;
}

-(void)configUI
{
    //create hoursArr
    NSMutableArray *arrHours = [[NSMutableArray alloc] initWithCapacity:12];
    for(int i = 1; i <= 23; i++) {
        [arrHours addObject:[NSString stringWithFormat:@"%02d",i]];
    }
    _hoursArr = [NSArray arrayWithArray:arrHours];
    
    //Create mins Arr
    NSMutableArray *arrMinutes = [[NSMutableArray alloc] initWithCapacity:60];
    for(int i = 0; i < 60; i++) {
        [arrMinutes addObject:[NSString stringWithFormat:@"%02d",i]];
    }
    _minsArr = [NSArray arrayWithArray:arrMinutes];
    
    UIView *barSel = [[UIView alloc] initWithFrame:CGRectMake(0.0, (self.frame.size.height - Component_Width)/2, self.frame.size.width, Component_Width)];
//    [barSel setBackgroundColor:[UIColor colorWithRed:76.0f/255.0f green:172.0f/255.0f blue:239.0f/255.0f alpha:0.8]];
        //两个圆圈
    UIImageView *imageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width/2 - CircleMargin - 80, CircleMargin, CircleRad, CircleRad)];
    imageView1.image = [UIImage imageNamed:@"bg_clock_256px"];
    UIImageView *imageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width/2 + CircleMargin,CircleMargin, CircleRad, CircleRad)];
    imageView2.image = [UIImage imageNamed:@"bg_clock_256px"];
    
    [barSel addSubview:imageView1];
    [barSel addSubview:imageView2];
    
    [self addSubview:barSel];
    //添加小时部分
    _hoursCom = [[HCL_ComponentTableView alloc] initWithFrame:CGRectMake(self.frame.size.width / 2 - Component_Width, CircleMargin/2, Component_Width, self.frame.size.height) andValues:_hoursArr withTextAlign:NSTextAlignmentLeft andTextSize:50.0f];
    _hoursCom.delegate = self;
    _hoursCom.dataSource = self;
    [self addSubview:_hoursCom];
    //添加分钟部分
    _minCom = [[HCL_ComponentTableView alloc] initWithFrame:CGRectMake(self.frame.size.width / 2 + CircleMargin, CircleMargin/2, Component_Width, self.frame.size.height) andValues:_minsArr withTextAlign:NSTextAlignmentCenter andTextSize:50.0f];
    _minCom.delegate = self;
    _minCom.dataSource = self;
    [self addSubview:_minCom];
    
}


#pragma  mark scroll//Center the value in the bar selector
//Center the value in the bar selector
- (void)centerValueForScrollView:(HCL_ComponentTableView *)scrollView {
    
    //Takes the actual offset
    float offset = scrollView.contentOffset.y;
    
    //Removes the contentInset and calculates the prcise value to center the nearest cell
    offset += scrollView.contentInset.top;
    int mod = (int)offset%(int)Component_Width;
    float newValue = (mod >= Component_Width/2.0) ? offset+(Component_Width-mod) : offset-mod;
    
    //Calculates the indexPath of the cell and set it in the object as property
    NSInteger indexPathRow = (int)(newValue/Component_Width);
    
    //Center the cell
    [self centerCellWithIndexPathRow:indexPathRow forScrollView:scrollView];
}

//Center phisically the cell
- (void)centerCellWithIndexPathRow:(NSUInteger)indexPathRow forScrollView:(HCL_ComponentTableView *)scrollView {
    
    if(indexPathRow >= [scrollView.values count]) {
        indexPathRow = [scrollView.values count]-1;
    }
    
    float newOffset = indexPathRow * Component_Width;
    
    //Re-add the contentInset and set the new offset
    newOffset -= BAR_SEL_ORIGIN_Y;
    [scrollView setContentOffset:CGPointMake(0.0, newOffset) animated:YES];
    
    //Highlight the cell
    [scrollView highlightCellWithIndexPathRow:indexPathRow];
    
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (![scrollView isDragging]) {
        [self centerValueForScrollView:(HCL_ComponentTableView *)scrollView];
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//    scrollView.decelerationRate = 0.5;
    [self centerValueForScrollView:(HCL_ComponentTableView *)scrollView];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
//    
    HCL_ComponentTableView *sv = (HCL_ComponentTableView *)scrollView;
//    
    [sv dehighlightLastCell];
}


#pragma mark tableView delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ((HCL_ComponentTableView *)tableView).values.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    HCL_ComponentTableView *comTableView = (HCL_ComponentTableView *)tableView;
    
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        [cell setBackgroundColor:[UIColor clearColor]];
        [cell.textLabel setFont:comTableView.titleFont];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
  //  [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
    [cell.textLabel setTextColor:(indexPath.row == comTableView.tagLastSelected) ? [UIColor orangeColor] : [UIColor darkGrayColor]];
    [cell.textLabel setText:[comTableView.values objectAtIndex:indexPath.row]];
    
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return Component_Width;
}

@end

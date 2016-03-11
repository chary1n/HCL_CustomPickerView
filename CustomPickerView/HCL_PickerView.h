//
//  HCL_PickerView.h
//  CustomPickerView
//
//  Created by bryantcharyn on 16/3/10.
//  Copyright © 2016年 linkloving. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface HCL_ComponentTableView : UITableView
@property (nonatomic,assign) NSInteger tagLastSelected;

- (void)dehighlightLastCell;
- (void)highlightCellWithIndexPathRow:(NSUInteger)indexPathRow;
@end
@interface HCL_PickerView : UIView

@end

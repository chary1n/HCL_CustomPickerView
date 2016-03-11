//
//  ViewController.m
//  CustomPickerView
//
//  Created by bryantcharyn on 16/3/10.
//  Copyright © 2016年 linkloving. All rights reserved.
//

#import "ViewController.h"
#import "HCL_PickerView.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    HCL_PickerView *picker = [[HCL_PickerView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 250)];
    picker.center = self.view.center;
    [self.view addSubview:picker];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

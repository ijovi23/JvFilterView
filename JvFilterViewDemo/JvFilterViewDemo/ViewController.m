//
//  ViewController.m
//  JvFilterViewDemo
//
//  Created by Jovi Du on 4/4/16.
//  Copyright © 2016 Jovi Du. All rights reserved.
//

#import "ViewController.h"
#import "JvFilterView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.1 alpha:1];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(150, 200, 70, 30);
    [button setTitle:@"Click" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    
    JvFilterView *filterView = [[JvFilterView alloc]init];
    filterView.extendedFrame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 100);
    
    NSArray *items = @[[JvFilterItem itemWithDict:@{JvFilterTitle:@"Category",
                                                    JvFilterOptions:@[@{JvFilterOptionName:@"Opt1"},
                                                                      @{JvFilterOptionName:@"Opt2"},
                                                                      @{JvFilterOptionName:@"Opt3"}]
                                                    }
                        ],
                       [JvFilterItem itemWithDict:@{JvFilterTitle:@"Meterial",
                                                    JvFilterOptions:@[@{JvFilterOptionName:@"Opt1"},
                                                                      @{JvFilterOptionName:@"Opt2"},
                                                                      @{JvFilterOptionName:@"Opt3"},
                                                                      @{JvFilterOptionName:@"Opt4"}]
                                                    }
                        ],
                       [JvFilterItem itemWithDict:@{JvFilterTitle:@"Price",
                                                    JvFilterOptions:@[@{JvFilterOptionName:@"Opt1"},
                                                                      @{JvFilterOptionName:@"Opt2"},
                                                                      @{JvFilterOptionName:@"Opt3"},
                                                                      @{JvFilterOptionName:@"Opt4"},
                                                                      @{JvFilterOptionName:@"Opt5"}]
                                                    }
                        ],
                       ];
    
    [filterView setItems:items];
    
    [self.view addSubview:filterView];
}

- (void)buttonClicked:(UIButton *)sender {
    static int clickedTimes = 0;
    clickedTimes += 1;
    NSString *newTitle = [NSString stringWithFormat:@"Clicked:%d", clickedTimes];
    [sender setTitle:newTitle forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

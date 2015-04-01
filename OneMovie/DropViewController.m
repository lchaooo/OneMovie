//
//  DropViewController.m
//  OneMovie
//
//  Created by 俞 丽央 on 15-3-21.
//  Copyright (c) 2015年 李超. All rights reserved.
//

#import "DropViewController.h"
#import "UIColor+CustomColors.h"
#import <YTKKeyValueStore.h>

@interface DropViewController ()<UIScrollViewDelegate>
@property (strong,nonatomic) YTKKeyValueStore *store;
@end

@implementation DropViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _store = [[YTKKeyValueStore alloc] initDBWithName:@"details.db"];
    NSDictionary *movieDetails = [_store getObjectById:@"movie" fromTable:@"detailsTable"];
    self.view.backgroundColor = [UIColor blackColor];
    self.view.alpha = 0.7;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    //w = width - 104.f,
    //h = height - 288.f
    
    float currentWidth = [[UIScreen mainScreen] bounds].size.width - 74.f;
    float currentHeight = [[UIScreen mainScreen] bounds].size.height - 238.f;
    
    NSArray *castsArray= [NSArray arrayWithArray:[movieDetails objectForKey:@"casts"]];
    
    _rqLabel = [[RQShineLabel alloc]initWithFrame:CGRectMake(0 , 0, currentWidth-40 , currentHeight-80)];
    _rqLabel.text = movieDetails[@"summary"];
    _rqLabel.text = [NSString stringWithFormat:@"%@\n\n主演:",_rqLabel.text];
    for (NSDictionary *dic in castsArray) {
        _rqLabel.text = [NSString stringWithFormat:@"%@%@/",_rqLabel.text,dic[@"name"]];
    }
    _rqLabel.text = [_rqLabel.text substringToIndex:[_rqLabel.text length]-1];
    _rqLabel.numberOfLines = 0;
    UIFont *tfont = [UIFont systemFontOfSize:18.0];
    NSDictionary * dic = [NSDictionary dictionaryWithObjectsAndKeys:tfont,NSFontAttributeName,nil];
    CGSize sizeText = [_rqLabel.text boundingRectWithSize:CGSizeMake(currentWidth-40, 2000) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
    if (sizeText.height>currentHeight-80){
        UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(20, 20, currentWidth-40, currentHeight-80)];
        scrollView.delegate = self;
        scrollView.showsVerticalScrollIndicator = NO;
        [self.view addSubview:scrollView];
        scrollView.contentSize = CGSizeMake(currentWidth-40, sizeText.height);
        _rqLabel.frame = CGRectMake(0,0,currentWidth-40, sizeText.height);
        [scrollView addSubview:_rqLabel];
    }
    else {
        [self.view addSubview:_rqLabel];
    }
    [self performSelector:@selector(shining) withObject:self afterDelay:0.3];
    
    
    
    UIButton *dismissButton = [UIButton buttonWithType:UIButtonTypeSystem];
    dismissButton.translatesAutoresizingMaskIntoConstraints = NO;
    dismissButton.tintColor = [UIColor whiteColor];
    dismissButton.titleLabel.font = [UIFont fontWithName:@"Avenir" size:20];
    [dismissButton setTitle:@"关 闭" forState:UIControlStateNormal];
    [dismissButton addTarget:self action:@selector(dismiss:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:dismissButton];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:dismissButton
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.f
                                                           constant:0.f]];
    
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"V:[dismissButton]-|"
                               options:0
                               metrics:nil
                               views:NSDictionaryOfVariableBindings(dismissButton)]];
}

- (void)shining{
    [_rqLabel shine];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dismiss:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

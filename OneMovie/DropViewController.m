//
//  DropViewController.m
//  OneMovie
//
//  Created by 俞 丽央 on 15-3-21.
//  Copyright (c) 2015年 李超. All rights reserved.
//

#import "DropViewController.h"
#import "UIColor+CustomColors.h"

@interface DropViewController ()<UIScrollViewDelegate>

@end

@implementation DropViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.layer.cornerRadius = 8.f;
    self.view.backgroundColor = [UIColor customBlueColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    //w = width - 104.f,
    //h = height - 288.f
    
    float currentWidth = [[UIScreen mainScreen] bounds].size.width - 104.f;
    float currentHeight = [[UIScreen mainScreen] bounds].size.height - 288.f;
    
    
    _rqLabel = [[RQShineLabel alloc]initWithFrame:CGRectMake(0 , 0, currentWidth-40 , currentHeight-80)];
//    _rqLabel.text = @"       未来世界的超级都市旧京山（San Fransokyo），热爱发明创造的天才少年小宏，在哥哥泰迪的鼓励下参加了罗伯特·卡拉汉教授主持的理工学院机器人专业的入学大赛。他凭借神奇的微型磁力机器人赢得观众、参赛者以及考官的一致好评，谁知突如其来的灾难却将小宏的梦想和人生毁于一旦。大火烧毁了展示会场，而哥哥为了救出受困的卡拉汉教授命丧火场。身心饱受创伤的小宏闭门不出，哥哥生前留下的治疗型机器人大白则成为安慰他的唯一伙伴。原以为微型机器人也毁于火灾，谁知小宏和大白竟意外发现有人在某座废弃工厂内大批量地生产他的发明。稍后哥哥的朋友们弗雷德等人也加入进来，他们穿上小宏发明的超级战士战斗装备，和怀有险恶阴谋的神秘对手展开较量……";
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
    [_rqLabel shine];
    
    
    UIButton *dismissButton = [UIButton buttonWithType:UIButtonTypeSystem];
    dismissButton.translatesAutoresizingMaskIntoConstraints = NO;
    dismissButton.tintColor = [UIColor whiteColor];
    dismissButton.titleLabel.font = [UIFont fontWithName:@"Avenir" size:20];
    [dismissButton setTitle:@"Dismiss" forState:UIControlStateNormal];
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
    // Do any additional setup after loading the view from its nib.
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

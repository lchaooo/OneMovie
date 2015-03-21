//
//  MainViewController.m
//  OneMovie
//
//  Created by 李超 on 15/3/20.
//  Copyright (c) 2015年 李超. All rights reserved.
//

#import "MainViewController.h"
#import <RQShineLabel.h>
#import "DropViewController.h"
#import "PresentingAnimator.h"
#import "DismissingAnimator.h"
#import <YTKKeyValueStore.h>
#import "WebModel.h"


@interface MainViewController ()<UIViewControllerTransitioningDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (weak, nonatomic) IBOutlet UIView *posterImage;
@property (weak, nonatomic) IBOutlet RQShineLabel *nameLabel;
@property (weak, nonatomic) IBOutlet RQShineLabel *ratingLabel;
@property (weak, nonatomic) IBOutlet RQShineLabel *typeLabel;
@property (strong,nonatomic) YTKKeyValueStore *store;//数据储存
@property (strong,nonatomic) NSString *tableName;//fmdb tablename
@property (strong,nonatomic) WebModel *model;

@end

@implementation MainViewController

- (id)init{
    self = [super init];
    if (self) {
        _tableName = @"movieTable";
        _store = [[YTKKeyValueStore alloc] initDBWithName:@"movie.db"];
        [_store createTableWithName:_tableName];
        _model = [[WebModel alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showMovieDetails) name:@"Dictionary has been downloaded" object:nil];
    [self getMovieIDAndSendRequest];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma CustomMethods
//随即选择电影并发出网络请求
- (void)getMovieIDAndSendRequest{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"MovieID" ofType:@"plist"];
    NSMutableArray *movieIDArray = [[NSMutableArray alloc] initWithContentsOfFile:plistPath];
    NSString *ID = [movieIDArray objectAtIndex:arc4random()%249];
    [_model getDictionaryByMovieID:ID];
}

//页面显示
- (void)showMovieDetails{
    
    NSDictionary *dic = [_store getObjectById:@"movie" fromTable:_tableName];
    
    //nameLabel
    _nameLabel.text = dic[@"title"];
    
    //ratingLabel
    NSString *rating = [NSString stringWithFormat:@"评分：%@",dic[@"rating"][@"average"]];
    rating = [rating substringToIndex:6];
    _ratingLabel.text = rating;
    
    //typeLabel
    NSString *type = @"类型：";
    for (int i=0; i<[dic[@"genres"] count]; i++) {
        type = [type stringByAppendingString:[NSString stringWithFormat:@"%@/",[dic[@"genres"] objectAtIndex:i]]];
    }
    NSString *realType = [type substringToIndex:[type length]-1];
    _typeLabel.text = realType;
    
    [_nameLabel shine];
    [_ratingLabel shine];
    [_typeLabel shine];
}


#pragma UIViewControllerTransitioningDelegate
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source
{
    return [PresentingAnimator new];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return [DismissingAnimator new];
}


- (IBAction)buttonClicked:(id)sender {
    DropViewController *dropViewController = [DropViewController new];
    dropViewController.transitioningDelegate = self;
    dropViewController.modalPresentationStyle = UIModalPresentationCustom;
    
    [self presentViewController:dropViewController
                                            animated:YES
                                          completion:NULL];
}


@end

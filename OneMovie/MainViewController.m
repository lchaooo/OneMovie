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
#import <UIImageView+RJLoader.h>
#import <UIImageView+WebCache.h>
#import "ContentView.h"

@interface MainViewController ()<UIViewControllerTransitioningDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (weak, nonatomic) IBOutlet UIImageView *posterImage;

@property (weak, nonatomic) IBOutlet RQShineLabel *nameLabel;
@property (weak, nonatomic) IBOutlet RQShineLabel *ratingLabel;
@property (weak, nonatomic) IBOutlet RQShineLabel *typeLabel;
@property (strong,nonatomic) ContentView *contentView;
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

- (void) viewWillAppear:(BOOL)animated
{
    [self resignFirstResponder];
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self becomeFirstResponder];
    
    _contentView = [[ContentView alloc] initWithFrame:CGRectMake(50, 130, 275, 340)];
    [self.view addSubview:_contentView];
    
    _contentView.posterImage.image = nil;
    _contentView.posterImage.layer.cornerRadius = 10;
    _contentView.posterImage.clipsToBounds=YES;
    
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageClicked)];
    [_contentView.posterImage addGestureRecognizer:tapGR];
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
    if ([rating length]>6) {
        rating = [rating substringToIndex:6];
    }
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
    
    //poster
    [_contentView.posterImage startLoaderWithTintColor:[UIColor blackColor]];
    __weak typeof(self)weakSelf = self;
    [_contentView.posterImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",dic[@"images"][@"large"]]] placeholderImage:[UIImage imageNamed:@"透明.png"] options:SDWebImageCacheMemoryOnly | SDWebImageRefreshCached progress:^(NSInteger receivedSize,NSInteger expectedSize){
        [weakSelf.contentView.posterImage updateImageDownloadProgress:(CGFloat)receivedSize/expectedSize];
    }completed:^(UIImage *image,NSError *error,SDImageCacheType cacheType,NSURL *imageURL){
        [weakSelf.contentView.posterImage reveal];
        weakSelf.backgroundImage.image = image;
        weakSelf.contentView.posterImage.userInteractionEnabled = YES;
    }];
}

- (void)disappearAndSendNewRequest{
    [_nameLabel fadeOut];
    [_ratingLabel fadeOut];
    [_typeLabel fadeOut];
    [self performSelector:@selector(disappearPicture) withObject:self afterDelay:1.5];
    [self performSelector:@selector(getMovieIDAndSendRequest) withObject:self afterDelay:1.5];
}

- (void)disappearPicture{
    _contentView.posterImage.userInteractionEnabled = NO;
}

#pragma shake
-(BOOL)canBecomeFirstResponder
{
    return YES;
}
- (void) motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    [self disappearAndSendNewRequest];
    
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


- (void)imageClicked {
    DropViewController *dropViewController = [DropViewController new];
    dropViewController.transitioningDelegate = self;
    dropViewController.modalPresentationStyle = UIModalPresentationCustom;

    [self presentViewController:dropViewController
                                            animated:YES
                                          completion:NULL];
}


@end

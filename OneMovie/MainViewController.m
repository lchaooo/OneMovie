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
#import <MBProgressHUD.h>
#import "SwitchView.h"
#import "MovieView.h"
#import "BookView.h"

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
        _tableName = @"detailsTable";
        _store = [[YTKKeyValueStore alloc] initDBWithName:@"details.db"];
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
    
    
    //iphone6 frame
    _contentView = [[ContentView alloc] initWithFrame:CGRectMake(62.5, 150, 250, 354)];
    //iphone 5s frame
    //_contentView = [[ContentView alloc] initWithFrame:CGRectMake(55, 100, 210, 300)];
    [self.view addSubview:_contentView];
    
    _contentView.posterImage.image = nil;
    _contentView.posterImage.layer.cornerRadius = 10;
    _contentView.posterImage.clipsToBounds=YES;
    
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageClicked)];
    [_contentView.posterImage addGestureRecognizer:tapGR];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showMovieDetails) name:@"MovieDictionary has been downloaded" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disappearAndOpenSafari) name:@"Please Fade Out" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showNoticeOfFailure) name:@"Net is not working" object:nil];
    [self showMovieDetails];
    
    
    SwitchView *sv = [[SwitchView alloc]initWithFrame:CGRectMake(62.5, 60, 250, 50)];
    sv.backgroundColor = [UIColor clearColor];
    [self.view addSubview:sv];
    [self.view bringSubviewToFront:_contentView];
    
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
    [_model getMovieDictionaryByMovieID:ID];
}

//页面显示
- (void)showMovieDetails{
    
    NSDictionary *dic = [_store getObjectById:@"movie" fromTable:_tableName];
    
    if (dic) {
    
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
        [_contentView.posterImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",dic[@"images"][@"large"]]] placeholderImage:[UIImage imageNamed:@"透明.png"] options:SDWebImageCacheMemoryOnly |       SDWebImageRefreshCached progress:^(NSInteger receivedSize,NSInteger expectedSize){
            [weakSelf.contentView.posterImage updateImageDownloadProgress:(CGFloat)receivedSize/expectedSize];
        }completed:^(UIImage *image,NSError *error,SDImageCacheType cacheType,NSURL *imageURL){
            [weakSelf.contentView.posterImage reveal];
            weakSelf.backgroundImage.image = image;
            weakSelf.contentView.posterImage.userInteractionEnabled = YES;
        }];
    }else{
        [self getMovieIDAndSendRequest];
    }
}

- (void)disappearAndOpenSafari{
    [self disappear];
    [self performSelector:@selector(openSafari) withObject:self afterDelay:1.5];
}

//显示连接失败提示
- (void)showNoticeOfFailure{
    _contentView.posterImage.image = nil;
    _backgroundImage.image = [UIImage imageNamed:@"p1910907404.jpg"];
    MBProgressHUD *hub = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hub];
    hub.labelText = @"网络连接发生错误";
    hub.mode = MBProgressHUDModeText;
    [hub showAnimated:YES whileExecutingBlock:^{
        sleep(2);
    }completionBlock:^{
        [hub removeFromSuperViewOnHide];
    }];
}

- (void)openSafari{
    NSString *latterPath = [_store getObjectById:@"movie" fromTable:_tableName][@"title"];
    NSString *formerPath = @"http://www.soku.com/m/y/video?q=";
    NSString *path = [NSString stringWithFormat:@"%@%@",formerPath,latterPath];
    NSLog(@"%@",path);
    NSString *utf8Path = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *safariURL = [NSURL URLWithString:utf8Path];
    [[UIApplication sharedApplication] openURL:safariURL];
}

- (void)disappear{
    [_nameLabel fadeOut];
    [_ratingLabel fadeOut];
    [_typeLabel fadeOut];
    [self performSelector:@selector(disappearPicture) withObject:self afterDelay:1.5];
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
    [self disappear];
    [self performSelector:@selector(getMovieIDAndSendRequest) withObject:self afterDelay:1.5];
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

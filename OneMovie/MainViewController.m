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
#import <POP.h>

@interface MainViewController ()<UIViewControllerTransitioningDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (strong,nonatomic) ContentView *movieView;
@property (strong,nonatomic) ContentView *bookView;
@property (strong,nonatomic) YTKKeyValueStore *store;//数据储存
@property (strong,nonatomic) NSString *tableName;//fmdb tablename
@property (strong,nonatomic) WebModel *model;
@property (strong,nonatomic) SwitchView *switchView;
@property (strong,nonatomic) NSArray *movieViewConstraint;
@property (strong,nonatomic) NSArray *bookViewConstraint;

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
    
    _movieView = [[ContentView alloc] init];
    _movieView.posterImage.image = [UIImage imageNamed:@"p1910907404.jpg"];
    _movieView.posterImage.layer.cornerRadius = 10;
    _movieView.posterImage.clipsToBounds=YES;
    _movieView.posterImage.userInteractionEnabled = YES;
    _movieView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_movieView];
    
    _bookView = [[ContentView alloc] init];
    _bookView.posterImage.image = [UIImage imageNamed:@"s1072541.jpg"];
    _bookView.posterImage.layer.cornerRadius = 10;
    _bookView.posterImage.clipsToBounds = YES;
    _bookView.posterImage.userInteractionEnabled = YES;
    _bookView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_bookView];
    
//    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageClicked)];
//    [_contentView.posterImage addGestureRecognizer:tapGR];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showMovieDetails) name:@"MovieDictionary has been downloaded" object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disappearAndOpenSafari) name:@"Please Fade Out" object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showNoticeOfFailure) name:@"Net is not working" object:nil];
//    [self showMovieDetails];
    
    
    _switchView = [[SwitchView alloc]init];
    _switchView.backgroundColor = [UIColor clearColor];
    _switchView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_switchView];
    
    [_switchView addTarget:self action:@selector(valueChanged) forControlEvents:UIControlEventValueChanged];
    [self.view bringSubviewToFront:_movieView];
    
    [self setUpFrame];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setUpFrame{
    _movieViewConstraint = @[[NSLayoutConstraint constraintWithItem:_movieView
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:0.8
                                                           constant:0],
                             [NSLayoutConstraint constraintWithItem:_movieView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:0],
                             [NSLayoutConstraint constraintWithItem:_movieView
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1.0
                                                           constant:0],
                             [NSLayoutConstraint constraintWithItem:_movieView
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0
                                                           constant:0]
                             ];
    
    _bookViewConstraint = @[[NSLayoutConstraint constraintWithItem:_bookView
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:0.8
                                                           constant:0],
                             [NSLayoutConstraint constraintWithItem:_bookView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:0],
                             [NSLayoutConstraint constraintWithItem:_bookView
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1.0
                                                           constant:0],
                             [NSLayoutConstraint constraintWithItem:_bookView
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0
                                                           constant:0]
                             ];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_switchView
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:0.25
                                                           constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_switchView
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_switchView
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:0.6
                                                           constant:50]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_switchView
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:0.08
                                                           constant:0]];
    
    for (int i = 0; i<4; ++i) {
        [self.view addConstraint:[_movieViewConstraint objectAtIndex:i]];
    }
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_bookView
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_movieView
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1.0
                                                           constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_bookView
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_movieView
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0
                                                           constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_bookView
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_movieView
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:1.0
                                                           constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_bookView
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_movieView
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:1.0
                                                           constant:0]];
}

- (void)valueChanged{
    NSLog(_switchView.isMovie? @"yes" :@"no");
    if (_switchView.isMovie) {
        [UIView animateWithDuration:0.5 animations:^{
            for (int i = 0; i<4; ++i) {
                [self.view removeConstraint:[_bookViewConstraint objectAtIndex:i]];
            }
            for (int j = 0; j<4; ++j) {
                [self.view addConstraint:[_movieViewConstraint objectAtIndex:j]];
            }
            [self.view layoutIfNeeded];
        }];
        [self.view bringSubviewToFront:_movieView];
    } else if(!_switchView.isMovie){
        [UIView animateWithDuration:0.5 animations:^{
            for (int i = 0; i<4; ++i) {
                [self.view removeConstraint:[_movieViewConstraint objectAtIndex:i]];
            }
            for (int j = 0; j<4; ++j) {
                [self.view addConstraint:[_bookViewConstraint objectAtIndex:j]];
            }
            [self.view layoutIfNeeded];
        }];
        [self.view bringSubviewToFront:_bookView];
    }
}

//
//#pragma CustomMethods
////随即选择电影并发出网络请求
//- (void)getMovieIDAndSendRequest{
//    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"MovieID" ofType:@"plist"];
//    NSMutableArray *movieIDArray = [[NSMutableArray alloc] initWithContentsOfFile:plistPath];
//    NSString *ID = [movieIDArray objectAtIndex:arc4random()%249];
//    [_model getMovieDictionaryByMovieID:ID];
//}
//
////页面显示
//- (void)showMovieDetails{
//    
//    NSDictionary *dic = [_store getObjectById:@"movie" fromTable:_tableName];
//    
//    if (dic) {
//    
//        //nameLabel
//        _nameLabel.text = dic[@"title"];
//    
//        //ratingLabel
//        NSString *rating = [NSString stringWithFormat:@"评分：%@",dic[@"rating"][@"average"]];
//        if ([rating length]>6) {
//            rating = [rating substringToIndex:6];
//        }
//        _ratingLabel.text = rating;
//        
//        //typeLabel
//        NSString *type = @"类型：";
//        for (int i=0; i<[dic[@"genres"] count]; i++) {
//            type = [type stringByAppendingString:[NSString stringWithFormat:@"%@/",[dic[@"genres"] objectAtIndex:i]]];
//        }
//        NSString *realType = [type substringToIndex:[type length]-1];
//        _typeLabel.text = realType;
//    
//        [_nameLabel shine];
//        [_ratingLabel shine];
//        [_typeLabel shine];
//    
//        
//        //poster
//        [_contentView.posterImage startLoaderWithTintColor:[UIColor blackColor]];
//        __weak typeof(self)weakSelf = self;
//        [_contentView.posterImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",dic[@"images"][@"large"]]] placeholderImage:[UIImage imageNamed:@"透明.png"] options:SDWebImageCacheMemoryOnly |       SDWebImageRefreshCached progress:^(NSInteger receivedSize,NSInteger expectedSize){
//            [weakSelf.contentView.posterImage updateImageDownloadProgress:(CGFloat)receivedSize/expectedSize];
//        }completed:^(UIImage *image,NSError *error,SDImageCacheType cacheType,NSURL *imageURL){
//            [weakSelf.contentView.posterImage reveal];
//            weakSelf.backgroundImage.image = image;
//            weakSelf.contentView.posterImage.userInteractionEnabled = YES;
//        }];
//    }else{
//        [self getMovieIDAndSendRequest];
//    }
//}
//
//- (void)disappearAndOpenSafari{
//    [self disappear];
//    [self performSelector:@selector(openSafari) withObject:self afterDelay:1.5];
//}
//
////显示连接失败提示
//- (void)showNoticeOfFailure{
//    _contentView.posterImage.image = nil;
//    _backgroundImage.image = [UIImage imageNamed:@"p1910907404.jpg"];
//    MBProgressHUD *hub = [[MBProgressHUD alloc] initWithView:self.view];
//    [self.view addSubview:hub];
//    hub.labelText = @"网络连接发生错误";
//    hub.mode = MBProgressHUDModeText;
//    [hub showAnimated:YES whileExecutingBlock:^{
//        sleep(2);
//    }completionBlock:^{
//        [hub removeFromSuperViewOnHide];
//    }];
//}
//
//- (void)openSafari{
//    NSString *latterPath = [_store getObjectById:@"movie" fromTable:_tableName][@"title"];
//    NSString *formerPath = @"http://www.soku.com/m/y/video?q=";
//    NSString *path = [NSString stringWithFormat:@"%@%@",formerPath,latterPath];
//    NSLog(@"%@",path);
//    NSString *utf8Path = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    NSURL *safariURL = [NSURL URLWithString:utf8Path];
//    [[UIApplication sharedApplication] openURL:safariURL];
//}
//
//- (void)disappear{
//    [_nameLabel fadeOut];
//    [_ratingLabel fadeOut];
//    [_typeLabel fadeOut];
//    [self performSelector:@selector(disappearPicture) withObject:self afterDelay:1.5];
//}
//
//- (void)disappearPicture{
//    _contentView.posterImage.userInteractionEnabled = NO;
//}
//
//#pragma shake
//-(BOOL)canBecomeFirstResponder
//{
//    return YES;
//}
//- (void) motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
//{
//    [self disappear];
//    [self performSelector:@selector(getMovieIDAndSendRequest) withObject:self afterDelay:1.5];
//}
//
//#pragma UIViewControllerTransitioningDelegate
//- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
//                                                                  presentingController:(UIViewController *)presenting
//                                                                      sourceController:(UIViewController *)source
//{
//    return [PresentingAnimator new];
//}
//
//- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
//{
//    return [DismissingAnimator new];
//}
//
//
//- (void)imageClicked {
//    DropViewController *dropViewController = [DropViewController new];
//    dropViewController.transitioningDelegate = self;
//    dropViewController.modalPresentationStyle = UIModalPresentationCustom;
//
//    [self presentViewController:dropViewController
//                                            animated:YES
//                                          completion:NULL];
//}


@end

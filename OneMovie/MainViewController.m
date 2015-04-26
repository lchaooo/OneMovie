//
//  MainViewController.m
//  OneMovie
//
//  Created by 李超 on 15/3/20.
//  Copyright (c) 2015年 李超. All rights reserved.
//

#import "MainViewController.h"
#import "WebModel.h"
#import "ContentView.h"
#import "SwitchView.h"
#import <YTKKeyValueStore.h>
#import <MBProgressHUD.h>
#import <POP.h>
#import "Info.h"
#import <UIImageView+RJLoader.h>
#import <UIImageView+WebCache.h>

@interface MainViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (strong,nonatomic) ContentView *movieView;
@property (strong,nonatomic) ContentView *bookView;
@property (strong,nonatomic) YTKKeyValueStore *store;//数据储存
@property (strong,nonatomic) NSString *tableName;//fmdb tablename
@property (strong,nonatomic) WebModel *model;
@property (strong,nonatomic) SwitchView *switchView;
@property (strong,nonatomic) NSArray *movieViewConstraint;
@property (strong,nonatomic) NSArray *bookViewConstraint;
@property BOOL ableToShake;
@end

@implementation MainViewController

- (id)init{
    self = [super init];
    if (self) {
        _tableName = @"detailsTable";
        _store = [[YTKKeyValueStore alloc] initDBWithName:@"details.db"];
        [_store createTableWithName:_tableName];
        _model = [[WebModel alloc] init];
        _ableToShake = YES;
    }
    return self;
}

- (void) viewWillAppear:(BOOL)animated
{
    [self resignFirstResponder];
    [super viewWillAppear:animated];
    
}

- (void)viewDidLoad {
    
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [super viewDidLoad];
    [self becomeFirstResponder];
    
    _movieView = [[ContentView alloc] init];
    _movieView.posterImage.layer.cornerRadius = 10;
    [self.view addSubview:_movieView];
    
    _bookView = [[ContentView alloc] init];
    _bookView.posterImage.userInteractionEnabled = YES;
    [self.view addSubview:_bookView];
    
    _switchView = [[SwitchView alloc]init];
    _switchView.backgroundColor = [UIColor clearColor];
    _switchView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_switchView];
    
    [_switchView addTarget:self action:@selector(valueChanged) forControlEvents:UIControlEventValueChanged];
    [self.view bringSubviewToFront:_movieView];
    
    [self setUpFrame];
    
    if (_switchView.isMovie) {
        [self getMovieIDAndSendRequest];
    } else{
        [self getBookDetails];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enableSwitchview) name:@"enableSwitchview" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notenableSwitchview) name:@"notenableSwitchview" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showMovieDetails) name:@"MovieDictionary has been downloaded" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showBookDetails) name:@"BookDictionary has been downloaded" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showNoticeOfFailure) name:@"Net is not working" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma CustomMethods
//autolayout
- (void)setUpFrame{
    //movieView Center Constraint
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
    
    //movieView Center Constraint
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
    
    //switchView Constraint
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
            //[self showMovieDetails];
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
            //[self showBookDetails];
        }];
        [self.view bringSubviewToFront:_bookView];
    }
}

- (void)enableSwitchview{
    _switchView.userInteractionEnabled = NO;
    _ableToShake = NO;
}

- (void)notenableSwitchview{
    if (_switchView.isMovie){
        [_movieView scrollToTop];
    } else{
        [_bookView scrollToTop];
    }
    _switchView.userInteractionEnabled = YES;
    _ableToShake = YES;
}

//发出网络请求
- (void)getMovieIDAndSendRequest{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"MovieID" ofType:@"plist"];
    NSMutableArray *movieIDArray = [[NSMutableArray alloc] initWithContentsOfFile:plistPath];
    NSString *ID = [movieIDArray objectAtIndex:arc4random()%249];
    [_model getMovieDictionaryByMovieID:ID];
    [self posterImageUserInterfactionEnbaledNo];
}

- (void)getBookDetails{
    [_model getBookIDByBookTag];
    [self posterImageUserInterfactionEnbaledNo];
}

//页面显示

- (void)showMovieDetails{
    _movieView.posterImage.userInteractionEnabled = YES;
    [_movieView show:_model.movieInfo];
    [self changePosterImageOf:_movieView of:_model.movieInfo];
}

- (void)showBookDetails{
    _bookView.posterImage.userInteractionEnabled = YES;
    [_bookView show:_model.bookInfo];
    [self changePosterImageOf:_bookView of:_model.bookInfo];
}

- (void)changePosterImageOf:(ContentView *)contentView of:(Info *)info{
    //poster
    [contentView.posterImage startLoaderWithTintColor:[UIColor blackColor]];
    __weak typeof(self)weakSelf = self;
    [contentView.posterImage sd_setImageWithURL:info.posterURL
                               placeholderImage:[UIImage imageNamed:@"透明.png"]
                                        options:SDWebImageCacheMemoryOnly |       SDWebImageRefreshCached
                                       progress:^(NSInteger receivedSize,NSInteger expectedSize){
                                           [contentView.posterImage updateImageDownloadProgress:(CGFloat)receivedSize/expectedSize];
                                       }
                                      completed:^(UIImage *image,NSError *error,SDImageCacheType cacheType,NSURL *imageURL){
                                          [contentView.posterImage reveal];
                                          weakSelf.backgroundImage.image = image;
                                          contentView.posterImage.userInteractionEnabled = YES;
                                          _ableToShake = YES;
    }];
}

//显示连接失败提示
- (void)showNoticeOfFailure{
    _backgroundImage.image = [UIImage imageNamed:@"p1910907404.jpg"];
    MBProgressHUD *hub = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hub];
    hub.labelText = @"请检查网络连接";
    hub.mode = MBProgressHUDModeText;
    __weak typeof(self) WeakSelf = self;
    [hub showAnimated:YES whileExecutingBlock:^{
        sleep(2);
    }completionBlock:^{
        [hub removeFromSuperViewOnHide];
        WeakSelf.ableToShake = YES;
    }];
}

- (void)posterImageUserInterfactionEnbaledNo{
    _movieView.posterImage.userInteractionEnabled = NO;
    _bookView.posterImage.userInteractionEnabled = NO;
}

#pragma shake
-(BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    if (_ableToShake) {
        if (_switchView.isMovie) {
            [_movieView allViewShake];
            _ableToShake = NO;
            [self performSelector:@selector(getMovieIDAndSendRequest) withObject:nil afterDelay:0.6];
        } else{
            [_bookView allViewShake];
            _ableToShake = NO;
            [self performSelector:@selector(getBookDetails) withObject:nil afterDelay:0.6];
        }
    }
}



@end

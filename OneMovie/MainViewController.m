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
#import <UIImageView+RJLoader.h>
#import <UIImageView+WebCache.h>
#import <MBProgressHUD.h>
#import <POP.h>

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

- (void)viewDidLoad {
    self.ableToShake = YES;
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [super viewDidLoad];
    [self becomeFirstResponder];
    
    [self.view addSubview:self.movieView];
    [self.view addSubview:self.bookView];
    [self.view addSubview:self.switchView];
    [self.view bringSubviewToFront:self.movieView];
    
    if (self.switchView.isMovie) {
        [self showMovieDetails];
    } else{
        [self showBookDetails];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enableSwitchview) name:@"enableSwitchview" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notenableSwitchview) name:@"notenableSwitchview" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showMovieDetails) name:@"MovieDictionary has been downloaded" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showBookDetails) name:@"BookDictionary has been downloaded" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showNoticeOfFailure) name:@"Net is not working" object:nil];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.switchView
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:0.25
                                                           constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.switchView
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.switchView
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:0.6
                                                           constant:50]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.switchView
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:0.08
                                                           constant:0]];
    
    for (int i = 0; i<4; ++i) {
        [self.view addConstraint:[self.movieViewConstraint objectAtIndex:i]];
    }
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.bookView
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.movieView
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1.0
                                                           constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.bookView
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.movieView
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0
                                                           constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.bookView
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.movieView
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:1.0
                                                           constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.bookView
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.movieView
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:1.0
                                                           constant:0]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma CustomMethods

- (void)valueChanged{
    NSLog(self.switchView.isMovie? @"yes" :@"no");
    if (self.switchView.isMovie) {
        [UIView animateWithDuration:0.5 animations:^{
            for (int i = 0; i<4; ++i) {
                [self.view removeConstraint:[self.bookViewConstraint objectAtIndex:i]];
            }
            for (int j = 0; j<4; ++j) {
                [self.view addConstraint:[self.movieViewConstraint objectAtIndex:j]];
            }
            [self.view layoutIfNeeded];
            [self showMovieDetails];
        }];
        [self.view bringSubviewToFront:self.movieView];
    } else if(!self.switchView.isMovie){
        [UIView animateWithDuration:0.5 animations:^{
            for (int i = 0; i<4; ++i) {
                [self.view removeConstraint:[self.movieViewConstraint objectAtIndex:i]];
            }
            for (int j = 0; j<4; ++j) {
                [self.view addConstraint:[self.bookViewConstraint objectAtIndex:j]];
            }
            [self.view layoutIfNeeded];
            [self showBookDetails];
        }];
        [self.view bringSubviewToFront:self.bookView];
    }
}

- (void)enableSwitchview{
    self.switchView.userInteractionEnabled = NO;
    self.ableToShake = NO;
}

- (void)notenableSwitchview{
    if (self.switchView.isMovie){
        [self.movieView scrollToTop];
    } else{
        [self.bookView scrollToTop];
    }
    self.switchView.userInteractionEnabled = YES;
    self.ableToShake = YES;
}

//发出网络请求
- (void)getMovieIDAndSendRequest{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"MovieID" ofType:@"plist"];
    NSMutableArray *movieIDArray = [[NSMutableArray alloc] initWithContentsOfFile:plistPath];
    NSString *ID = [movieIDArray objectAtIndex:arc4random()%249];
    [self.model getMovieDictionaryByMovieID:ID];
    [self posterImageUserInterfactionEnbaledNo];
}

- (void)getBookDetails{
    [self.model getBookIDByBookTag];
    [self posterImageUserInterfactionEnbaledNo];
}

//页面显示
- (void)showMovieDetails{
    NSDictionary *dic = [self.store getObjectById:@"movie" fromTable:self.tableName];
    if (dic) {
        self.movieView.posterImage.userInteractionEnabled = YES;
        //nameLabel
        self.movieView.nameLabel.text = dic[@"title"];
    
        //ratingLabel
        NSString *rating = [NSString stringWithFormat:@"评分：%@",dic[@"rating"][@"average"]];
        if ([rating length]>6) {
            rating = [rating substringToIndex:6];
        }
        self.movieView.ratingLabel.text = rating;

        //typeLabel
        NSString *type = @"类型：";
        for (int i=0; i<[dic[@"genres"] count]; i++) {
            type = [type stringByAppendingString:[NSString stringWithFormat:@"%@/",[dic[@"genres"] objectAtIndex:i]]];
        }
        NSString *realType = [type substringToIndex:[type length]-1];
        self.movieView.typeLabel.text = realType;
        
        //poster
        [self.movieView.posterImage startLoaderWithTintColor:[UIColor blackColor]];
        __weak typeof(self)weakSelf = self;
        [self.movieView.posterImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",dic[@"images"][@"large"]]] placeholderImage:[UIImage imageNamed:@"透明.png"] options:SDWebImageCacheMemoryOnly |       SDWebImageRefreshCached progress:^(NSInteger receivedSize,NSInteger expectedSize){
            [weakSelf.movieView.posterImage updateImageDownloadProgress:(CGFloat)receivedSize/expectedSize];
        }completed:^(UIImage *image,NSError *error,SDImageCacheType cacheType,NSURL *imageURL){
            [weakSelf.movieView.posterImage reveal];
            weakSelf.backgroundImage.image = image;
            weakSelf.movieView.posterImage.userInteractionEnabled = YES;
            self.ableToShake = YES;
        }];
        
        self.movieView.detailLabel.text = dic[@"summary"];
        self.movieView.detailLabel.text = [NSString stringWithFormat:@"%@\n\n主演:",self.movieView.detailLabel.text];
        for (NSDictionary *castDic in dic[@"casts"]) {
            self.movieView.detailLabel.text = [NSString stringWithFormat:@"%@%@/",self.movieView.detailLabel.text,castDic[@"name"]];
        }
        self.movieView.detailLabel.text = [self.movieView.detailLabel.text substringToIndex:[self.movieView.detailLabel.text length]-1];
        self.movieView.detailLabel.numberOfLines = 0;
    }else{
        [self getMovieIDAndSendRequest];
    }
    
    [self.movieView reloadDetaillabel];
}


- (void)showBookDetails{
    NSDictionary *dic = [self.store getObjectById:@"book" fromTable:self.tableName];
    if (dic) {
        self.bookView.posterImage.userInteractionEnabled = YES;
        //nameLabel
        self.bookView.nameLabel.text = dic[@"title"];
        
        //ratingLabel
        NSString *rating = [NSString stringWithFormat:@"评分：%@",dic[@"rating"][@"average"]];
        if ([rating length]>6) {
            rating = [rating substringToIndex:6];
        }
        self.bookView.ratingLabel.text = rating;
        
        //typeLabel
        NSString *type = @"类型：";
        for (int i=0; i<3; i++) {
            type = [type stringByAppendingString:[NSString stringWithFormat:@"%@/",[dic[@"tags"] objectAtIndex:i][@"name"]]];
        }
        NSString *realType = [type substringToIndex:[type length]-1];
        self.bookView.typeLabel.text = realType;
        
        //poster
        [self.bookView.posterImage startLoaderWithTintColor:[UIColor blackColor]];
        __weak typeof(self)weakSelf = self;
        [self.bookView.posterImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",dic[@"images"][@"large"]]] placeholderImage:[UIImage imageNamed:@"透明.png"] options:SDWebImageCacheMemoryOnly |       SDWebImageRefreshCached progress:^(NSInteger receivedSize,NSInteger expectedSize){
            [weakSelf.bookView.posterImage updateImageDownloadProgress:(CGFloat)receivedSize/expectedSize];
        }completed:^(UIImage *image,NSError *error,SDImageCacheType cacheType,NSURL *imageURL){
            [weakSelf.bookView.posterImage reveal];
            weakSelf.backgroundImage.image = image;
            weakSelf.bookView.posterImage.userInteractionEnabled = YES;
            self.ableToShake = YES;
        }];
        self.bookView.detailLabel.text = dic[@"summary"];
        self.bookView.detailLabel.text = [NSString stringWithFormat:@"介绍：%@\n\n作者介绍:",self.bookView.detailLabel.text];
        self.bookView.detailLabel.text = [NSString stringWithFormat:@"%@%@/",self.bookView.detailLabel.text,dic[@"author_intro"]];
        self.bookView.detailLabel.text = [self.bookView.detailLabel.text substringToIndex:[self.bookView.detailLabel.text length]-1];
        self.bookView.detailLabel.numberOfLines = 0;
    }else{
        [self getBookDetails];
    }
    [self.bookView reloadDetaillabel];
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
    self.movieView.posterImage.userInteractionEnabled = NO;
    self.bookView.posterImage.userInteractionEnabled = NO;
}

#pragma shake
-(BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    if (self.ableToShake) {
        if (self.switchView.isMovie) {
            [self.movieView allViewShake];
            self.ableToShake = NO;
            [self performSelector:@selector(getMovieIDAndSendRequest) withObject:nil afterDelay:0.6];
        } else{
            [self.bookView allViewShake];
            self.ableToShake = NO;
            [self performSelector:@selector(getBookDetails) withObject:nil afterDelay:0.6];
        }
    }
}

#pragma getters and setters

- (ContentView *)movieView{
    if (_movieView == nil) {
        _movieView = [[ContentView alloc] init];
        _movieView.posterImage.userInteractionEnabled = YES;
    }
    return _movieView;
}

- (ContentView *)bookView{
    if (_bookView == nil) {
        _bookView = [[ContentView alloc] init];
        _bookView.posterImage.userInteractionEnabled = YES;
    }
    return _bookView;
}

- (SwitchView *)switchView{
    if (_switchView == nil) {
        _switchView = [[SwitchView alloc]init];
        _switchView.backgroundColor = [UIColor clearColor];
        _switchView.translatesAutoresizingMaskIntoConstraints = NO;
        [_switchView addTarget:self action:@selector(valueChanged) forControlEvents:UIControlEventValueChanged];
    }
    return _switchView;
}

- (NSString *)tableName{
    return @"detailsTable";
}

- (YTKKeyValueStore *)store{
    if (_store == nil) {
        _store = [[YTKKeyValueStore alloc] initDBWithName:@"details.db"];
        [_store createTableWithName:self.tableName];
    }
    return _store;
}

- (WebModel *)model{
    if (_model == nil) {
        _model = [[WebModel alloc] init];
    }
    return _model;
}

- (NSArray *)movieViewConstraint{
    if (_movieViewConstraint == nil) {
        _movieViewConstraint = @[[NSLayoutConstraint constraintWithItem:self.movieView
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeHeight
                                                             multiplier:0.8
                                                               constant:0],
                                 [NSLayoutConstraint constraintWithItem:self.movieView
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeBottom
                                                             multiplier:1.0
                                                               constant:0],
                                 [NSLayoutConstraint constraintWithItem:self.movieView
                                                              attribute:NSLayoutAttributeLeft
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeLeft
                                                             multiplier:1.0
                                                               constant:0],
                                 [NSLayoutConstraint constraintWithItem:self.movieView
                                                              attribute:NSLayoutAttributeRight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeRight
                                                             multiplier:1.0
                                                               constant:0]
                                 ];
    }
    return _movieViewConstraint;
}

- (NSArray *)bookViewConstraint{
    if (_bookViewConstraint == nil) {
        _bookViewConstraint = @[[NSLayoutConstraint constraintWithItem:self.bookView
                                                             attribute:NSLayoutAttributeHeight
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.view
                                                             attribute:NSLayoutAttributeHeight
                                                            multiplier:0.8
                                                              constant:0],
                                [NSLayoutConstraint constraintWithItem:self.bookView
                                                             attribute:NSLayoutAttributeBottom
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.view
                                                             attribute:NSLayoutAttributeBottom
                                                            multiplier:1.0
                                                              constant:0],
                                [NSLayoutConstraint constraintWithItem:self.bookView
                                                             attribute:NSLayoutAttributeLeft
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.view
                                                             attribute:NSLayoutAttributeLeft
                                                            multiplier:1.0
                                                              constant:0],
                                [NSLayoutConstraint constraintWithItem:self.bookView
                                                             attribute:NSLayoutAttributeRight
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.view
                                                             attribute:NSLayoutAttributeRight
                                                            multiplier:1.0
                                                              constant:0]
                                ];
    }
    return _bookViewConstraint;
}

@end

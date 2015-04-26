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

    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [super viewDidLoad];
    [self becomeFirstResponder];
    
    [self.view addSubview:_movieView];
    [self.view addSubview:_bookView];
    [self.view addSubview:_switchView];
    [self.view bringSubviewToFront:_movieView];
    
    if (_switchView.isMovie) {
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
    [self resignFirstResponder];
    [super viewWillAppear:animated];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma CustomMethods
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
            [self showMovieDetails];
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
            [self showBookDetails];
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
    NSDictionary *dic = [_store getObjectById:@"movie" fromTable:_tableName];
    if (dic) {
        _movieView.posterImage.userInteractionEnabled = YES;
        //nameLabel
        _movieView.nameLabel.text = dic[@"title"];
    
        //ratingLabel
        NSString *rating = [NSString stringWithFormat:@"评分：%@",dic[@"rating"][@"average"]];
        if ([rating length]>6) {
            rating = [rating substringToIndex:6];
        }
        _movieView.ratingLabel.text = rating;

        //typeLabel
        NSString *type = @"类型：";
        for (int i=0; i<[dic[@"genres"] count]; i++) {
            type = [type stringByAppendingString:[NSString stringWithFormat:@"%@/",[dic[@"genres"] objectAtIndex:i]]];
        }
        NSString *realType = [type substringToIndex:[type length]-1];
        _movieView.typeLabel.text = realType;
        
        //poster
        [_movieView.posterImage startLoaderWithTintColor:[UIColor blackColor]];
        __weak typeof(self)weakSelf = self;
        [_movieView.posterImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",dic[@"images"][@"large"]]] placeholderImage:[UIImage imageNamed:@"透明.png"] options:SDWebImageCacheMemoryOnly |       SDWebImageRefreshCached progress:^(NSInteger receivedSize,NSInteger expectedSize){
            [weakSelf.movieView.posterImage updateImageDownloadProgress:(CGFloat)receivedSize/expectedSize];
        }completed:^(UIImage *image,NSError *error,SDImageCacheType cacheType,NSURL *imageURL){
            [weakSelf.movieView.posterImage reveal];
            weakSelf.backgroundImage.image = image;
            weakSelf.movieView.posterImage.userInteractionEnabled = YES;
            _ableToShake = YES;
        }];
        
        _movieView.detailLabel.text = dic[@"summary"];
        _movieView.detailLabel.text = [NSString stringWithFormat:@"%@\n\n主演:",_movieView.detailLabel.text];
        for (NSDictionary *castDic in dic[@"casts"]) {
            _movieView.detailLabel.text = [NSString stringWithFormat:@"%@%@/",_movieView.detailLabel.text,castDic[@"name"]];
        }
        _movieView.detailLabel.text = [_movieView.detailLabel.text substringToIndex:[_movieView.detailLabel.text length]-1];
        _movieView.detailLabel.numberOfLines = 0;
    }else{
        [self getMovieIDAndSendRequest];
    }
    
    [_movieView reloadDetaillabel];
}


- (void)showBookDetails{
    NSDictionary *dic = [_store getObjectById:@"book" fromTable:_tableName];
    if (dic) {
        _bookView.posterImage.userInteractionEnabled = YES;
        //nameLabel
        _bookView.nameLabel.text = dic[@"title"];
        
        //ratingLabel
        NSString *rating = [NSString stringWithFormat:@"评分：%@",dic[@"rating"][@"average"]];
        if ([rating length]>6) {
            rating = [rating substringToIndex:6];
        }
        _bookView.ratingLabel.text = rating;
        
        //typeLabel
        NSString *type = @"类型：";
        for (int i=0; i<3; i++) {
            type = [type stringByAppendingString:[NSString stringWithFormat:@"%@/",[dic[@"tags"] objectAtIndex:i][@"name"]]];
        }
        NSString *realType = [type substringToIndex:[type length]-1];
        _bookView.typeLabel.text = realType;
        
        //poster
        [_bookView.posterImage startLoaderWithTintColor:[UIColor blackColor]];
        __weak typeof(self)weakSelf = self;
        [_bookView.posterImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",dic[@"images"][@"large"]]] placeholderImage:[UIImage imageNamed:@"透明.png"] options:SDWebImageCacheMemoryOnly |       SDWebImageRefreshCached progress:^(NSInteger receivedSize,NSInteger expectedSize){
            [weakSelf.bookView.posterImage updateImageDownloadProgress:(CGFloat)receivedSize/expectedSize];
        }completed:^(UIImage *image,NSError *error,SDImageCacheType cacheType,NSURL *imageURL){
            [weakSelf.bookView.posterImage reveal];
            weakSelf.backgroundImage.image = image;
            weakSelf.bookView.posterImage.userInteractionEnabled = YES;
            _ableToShake = YES;
        }];
        _bookView.detailLabel.text = dic[@"summary"];
        _bookView.detailLabel.text = [NSString stringWithFormat:@"介绍：%@\n\n作者介绍:",_bookView.detailLabel.text];
        _bookView.detailLabel.text = [NSString stringWithFormat:@"%@%@/",_bookView.detailLabel.text,dic[@"author_intro"]];
        _bookView.detailLabel.text = [_bookView.detailLabel.text substringToIndex:[_bookView.detailLabel.text length]-1];
        _bookView.detailLabel.numberOfLines = 0;
    }else{
        [self getBookDetails];
    }
    [_bookView reloadDetaillabel];
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

#pragma getters and setters
- (NSString *)tableName{
    return @"detailsTable";
}

- (YTKKeyValueStore *)store{
    _store = [[YTKKeyValueStore alloc] initDBWithName:@"details.db"];
    [_store createTableWithName:_tableName];
    return _store;
}

- (WebModel *)model{
    _model = [[WebModel alloc] init];
    return _model;
}

- (ContentView *)bookView{
    _bookView = [[ContentView alloc] init];
    _bookView.posterImage.userInteractionEnabled = YES;
    return _bookView;
}

- (ContentView *)movieView{
    _movieView = [[ContentView alloc] init];
    _movieView.posterImage.userInteractionEnabled = YES;
    return _movieView;
}

- (SwitchView *)switchView{
    SwitchView *switchV = [[SwitchView alloc] init];
    switchV.backgroundColor = [UIColor clearColor];
    switchV.translatesAutoresizingMaskIntoConstraints = NO;
    [switchV addTarget:self action:@selector(valueChanged) forControlEvents:UIControlEventValueChanged];
    return switchV;
}

- (NSArray *)movieViewConstraint{
    return @[[NSLayoutConstraint constraintWithItem:_movieView
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
}

- (NSArray *)bookViewConstraint{
    return @[[NSLayoutConstraint constraintWithItem:_bookView
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
}

@end

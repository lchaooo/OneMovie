//
//  MainViewController.m
//  OneMovie
//
//  Created by 李超 on 15/3/20.
//  Copyright (c) 2015年 李超. All rights reserved.
//

#import "MainViewController.h"
#import "AppDelegate.h"
#import "WebModel.h"
#import "ContentView.h"
#import "SwitchView.h"
#import "FileStore.h"
#import <YTKKeyValueStore.h>
#import <UIImageView+RJLoader.h>
#import <UIImageView+WebCache.h>
#import <MBProgressHUD.h>
#import <POP.h>
#import <Masonry.h>

@interface MainViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (strong,nonatomic) ContentView *movieView;
@property (strong,nonatomic) ContentView *bookView;
@property (strong,nonatomic) YTKKeyValueStore *store;//数据储存
@property (strong,nonatomic) NSString *tableName;//fmdb tablename
@property (strong,nonatomic) WebModel *model;
@property (strong,nonatomic) SwitchView *switchView;
@property (strong,nonatomic) NSString *movieID;
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
    [self.switchView mas_makeConstraints:^(MASConstraintMaker *make){
        make.centerY.equalTo(self.view).with.multipliedBy(0.25f);
        make.centerX.equalTo(self.view);
        make.width.equalTo(self.view).multipliedBy(0.6f).with.offset(50);
        make.height.equalTo(self.view).multipliedBy(0.08f);
    }];
    [self.movieView mas_makeConstraints:^(MASConstraintMaker *make){
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
        make.width.equalTo(self.view);
        make.height.equalTo(self.view).multipliedBy(0.8f);
    }];
    [self.bookView mas_makeConstraints:^(MASConstraintMaker *make){
        make.bottom.equalTo(self.view);
        make.left.equalTo(self.movieView.mas_right);
        make.width.equalTo(self.view);
        make.height.equalTo(self.movieView);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma Event Response
- (void)valueChanged{
    NSLog(self.switchView.isMovie? @"yes" :@"no");
    [self.view setNeedsUpdateConstraints];
    if (self.switchView.isMovie) {
        [self.movieView mas_remakeConstraints:^(MASConstraintMaker *make){
            make.right.equalTo(self.view);
            make.left.equalTo(self.view);
            make.bottom.equalTo(self.view);
            make.height.equalTo(self.view).multipliedBy(0.8f);
        }];
        [UIView animateWithDuration:0.5 animations:^{
            [self.view layoutIfNeeded];
        }];
        [self showMovieDetails];
        [self.view bringSubviewToFront:self.movieView];
    } else if(!self.switchView.isMovie){
        [self.movieView mas_remakeConstraints:^(MASConstraintMaker *make){
            make.right.equalTo(self.view.mas_left);
            make.width.equalTo(self.view);
            make.height.equalTo(self.view).with.multipliedBy(0.8f);
            make.bottom.equalTo(self.view);
        }];
        [UIView animateWithDuration:0.5 animations:^{
            [self.view layoutIfNeeded];
        }];
        [self showBookDetails];
        [self.view bringSubviewToFront:self.bookView];
    }
}


#pragma custom
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
    [self.model getMovieDictionaryByMovieID:self.movieID];
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
        [self.movieView showDetailsOfInfo:self.model.movieInfo];
        _ableToShake = YES;
    }else{
        [self getMovieIDAndSendRequest];
    }
    [self.movieView reloadDetaillabel];
    NSLog(@"%@",[self.model movieInfo].name);
}


- (void)showBookDetails{
    NSDictionary *dic = [self.store getObjectById:@"book" fromTable:self.tableName];
    if (dic) {
        [self.bookView showDetailsOfInfo:self.model.bookInfo];
        _ableToShake = YES;
        NSLog(@"%@",self.model.bookInfo.type);
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

- (NSString *)movieID{
    return [AppDelegate sharedDelegate].fileStore.getMovieID;
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

@end

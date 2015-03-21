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



@interface MainViewController ()<UIViewControllerTransitioningDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (weak, nonatomic) IBOutlet UIView *posterImage;
@property (weak, nonatomic) IBOutlet RQShineLabel *nameLabel;
@property (weak, nonatomic) IBOutlet RQShineLabel *ratingLabel;
@property (weak, nonatomic) IBOutlet RQShineLabel *typeLabel;



@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _nameLabel.text = @"教父";
    _ratingLabel.text = @"评分：9.1";
    _typeLabel.text = @"类型：剧情／犯罪";
    [_nameLabel shine];
    [_ratingLabel shine];
    [_typeLabel shine];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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

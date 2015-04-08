//
//  SwitchView.h
//  OneMovie
//
//  Created by 俞 丽央 on 15-3-31.
//  Copyright (c) 2015年 李超. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SwitchView : UIControl


@property (nonatomic) NSUInteger      initialLocation;
@property (nonatomic) NSUInteger      initialcenter;
@property (nonatomic,strong) UIView *switchButton;
@property (nonatomic,strong) UILabel *movieLabel;
@property (nonatomic,strong) UILabel *bookLabel;
@property  BOOL isMovie;

@end

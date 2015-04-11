//
//  ContentView.h
//  OneMovie
//
//  Created by 李超 on 15/3/22.
//  Copyright (c) 2015年 李超. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RQShineLabel.h>

@interface ContentView : UIView <UIScrollViewDelegate>
@property (strong,nonatomic) UIImageView *posterImage;
@property (nonatomic) NSUInteger      initialLocation;
@property (strong,nonatomic) UILabel *detailLabel;
@property (strong,nonatomic) UIScrollView *scrollView;
@property (nonatomic) NSUInteger      labelheight;
@property (nonatomic) CGSize standardSize;
@property (strong,nonatomic) UILabel *nameLabel;
@property (strong,nonatomic) UILabel *ratingLabel;
@property (strong,nonatomic) UILabel *typeLabel;
@end

//
//  MovieView.m
//  OneMovie
//
//  Created by 俞 丽央 on 15-4-4.
//  Copyright (c) 2015年 李超. All rights reserved.
//

#import "MovieView.h"
#import <POP.h>

@interface MovieView()
@property (nonatomic) NSUInteger      initialLocation;
@end

@implementation MovieView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpLayOut];
    }
    return self;
}

- (void)setUpLayOut{
    _contentView = [[ContentView alloc] initWithFrame:CGRectMake(10, 10, 300, 425)];
    _contentView.userInteractionEnabled = YES;
    [self addSubview:_contentView];
    
    _contentView.posterImage.image = [UIImage imageNamed:@"p1910907404.jpg"];
    UIPanGestureRecognizer *panGesture   = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan1:)];
    [_contentView.posterImage addGestureRecognizer:panGesture];
}


@end

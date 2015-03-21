//
//  ContentView.m
//  OneMovie
//
//  Created by 李超 on 15/3/22.
//  Copyright (c) 2015年 李超. All rights reserved.
//

#import "ContentView.h"
#import <POP.h>



@implementation ContentView

- (id)initWithFrame:(CGRect)frame  {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpLabelAndImageView];
    }
    return self;
}

- (void)setUpLabelAndImageView{
    _noticeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 140, 250, 70)];
    _noticeLabel.textAlignment = NSTextAlignmentCenter;
    _noticeLabel.text = @"松开后搜索";
    _noticeLabel.alpha = 0;
    _noticeLabel.font = [UIFont systemFontOfSize:35];
    _noticeLabel.backgroundColor = [UIColor clearColor];
    _noticeLabel.textColor = [UIColor whiteColor];
    [self addSubview:_noticeLabel];
    
    _posterImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    _posterImage.layer.anchorPoint = CGPointMake(0.5, 0);
    _posterImage.layer.position = CGPointMake(self.frame.size.width/2, 0);
    _posterImage.layer.transform   = [self setTransform3D];
    _posterImage.contentMode = UIViewContentModeScaleAspectFill;
    UIPanGestureRecognizer *panGesture   = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan1:)];
    [_posterImage addGestureRecognizer:panGesture];
    
    
    [self addSubview:_posterImage];
    
}

-(void)pan1:(UIPanGestureRecognizer *)recognizer{
    CGPoint location = [recognizer locationInView:self];
    
    static float y_coordinate;
    if (y_coordinate != location.y) {
        y_coordinate = location.y;
        NSLog(@"%f",y_coordinate);
    }
    
    //获取手指在PageView中的初始坐标
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.initialLocation = location.y;
        [self bringSubviewToFront:_posterImage];
    }

    if (recognizer.state == UIGestureRecognizerStateEnded) {
    
        
        y_coordinate = 0.0f;
    }
    
    //如果手指在PageView里面,开始使用POPAnimation
    if (location.y<=_initialLocation) {
        if([self isLocation:location InView:self] || location.y<0){
            //把一个PI平均分成可以下滑的最大距离份
            CGFloat percent = -(M_PI /self.initialLocation)/2;
            POPBasicAnimation *alphaAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
            alphaAnimation.toValue = @(((location.y-self.initialLocation)*percent/M_PI-0.45)*0.75*5);
            NSLog(@"%f",((location.y-self.initialLocation)*percent/M_PI-0.45)*0.75*5);
            alphaAnimation.duration = 0.01;
            [_noticeLabel pop_addAnimation:alphaAnimation forKey:@"alphaAnimation"];
            
            //POPAnimation的使用
            POPBasicAnimation *rotationAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerRotationX];
            //给这个animation设值。这个值根据手的滑动而变化，所以值会不断改变。又因为这个方法会实时调用，所以变化的值会实时显示在屏幕上。
            rotationAnimation.duration = 0.01;//默认的duration是0.4
            rotationAnimation.toValue =@((location.y-self.initialLocation)*percent);
            
            //把这个animation加到topView的layer,key只是个识别符。
            [_posterImage.layer pop_addAnimation:rotationAnimation forKey:@"rotationAnimation"];
        
        //当松手的时候，自动复原
            if (recognizer.state == UIGestureRecognizerStateEnded ||
                recognizer.state == UIGestureRecognizerStateCancelled) {
                if ((location.y-self.initialLocation)*percent <= M_PI/4) {
                    POPSpringAnimation *recoverAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerRotationX];
                    recoverAnimation.springBounciness = 18.0f; //弹簧反弹力度
                    recoverAnimation.dynamicsMass = 2.0f;
                    recoverAnimation.dynamicsTension = 200;
                    recoverAnimation.toValue = @(0);
                    [_posterImage.layer pop_addAnimation:recoverAnimation forKey:@"recoverAnimation"];
                    _noticeLabel.alpha = 0;
                } else {
                    _noticeLabel.text = @"正在搜索";
                    _noticeLabel.alpha = 1;
                    
                    POPSpringAnimation *recoverAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerRotationX];
                    recoverAnimation.springBounciness = 18.0f; //弹簧反弹力度
                    recoverAnimation.dynamicsMass = 2.0f;
                    recoverAnimation.dynamicsTension = 200;
                    recoverAnimation.toValue = @(M_PI);
                    [_posterImage.layer pop_addAnimation:recoverAnimation forKey:@"recoverAnimation"];
                    
                    POPSpringAnimation *enlargeAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
                    enlargeAnimation.toValue = [NSValue valueWithCGRect:[[UIScreen mainScreen] bounds]];
                    enlargeAnimation.springSpeed = 1;
                    [self.layer pop_addAnimation:enlargeAnimation forKey:@"enlargeAnimation"];
                    
                    POPSpringAnimation *keepLabelAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionX];
                    keepLabelAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(CGRectGetMidX([[UIScreen mainScreen] bounds]), 290)];
                    keepLabelAnimation.springSpeed = 1;
                    [_noticeLabel.layer pop_addAnimation:keepLabelAnimation forKey:@"keepLabelAnimation"];
                    
                    POPSpringAnimation *keepMidAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionX];
                    keepMidAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(CGRectGetMidX([[UIScreen mainScreen] bounds]), 0)];
                    keepMidAnimation.springSpeed = 1;
                    [_posterImage.layer pop_addAnimation:keepMidAnimation forKey:@"keepMidAnimation"];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"Please Fade Out" object:nil];
                }
            }
        
        }
    }
    
    //手指超出边界也自动复原
    if ( location.x<0 || location.x > self.bounds.size.width || (location.y - self.initialLocation)>(CGRectGetHeight(self.bounds))-(self.initialLocation)) {
        recognizer.enabled = NO;
        POPSpringAnimation *recoverAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerRotationX];
        recoverAnimation.springBounciness = 18.0f; //弹簧反弹力度
        recoverAnimation.dynamicsMass = 2.0f;
        recoverAnimation.dynamicsTension = 200;
        recoverAnimation.toValue = @(0);
        [_posterImage.layer pop_addAnimation:recoverAnimation forKey:@"recoverAnimation"];
}
    
    recognizer.enabled = YES;
    
    
}

-(BOOL)isLocation:(CGPoint)location InView:(UIView *)view{
    if ((location.x > 0 && location.x < view.bounds.size.width) &&
        (location.y > 0 && location.y < view.bounds.size.height)) {
        return YES;
    }else{
        return NO;
    }
}

-(CATransform3D)setTransform3D{
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = 2.5/-2000;
    return transform;
}

@end

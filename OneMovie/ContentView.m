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
    
    //iphone6 frame
    _noticeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 140, 250, 70)];
    //iphone 5s frame
    //_noticeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 140, 210, 70)];
    _noticeLabel.textAlignment = NSTextAlignmentCenter;
    _noticeLabel.text = @"松开搜索片源";
    _noticeLabel.alpha = 0;
    _noticeLabel.font = [UIFont systemFontOfSize:35];
    _noticeLabel.backgroundColor = [UIColor clearColor];
    _noticeLabel.textColor = [UIColor whiteColor];
    [self addSubview:_noticeLabel];
    
    
    _posterImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    _posterImage.layer.anchorPoint = CGPointMake(0.5, 0);
    _posterImage.layer.position = CGPointMake(self.frame.size.width/2, 0);
    //_posterImage.layer.transform   = [self setTransform3D];
    _posterImage.contentMode = UIViewContentModeScaleAspectFill;
    UIPanGestureRecognizer *panGesture   = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan1:)];
    [_posterImage addGestureRecognizer:panGesture];
    
    
    [self addSubview:_posterImage];
    
}

-(void)pan1:(UIPanGestureRecognizer *)recognizer{
    CGPoint location = [recognizer locationInView:self];
    
//    static float y_coordinate;
//    if (y_coordinate != location.y) {
//        y_coordinate = location.y;
//        NSLog(@"%f",y_coordinate);
//    }
    
    //获取手指在PageView中的初始坐标
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.initialLocation = location.x;
        [self bringSubviewToFront:_posterImage];
    }

//    if (recognizer.state == UIGestureRecognizerStateEnded) {
//    
//        
//        y_coordinate = 0.0f;
//    }
    
    
    
    
    //如果手指在PageView里面,开始使用POPAnimation
    if (location.x<=_initialLocation) {
        if([self isLocation:location InView:self] || location.x<0){
            //把一个PI平均分成可以下滑的最大距离份
            CGFloat percent = (M_PI /self.initialLocation);
            NSLog(@"%f",(location.x-self.initialLocation)*percent);
            
            CATransform3D rotate = CATransform3DMakeRotation((location.x-self.initialLocation)*percent, 0, 1, 0);
            _posterImage.layer.transform = CATransform3DPerspect(rotate, CGPointMake(self.bounds.size.width/2, 0), 800);
            
            
            //当松手的时候，自动复原
            
            if (recognizer.state == UIGestureRecognizerStateEnded ||
                recognizer.state == UIGestureRecognizerStateCancelled) {
                if ((location.x-self.initialLocation)*percent > -M_PI/2) {
                    POPSpringAnimation *recoverAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerRotationY];
                    recoverAnimation.springBounciness = 18.0f; //弹簧反弹力度
                    recoverAnimation.dynamicsMass = 2.0f;
                    recoverAnimation.dynamicsTension = 200;
                    recoverAnimation.toValue = @(0);
                    [_posterImage.layer pop_addAnimation:recoverAnimation forKey:@"recoverAnimation"];
                    
                } else {
                    
                    
                    POPSpringAnimation *recoverAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerRotationY];
                    recoverAnimation.springBounciness = 18.0f; //弹簧反弹力度
                    recoverAnimation.dynamicsMass = 2.0f;
                    recoverAnimation.dynamicsTension = 200;
                    recoverAnimation.toValue = @(0);
                    [_posterImage.layer pop_addAnimation:recoverAnimation forKey:@"recoverAnimation"];

                    
                    
                    /* old
                    _noticeLabel.text = @"正在跳转";
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
                     */
                }
            }
        
        }
    }
    if (location.x>0) {
        //手指超出边界也自动复原
        if ( location.y<0 || location.y > self.bounds.size.height || (location.x - self.initialLocation)>(CGRectGetWidth(self.bounds))-(self.initialLocation)||location.x<0) {
            recognizer.enabled = NO;
            POPSpringAnimation *recoverAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerRotationY];
            recoverAnimation.springBounciness = 18.0f; //弹簧反弹力度
            recoverAnimation.dynamicsMass = 2.0f;
            recoverAnimation.dynamicsTension = 200;
            recoverAnimation.toValue = @(0);
            [_posterImage.layer pop_addAnimation:recoverAnimation forKey:@"recoverAnimation"];
        }
    
        recognizer.enabled = YES;
    }
    
}

-(BOOL)isLocation:(CGPoint)location InView:(UIView *)view{
    if ((location.y > 0 && location.y < view.bounds.size.height) &&
        (location.x > 0 && location.x < view.bounds.size.width)) {
        return YES;
    }else{
        return NO;
    }
}

//-(CATransform3D)setTransform3D{
//    CATransform3D transform = CATransform3DIdentity;
//    transform.m34 = 2.5/-2000;
//    return transform;
//}

CATransform3D CATransform3DMakePerspective(CGPoint center, float disZ)
{
    CATransform3D transToCenter = CATransform3DMakeTranslation(-center.x, -center.y, 0);
    CATransform3D transBack = CATransform3DMakeTranslation(center.x, center.y, 0);
    CATransform3D scale = CATransform3DIdentity;
    scale.m34 = -1.0f/disZ;
    return CATransform3DConcat(CATransform3DConcat(transToCenter, scale), transBack);
}

CATransform3D CATransform3DPerspect(CATransform3D t, CGPoint center, float disZ)
{
    return CATransform3DConcat(t, CATransform3DMakePerspective(center, disZ));
}

@end

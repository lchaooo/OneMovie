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
    _posterImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    _posterImage.layer.anchorPoint = CGPointMake(0, 0.5);
    _posterImage.layer.position = CGPointMake(0, self.frame.size.height/2);
    _posterImage.layer.transform   = [self setTransform3D];
    _posterImage.contentMode = UIViewContentModeScaleAspectFill;
    UIPanGestureRecognizer *panGesture   = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan1:)];
    [_posterImage addGestureRecognizer:panGesture];
    
    
    [self addSubview:_posterImage];
    
}

-(void)pan1:(UIPanGestureRecognizer *)recognizer{
    CGPoint location = [recognizer locationInView:self];
    
    static float x_coordinate;
    if (x_coordinate != location.x) {
        x_coordinate = location.x;
        NSLog(@"%f",x_coordinate);
    }
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        x_coordinate = 0.0f;
    }
    
    //获取手指在PageView中的初始坐标
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.initialLocation = location.x;
        [self bringSubviewToFront:_posterImage];
    }
    
    //如果手指在PageView里面,开始使用POPAnimation
    if (location.x<=_initialLocation) {
        if([self isLocation:location InView:self] || location.x<0){
            //把一个PI平均分成可以下滑的最大距离份
            CGFloat percent = (M_PI /self.initialLocation)/2;
            
//            //POPAnimation的使用
//            POPBasicAnimation *rotationAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerRotationY];
//            //给这个animation设值。这个值根据手的滑动而变化，所以值会不断改变。又因为这个方法会实时调用，所以变化的值会实时显示在屏幕上。
//            rotationAnimation.duration = 0.01;//默认的duration是0.4
//            rotationAnimation.toValue =@((_initialLocation-location.x)*percent);
//            
            //把这个animation加到topView的layer,key只是个识别符。
//            [_posterImage.layer pop_addAnimation:rotationAnimation forKey:@"rotationAnimation"];
            
            CATransform3D rotate = CATransform3DMakeRotation((location.x-self.initialLocation)*percent, 0, 1, 0);
            _posterImage.layer.transform = CATransform3DPerspect(rotate, CGPointMake(0, 0), 600);
            
            //当松手的时候，自动复原
            if (recognizer.state == UIGestureRecognizerStateEnded ||
                recognizer.state == UIGestureRecognizerStateCancelled) {
                if ((location.x-self.initialLocation)*percent <= M_PI/4) {
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
                    recoverAnimation.toValue = @(M_PI);
                    [_posterImage.layer pop_addAnimation:recoverAnimation forKey:@"recoverAnimation"];
                    
                    POPSpringAnimation *enlargeAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
                    enlargeAnimation.toValue = [NSValue valueWithCGRect:[[UIScreen mainScreen] bounds]];
                    enlargeAnimation.springSpeed = 1;
                    [self.layer pop_addAnimation:enlargeAnimation forKey:@"enlargeAnimation"];
                    
                    POPSpringAnimation *keepMidAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionX];
                    keepMidAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(CGRectGetMidX([[UIScreen mainScreen] bounds]), 0)];
                    keepMidAnimation.springSpeed = 1;
                    [_posterImage.layer pop_addAnimation:keepMidAnimation forKey:@"keepMidAnimation"];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"Please Fade Out" object:nil];
                }
            }
        
        }
    }
    if (location.x>0) {
        //手指超出边界也自动复原
        if ( location.y<0 || location.y > self.bounds.size.height || (location.x - self.initialLocation)>(CGRectGetWidth(self.bounds))-(self.initialLocation)) {
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

CATransform3D CATransform3DPerspect(CATransform3D t, CGPoint center, float disZ)
{
    return CATransform3DConcat(t, CATransform3DMakePerspective(center, disZ));
}

CATransform3D CATransform3DMakePerspective(CGPoint center, float disZ)
{
    CATransform3D transToCenter = CATransform3DMakeTranslation(-center.x, -center.y, 0);
    CATransform3D transBack = CATransform3DMakeTranslation(center.x, center.y, 0);
    CATransform3D scale = CATransform3DIdentity;
    scale.m34 = -1.0f/disZ;
    return CATransform3DConcat(CATransform3DConcat(transToCenter, scale), transBack);
}


@end

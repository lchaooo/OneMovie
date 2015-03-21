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
        [self setUpImageView];
    }
    return self;
}

- (void)setUpImageView{
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
    //添加阴影
//    if ([[_posterImage.layer valueForKeyPath:@"transform.rotation.x"] floatValue] < -M_PI_2) {
//        
//        [CATransaction begin];
//        [CATransaction setValue:(id)kCFBooleanTrue
//                         forKey:kCATransactionDisableActions];
//        self.topShadowLayer.opacity = 0.0;
//        self.bottomShadowLayer.opacity = (location.y-self.initialLocation)/(CGRectGetHeight(self.bounds)-self.initialLocation);
//        [CATransaction commit];
//    } else {
//        
//        [CATransaction begin];
//        [CATransaction setValue:(id)kCFBooleanTrue
//                         forKey:kCATransactionDisableActions];
//        CGFloat opacity = (location.y-self.initialLocation)/(CGRectGetHeight(self.bounds)-self.initialLocation);
//        self.bottomShadowLayer.opacity = opacity;
//        self.topShadowLayer.opacity = opacity;
//        [CATransaction commit];
//    }
    
    
    
    //如果手指在PageView里面,开始使用POPAnimation
    if (location.y<=_initialLocation) {
        if([self isLocation:location InView:self] || location.y<0){
            //把一个PI平均分成可以下滑的最大距离份
            CGFloat percent = -(M_PI /self.initialLocation)/2;
        
            //POPAnimation的使用
            //创建一个Animation,设置为绕着X轴旋转。还记得我们上面设置的锚点吗？设置为（0.5，0.5）。这时什么意思呢？当我们设置kPOPLayerRotationX（绕X轴旋转），那么x就起作用了，绕x所在轴；kPOPLayerRotationY，y就起作用了，绕y所在轴。
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

                } else {
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
                }
                //self.topShadowLayer.opacity = 0.0;
                //self.bottomShadowLayer.opacity = 0.0;
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
        //self.topShadowLayer.opacity = 0.0;
        //self.bottomShadowLayer.opacity = 0.0;
        
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
    //如果不设置这个值，无论转多少角度都不会有3D效果
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = 2.5/-2000;
    return transform;
}

@end

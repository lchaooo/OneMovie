//
//  ContentView.m
//  OneMovie
//
//  Created by 李超 on 15/3/22.
//  Copyright (c) 2015年 李超. All rights reserved.
//

#import "ContentView.h"
#import <POP.h>

@interface ContentView()
@property (strong,nonatomic) UIVisualEffectView *blurView;
@property BOOL hasBeginAnimation;
@end

@implementation ContentView
@synthesize scrollView;

- (id)init  {
    self = [super init];
    if (self) {
        [self setUpLabelAndImageView];
        self.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return self;
}


- (void)setUpLabelAndImageView{
    _nameLabel = [[UILabel alloc]init];
    _nameLabel.font = [UIFont fontWithName:@"Arial" size:28];
    _nameLabel.numberOfLines = 0;
    _nameLabel.textAlignment = NSTextAlignmentCenter;
    _nameLabel.textColor = [UIColor whiteColor];
    
    
    _ratingLabel = [[UILabel alloc]init];
    _ratingLabel.font = [UIFont fontWithName:@"Arial" size:18];
    _ratingLabel.textAlignment = NSTextAlignmentCenter;
    _ratingLabel.textColor = [UIColor whiteColor];
    
    
    _typeLabel = [[UILabel alloc]init];
    _typeLabel.font = [UIFont fontWithName:@"Arial" size:18];
    _typeLabel.textAlignment = NSTextAlignmentCenter;
    _typeLabel.textColor = [UIColor whiteColor];
    
    _posterImage = [[UIImageView alloc] init];
    scrollView = [[UIScrollView alloc]init];
    [self addSubview:_nameLabel];
    [self addSubview:_typeLabel];
    [self addSubview:_ratingLabel];
    
    _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _typeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _ratingLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_typeLabel
                                                           attribute:NSLayoutAttributeBottom
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self
                                                           attribute:NSLayoutAttributeBottom
                                                          multiplier:1
                                                            constant:-30]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_typeLabel
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1
                                                      constant:0]];
    [_typeLabel addConstraint:[NSLayoutConstraint constraintWithItem:_typeLabel
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1
                                                      constant:250]];
    [_typeLabel addConstraint:[NSLayoutConstraint constraintWithItem:_typeLabel
                                                           attribute:NSLayoutAttributeHeight
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:nil
                                                           attribute:NSLayoutAttributeNotAnAttribute
                                                          multiplier:1
                                                            constant:20]];
    
    
    [_ratingLabel addConstraint:[NSLayoutConstraint constraintWithItem:_ratingLabel
                                                           attribute:NSLayoutAttributeHeight
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:nil
                                                           attribute:NSLayoutAttributeNotAnAttribute
                                                          multiplier:1
                                                            constant:20]];
    [_ratingLabel addConstraint:[NSLayoutConstraint constraintWithItem:_ratingLabel
                                                             attribute:NSLayoutAttributeWidth
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:nil
                                                             attribute:NSLayoutAttributeNotAnAttribute
                                                            multiplier:1
                                                              constant:250]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_typeLabel
                                                             attribute:NSLayoutAttributeTop
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:_ratingLabel
                                                             attribute:NSLayoutAttributeBottom
                                                            multiplier:1
                                                              constant:5]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_ratingLabel
                                                             attribute:NSLayoutAttributeCenterX
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self
                                                             attribute:NSLayoutAttributeCenterX
                                                            multiplier:1
                                                              constant:0]];
    
    
    [_nameLabel addConstraint:[NSLayoutConstraint constraintWithItem:_nameLabel
                                                           attribute:NSLayoutAttributeWidth
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:nil
                                                           attribute:NSLayoutAttributeNotAnAttribute
                                                          multiplier:1
                                                            constant:250]];
    [_nameLabel addConstraint:[NSLayoutConstraint constraintWithItem:_nameLabel
                                                           attribute:NSLayoutAttributeHeight
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:nil
                                                           attribute:NSLayoutAttributeNotAnAttribute
                                                          multiplier:1
                                                            constant:50]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_nameLabel
                                                           attribute:NSLayoutAttributeBottom
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:_ratingLabel
                                                           attribute:NSLayoutAttributeTop
                                                          multiplier:1
                                                            constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_nameLabel
                                                           attribute:NSLayoutAttributeCenterX
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self
                                                           attribute:NSLayoutAttributeCenterX
                                                          multiplier:1
                                                            constant:0]];
    
    
    _posterImage.frame = CGRectMake([UIScreen mainScreen].bounds.size.width*0.15, 10 , [UIScreen mainScreen].bounds.size.width*0.7, [UIScreen mainScreen].bounds.size.width*0.7/300*425);
    _posterImage.layer.cornerRadius = 10;
    _posterImage.clipsToBounds = YES;
    
    scrollView.frame = _posterImage.frame;
    

    _standardSize = scrollView.frame.size;
    
    _posterImage.contentMode = UIViewContentModeScaleAspectFill;
    UIPanGestureRecognizer *panGesture   = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan1:)];
    UIPanGestureRecognizer *panGesture2   = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan2:)];
    panGesture2.delegate = self;
    [_posterImage addGestureRecognizer:panGesture];
    [self addSubview:_posterImage];
    
    [self bringSubviewToFront:_posterImage];

    scrollView.layer.cornerRadius = 10;
    scrollView.backgroundColor = [UIColor clearColor];

    
    _blurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    _blurView.layer.cornerRadius = 10;
    _blurView.clipsToBounds = YES;
    
    _detailLabel = [[UILabel alloc]init];
    _detailLabel.backgroundColor = [UIColor clearColor];
    _detailLabel.layer.cornerRadius = 10;
    _detailLabel.clipsToBounds = YES;
    _detailLabel.textColor =  [UIColor whiteColor];
    _detailLabel.numberOfLines = 0;
    _detailLabel.userInteractionEnabled = YES;
    [_detailLabel addGestureRecognizer:panGesture2];

    scrollView.delegate = self;
    scrollView.showsVerticalScrollIndicator = NO;
    [self addSubview:scrollView];
    
    [scrollView addSubview:_blurView];
    [scrollView addSubview:_detailLabel];
 
    
    [self bringSubviewToFront:_posterImage];
    scrollView.hidden = YES;
    
    _hasBeginAnimation = NO;
}

-(void)reloadDetaillabel{
    UIFont *tfont = [UIFont systemFontOfSize:18.0];
    _detailLabel.font = tfont;
    NSDictionary * dic = [NSDictionary dictionaryWithObjectsAndKeys:tfont,NSFontAttributeName,nil];
    CGSize sizeText = [_detailLabel.text boundingRectWithSize:CGSizeMake(_standardSize.width*1.2-40, 2000) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
    scrollView.contentSize = CGSizeMake(_standardSize.width*1.2-40, sizeText.height+50);
    _detailLabel.frame = CGRectMake(0, 0, _standardSize.width*1.2-40, sizeText.height+20);
    _labelheight = sizeText.height;
    _blurView.frame = _detailLabel.frame;
}

-(void)pan1:(UIPanGestureRecognizer *)recognizer{
    CGPoint location = [recognizer locationInView:self];
    

    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.initialLocation = location.x;
        [self bringSubviewToFront:_posterImage];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"enableSwitchview" object:nil];
    }
    
        if (recognizer.state == UIGestureRecognizerStateEnded) {
    
            [[NSNotificationCenter defaultCenter]postNotificationName:@"notenableSwitchview" object:nil];
        }
    
    
    CGFloat percent = (M_PI /self.initialLocation);
    
    if (location.x<=_initialLocation&_initialLocation>=self.frame.size.width/2) {
        if([self isLocation:location InView:self] || location.x<0){
            
            CATransform3D move = CATransform3DMakeTranslation(0, 0, 0.1);
            CATransform3D back = CATransform3DMakeTranslation(0, 0, 0.1);
            
            CATransform3D rotate1 = CATransform3DMakeRotation((location.x-self.initialLocation)*percent, 0, 1, 0);
            CATransform3D rotate2 = CATransform3DMakeRotation(-M_PI+(location.x-self.initialLocation)*percent, 0, 1, 0);
            
            CATransform3D mat1 = CATransform3DConcat(CATransform3DConcat(move, rotate1), back);
            CATransform3D mat2 = CATransform3DConcat(CATransform3DConcat(move, rotate2), back);
            
            _posterImage.layer.transform = CATransform3DPerspect(mat1, CGPointMake(0, 0), 800);
            scrollView.layer.transform = CATransform3DPerspect(mat2, CGPointMake(0, 0), 800);
            
            
            if ((location.x-self.initialLocation)*percent < -M_PI_2 ){
                _posterImage.hidden = YES;
                scrollView.hidden = NO;
            }
            else {
                _posterImage.hidden = NO;
                scrollView.hidden = YES;
            }
            
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
                    POPSpringAnimation *exAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewSize];
                    exAnimation.springBounciness = 18.0f;
                    exAnimation.dynamicsMass = 0.8f;
                    exAnimation.dynamicsTension = 200;
                    exAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(_standardSize.width*1.2 , _standardSize.height*1.6 )];
                    [scrollView.layer pop_addAnimation:exAnimation forKey:@"exAnimation"];
                    [UIView animateWithDuration:0.5 animations:^{
                        _detailLabel.frame = CGRectMake(20, 20, _standardSize.width*1.2-40, _labelheight+20);
                        _blurView.frame = CGRectMake(_detailLabel.frame.origin.x-10, _detailLabel.frame.origin.y-10, _detailLabel.frame.size.width+20, _detailLabel.frame.size.height+20);
                    }];
                    
                    [UIView animateWithDuration:0.2 animations:^{
                        _nameLabel.alpha =0;
                        _ratingLabel.alpha = 0;
                        _typeLabel.alpha = 0;
                        scrollView.layer.transform = CATransform3DMakeRotation(0 , 0, 1, 0);
                        
                    }];
                    [self performSelector:@selector(changeSomething) withObject:nil afterDelay:0.1];
                    
                
                    
                }
            }
        }
    }
    
    
    if (location.x>=_initialLocation&_initialLocation<=self.frame.size.width/2) {
        if([self isLocation:location InView:self] || location.x<0){
            
            CGFloat percent = (M_PI /([UIScreen mainScreen].bounds.size.width-self.initialLocation));
            
            CATransform3D move = CATransform3DMakeTranslation(0, 0, 0.1);
            CATransform3D back = CATransform3DMakeTranslation(0, 0, 0.1);
            
            CATransform3D rotate1 = CATransform3DMakeRotation((location.x-self.initialLocation)*percent, 0, 1, 0);
            CATransform3D rotate2 = CATransform3DMakeRotation(-M_PI+(location.x-self.initialLocation)*percent, 0, 1, 0);
            
            CATransform3D mat1 = CATransform3DConcat(CATransform3DConcat(move, rotate1), back);
            CATransform3D mat2 = CATransform3DConcat(CATransform3DConcat(move, rotate2), back);
            
            _posterImage.layer.transform = CATransform3DPerspect(mat1, CGPointMake(0, 0), 800);
            scrollView.layer.transform = CATransform3DPerspect(mat2, CGPointMake(0, 0), 800);
            
            
            if ((location.x-self.initialLocation)*percent > M_PI_2 ){
                _posterImage.hidden = YES;
                scrollView.hidden = NO;
            }
            else {
                _posterImage.hidden = NO;
                scrollView.hidden = YES;
            }
            
            //当松手的时候，自动复原
            
            if (recognizer.state == UIGestureRecognizerStateEnded ||
                recognizer.state == UIGestureRecognizerStateCancelled) {
                if ((location.x-self.initialLocation)*percent < M_PI/2) {
                    POPSpringAnimation *recoverAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerRotationY];
                    recoverAnimation.springBounciness = 18.0f; //弹簧反弹力度
                    recoverAnimation.dynamicsMass = 2.0f;
                    recoverAnimation.dynamicsTension = 200;
                    recoverAnimation.toValue = @(0);
                    [_posterImage.layer pop_addAnimation:recoverAnimation forKey:@"recoverAnimation"];
                    
                } else {
                    POPSpringAnimation *exAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewSize];
                    exAnimation.springBounciness = 18.0f;
                    exAnimation.dynamicsMass = 0.8f;
                    exAnimation.dynamicsTension = 200;
                    exAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(_standardSize.width*1.2 , _standardSize.height*1.6 )];
                    [scrollView.layer pop_addAnimation:exAnimation forKey:@"exAnimation"];
                    [UIView animateWithDuration:0.5 animations:^{
                        _detailLabel.frame = CGRectMake(20, 20, _standardSize.width*1.2-40, _labelheight+20);
                        _blurView.frame = CGRectMake(_detailLabel.frame.origin.x-10, _detailLabel.frame.origin.y-10, _detailLabel.frame.size.width+20, _detailLabel.frame.size.height+20);
                    }];
                    
                    [UIView animateWithDuration:0.2 animations:^{
                        _nameLabel.alpha =0;
                        _ratingLabel.alpha = 0;
                        _typeLabel.alpha = 0;
                        scrollView.layer.transform = CATransform3DMakeRotation(0 , 0, 1, 0);
                        
                    }];
                    [self performSelector:@selector(changeSomething) withObject:nil afterDelay:0.1];
                }
            }
        }
    }
    if (location.x>0) {
        //手指超出边界也自动复原
        if ( location.y<0 || location.y > self.bounds.size.height || (location.x - self.initialLocation)>(CGRectGetWidth(self.bounds))-(self.initialLocation)||location.x<0) {
            recognizer.enabled = NO;
            
            
            if ((location.x-self.initialLocation)*percent > -M_PI/2) {
                POPSpringAnimation *recoverAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerRotationY];
                recoverAnimation.springBounciness = 18.0f; //弹簧反弹力度
                recoverAnimation.dynamicsMass = 2.0f;
                recoverAnimation.dynamicsTension = 200;
                recoverAnimation.toValue = @(0);
                [_posterImage.layer pop_addAnimation:recoverAnimation forKey:@"recoverAnimation"];
                
            } else {
                POPSpringAnimation *exAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewSize];
                exAnimation.springBounciness = 18.0f;
                exAnimation.dynamicsMass = 1.0f;
                exAnimation.dynamicsTension = 300;
                exAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(_standardSize.width*1.2 , _standardSize.height*1.6 )];
                [scrollView pop_addAnimation:exAnimation forKey:@"exAnimation"];
                [UIView animateWithDuration:0.5 animations:^{
                    _detailLabel.frame = CGRectMake(20, 20, _standardSize.width*1.2-40, _labelheight+20);
                    _blurView.frame = _detailLabel.frame;
                    NSLog(@"2");
                }];
                [UIView animateWithDuration:0.2 animations:^{
                    scrollView.layer.transform = CATransform3DMakeRotation(0 , 0, 1, -M_PI);
                    _nameLabel.alpha =0;
                    _ratingLabel.alpha = 0;
                    _typeLabel.alpha = 0;
                }];
                [self performSelector:@selector(changeSomething) withObject:nil afterDelay:0.1];
                
            }

        }
        
        recognizer.enabled = YES;
    }
    
}

- (void)changeSomething{
   [[NSNotificationCenter defaultCenter]postNotificationName:@"enableSwitchview" object:nil];
    _hasBeginAnimation = NO;
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



-(void)pan2:(UIPanGestureRecognizer *)recognizer{
    
    CGPoint location = [recognizer locationInView:self];
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.initialLocation = location.x;
    }
    if ((location.x-self.initialLocation>50)&(!_hasBeginAnimation)&(self.initialLocation<=_detailLabel.frame.size.width/2)){
        _hasBeginAnimation = YES;
        POPSpringAnimation *leAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewSize];
        leAnimation.springBounciness = 18.0f;
        leAnimation.dynamicsMass = 2.0f;
        leAnimation.dynamicsTension = 200;
        leAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(_standardSize.width , _standardSize.height )];
        [scrollView pop_addAnimation:leAnimation forKey:@"leAnimation"];
        
        [UIView animateWithDuration:0.2 animations:^{
            scrollView.frame = CGRectMake( self.bounds.size.width/6, 10 , self.bounds.size.width*2/3, self.bounds.size.width*850/900);
            _detailLabel.frame = CGRectMake(0, 0, _standardSize.width*1.2-40, _labelheight+20);
            _blurView.frame = _detailLabel.frame;
            _nameLabel.alpha =1;
            _ratingLabel.alpha = 1;
            _typeLabel.alpha = 1;
        }];
        [UIView animateWithDuration:0.5 animations:^{
            CATransform3D rotate2 = CATransform3DMakeRotation(M_PI/2, 0, 1, 0);
            scrollView.layer.transform = CATransform3DPerspect(rotate2, CGPointMake(0, 0), 800);
        } completion:^(BOOL finished){
            _posterImage.hidden = NO;
            scrollView.hidden = YES;
            CATransform3D rotate1 = CATransform3DMakeRotation(-M_PI/2, 0, 1, 0);
            _posterImage.layer.transform = CATransform3DPerspect(rotate1, CGPointMake(0, 0), 800);
            POPSpringAnimation *recoverAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerRotationY];
            recoverAnimation.springBounciness = 18.0f; //弹簧反弹力度
            recoverAnimation.dynamicsMass = 2.0f;
            recoverAnimation.dynamicsTension = 200;
            recoverAnimation.toValue = @(0);
            [_posterImage.layer pop_addAnimation:recoverAnimation forKey:@"recoverAnimation"];
            
        }];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"notenableSwitchview" object:nil];
    }
    if ((location.x-self.initialLocation<-50)&(!_hasBeginAnimation)&(self.initialLocation>=_detailLabel.frame.size.width/2)){
        _hasBeginAnimation = YES;
        POPSpringAnimation *leAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewSize];
        leAnimation.springBounciness = 18.0f;
        leAnimation.dynamicsMass = 2.0f;
        leAnimation.dynamicsTension = 200;
        leAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(_standardSize.width , _standardSize.height )];
        [scrollView pop_addAnimation:leAnimation forKey:@"leAnimation"];
        
        [UIView animateWithDuration:0.2 animations:^{
            scrollView.frame = CGRectMake( self.bounds.size.width/6, 10 , self.bounds.size.width*2/3, self.bounds.size.width*850/900);
            _detailLabel.frame = CGRectMake(0, 0, _standardSize.width*1.2-40, _labelheight+20);
            _blurView.frame = _detailLabel.frame;
            _nameLabel.alpha =1;
            _ratingLabel.alpha = 1;
            _typeLabel.alpha = 1;
        }];
        [UIView animateWithDuration:0.5 animations:^{
            CATransform3D rotate2 = CATransform3DMakeRotation(-M_PI/2, 0, 1, 0);
            scrollView.layer.transform = CATransform3DPerspect(rotate2, CGPointMake(0, 0), 800);
        } completion:^(BOOL finished){
            _posterImage.hidden = NO;
            scrollView.hidden = YES;
            CATransform3D rotate1 = CATransform3DMakeRotation(M_PI/2, 0, 1, 0);
            _posterImage.layer.transform = CATransform3DPerspect(rotate1, CGPointMake(0, 0), 800);
            POPSpringAnimation *recoverAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerRotationY];
            recoverAnimation.springBounciness = 18.0f; //弹簧反弹力度
            recoverAnimation.dynamicsMass = 2.0f;
            recoverAnimation.dynamicsTension = 200;
            recoverAnimation.toValue = @(0);
            [_posterImage.layer pop_addAnimation:recoverAnimation forKey:@"recoverAnimation"];
            
        }];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"notenableSwitchview" object:nil];
    }
}

-(void)scrollToTop{
    [scrollView scrollRectToVisible:CGRectMake(0, 0, _posterImage.frame.size.width, _posterImage.frame.size.height) animated:YES];
}

-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]){
        CGPoint translation = [(UIPanGestureRecognizer *)gestureRecognizer translationInView:_detailLabel];
        return fabs(translation.x)>fabs(translation.y);
    }
    return YES;
    
}

- (void)shakeAnimationForView:(UIView *) view

{
    // 获取到当前的View
    CALayer *viewLayer = view.layer;
    
    // 获取当前View的位置
    CGPoint position = viewLayer.position;
    
    // 移动的两个终点位置
    CGPoint x = CGPointMake(position.x + 10, position.y);
    CGPoint y = CGPointMake(position.x - 10, position.y);
    
    // 设置动画
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    
    // 设置运动形式
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
    
    // 设置开始位置
    [animation setFromValue:[NSValue valueWithCGPoint:x]];
    
    // 设置结束位置
    [animation setToValue:[NSValue valueWithCGPoint:y]];
    
    // 设置自动反转
    [animation setAutoreverses:YES];
    
    // 设置时间
    [animation setDuration:.06];
    
    // 设置次数
    [animation setRepeatCount:3];
    
    // 添加上动画
    [viewLayer addAnimation:animation forKey:nil];
}

- (void)allViewShake{
    [self shakeAnimationForView:_posterImage];
    [self shakeAnimationForView:_nameLabel];
    [self shakeAnimationForView:_ratingLabel];
    [self shakeAnimationForView:_typeLabel];
}

@end

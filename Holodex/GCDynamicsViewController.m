//
//  GCDynamicsViewController.m
//  Holodex
//
//  Created by Cameron Westbury on 10/16/15.
//  Copyright © 2015 Cameron Westbury. All rights reserved.
//

#import "GCDynamicsViewController.h"

@interface GCDynamicsViewController ()
@property (nonatomic, strong)        UIDynamicAnimator      *animator;
@property (nonatomic, weak) IBOutlet UIImageView            *falcon;
@property (nonatomic, weak) IBOutlet UIImageView            *tieFighter;
@property (nonatomic, strong)        UICollisionBehavior    *collisionBehavior;
@property (nonatomic, strong)        UIPushBehavior         *pushBehavior;
@property (nonatomic, strong)        UIAttachmentBehavior   *attachment;
@property (nonatomic,weak) IBOutlet  UIButton               *startButton;

@end

@implementation GCDynamicsViewController

-(IBAction)handlePan:(UIPanGestureRecognizer*)Gesture{
    if (Gesture.state == UIGestureRecognizerStateEnded) {
        [_animator updateItemUsingCurrentState:_falcon];
        [_animator updateItemUsingCurrentState:_tieFighter];
    }
    CGPoint translation = [Gesture translationInView:self.view];
    Gesture.view.center = CGPointMake(Gesture.view.center.x + translation.x, Gesture.view.center.y + translation.y);
    [Gesture setTranslation:CGPointMake(0, 0) inView:self.view];
    
    [UIView animateWithDuration: 1.0 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        _startButton.alpha = 1;
        _startButton.enabled = true;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
    }];

    
}


-(IBAction)startButtonPressed:(id)sender{
    _startButton.enabled = false;
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(_falcon.center.x, _falcon.center.y)];
    [path addLineToPoint:CGPointMake(133,353)];
    //[path addLineToPoint:CGPointMake(123,270)];
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = [path CGPath];
    shapeLayer.strokeColor = [[UIColor greenColor] CGColor];
    shapeLayer.lineWidth = 1.5;
    shapeLayer.fillColor = [[UIColor greenColor] CGColor];
    [self.view.layer addSublayer:shapeLayer];
    double delayInSeconds = .05;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        shapeLayer.strokeColor = [[UIColor clearColor]CGColor];
        shapeLayer.fillColor =[[UIColor clearColor]CGColor];
        [self.view.layer addSublayer:shapeLayer];
    });
    [UIView animateWithDuration:.80 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
         _falcon.center = CGPointMake(500, _falcon.center.y);
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
    }];
    [UIView animateWithDuration:.80 delay:.2 options:UIViewAnimationOptionCurveEaseOut animations:^{
        _tieFighter.center = CGPointMake(_falcon.center.x, _falcon.center.y);
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self performSegueWithIdentifier:@"enter" sender:self];
    }];

}

- (void)addLinearVelocity:(CGPoint)velocity {
    NSMutableArray *dynamicItems = [[NSMutableArray alloc]init];
    [dynamicItems addObject:_falcon];
    [dynamicItems addObject:_tieFighter];
    
}

-(UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma Mark Life Cycle Methods

- (void)viewWillAppear:(BOOL)animated {
    _startButton.enabled = false;
    _startButton.alpha = 0.0;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _animator = [[UIDynamicAnimator alloc] init];
    NSMutableArray *dynamicItems = [[NSMutableArray alloc]init];
    [dynamicItems addObject:_falcon];
    [dynamicItems addObject:_tieFighter];
    
    

   
    
    _collisionBehavior = [[UICollisionBehavior alloc]init];
    [_collisionBehavior addBoundaryWithIdentifier:@"bottomScreen" fromPoint:CGPointMake(0, self.view.frame.size.height) toPoint:CGPointMake(self.view.frame.size.width, self.view.frame.size.height)];
    [_collisionBehavior addBoundaryWithIdentifier:@"topScreen" fromPoint:CGPointMake(0, 0) toPoint:CGPointMake(self.view.frame.size.width, 0)];
    [_collisionBehavior addBoundaryWithIdentifier:@"leftScreen" fromPoint:CGPointMake(0, 0) toPoint:CGPointMake(0, self.view.frame.size.height)];
    [_collisionBehavior addBoundaryWithIdentifier:@"rightScreen" fromPoint:CGPointMake(self.view.frame.size.width, 0) toPoint:CGPointMake(self.view.frame.size.width, self.view.frame.size.height)];
    [_animator addBehavior:_collisionBehavior];
    [_animator addBehavior:_attachment];
    [_animator addBehavior:_pushBehavior];
    
    
}

- (void)didReceiveMemoryWarning {
    
  
    [super didReceiveMemoryWarning];
}

@end

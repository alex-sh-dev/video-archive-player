//
//  StepSlider.h
//  StepSlider
//
//  Created by dev on 1/31/26.
//

#import <UIKit/UIKit.h>

@class StepSlider;

@protocol StepSliderDelegate<NSObject>

@optional
- (void)stepSlider:(nonnull StepSlider *)slider didChangeValue:(nonnull NSNumber *)value;
- (void)stepSlider:(nonnull StepSlider *)slider didUpdateValue:(nonnull NSNumber *)value;

- (void)stepSlider:(nonnull StepSlider *)slider thumbPanGestureBeganAtPoint:(CGPoint)p withValue:(nonnull NSNumber *)value;
- (void)stepSlider:(nonnull StepSlider *)slider thumbPanGestureChangedAtPoint:(CGPoint)p withValue:(nonnull NSNumber *)value;
- (void)stepSlider:(nonnull StepSlider *)slider thumbPanGestureEndedAtPoint:(CGPoint)p withValue:(nonnull NSNumber *)value;

@end

@interface StepSlider : UIView

@property (nonatomic, strong, nonnull) NSNumber *value;

@property (nonatomic, strong, nullable) UIColor *minimumTrackTintColor;
@property (nonatomic, strong, nullable) UIColor *maximumTrackTintColor;

@property (nonatomic, strong, nonnull) NSNumber *minimumValue;
@property (nonatomic, strong, nonnull) NSNumber *maximumValue;

@property (nonatomic, weak, nullable) UIView *thumbView;
@property (nonatomic, strong, nullable) UIImage *thumbImage;

@property (nonatomic, assign) BOOL adjustedThumbRectRelativelyTrack;

@property (nonatomic, assign) UIEdgeInsets thumbInsets;
@property (assign, nonatomic, readonly) BOOL isThumbCaptured;

@property (nonatomic, weak, nullable) id<StepSliderDelegate> delegate;

- (void)setValue:(nonnull NSNumber *)value animated:(BOOL)animated;

- (void)setRelativeViewForGestureRecognizing:(nonnull UIView *)view;

@end

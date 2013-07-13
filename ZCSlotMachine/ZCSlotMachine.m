
#import <QuartzCore/QuartzCore.h>

#import "ZCSlotMachine.h"

#define SHOW_BORDER 0

static BOOL isSliding = NO;
static const NSUInteger kMinTurn = 3;

/********************************************************************************************/

@implementation ZCSlotMachine {
 @private
    UIImageView *_backgroundImageView;
    UIImageView *_coverImageView;
    UIView *_contentView;
    NSUInteger _slotCount;
    NSArray *_slotIcons;
    NSMutableArray *_slotScrollLayerArray;
    NSArray *_slotResults;
    NSArray *_currentSlotResults;
}

#pragma mark - View LifeCycle

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
        _backgroundImageView = [[UIImageView alloc] initWithFrame:frame];
        _backgroundImageView.contentMode = UIViewContentModeCenter;
        [self addSubview:_backgroundImageView];
        
        _contentView = [[UIView alloc] initWithFrame:frame];
#if SHOW_BORDER
        _contentView.layer.borderColor = [UIColor blueColor].CGColor;
        _contentView.layer.borderWidth = 1;
#endif
        
        [self addSubview:_contentView];
        
        _coverImageView = [[UIImageView alloc] initWithFrame:frame];
        _coverImageView.contentMode = UIViewContentModeCenter;
        [self addSubview:_coverImageView];
        
        _slotScrollLayerArray = [NSMutableArray array];
        
        self.singleUnitDuration = 0.14f;
    }
    return self;
}

#pragma mark - Properties Methods

- (void)setBackgroundImage:(UIImage *)backgroundImage {
    _backgroundImageView.image = backgroundImage;
}

- (void)setCoverImage:(UIImage *)coverImage {
    _coverImageView.image = coverImage;
}

- (void)setContentInset:(UIEdgeInsets)contentInset {
    CGRect viewFrame = self.frame;
    
    _contentView.frame = CGRectMake(contentInset.left, contentInset.top, viewFrame.size.width - contentInset.left - contentInset.right, viewFrame.size.height - contentInset.top - contentInset.bottom);
}

- (NSUInteger)slotCount {
    return _slotCount;
}

- (void)setSlotCount:(NSUInteger)slotCount {
    _slotCount = slotCount;
    
    CGFloat slotSpacing = 0;
    if ([self.delegate respondsToSelector:@selector(slotSpacing)]) {
        slotSpacing = [self.delegate slotSpacing];
    }
    
    CGFloat slotWidth = _contentView.frame.size.width / slotCount;
    if ([self.delegate respondsToSelector:@selector(slotWidth)]) {
        slotWidth = [self.delegate slotWidth];
    }
    
    for (int i = 0; i < slotCount; i++) {
        CALayer *slotContainerLayer = [[CALayer alloc] init];
        slotContainerLayer.frame = CGRectMake(i * (slotWidth + slotSpacing), 0, slotWidth, _contentView.frame.size.height);
        slotContainerLayer.masksToBounds = YES;
        
        CALayer *slotScrollLayer = [[CALayer alloc] init];
        slotScrollLayer.frame = CGRectMake(0, 0, slotWidth, _contentView.frame.size.height);
#if SHOW_BORDER
        slotScrollLayer.borderColor = [UIColor greenColor].CGColor;
        slotScrollLayer.borderWidth = 1;
#endif
        [slotContainerLayer addSublayer:slotScrollLayer];
        
        [_contentView.layer addSublayer:slotContainerLayer];
        
        [_slotScrollLayerArray addObject:slotScrollLayer];
    }
}

- (void)setSlotIcons:(NSArray *)slotIcons {
    _slotIcons = slotIcons;
    
    CGFloat singleUnitHeight = _contentView.frame.size.height / 3;
    NSUInteger iconCount = [slotIcons count];
    NSUInteger slotCount = [_slotScrollLayerArray count];
    for (int i = 0; i < slotCount; i++) {
        CALayer *slotScrollLayer = [_slotScrollLayerArray objectAtIndex:i];
        NSInteger scrollLayerTopIndex = - (i + kMinTurn + 3) * iconCount;
        
        for (int j = 0; j > scrollLayerTopIndex; j--) {
            UIImage *iconImage = [slotIcons objectAtIndex:abs(j) % slotCount];
            
            CALayer *iconImageLayer = [[CALayer alloc] init];
            // adjust the beginning offset of the first unit
            NSInteger offsetYUnit = j + 1 + iconCount;
            iconImageLayer.frame = CGRectMake(0, offsetYUnit * singleUnitHeight, slotScrollLayer.frame.size.width, singleUnitHeight);
            
            iconImageLayer.contents = (id)iconImage.CGImage;
            iconImageLayer.contentsScale = iconImage.scale;
            iconImageLayer.contentsGravity = kCAGravityCenter;
#if SHOW_BORDER
            iconImageLayer.borderColor = [UIColor redColor].CGColor;
            iconImageLayer.borderWidth = 1;
#endif
            
            [slotScrollLayer addSublayer:iconImageLayer];
        }
    }
}

- (NSArray *)slotResults {
    return _slotResults;
}

- (void)setSlotResults:(NSArray *)slotResults {
    if (!isSliding) {
        _slotResults = slotResults;
        
        if (!_currentSlotResults) {
            NSMutableArray *currentSlotResults = [NSMutableArray array];
            for (int i = 0; i < [slotResults count]; i++) {
                [currentSlotResults addObject:[NSNumber numberWithUnsignedInteger:0]];
            }
            _currentSlotResults = [NSArray arrayWithArray:currentSlotResults];
        }
    }
}

#pragma mark - Public Methods

- (void)startSliding {
    
    if (isSliding) {
        return;
    }
    else {
        isSliding = YES;
        
        if ([self.delegate respondsToSelector:@selector(slotMachineWillStartSliding:)]) {
            [self.delegate slotMachineWillStartSliding:self];
        }
        
        __block NSMutableArray *completePositionArray = [NSMutableArray array];
        
        [CATransaction begin];
        
        [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [CATransaction setDisableActions:YES];
        [CATransaction setCompletionBlock:^{
            isSliding = NO;
            
            if ([self.delegate respondsToSelector:@selector(slotMachineDidEndSliding:)]) {
                [self.delegate slotMachineDidEndSliding:self];
            }
            
            for (int i = 0; i < [_slotScrollLayerArray count]; i++) {
                CALayer *slotScrollLayer = [_slotScrollLayerArray objectAtIndex:i];
                
                slotScrollLayer.position = CGPointMake(slotScrollLayer.position.x, ((NSNumber *)[completePositionArray objectAtIndex:i]).floatValue);
                
                NSMutableArray *toBeDeletedLayerArray = [NSMutableArray array];
                
                NSUInteger resultIndex = [[self.slotResults objectAtIndex:i] unsignedIntegerValue];
                NSUInteger currentIndex = [[_currentSlotResults objectAtIndex:i] unsignedIntegerValue];
                
                for (int j = 0; j < [self.slotIcons count] * (kMinTurn + i) + resultIndex - currentIndex; j++) {
                    CALayer *iconLayer = [slotScrollLayer.sublayers objectAtIndex:j];
                    [toBeDeletedLayerArray addObject:iconLayer];
                }
                
                for (CALayer *toBeDeletedLayer in toBeDeletedLayerArray) {
                    // use initWithLayer does not work
                    CALayer *toBeAddedLayer = [CALayer layer];
                    toBeAddedLayer.frame = toBeDeletedLayer.frame;
                    toBeAddedLayer.contents = toBeDeletedLayer.contents;
                    toBeAddedLayer.contentsScale = toBeDeletedLayer.contentsScale;
                    toBeAddedLayer.contentsGravity = toBeDeletedLayer.contentsGravity;
                    
                    CGFloat shiftY = [self.slotIcons count] * toBeAddedLayer.frame.size.height * (kMinTurn + i + 3);
                    toBeAddedLayer.position = CGPointMake(toBeAddedLayer.position.x, toBeAddedLayer.position.y - shiftY);
                    
                    [toBeDeletedLayer removeFromSuperlayer];
                    [slotScrollLayer addSublayer:toBeAddedLayer];
                }
                toBeDeletedLayerArray = [NSMutableArray array];
            }
            
            _currentSlotResults = self.slotResults;
            completePositionArray = [NSMutableArray array];
        }];
        
        static NSString * const keyPath = @"position.y";
        
        for (int i = 0; i < [_slotScrollLayerArray count]; i++) {
            CALayer *slotScrollLayer = [_slotScrollLayerArray objectAtIndex:i];
            
            NSUInteger resultIndex = [[self.slotResults objectAtIndex:i] unsignedIntegerValue];
            NSUInteger currentIndex = [[_currentSlotResults objectAtIndex:i] unsignedIntegerValue];
            
            NSUInteger howManyUnit = (i + kMinTurn) * [self.slotIcons count] + resultIndex - currentIndex;
            CGFloat slideY = howManyUnit * (_contentView.frame.size.height / 3);
            
            CABasicAnimation *slideAnimation = [CABasicAnimation animationWithKeyPath:keyPath];
            slideAnimation.fillMode = kCAFillModeForwards;
            slideAnimation.duration = howManyUnit * self.singleUnitDuration;
            slideAnimation.toValue = [NSNumber numberWithFloat:slotScrollLayer.position.y + slideY];
            slideAnimation.removedOnCompletion = NO;
            
            [slotScrollLayer addAnimation:slideAnimation forKey:@"slideAnimation"];
            
            [completePositionArray addObject:slideAnimation.toValue];
        }
        
        [CATransaction commit];
    }
}

@end

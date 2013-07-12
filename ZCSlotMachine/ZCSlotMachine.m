
#import <QuartzCore/QuartzCore.h>

#import "ZCSlotMachine.h"

#define SHOW_BORDER 0

static BOOL isSliding = NO;
static const CGFloat kSingleFrameDuration = 0.14f; // animation duration for single icon
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
    
    CGFloat singleFrameHeight = _contentView.frame.size.height / 3;
    NSUInteger iconCount = [slotIcons count];
    NSUInteger slotCount = [_slotScrollLayerArray count];
    for (int i = 0; i < slotCount; i++) {
        CALayer *slotScrollLayer = [_slotScrollLayerArray objectAtIndex:i];
//        NSUInteger resultIndex = [[self.slotResults objectAtIndex:i] unsignedIntValue];
//        NSInteger scrollLayerTopIndex = - (i + kMinTurn) * iconCount - resultIndex;
        NSInteger scrollLayerTopIndex = - (i + kMinTurn + 1) * iconCount;
        
        for (int j = 1; j > scrollLayerTopIndex; j--) {
            UIImage *iconImage = [slotIcons objectAtIndex:j%slotCount];
            
            CALayer *iconImageLayer = [[CALayer alloc] init];
            iconImageLayer.frame = CGRectMake(0, j * singleFrameHeight, slotScrollLayer.frame.size.width, singleFrameHeight);
            
            iconImageLayer.contents = (id)iconImage.CGImage;
            iconImageLayer.contentsGravity = kCAGravityCenter;
            iconImageLayer.contentsScale = [[UIScreen mainScreen] scale];
#if SHOW_BORDER
            iconImageLayer.borderColor = [UIColor redColor].CGColor;
            iconImageLayer.borderWidth = 1;
#endif
            
            [slotScrollLayer addSublayer:iconImageLayer];
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
        
        [CATransaction begin];
        
        [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [CATransaction setCompletionBlock:^{
            isSliding = NO;
            if (self.delegate) {
                if ([self.delegate respondsToSelector:@selector(slotMachineDidEndSliding:)]) {
                    [self.delegate slotMachineDidEndSliding:self];
                }
            }
        }];
        
        NSString *keyPath = @"position.y";
        
        for (int i = 0; i < [_slotScrollLayerArray count]; i++) {
            CALayer *slotScrollLayer = [_slotScrollLayerArray objectAtIndex:i];
            
            NSUInteger resultIndex = [[self.slotResults objectAtIndex:i] unsignedIntValue];
            NSUInteger howManyUnit = (i + kMinTurn) * [self.slotIcons count] + resultIndex;
            CGFloat slideY = howManyUnit * (_contentView.frame.size.height / 3);
            
            CABasicAnimation *slideAnimation = [CABasicAnimation animationWithKeyPath:keyPath];
            slideAnimation.fillMode = kCAFillModeForwards;
            slideAnimation.duration = howManyUnit * kSingleFrameDuration;
            slideAnimation.toValue = [NSNumber numberWithFloat:slotScrollLayer.position.y + slideY];
            slideAnimation.removedOnCompletion = NO;
            
            [slotScrollLayer addAnimation:slideAnimation forKey:@"slideAnimation"];
        }
        
        [CATransaction commit];
    }
}

@end

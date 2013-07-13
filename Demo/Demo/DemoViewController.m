
#import "DemoViewController.h"

@implementation DemoViewController {
 @private
    ZCSlotMachine *_slotMachine;
    UIButton *_startButton;
    
    UIView *_slotContainerView;
    UIImageView *_slotOneImageView;
    UIImageView *_slotTwoImageView;
    UIImageView *_slotThreeImageView;
    UIImageView *_slotFourImageView;
}

#pragma mark - View LifeCycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)dealloc {
    [_startButton removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
    _slotMachine = [[ZCSlotMachine alloc] initWithFrame:CGRectMake(0, 0, 291, 193)];
    _slotMachine.center = CGPointMake(self.view.frame.size.width / 2, 120);
    _slotMachine.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    _slotMachine.slotResults = [NSArray arrayWithObjects:[NSNumber numberWithUnsignedInt:3], [NSNumber numberWithUnsignedInt:3], [NSNumber numberWithUnsignedInt:3], [NSNumber numberWithUnsignedInt:3], nil];
    _slotMachine.delegate = self;
    _slotMachine.contentInset = UIEdgeInsetsMake(5, 8, 5, 8);
    _slotMachine.backgroundImage = [UIImage imageNamed:@"SlotMachineBackground"];
    _slotMachine.coverImage = [UIImage imageNamed:@"SlotMachineCover"];
    _slotMachine.slotCount = 4;
    _slotMachine.slotIcons = [NSArray arrayWithObjects:
                              [UIImage imageNamed:@"Doraemon"], [UIImage imageNamed:@"Mario"], [UIImage imageNamed:@"Nobi Nobita"], [UIImage imageNamed:@"Batman"], nil];
    
    
    [self.view addSubview:_slotMachine];
    
    _startButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *btnImageN = [UIImage imageNamed:@"StartBtn_N"];
    UIImage *btnImageH = [UIImage imageNamed:@"StartBtn_H"];
    _startButton.frame = CGRectMake(0, 0, btnImageN.size.width, btnImageN.size.height);
    _startButton.center = CGPointMake(self.view.frame.size.width / 2, 270);
    _startButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    _startButton.titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    [_startButton setBackgroundImage:btnImageN forState:UIControlStateNormal];
    [_startButton setBackgroundImage:btnImageH forState:UIControlStateHighlighted];
    [_startButton setTitle:@"Start" forState:UIControlStateNormal];
    [_startButton addTarget:self action:@selector(start) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_startButton];
    
    
    _slotContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 180, 45)];
    _slotContainerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    _slotContainerView.center = CGPointMake(self.view.frame.size.width / 2, 350);
    
    [self.view addSubview:_slotContainerView];
    
    _slotOneImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 45, 45)];
    _slotOneImageView.contentMode = UIViewContentModeCenter;
    
    _slotTwoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(45, 0, 45, 45)];
    _slotTwoImageView.contentMode = UIViewContentModeCenter;
    
    _slotThreeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(90, 0, 45, 45)];
    _slotThreeImageView.contentMode = UIViewContentModeCenter;
    
    _slotFourImageView = [[UIImageView alloc] initWithFrame:CGRectMake(135, 0, 45, 45)];
    _slotFourImageView.contentMode = UIViewContentModeCenter;
    
    [_slotContainerView addSubview:_slotOneImageView];
    [_slotContainerView addSubview:_slotTwoImageView];
    [_slotContainerView addSubview:_slotThreeImageView];
    [_slotContainerView addSubview:_slotFourImageView];
}

#pragma mark - Private Methods

- (void)start {
    NSUInteger slotIconCount = [_slotMachine.slotIcons count];
    
    NSUInteger slotOneIndex = abs(rand() % slotIconCount);
    NSUInteger slotTwoIndex = abs(rand() % slotIconCount);
    NSUInteger slotThreeIndex = abs(rand() % slotIconCount);
    NSUInteger slotFourIndex = abs(rand() % slotIconCount);
    
    _slotOneImageView.image = [_slotMachine.slotIcons objectAtIndex:slotOneIndex];
    _slotTwoImageView.image = [_slotMachine.slotIcons objectAtIndex:slotTwoIndex];
    _slotThreeImageView.image = [_slotMachine.slotIcons objectAtIndex:slotThreeIndex];
    _slotFourImageView.image = [_slotMachine.slotIcons objectAtIndex:slotFourIndex];
    
    _slotMachine.slotResults = [NSArray arrayWithObjects:
                                [NSNumber numberWithInteger:slotOneIndex],
                                [NSNumber numberWithInteger:slotTwoIndex],
                                [NSNumber numberWithInteger:slotThreeIndex],
                                [NSNumber numberWithInteger:slotFourIndex],
                                nil];
    
    [_slotMachine startSliding];
}

#pragma mark - UIResponder

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {

    _startButton.highlighted = YES;
    [_startButton performSelector:@selector(setHighlighted:) withObject:[NSNumber numberWithBool:NO] afterDelay:0.8];
    
    [self start];
}

#pragma mark - ZCSlotMachineDelegate

- (CGFloat)slotWidth {
    return 65.0f;
}

- (CGFloat)slotSpacing {
    return 5.0f;
}

- (void)slotMachineWillStartSliding:(ZCSlotMachine *)slotMachine {
    _startButton.enabled = NO;
}

- (void)slotMachineDidEndSliding:(ZCSlotMachine *)slotMachine {
    _startButton.enabled = YES;
}

@end

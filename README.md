### SCREEN SHOT
---

### Requirements
---
* **iOS 5** or later
* QuartzCore.framework
* **ARC**

### HOW TO USE
---

ZCSlotMachine is a subclass of UIView. The demo application shows how it is used.

```
_slotMachine = [[ZCSlotMachine alloc] initWithFrame:CGRectMake(0, 0, 291, 193)];
_slotMachine.center = CGPointMake(self.view.frame.size.width / 2, 120);
_slotMachine.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
_slotMachine.contentInset = UIEdgeInsetsMake(5, 8, 5, 8);
_slotMachine.backgroundImage = [UIImage imageNamed:@"SlotMachineBackground"];
_slotMachine.coverImage = [UIImage imageNamed:@"SlotMachineCover"];
    
_slotMachine.delegate = self;
_slotMachine.dataSource = self;
    
[self.view addSubview:_slotMachine];
```

And implement the ZCSlotMachineDataSource protocol.

```
- (NSArray *)iconsForSlotsInSlotMachine:(ZCSlotMachine *)slotMachine {
    return _slotIcons;
}

- (NSUInteger)numberOfSlotsInSlotMachine:(ZCSlotMachine *)slotMachine {
    return 4;
}

- (CGFloat)slotWidthInSlotMachine:(ZCSlotMachine *)slotMachine {
    return 65.0f;
}

- (CGFloat)slotSpacingInSlotMachine:(ZCSlotMachine *)slotMachine {
    return 5.0f;
}
```

And finally get the slot machine started.

```
[_slotMachine startSliding];
```

### Credits
---


### LICENSE
---

The MIT License

Copyright © 2013 ZCCStudio

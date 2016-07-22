//
//  SWSourceItemCell.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 3/21/12.
//  Copyright (c) 2012 Sweet William SL. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SWSourceItem.h"

@class SWSourceItem;

@interface SWSourceItemCell : UITableViewCell <SWObjectObserver>
{
    SWSourceItem *_sourceItem;   // fem la ivar accessible desde les subclasses
    BOOL _isObserving;
}

@property (nonatomic, strong) SWSourceItem *sourceItem;

// Methods to override in subclasses
- (void)disconnectFromSourceItem;
- (void)connectToSourceItem;

// per overrides
- (void)startObserving;
- (void)stopObserving;

// per cridar desde el controlador
- (void)beginObservingModel;
- (void)endObservingModel;
@end

//
//  SWObjectCell.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 7/20/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SWModelBrowserCell.h"
#import "SWObject.h"

typedef enum {
    SWObjectCellGroupDetailTypeItemCount,
    SWObjectCellGroupDetailTypeValueCount
} SWObjectCellGroupDetailType;

@interface SWObjectCell : SWModelBrowserCell <SWObjectObserver, ValueObserver>
{
    BOOL _isObserving;
}

@property (nonatomic, strong) SWObject *modelObject;

- (void)updateCell;

- (void)reloadTextLabel;
- (void)reloadDetailTextLabel;
- (void)reloadRightDetailTextLabel;

// per overrides
- (void)didStartObservation;
- (void)didEndObservation;

// per cridar desde el controlador
- (void)beginObservingModel;
- (void)endObservingModel;

@property (nonatomic, strong) NSIndexSet *acceptedTypes;
@property (nonatomic, assign) SWObjectCellGroupDetailType groupDetailType;

@end

//
//  SWValueCell.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 6/7/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SWDrawRectCell.h"
#import "SWValue.h"

extern NSString *SWValueNoEditableCellIdentifier;
extern NSString *SWValueNoEditableCellNibName;

@class SWValue;

@protocol SWValueCellDelegate <NSObject>

//@optional
//- (NSString*)typeDescriptionForValue:(SWValue*)value;

@end

typedef enum {
    SWValueCellAccessoryTypeNone,
    SWValueCellAccessoryTypeGearIndicator,
    SWValueCellAccessoryTypeSeekerIndicator
} SWValueCellAccessoryType;


@interface SWValueCell : SWDrawRectCell <ValueObserver>
{
    SWValue *_value;
    __weak UILabel *_valuePropertyLabel;
    __weak UILabel *_valueAsStringLabel;
    __weak UILabel *_valueSemanticTypeLabel;
    //__weak id _delegate;    //DDDD
    BOOL _isObserving;
}

@property (nonatomic, strong) SWValue *value;
- (void)setAccessory:(SWValueCellAccessoryType)accessory;

@property (nonatomic, weak) IBOutlet UILabel *valuePropertyLabel;
@property (nonatomic, weak) IBOutlet UILabel *valueAsStringLabel;
@property (nonatomic, weak) IBOutlet UILabel *valueSemanticTypeLabel;

@property (nonatomic, weak) id <SWValueCellDelegate> delegate;

- (void)refreshAll;
- (void)doInit;
- (void)refreshValueName;
- (void)refreshSemanticType;
- (void)refreshValue;

// to call by the controller
- (void)beginObservingModel;
- (void)endObservingModel;

@end


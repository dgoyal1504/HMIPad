//
//  SWIdentifierView.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 6/7/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWObject.h"
@class SWTextField;

@interface SWIdentifierView : UIView <SWObjectObserver>

@property (nonatomic, strong) SWObject *modelObject;

@property (nonatomic, weak) IBOutlet UILabel *name;
@property (nonatomic, weak) IBOutlet SWTextField *identifierField;

//- (void)refresh;

@end

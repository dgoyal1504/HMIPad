//
//  SWProjectUserCell.m
//  HmiPad
//
//  Created by Joan Lluch on 25/03/14.
//  Copyright (c) 2014 SweetWilliam, SL. All rights reserved.
//

#import "SWProjectUserCell.h"

@implementation SWProjectUserCell


#pragma mark Overriden Methods

//- (void)reloadRightDetailTextLabel
//{
//    [super reloadRightDetailTextLabel];
//
//    SWProjectUser *user = self.modelObject;
//    NSInteger level = user.userL.valueAsInteger;
//    
//    UILabel *label = self.rightDetailTextLabel;
//    [label setText:[label.text stringByAppendingFormat:@"(≤%d)", level]];
//}


- (void)reloadDetailTextLabel
{
    [super reloadDetailTextLabel];
    
    SWProjectUser *user = self.modelObject;
    NSString *userName = user.userName.valueAsString;
    NSInteger level = user.userL.valueAsInteger;
    
    UILabel *label = self.detailTextLabel;
    [label setText:[label.text stringByAppendingFormat:@": %@ (%ld)", userName, (long)level]];
}



#pragma mark overrides

- (void)didStartObservation
{
    [super didStartObservation];
    SWProjectUser *user = self.modelObject;
    
    [user.userName addObserver:self];
    [user.userL addObserver:self];
}

- (void)didEndObservation
{
    [super didEndObservation];
    SWProjectUser *user = self.modelObject;
    
    [user.userName removeObserver:self];
    [user.userL removeObserver:self];
}


#pragma mark ValueObserver

- (void)value:(SWValue *)value didEvaluateWithChange:(BOOL)changed
{
    SWProjectUser *user = self.modelObject;
  
    if (value == user.userL || value == user.userName )
    {
        [self reloadDetailTextLabel];
    }
    
    else
    {
        [super value:value didEvaluateWithChange:changed];
    }
}

@end



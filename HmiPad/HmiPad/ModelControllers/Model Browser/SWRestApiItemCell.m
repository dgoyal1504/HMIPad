//
//  SWRestApiItemCell.m
//  HmiPad
//
//  Created by Joan Lluch on 18/04/15.
//  Copyright (c) 2015 SweetWilliam, SL. All rights reserved.
//

#import "SWRestApiItemCell.h"

@implementation SWRestApiItemCell

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
    
    SWRestApiItem *restApiItem = self.modelObject;
    NSString *restApiName = [restApiItem.baseApiUrl valueAsString];
    
    UILabel *label = self.detailTextLabel;
    [label setText:[label.text stringByAppendingFormat:@": %@", restApiName]];
}



#pragma mark overrides

- (void)didStartObservation
{
    [super didStartObservation];
    SWRestApiItem *restApiItem = self.modelObject;
    
    [restApiItem.baseApiUrl addObserver:self];
}

- (void)didEndObservation
{
    [super didEndObservation];
    SWRestApiItem *restApiItem = self.modelObject;
    
    [restApiItem.baseApiUrl removeObserver:self];
}


#pragma mark ValueObserver

- (void)value:(SWValue *)value didEvaluateWithChange:(BOOL)changed
{
    SWRestApiItem *restApiItem = self.modelObject;
  
    if (value == restApiItem.baseApiUrl )
    {
        [self reloadDetailTextLabel];
    }
    
    else
    {
        [super value:value didEvaluateWithChange:changed];
    }
}


@end

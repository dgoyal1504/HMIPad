//
//  SWDatabaseCell.m
//  HmiPad
//
//  Created by Joan Lluch on 18/04/14.
//  Copyright (c) 2014 SweetWilliam, SL. All rights reserved.
//

#import "SWDatabaseCell.h"

@implementation SWDatabaseCell

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
    
    SWDataLoggerItem *database = self.modelObject;
    NSString *databaseName = [database.databaseName valueAsString];
    
    UILabel *label = self.detailTextLabel;
    [label setText:[label.text stringByAppendingFormat:@": %@", databaseName]];
}



#pragma mark overrides

- (void)didStartObservation
{
    [super didStartObservation];
    SWDataLoggerItem *database = self.modelObject;
    
    [database.databaseName addObserver:self];
}

- (void)didEndObservation
{
    [super didEndObservation];
    SWDataLoggerItem *database = self.modelObject;
    
    [database.databaseName removeObserver:self];
}


#pragma mark ValueObserver

- (void)value:(SWValue *)value didEvaluateWithChange:(BOOL)changed
{
    SWDataLoggerItem *database = self.modelObject;
  
    if (value == database.databaseName )
    {
        [self reloadDetailTextLabel];
    }
    
    else
    {
        [super value:value didEvaluateWithChange:changed];
    }
}


@end

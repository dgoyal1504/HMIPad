//
//  SWDataPresenter.m
//  HmiPad
//
//  Created by Joan Lluch on 01/05/14.
//  Copyright (c) 2014 SweetWilliam, SL. All rights reserved.
//

#import "SWDataPresenterItem.h"
#import "SWPropertyDescriptor.h"
#import "SWEnumTypes.h"
#import "SWValue.h"

#import "SWDatabaseContext.h"

//#import "SWDatabaseContext.h"
//#import "SWHistoValues.h"
//#import "SWDocumentModel.h"


@interface SWDataPresenterItem()
{
    SWDatabaseContext *_dbContext;
}
@end


@implementation SWDataPresenterItem

#pragma mark Class stuff

static SWObjectDescription *_objectDescription = nil;

+ (SWObjectDescription *)objectDescription
{
    if ( _objectDescription == nil ) {
        _objectDescription = [[SWObjectDescription alloc] initWithObjectClass:[self class]];
    }
    return _objectDescription ;
}

+ (NSString*)defaultIdentifier
{
    return @"dataPresenter";
}

+ (NSString*)localizedName
{
    return NSLocalizedString(@"DATA PRESENTER", nil);
}

+ (NSArray*)propertyDescriptions
{
    return [NSArray arrayWithObjects:
    
        [SWPropertyDescriptor propertyDescriptorWithName:@"databaseTimeRange" type:SWTypeEnumDatabaseTimeRange
            propertyType:SWPropertyTypeValue defaultValue:[SWValue valueWithDouble:SWDatabaseTimeRangeMonthly]],
            
        [SWPropertyDescriptor propertyDescriptorWithName:@"databaseName" type:SWTypeString
            propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithString:@""]],
        
        [SWPropertyDescriptor propertyDescriptorWithName:@"referenceTime" type:SWTypeAbsoluteTime
            propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithAbsoluteTime:[SWDatabaseContext distantFutureTime]]],
            
        [SWPropertyDescriptor propertyDescriptorWithName:@"databaseFile" type:SWTypeString
            propertyType:SWPropertyTypeNoEditableValue defaultValue:[SWValue valueWithString:@""]],
        nil];
}


#pragma mark - Init and Properties


- (SWValue*)databaseTimeRange
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex+0];
}


- (SWValue*)databaseName
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex+1];
}


- (SWValue*)referenceTime
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex+2];
}


- (SWValue*)databaseFile
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex+3];
}



#pragma mark - SWValueHolder




//-(void)value:(SWExpression *)expression didTriggerWithChange:(BOOL)changed
//{
//    SWValue *rangeVa = self.databaseTimeRange;
//    SWValue *nameVa = self.databaseName;
//    SWValue *refTimeVa = self.referenceTime;
//    
////    if ( [timeRangeVa valueIsEmpty] || [nameVa valueIsEmpty] || [refTimeVa valueIsEmpty] )
//
//    if ( expression == rangeVa || expression == nameVa || expression == refTimeVa )
//    {
//        NSString *nameKey = [SWDatabaseContext dictionaryKeyForName:nameVa.valueAsString range:rangeVa.valueAsInteger referenceTime:refTimeVa.valueAsAbsoluteTime];
//        [self.databaseFile evalWithString:nameKey];
//    }
//}

//#pragma mark - dbContext
//
//- (void)setDbContext:(SWDatabaseContext *)dbContext
//{
//    if ( _dbContext != dbContext )
//    {
//        SWHistoValues *h = _docModel.histoValues;
//        [h retainContext:dbContext];
//        [h releaseContext:_dbContext];
//        _dbContext = dbContext;
//    }
//}
//
//- (SWDatabaseContext *)dbContext
//{
//    return _dbContext;
//}

@end

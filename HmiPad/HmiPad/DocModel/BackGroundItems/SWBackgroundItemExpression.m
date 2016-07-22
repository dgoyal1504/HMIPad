//
//  SWBackgroundItemExpression.m
//  HmiPad
//
//  Created by Joan on 26/05/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import "SWBackgroundItemExpression.h"
#import "SWPropertyDescriptor.h"

@implementation SWBackgroundItemExpression


static SWObjectDescription *_objectDescription = nil;

+ (SWObjectDescription *)objectDescription
{
    if(_objectDescription == nil) {
        _objectDescription = [[SWObjectDescription alloc] initWithObjectClass:[self class]];
    }
    return _objectDescription;
}

+ (NSString*)defaultIdentifier
{
    return @"exp";
}

+ (NSString*)localizedName
{
    return NSLocalizedString(@"EXPRESSION", nil);
}

+ (NSArray*)propertyDescriptions
{
    return [NSArray arrayWithObjects:

        [SWPropertyDescriptor propertyDescriptorWithName:@"value" type:SWTypeAny
            propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithDouble:0.0]],
        
        nil
    ];
}


// #pragma mark init / dealloc / observer retain

//- (id)initInDocument:(SWDocumentModel *)docModel
//{
//    self = [super initInDocument:docModel];
//    if ( self )
//    {
//        [self.value observerCountRetainBy:1];
//    }
//    return self;
//}

//- (id)initWithQuickCoder:(QuickUnarchiver *)decoder
//{
//    self = [super initWithQuickCoder:decoder];
//    if (self) 
//    {
//        [self _observerRetainAfterDecode];
//    }
//    return self;
//}

//- (id)initWithSymbolicCoder:(SymbolicUnarchiver *)decoder identifier:(NSString *)ident parentObject:(id<SymbolicCoding>)parent
//{
//    self = [super initWithSymbolicCoder:decoder identifier:ident parentObject:parent];
//    if ( self )
//    {
//        [self _observerRetainAfterDecode];
//    }
//    return self;
//}

//- (void)_observerRetainAfterDecode
//{
//    // dispatchem el retain per asegurarnos que el graph d'expressions esta completament carregat 
//    dispatch_async(dispatch_get_main_queue(), ^
//    {
//        [self.value observerCountRetainBy:1];
//    }) ;
//}

//- (void)putToSleep
//{
//    if ( !self.isAsleep )
//        [self.value observerCountReleaseBy:1];
//    
//    [super putToSleep];
//}

//- (void)awakeFromSleepIfNeeded
//{
//    BOOL isAsleep = self.isAsleep;
//    [super awakeFromSleepIfNeeded];
//    
//    if (isAsleep)
//        [self.value observerCountRetainBy:1];
//}

//- (void)dealloc
//{
//    if (!self.isAsleep)
//        [self.value observerCountReleaseBy:1];
//}


#pragma mark - Properties

- (SWExpression*)value
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex+0];
}





@end

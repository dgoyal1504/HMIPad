//
//  SWFloatingPopoverManager.m
//  HmiPad
//
//  Created by Joan Martin on 8/6/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWFloatingPopoverManager.h"

@implementation SWFloatingPopoverManager

static SWFloatingPopoverManager *_instance = nil;

+ (SWFloatingPopoverManager*)defaultManager
{
    if (!_instance)
        _instance = [[SWFloatingPopoverManager alloc] init];
    
    return _instance;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _floatingPopoversDict = CFDictionaryCreateMutable(NULL, 0,
            &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    }
    return self;
}

- (void)dealloc
{
    if ( _floatingPopoversDict ) CFRelease( _floatingPopoversDict );
}

- (void)presentFloatingPopover:(SWFloatingPopoverController*)fpc animated:(BOOL)animated
{
    fpc.manager = self;
    CFDictionaryAddValue(_floatingPopoversDict, (__bridge CFTypeRef)(fpc.key), (__bridge CFTypeRef)(fpc));
    
    [fpc presentFloatingPopoverAnimated:animated];
}

- (void)presentFloatingPopover:(SWFloatingPopoverController*)fpc atPoint:(CGPoint)point animated:(BOOL)animated
{

    fpc.manager = self;
    CFDictionaryAddValue(_floatingPopoversDict, (__bridge CFTypeRef)(fpc.key), (__bridge CFTypeRef)(fpc));
    
    [fpc presentFloatingPopoverAtPoint:point animated:animated];
}

- (void)dismissAllPopoversAnimated:(BOOL)animated
{    
    [(__bridge NSDictionary*)_floatingPopoversDict enumerateKeysAndObjectsUsingBlock:^(id key, SWFloatingPopoverController *fpc, BOOL *stop)
    {
        [fpc dismissFloatingPopoverAnimated:animated];
    }];
    
}

- (void)dismissFloatingPopoversWithKeys:(NSArray*)keys animated:(BOOL)animated
{
    for (id key in keys)
    {
        SWFloatingPopoverController *fpc = [self floatingPopoverControllerWithKey:key];
        [fpc dismissFloatingPopoverAnimated:animated];
    }
}


- (SWFloatingPopoverController*)floatingPopoverControllerWithKey:(id)key
{
    SWFloatingPopoverController *fpc = CFDictionaryGetValue(_floatingPopoversDict, (__bridge CFTypeRef)(key));
    return fpc;
}

- (NSArray*)presentedFloatingPopovers
{


}


#pragma mark Protocol SWFloatingPopoverControllerDelegate

- (void)floatingPopoverControllerDidDismissPopover:(SWFloatingPopoverController *)fpc
{
    CFDictionaryRemoveValue( _floatingPopoversDict, (__bridge CFTypeRef)(fpc.key));
}

@end


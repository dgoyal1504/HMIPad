//
//  SWSystemItemScanner.m
//  HmiPad
//
//  Created by Joan Lluch on 03/03/14.
//  Copyright (c) 2014 SweetWilliam, SL. All rights reserved.
//

#import "SWSystemItemScanner.h"
#import "SWPropertyDescriptor.h"
#import "SWDocumentModel.h"
#import "UserDefaults.h"
//#import "SWEventCenter.h"

#import "SWCodeScannerViewController.h"

@interface SWSystemItemScanner()<SWCodeScannerViewControllerDelegate>

@end


@implementation SWSystemItemScanner
{
    BOOL _isPerformingScan;
}

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
    return @"$Scanner";
}

+ (NSString*)localizedName
{
    return NSLocalizedString(@"BAR CODE READER", nil);
}

+ (NSArray*)propertyDescriptions
{
    return [NSArray arrayWithObjects:

        [SWPropertyDescriptor propertyDescriptorWithName:@"scan" type:SWTypeBool
            propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithDouble:0.0]],
            
        [SWPropertyDescriptor propertyDescriptorWithName:@"scanResult" type:SWTypeString
            propertyType:SWPropertyTypeNoEditableValue defaultValue:[SWValue valueWithString:@""]],
     
        nil
    ];
}



#pragma mark init / dealloc / observer retain


- (void)_commonInit
{
//    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
//    [nc addObserver:self selector:@selector(playerCenterErrorNotification:) name:SWPlayerCenterErrorNotification object:nil];
}


- (id)initInDocument:(SWDocumentModel *)docModel
{
    self = [super initInDocument:docModel];
    if ( self )
    {
        [self _performObserverRetain];
        [self _commonInit];
    }
    return self;
}

- (id)initWithQuickCoder:(QuickUnarchiver *)decoder
{
    self = [super initWithQuickCoder:decoder];
    if (self) 
    {
        [self _observerRetainAfterDecode];
        [self _commonInit];
    }
    return self;
}

- (void)_observerRetainAfterDecode
{
    // dispatchem el retain per asegurarnos que el graph d'expressions esta completament carregat 
    dispatch_async(dispatch_get_main_queue(), ^
    {
        [self _performObserverRetain];
    }) ;
}


- (void)putToSleep
{
    if ( !self.isAsleep )
        [self _performObserverRelease];
    
    [super putToSleep];
}

- (void)awakeFromSleepIfNeeded
{
    BOOL isAsleep = self.isAsleep;
    [super awakeFromSleepIfNeeded];
    
    if (isAsleep)
        [self _performObserverRetain];
}

- (void)dealloc
{
    if (!self.isAsleep)
        [self _performObserverRelease];
    
//    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
//    [nc removeObserver:self];
}

- (void)_performObserverRetain
{
    [self.scan observerCountRetainBy:1];
}

- (void)_performObserverRelease
{
    [self.scan observerCountReleaseBy:1];
}


#pragma mark - Properties

- (SWExpression*)scan
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex+0];
}

- (SWValue*)scanResult
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex+1];
}


#pragma mark - Private

- (void)_performScan
{
    BOOL scan = [self.scan valueAsBool];

    if ( scan == NO )
        return;

    // escaneja en el flanc de pujada de scan
    if ( _isPerformingScan )
        return;
    
    _isPerformingScan = YES;

    NSArray *windows = [[UIApplication sharedApplication] windows] ;
    UIWindow *window = windows.firstObject;
    UIViewController *viewController = [window rootViewController];
    
    SWCodeScannerViewController *scannerController = [[SWCodeScannerViewController alloc] init];
    [scannerController setDelegate:self];
    [scannerController setScannerZoomFactor:1.5];
    [scannerController setSupportText:@"Bar Code Scanner"];
    [scannerController setCameraPosition:[defaults() lastCameraPosition]];
    
    [scannerController setModalPresentationStyle:UIModalPresentationPageSheet];
    [scannerController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [viewController presentViewController:scannerController animated:YES completion:^
    {
            // res
    }];
}


#pragma mark - SWCodeScannerViewControllerDelegate

- (void)codeScannerViewController:(SWCodeScannerViewController*)controller didScanText:(NSString*)text
{
    _isPerformingScan = NO;
    [controller dismissViewControllerAnimated:YES completion:nil];
    
    [self.scanResult evalWithString:text];
}


- (void)codeScannerViewController:(SWCodeScannerViewController*)controller didCancelWithError:(BOOL)err
{
    _isPerformingScan = NO;
    [controller dismissViewControllerAnimated:YES completion:nil];
}


- (void)codeScannerViewController:(SWCodeScannerViewController *)controller didFlipCameraToPosition:(AVCaptureDevicePosition)position
{
    [defaults() setLastCameraPosition:position];
}


#pragma mark - SWValueHolder


- (void)value:(SWExpression *)expression didTriggerWithChange:(BOOL)changed
{
    if ( expression == self.scan )
    {
        [self _performScan];
    }
}


#pragma mark - Symbolic Coding

- (id)initWithSymbolicCoder:(SymbolicUnarchiver *)decoder identifier:(NSString*)ident parentObject:(SWDocumentModel*)parent
{
    self = [super initWithSymbolicCoder:decoder identifier:ident parentObject:parent];
    if (self) 
    {
        SWExpression *exp = [decoder decodeExpressionForKey:@"scan"];
        if ( exp ) [_properties replaceObjectAtIndex:_objectDescription.firstClassPropertyIndex+0 withObject:exp];
        
        SWValue *va0 = [decoder decodeValueForKey:@"scanResult"];
        if ( va0 ) [_properties replaceObjectAtIndex:_objectDescription.firstClassPropertyIndex+1 withObject:va0];
        
        [self _observerRetainAfterDecode];
        
    }
    return self;
}


- (void)encodeWithSymbolicCoder:(SymbolicArchiver *)encoder
{
    [super encodeWithSymbolicCoder:encoder];

    [encoder encodeValue:self.scan forKey:@"scan"];
    [encoder encodeValue:self.scanResult forKey:@"scanResult"];
}



@end

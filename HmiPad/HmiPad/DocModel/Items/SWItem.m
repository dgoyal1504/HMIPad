//
//  SWItem.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 2/14/12.
//  Copyright (c) 2012 SweetWilliam SL. All rights reserved.
//

#import "SWItem.h"
#import "SWDocumentModel.h"
#import "SWPage.h"
#import "SWGroupItem.h"
#import "SWPropertyDescriptor.h"
#import "SWItemController.h"

#import "SWHorizontalPipeItem.h"

@interface SWItem()
{
    unsigned int _selected:1;   // <-- Atencio amb aixo: un BOOL es un 'signed char',
                        // per tant si nomes te 1 bit els unics estats possibles son 0 per false i -1 per true
    unsigned int _locked:1;
}
@end


@implementation SWItem

#pragma mark - Class Stuff


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
    return @"item";
}

+ (NSString*)localizedName
{
    return NSLocalizedString(@"ITEM PROPERTIES", nil);
}

+ (NSArray*)propertyDescriptions
{
    return [NSArray arrayWithObjects:
            [SWPropertyDescriptor propertyDescriptorWithName:@"framePortrait" type:SWTypeRect
                propertyType:SWPropertyTypeValue defaultValue:[SWValue valueWithCGRect:CGRectZero]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"frameLandscape" type:SWTypeRect
                propertyType:SWPropertyTypeValue defaultValue:[SWValue valueWithCGRect:CGRectZero]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"framePortraitPhone" type:SWTypeRect
                propertyType:SWPropertyTypeValue defaultValue:[SWValue valueWithCGRect:CGRectZero]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"frameLandscapePhone" type:SWTypeRect
                propertyType:SWPropertyTypeValue defaultValue:[SWValue valueWithCGRect:CGRectZero]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"backgroundColor" type:SWTypeColor
                propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithString:@"ClearWhite"]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"hidden" type:SWTypeBool
                propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithDouble:0.0]],
            
            nil];
}

+ (Class)defaultControllerClass
{
    return NSClassFromString( self.controllerType );
}

+ (SWItemControllerType)controllerType
{
    return SWItemControllerTypeNone;
}

#pragma mark - Properties

@dynamic framePortrait;
@dynamic frameLandscape;
@dynamic backgroundColor;
@dynamic hidden;

// -- No-Coding Properties -- //
@dynamic resizeMask;
@dynamic defaultSize;
@dynamic minimumSize;




- (id)initInPage:(SWPage*)page
{
    self = [super initInDocument:page.docModel];
    if (self)
    {
        //_page = page;
        _parentObject = page;
        
        // Setting the default frame size
        CGRect frame = CGRectZero;
        frame.size = [self defaultSize];
        self.framePortrait.valueAsCGRect = frame;
        self.frameLandscape.valueAsCGRect = frame;
        self.framePortraitPhone.valueAsCGRect = frame;
        self.frameLandscapePhone.valueAsCGRect = frame;
        _selected = NO;
    }
    return self;
}

#pragma mark - QuickCoding

- (id)initWithQuickCoder:(QuickUnarchiver *)decoder
{
    self = [super initWithQuickCoder:decoder];
    if (self)
    {
        //_page = [decoder decodeObject];
        _parentObject = [decoder decodeObject];
        _locked = ([decoder decodeInt] != 0);
        _selected = NO;
    }
        
    return self;
}

- (void)encodeWithQuickCoder:(QuickArchiver *)encoder
{
    [super encodeWithQuickCoder:encoder];
    [encoder encodeObject:_parentObject];
    [encoder encodeInt:(_locked!=0)];
}


- (void)retrieveWithQuickCoder:(QuickUnarchiver *)decoder
{
    [super retrieveWithQuickCoder:decoder];
}

- (void)storeWithQuickCoder:(QuickArchiver *)encoder
{
    [super storeWithQuickCoder:encoder];
}




#pragma mark - SymbolicCoding

- (id)initWithSymbolicCoder:(SymbolicUnarchiver *)decoder identifier:(NSString*)ident parentObject:(SWPage *)parent
{
    SWDocumentModel *docModel = parent.docModel;
    self = [super initWithSymbolicCoder:decoder identifier:ident parentObject:docModel];
    if (self)
    {
        //_page = parent;
        _parentObject = parent;
        _locked = ([decoder decodeIntForKey:@"locked"] != 0);
        _selected = NO;
        
        // addition of phone compatibility support if source file did not contain phone frame values
        
        SWValue *va0 = self.framePortraitPhone;
        if ( CGRectEqualToRect(va0.valueAsCGRect, CGRectZero) )
            [va0 setValueFromValue:self.framePortrait];

        SWValue *va1 = self.frameLandscapePhone;
        if ( CGRectEqualToRect(va1.valueAsCGRect, CGRectZero) )
            [va1 setValueFromValue:self.frameLandscape];
    }
    return self ;
}

-(void)encodeWithSymbolicCoder:(SymbolicArchiver *)encoder 
{
    [super encodeWithSymbolicCoder:encoder];
    [encoder encodeInt:(_locked!=0) forKey:@"locked"];
}

- (void)retrieveWithSymbolicCoder:(SymbolicUnarchiver *)decoder identifier:(NSString*)ident parentObject:(id<SymbolicCoding>)parent
{
    [super retrieveWithSymbolicCoder:decoder identifier:ident parentObject:parent];
}

- (void)storeWithSymbolicCoder:(SymbolicArchiver*) encoder
{
    [super storeWithSymbolicCoder:encoder];
}

#pragma mark - Overriden Methods

- (void)dealloc
{

}

- (BOOL)matchesSearchWithString:(NSString*)searchString
{
    NSComparisonResult result = [[self.class localizedName] compare:searchString
                                                            options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)
                                                              range:NSMakeRange(0, [searchString length])];
    
    return (result == NSOrderedSame) || [super matchesSearchWithString:searchString];
}

#pragma mark - Properties

- (SWValue*)framePortrait
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 0];
}

- (SWValue*)frameLandscape
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 1];
}

- (SWValue*)framePortraitPhone
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 2];
}

- (SWValue*)frameLandscapePhone
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 3];
}

- (SWExpression*)backgroundColor
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 4];
}

- (SWExpression*)hidden
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 5];
}

//- (void)setSelected:(BOOL)selected
//{
//    if (selected == _selected)
//        return;
//    
//    NSInteger itemIndex = [_page.items indexOfObjectIdenticalTo:self];
//    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:itemIndex];
//    
//    if (selected)
//        [_page selectItemsAtIndexes:indexSet];
//    else
//        [_page deselectItemsAtIndexes:indexSet];
//}

- (BOOL)selected
{
    return (_selected != 0);
}


- (BOOL)locked
{
    return (_locked != 0);
}


- (BOOL)pickEnabled
{
    return NO;
}


- (void)primitiveSetSelected:(BOOL)selected
{
    if (selected == _selected)
        return;
    
//    if ( [self isKindOfClass:[SWHorizontalPipeItem class]] )
//    {
//        _selected = selected;
//    }
    _selected = selected;
    
    NSArray *observers = [_observers copy];
    for (id <SWItemObserver>observer in observers)
    {
        if ([observer respondsToSelector:@selector(selectedDidChangeForItem:)])
            [observer selectedDidChangeForItem:self];
    }
}

- (void)primitiveSetLocked:(BOOL)locked
{
    if (locked == _locked)
        return;
    
    _locked = locked;
    
    NSArray *observers = [_observers copy];
    for (id <SWItemObserver>observer in observers)
    {
        if ([observer respondsToSelector:@selector(lockedDidChangeForItem:)])
            [observer lockedDidChangeForItem:self];
    }
}

- (void)primitiveSetPickEnabled:(BOOL)enabled
{
}

- (void)prepareForGroupOperation
{
    for (SWValue *value in _properties)
        [value observerCountRetainBy:1];
}

- (void)finishGroupOperation
{
    for (SWValue *value in _properties)
        [value observerCountReleaseBy:1];
}


//- (void)primitiveWillRemove
//{
//    NSArray *observers = [_observers copy];
//    for (id <SWItemObserver> observer in observers)
//    {
//        if ([observer respondsToSelector:@selector(willRemoveObject:)])
//            [observer willRemoveObject:self];
//    }
//}

#pragma mark - Item Methods

// -- Methods to override in subclasses -- //

- (SWItemResizeMask)resizeMask
{
    return SWItemResizeMaskFlexibleWidth | SWItemResizeMaskFlexibleHeight;
}

- (CGSize)defaultSize
{
    return CGSizeMake(50, 50);
}

- (CGSize)minimumSize
{
    return CGSizeMake(10, 10);
}

- (CGSize)currentMinimumSize
{
    if ( _docModel.autoAlignItems )
        return [self minimumSize];
    
    return CGSizeMake(8, 8);
}

//- (void)setFrameV:(CGRect)frame withOrientation:(UIInterfaceOrientation)orientation
//{
//    // si autoalign es zero ho deixem passar tot
//    // si autoaling esta activat filtrem la mida que ha canviat, si no canvia la mida no filtrem
//    // el el resize manual filtrar sempre  ( mirar el delegat implementat per layoutView)
//
//    BOOL portrait = UIInterfaceOrientationIsPortrait(orientation);
//    SWValue *frameSWValue = portrait?self.framePortrait:self.frameLandscape;
//    
//    CGSize minSize = CGSizeMake(8, 8);
//    if ( _docModel.autoAlignItems )
//    {
//        CGSize currentSize = frameSWValue.valueAsCGRect.size;
//        CGSize itemMinSize =  [self minimumSize];
//        if ( frame.size.width != currentSize.width ) minSize.width = itemMinSize.width;
//        if ( frame.size.height != currentSize.height ) minSize.height = itemMinSize.height;
//    }
//    
//    if (frame.size.width < minSize.width) frame.size.width = minSize.width;
//    if (frame.size.height < minSize.height) frame.size.height = minSize.height;
//    
//    [frameSWValue setValueAsCGRect:frame] ;
//}


//- (void)setFrameVV:(CGRect)frame withOrientation:(UIInterfaceOrientation)orientation
//{
//
//    // si autoalign es zero ho deixem passar tot
//    // si autoaling esta activat filtrem la mida que ha canviat, si no canvia la mida no filtrem
//    // el el resize manual filtrar sempre  ( mirar el delegat implementat per layoutView)
//
//    CGSize minSize = [self minimumSize];
//    
//    if (frame.size.width < minSize.width)
//        frame.size.width = minSize.width;
//    
//    if (frame.size.height < minSize.height)
//        frame.size.height = minSize.height;
//        
//    switch (orientation)
//    {
//        case UIInterfaceOrientationPortraitUpsideDown:
//        case UIInterfaceOrientationPortrait:
//            self.framePortrait.valueAsCGRect = frame;
//            break;
//            
//        case UIInterfaceOrientationLandscapeLeft:
//        case UIInterfaceOrientationLandscapeRight:
//            self.frameLandscape.valueAsCGRect = frame;
//            break;
//            
//        default:
//            break;
//    }
//}


//- (void)setFrame0:(CGRect)frame withOrientation:(UIInterfaceOrientation)orientation
//{
//    // si autoalign es zero ho deixem passar tot
//    // si autoaling esta activat filtrem la mida que ha canviat, si no canvia la mida no filtrem
//    // el el resize manual filtrar sempre  ( mirar el delegat implementat per layoutView)
//
//    BOOL portrait = UIInterfaceOrientationIsPortrait(orientation);
//    SWValue *frameSWValue = portrait?self.framePortrait:self.frameLandscape;
//    CGRect theFrame = frameSWValue.valueAsCGRect;
//    
//    CGSize minSize = [self currentMinimumSize];
//    
//    if ( frame.size.width != theFrame.size.width )
//        if (frame.size.width < minSize.width) frame.size.width = minSize.width;
//    
//    if ( frame.size.height != theFrame.size.height )
//        if (frame.size.height < minSize.height) frame.size.height = minSize.height;
//    
//    [frameSWValue setValueAsCGRect:frame] ;
//}
//
//
//- (CGRect)frameForOrientation0:(UIInterfaceOrientation)orientation
//{   
//    switch (orientation)
//    {
//        case UIInterfaceOrientationPortraitUpsideDown:
//        case UIInterfaceOrientationPortrait:
//            return self.framePortrait.valueAsCGRect;
//            break;
//            
//        case UIInterfaceOrientationLandscapeLeft:
//        case UIInterfaceOrientationLandscapeRight:
//            return self.frameLandscape.valueAsCGRect;
//            break;
//            
//        default:
//            return CGRectZero;
//            break;
//    }
//}


- (SWValue*)_frameSWValueWithOrientation:(UIInterfaceOrientation)orientation idiom:(SWDeviceInterfaceIdiom)idiom
{
    if ( UIInterfaceOrientationIsPortrait(orientation) )
    {
        if ( idiom == SWDeviceInterfaceIdiomPad ) return self.framePortrait;
        if ( idiom == SWDeviceInterfaceIdiomPhone ) return self.framePortraitPhone;
    }
    
    if ( UIInterfaceOrientationIsLandscape(orientation) )
    {
        if ( idiom == SWDeviceInterfaceIdiomPad ) return self.frameLandscape;
        if ( idiom == SWDeviceInterfaceIdiomPhone ) return self.frameLandscapePhone;
    }

    return nil;
}



- (void)setFrame:(CGRect)frame withOrientation:(UIInterfaceOrientation)orientation idiom:(SWDeviceInterfaceIdiom)idiom
{
    // si autoalign es zero ho deixem passar tot
    // si autoaling esta activat filtrem la mida que ha canviat, si no canvia la mida no filtrem
    // el el resize manual filtrar sempre  ( mirar el delegat implementat per layoutView)

    SWValue *frameSWValue = [self _frameSWValueWithOrientation:orientation idiom:idiom];
    CGRect theFrame = frameSWValue.valueAsCGRect;
    
    CGSize minSize = [self currentMinimumSize];
    
    if ( frame.size.width != theFrame.size.width )
        if (frame.size.width < minSize.width) frame.size.width = minSize.width;
    
    if ( frame.size.height != theFrame.size.height )
        if (frame.size.height < minSize.height) frame.size.height = minSize.height;
    
    [frameSWValue setValueAsCGRect:frame] ;
}


//- (void)setAllFramesToFrame:(CGRect)frame
//{
//    [self setFrame:frame withOrientation:UIInterfaceOrientationPortrait idiom:SWDeviceInterfaceIdiomPad];
//    [self setFrame:frame withOrientation:UIInterfaceOrientationLandscapeLeft idiom:SWDeviceInterfaceIdiomPad];
//    [self setFrame:frame withOrientation:UIInterfaceOrientationPortrait idiom:SWDeviceInterfaceIdiomPhone];
//    [self setFrame:frame withOrientation:UIInterfaceOrientationLandscapeLeft idiom:SWDeviceInterfaceIdiomPhone];
//}


- (void)itemFramesAddOffset:(CGPoint)offset
{
    SWValue *frameValue;
    CGRect frame;
    
    frameValue = [self _frameSWValueWithOrientation:UIInterfaceOrientationPortrait idiom:SWDeviceInterfaceIdiomPad];
    frame = frameValue.valueAsCGRect; frame.origin.x += offset.x; frame.origin.y += offset.y;
    [frameValue setValueAsCGRect:frame];
    
    frameValue = [self _frameSWValueWithOrientation:UIInterfaceOrientationPortrait idiom:SWDeviceInterfaceIdiomPhone];
    frame = frameValue.valueAsCGRect; frame.origin.x += offset.x; frame.origin.y += offset.y;
    [frameValue setValueAsCGRect:frame];
    
    frameValue = [self _frameSWValueWithOrientation:UIInterfaceOrientationLandscapeLeft idiom:SWDeviceInterfaceIdiomPad];
    frame = frameValue.valueAsCGRect; frame.origin.x += offset.x; frame.origin.y += offset.y;
    [frameValue setValueAsCGRect:frame];
    
    frameValue = [self _frameSWValueWithOrientation:UIInterfaceOrientationLandscapeLeft idiom:SWDeviceInterfaceIdiomPhone];
    frame = frameValue.valueAsCGRect; frame.origin.x += offset.x; frame.origin.y += offset.y;
    [frameValue setValueAsCGRect:frame];
}


- (CGRect)frameForOrientation:(UIInterfaceOrientation)orientation idiom:(SWDeviceInterfaceIdiom)idiom
{
    SWValue *frameSWValue = [self _frameSWValueWithOrientation:orientation idiom:idiom];
    return frameSWValue.valueAsCGRect;
}


- (SWValue*)frameSWValueWithOrientation:(UIInterfaceOrientation)orientation idiom:(SWDeviceInterfaceIdiom)idiom
{
    SWValue *frameSWValue = [self _frameSWValueWithOrientation:orientation idiom:idiom];
    return frameSWValue;
}

- (BOOL)frameValue:(SWValue*)value matchesInterfaceIdiom:(SWDeviceInterfaceIdiom)idiom forOrientation:(UIInterfaceOrientation)orientation
{
    if ( value == self.framePortrait )
        return idiom == SWDeviceInterfaceIdiomPad && UIInterfaceOrientationIsPortrait(orientation);
    
    if ( value == self.frameLandscape )
        return idiom == SWDeviceInterfaceIdiomPad && UIInterfaceOrientationIsLandscape(orientation);
    
    if ( value == self.framePortraitPhone )
        return idiom == SWDeviceInterfaceIdiomPhone && UIInterfaceOrientationIsPortrait(orientation);
    
    if ( value == self.frameLandscapePhone )
        return idiom == SWDeviceInterfaceIdiomPhone && UIInterfaceOrientationIsLandscape(orientation);

    return NO;
}


@end


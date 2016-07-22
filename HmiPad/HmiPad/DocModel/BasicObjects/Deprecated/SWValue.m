//
//  SWObjectProperty.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 5/25/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//
/*
#import "SWValue.h"
#import "SWColor.h"

@interface SWValue () 

- (void)_doInit;
- (void)_reset;
- (void)_valueWillChange;
- (void)_valueDidChange;

@end

@implementation SWValue

@synthesize type = _type;
@synthesize holder = _holder;


- (void)_doInit
{
    [self _reset];
}

- (id)init
{
    self = [super init];
    if (self) 
    {
        [self _doInit];
    }
    return self;
}

// ------------------------------------------------------------------------------------------ // 
// ----------------------------------------- DEALLOC ---------------------------------------- // 
// ------------------------------------------------------------------------------------------ // 

- (void)dealloc
{
    [self _reset];
    
    if (_observers != NULL)
        CFRelease(_observers);
}

// ------------------------------------------------------------------------------------------ // 
// -------------------------------------- INITIALIZERS -------------------------------------- // 
// ------------------------------------------------------------------------------------------ // 

- (id)initWithType:(SWStorageType)type
{
    self = [self init];
    if (self) 
    {
        _type = type;
    }
    return self;
}

- (id)initWithInteger:(NSInteger)value
{
    self = [self init];
    if (self) 
    {
        _type = SWStorageTypeInteger;
        _myValueContainer.integerValue = value;
    }
    return self;
}

- (id)initWithFloat:(CGFloat)value
{
    self = [self init];
    if (self) 
    {
        _type = SWStorageTypeFloat;
        _myValueContainer.floatValue = value;
    }
    return self;
}

- (id)initWithDouble:(double)value
{
    self = [self init];
    if (self) 
    {
        _type = SWStorageTypeDouble;
        _myValueContainer.doubleValue = value;
    }
    return self;
}

- (id)initWithBool:(BOOL)value
{
    self = [self init];
    if (self) 
    {
        _type = SWStorageTypeBool;
        _myValueContainer.integerValue = value;
    }
    return self;
}

- (id)initWithCGPoint:(CGPoint)value
{
    self = [self init];
    if (self) 
    {
        _type = SWStorageTypePoint;
        _myValueContainer.pointValue = value;
    }
    return self;
}

- (id)initWithCGSize:(CGSize)value
{
    self = [self init];
    if (self) 
    {
        _type = SWStorageTypeSize;
        _myValueContainer.sizeValue = value;
    }
    return self;
}

- (id)initWithCGRect:(CGRect)value
{
    self = [self init];
    if (self) 
    {
        _type = SWStorageTypeRect;
        _myValueContainer.rectValue = value;
    }
    return self;
}

- (id)initWithString:(NSString*)value
{
    self = [self init];
    if (self) 
    {
        _type = SWStorageTypeString;
        _myValueContainer.object = (__bridge_retained CFTypeRef)value;
    }
    return self;
}

- (id)initWithObject:(id <QuickCoding, SymbolicCoding> )value
{
    self = [self init];
    if (self) 
    {
        _type = SWStorageTypeObject;
        _myValueContainer.object = (__bridge_retained CFTypeRef)value;
    }
    return self;
}

// ------------------------------------------------------------------------------------------ // 
// ----------------------------------------- STATICS ---------------------------------------- // 
// ------------------------------------------------------------------------------------------ //

#pragma mark - Static Methods

+ (SWValue*)valueWithType:(SWStorageType)type
{
    return [[SWValue alloc] initWithType:type];
}

+ (SWValue*)valueWithInteger:(NSInteger)value
{
    return [[SWValue alloc] initWithInteger:value];
}

+ (SWValue*)valueWithFloat:(CGFloat)value
{
    return [[SWValue alloc] initWithFloat:value];
}

+ (SWValue*)valueWithDouble:(double)value
{
    return [[SWValue alloc] initWithDouble:value];
}

+ (SWValue*)valueWithBool:(BOOL)value
{
    return [[SWValue alloc] initWithBool:value];
}

+ (SWValue*)valueWithCGPoint:(CGPoint)value
{
    return [[SWValue alloc] initWithCGPoint:value];
}

+ (SWValue*)valueWithCGSize:(CGSize)value
{
    return [[SWValue alloc] initWithCGSize:value];
}

+ (SWValue*)valueWithCGRect:(CGRect)value
{
    return [[SWValue alloc] initWithCGRect:value];
}

+ (SWValue*)valueWithString:(NSString*)value
{
    return [[SWValue alloc] initWithString:value];
}

+ (SWValue*)valueWithObject:(id <QuickCoding, SymbolicCoding>)value
{
    return [[SWValue alloc] initWithObject:value];
}

// ------------------------------------------------------------------------------------------ // 
// ------------------------------------ QUICK CODING ---------------------------------------- // 
// ------------------------------------------------------------------------------------------ // 

#pragma mark - Quick Coding

- (id)initWithQuickCoder:(QuickUnarchiver *)decoder
{
    self = [super init];
    if (self) 
    {
        [self _doInit];
        
        _type = [decoder decodeInt];
        
        switch (_type) {
            case SWStorageTypeBool:
            case SWStorageTypeInteger:
                _myValueContainer.integerValue = [decoder decodeInt];
                break;
            case SWStorageTypeFloat:
                _myValueContainer.floatValue = [decoder decodeFloat];
                break;
            case SWStorageTypeDouble:
                _myValueContainer.doubleValue = [decoder decodeDouble];
                break;
            case SWStorageTypePoint:
            {
                CGPoint point;
                point.x = [decoder decodeFloat];
                point.y = [decoder decodeFloat];
                _myValueContainer.pointValue = point;
            }
                break;
            case SWStorageTypeSize:
            {
                CGSize size;
                size.width = [decoder decodeFloat];
                size.height = [decoder decodeFloat];
                _myValueContainer.sizeValue = size;
            }
                break;
            case SWStorageTypeRect:
            {
                CGPoint point;
                point.x = [decoder decodeFloat];
                point.y = [decoder decodeFloat];
                CGSize size;
                size.width = [decoder decodeFloat];
                size.height = [decoder decodeFloat];
                CGRect rect;
                rect.origin = point;
                rect.size = size;
                _myValueContainer.rectValue = rect;
            }
                break;
            case SWStorageTypeString:
            case SWStorageTypeObject:
                _myValueContainer.object = (__bridge_retained CFTypeRef)[decoder decodeObject];
                break;
            case SWStorageTypeUndefined:
            default:
                // Nothing to decode
                break;
        }
        
        // TODO : Fa falta codificar el delgate?
        _holder = [decoder decodeObject];
    }
    return self;
}

- (void)encodeWithQuickCoder:(QuickArchiver *)encoder
{
    [encoder encodeInt:_type];
    
    switch (_type) {
        case SWStorageTypeBool:
        case SWStorageTypeInteger:
            [encoder encodeInt:_myValueContainer.integerValue];
            break;
        case SWStorageTypeFloat:
            [encoder encodeFloat:_myValueContainer.floatValue];
            break;
        case SWStorageTypeDouble:
            [encoder encodeDouble:_myValueContainer.doubleValue];
            break;
        case SWStorageTypePoint:
            [encoder encodeFloat:_myValueContainer.pointValue.x];
            [encoder encodeFloat:_myValueContainer.pointValue.y];
            break;
        case SWStorageTypeSize:
            [encoder encodeFloat:_myValueContainer.sizeValue.width];
            [encoder encodeFloat:_myValueContainer.sizeValue.height];
            break;
        case SWStorageTypeRect:
            [encoder encodeFloat:_myValueContainer.rectValue.origin.x];
            [encoder encodeFloat:_myValueContainer.rectValue.origin.y];
            [encoder encodeFloat:_myValueContainer.rectValue.size.width];
            [encoder encodeFloat:_myValueContainer.rectValue.size.height];
            break;
        case SWStorageTypeString:
        case SWStorageTypeObject:
            [encoder encodeObject:(__bridge id)_myValueContainer.object];
            break;
        case SWStorageTypeUndefined:
        default:
            // Nothing to encode
            break;
    }
    
    // TODO : Fa falta codificar el delegate?
    [encoder encodeObject:_holder];
}

// ------------------------------------------------------------------------------------------ // 
// ------------------------------------ OVERRIDEN METHODS ----------------------------------- // 
// ------------------------------------------------------------------------------------------ // 

#pragma mark - Overriden Methods

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[SWValue class]])
        return NO;
    
    SWValue *value = object;
    
    if (_type != value.type)
        return NO;
    
    switch (_type) {
        case SWStorageTypeInteger:
        case SWStorageTypeBool:
            return _myValueContainer.integerValue == value->_myValueContainer.integerValue;
            break;
        case SWStorageTypeFloat:
            return _myValueContainer.floatValue == value->_myValueContainer.floatValue;
            break;
        case SWStorageTypeDouble:
            return _myValueContainer.doubleValue == value->_myValueContainer.doubleValue;
            break;
        case SWStorageTypePoint:
            return CGPointEqualToPoint(_myValueContainer.pointValue, value->_myValueContainer.pointValue);
            break;
        case SWStorageTypeSize:
            return CGSizeEqualToSize(_myValueContainer.sizeValue, value->_myValueContainer.sizeValue);
            break;
        case SWStorageTypeRect:
            return CGRectEqualToRect(_myValueContainer.rectValue, value->_myValueContainer.rectValue);
            break;
        case SWStorageTypeString:
        {
            NSString *selfString = (__bridge NSString*)_myValueContainer.object;
            NSString *otherString = [value stringValue];
            return [selfString isEqualToString:otherString];
        }
            break;
        case SWStorageTypeObject:
        {
            id selfObject = (__bridge id)_myValueContainer.object;
            id otherObject = [value objectValue];
            return [selfObject isEqual:otherObject];
        }
            break;
        case SWStorageTypeUndefined:
        default:
            break;
    } 
    
    return NO;
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"%@:[name:%@,type:%@,stringValue:%@]",[super description],[self name],NSStringFromSWStorageType(_type),[self stringValue]];
}

// ------------------------------------------------------------------------------------------ // 
// ----------------------------------------- GETTERS ---------------------------------------- // 
// ------------------------------------------------------------------------------------------ // 

#pragma mark - Getters

- (NSInteger)integerValue
{
    NSInteger value = 0;
    
    switch (_type) {
        case SWStorageTypeInteger:
        case SWStorageTypeBool:
            value = _myValueContainer.integerValue;
            break;
        case SWStorageTypeFloat:
            value = (NSInteger)_myValueContainer.floatValue;
            break;
        case SWStorageTypeDouble:
            value = (NSInteger)_myValueContainer.doubleValue;
            break;
        case SWStorageTypePoint:
        case SWStorageTypeSize:
        case SWStorageTypeRect:
            break;
        case SWStorageTypeString:
        case SWStorageTypeObject:
            value = (NSInteger)(__bridge id)_myValueContainer.object;
            break;
        case SWStorageTypeUndefined:
        default:
            break;
    } 
    
    return value;
}

- (CGFloat)floatValue
{
    CGFloat value = 0.0f;
    
    switch (_type) {
        case SWStorageTypeInteger:
        case SWStorageTypeBool:
            value = (CGFloat)_myValueContainer.integerValue;
            break;
        case SWStorageTypeFloat:
            value = _myValueContainer.floatValue;
            break;
        case SWStorageTypeDouble:
            value = (CGFloat)_myValueContainer.doubleValue;
            break;
        case SWStorageTypePoint:
        case SWStorageTypeSize:
        case SWStorageTypeRect:
            break;
        case SWStorageTypeString:
        case SWStorageTypeObject:
        case SWStorageTypeUndefined:
        default:
            break;
    } 
    
    return value;
}

- (double)doubleValue
{
    double value = 0.0;
    
    switch (_type) {
        case SWStorageTypeInteger:
        case SWStorageTypeBool:
            value = (double)_myValueContainer.integerValue;
            break;
        case SWStorageTypeFloat:
            value = (double)_myValueContainer.floatValue;
            break;
        case SWStorageTypeDouble:
            value = _myValueContainer.doubleValue;
            break;
        case SWStorageTypePoint:
        case SWStorageTypeSize:
        case SWStorageTypeRect:
            break;
        case SWStorageTypeString:
        case SWStorageTypeObject:
        case SWStorageTypeUndefined:
        default:
            break;
    }
    
    return value;
}

- (BOOL)boolValue
{
    BOOL value = FALSE;
    
    switch (_type) {
        case SWStorageTypeInteger:
        case SWStorageTypeBool:
            value = (BOOL)_myValueContainer.integerValue;
            break;
        case SWStorageTypeFloat:
            value = _myValueContainer.floatValue != 0.0f;
            break;
        case SWStorageTypeDouble:
            value = _myValueContainer.doubleValue != 0.0;
            break;
        case SWStorageTypePoint:
            value = !CGPointEqualToPoint(_myValueContainer.pointValue, CGPointZero);
            break;
        case SWStorageTypeSize:
            value = !CGSizeEqualToSize(_myValueContainer.sizeValue, CGSizeZero);
            break;
        case SWStorageTypeRect:
            value = !CGRectEqualToRect(_myValueContainer.rectValue, CGRectZero);
            break;
        case SWStorageTypeString:
        case SWStorageTypeObject:
            value = _myValueContainer.object != NULL;
            break;
        case SWStorageTypeUndefined:
        default:
            break;
    }
    
    return value;
}

- (CGPoint)pointValue
{
    CGPoint value = CGPointZero;

    switch (_type) {
        case SWStorageTypeInteger:
        case SWStorageTypeBool:
        case SWStorageTypeFloat:
        case SWStorageTypeDouble:
            break;
        case SWStorageTypePoint:
            value = _myValueContainer.pointValue;
            break;
        case SWStorageTypeSize:
            break;
        case SWStorageTypeRect:
            value = _myValueContainer.rectValue.origin;
            break;
        case SWStorageTypeString:
        case SWStorageTypeObject:
        case SWStorageTypeUndefined:
        default:
            break;
    }

    return value;
}

- (CGSize)sizeValue
{
    CGSize value = CGSizeZero;
    
    switch (_type) {
        case SWStorageTypeInteger:
        case SWStorageTypeBool:
        case SWStorageTypeFloat:
        case SWStorageTypeDouble:
            break;
        case SWStorageTypePoint:
            break;
        case SWStorageTypeSize:
            value = _myValueContainer.sizeValue;
            break;
        case SWStorageTypeRect:
            value = _myValueContainer.rectValue.size;
            break;
        case SWStorageTypeString:
        case SWStorageTypeObject:
        case SWStorageTypeUndefined:
        default:
            break;
    }
    
    return value;
}

- (CGRect)rectValue
{
    CGRect value = CGRectZero;
    
    switch (_type) {
        case SWStorageTypeInteger:
        case SWStorageTypeBool:
        case SWStorageTypeFloat:
        case SWStorageTypeDouble:
            break;
        case SWStorageTypePoint:
            value.origin = _myValueContainer.pointValue;
            break;
        case SWStorageTypeSize:
            value.size = _myValueContainer.sizeValue;
            break;
        case SWStorageTypeRect:
            value = _myValueContainer.rectValue;
            break;
        case SWStorageTypeString:
        case SWStorageTypeObject:
        case SWStorageTypeUndefined:
        default:
            break;
    }
    
    return value;
}

- (NSString*)stringValue
{    
    NSString *value = nil;
    
    switch (_type) {
        case SWStorageTypeInteger:
        case SWStorageTypeBool:
            value = [NSString stringWithFormat:@"%d",_myValueContainer.integerValue];
            break;
        case SWStorageTypeFloat:
            value = [NSString stringWithFormat:@"%f",_myValueContainer.floatValue];
            break;
        case SWStorageTypeDouble:
            value = [NSString stringWithFormat:@"%f",_myValueContainer.doubleValue];
            break;
        case SWStorageTypePoint:
            value = [NSString stringWithFormat:@"%@",NSStringFromCGPoint(_myValueContainer.pointValue)];
            break;
        case SWStorageTypeSize:
            value = [NSString stringWithFormat:@"%@",NSStringFromCGSize(_myValueContainer.sizeValue)];
            break;
        case SWStorageTypeRect:
            value = [NSString stringWithFormat:@"%@",NSStringFromCGRect(_myValueContainer.rectValue)];
            break;
        case SWStorageTypeString:
            value = (__bridge NSString*)_myValueContainer.object;
            break;
        case SWStorageTypeObject:
        {
            id obj = (__bridge id)_myValueContainer.object;
            if ([obj respondsToSelector:@selector(description)])
                value = [NSString stringWithFormat:@"%@",[obj description]];
            else
                value = [NSString stringWithFormat:@"%d",(int)obj];
        }
            break;
        case SWStorageTypeUndefined:
        default:
            value = @"<UndefinedValue>";
            break;
    }
    
    return value;
}

- (id <QuickCoding, SymbolicCoding>)objectValue
{
    id value = nil;
    
    switch (_type) {
        case SWStorageTypeInteger:
        case SWStorageTypeBool:
        case SWStorageTypeFloat:
        case SWStorageTypeDouble:
        case SWStorageTypePoint:
        case SWStorageTypeSize:
        case SWStorageTypeRect:
            break;
        case SWStorageTypeString:
        case SWStorageTypeObject:
            value = (__bridge id)_myValueContainer.object;
            break;
        case SWStorageTypeUndefined:
        default:
            break;
    }
    
    return value;
}

// ------------------------------------------------------------------------------------------ // 
// ----------------------------------------- SETTERS ---------------------------------------- // 
// ------------------------------------------------------------------------------------------ // 

#pragma mark - Setters

- (void)setIntegerValue:(NSInteger)value
{
    NSAssert(_type == SWStorageTypeInteger, @"Setting value of type %@, incompatible with instance attribute type %@",NSStringFromSWStorageType(SWStorageTypeInteger), NSStringFromSWStorageType(_type));
    
    [self _valueWillChange];
    [self _reset];
    
    _myValueContainer.integerValue = value;
    
    [self _valueDidChange];
}

- (void)setBoolValue:(BOOL)value
{
    NSAssert(_type == SWStorageTypeBool, @"Setting value of type %@, incompatible with instance attribute type %@",NSStringFromSWStorageType(SWStorageTypeBool), NSStringFromSWStorageType(_type));
    
    [self _valueWillChange];
    [self _reset];
    
    _myValueContainer.integerValue = value;
    
    [self _valueDidChange];
}


- (void)setFloatValue:(CGFloat)value
{
    NSAssert(_type == SWStorageTypeFloat, @"Setting value of type %@, incompatible with instance attribute type %@",NSStringFromSWStorageType(SWStorageTypeFloat), NSStringFromSWStorageType(_type));
    
    [self _valueWillChange];
    [self _reset];
    
    _myValueContainer.floatValue = value;
    
    [self _valueDidChange];
}

- (void)setDoubleValue:(double)value
{
    NSAssert(_type == SWStorageTypeDouble, @"Setting value of type %@, incompatible with instance attribute type %@", NSStringFromSWStorageType(SWStorageTypeDouble), NSStringFromSWStorageType(_type));
    
    [self _valueWillChange];
    [self _reset];
    
    _myValueContainer.doubleValue = value;
    
    [self _valueDidChange];
}

- (void)setPointValue:(CGPoint)value
{
    NSAssert(_type == SWStorageTypePoint, @"Setting value of type %@, incompatible with instance attribute type %@",NSStringFromSWStorageType(SWStorageTypePoint), NSStringFromSWStorageType(_type));
    
    [self _valueWillChange];
    [self _reset];
    
    _myValueContainer.pointValue = value;
    
    [self _valueDidChange];
}

- (void)setSizeValue:(CGSize)value
{
    NSAssert(_type == SWStorageTypeSize, @"Setting value of type %@, incompatible with instance attribute type %@",NSStringFromSWStorageType(SWStorageTypeSize), NSStringFromSWStorageType(_type));
    
    [self _valueWillChange];
    [self _reset];
    
    _myValueContainer.sizeValue = value;
    
    [self _valueDidChange];
}

- (void)setRectValue:(CGRect)value
{    
    NSAssert(_type == SWStorageTypeRect, @"Setting value of type %@, incompatible with instance attribute type %@",NSStringFromSWStorageType(SWStorageTypeRect), NSStringFromSWStorageType(_type));
    
    [self _valueWillChange];
    [self _reset];
    
    _myValueContainer.rectValue = value;
    
    [self _valueDidChange];
}

- (void)setStringValue:(NSString*)value
{
    NSAssert(_type == SWStorageTypeString, @"Setting value of type %@, incompatible with instance attribute type %@",NSStringFromSWStorageType(SWStorageTypeString), NSStringFromSWStorageType(_type));
 
    if ((__bridge id)_myValueContainer.object == value)
        return;
    
    [self _valueWillChange];
    [self _reset];
    
    CFTypeRef obj = (__bridge_retained CFTypeRef)value;
    _myValueContainer.object = obj;
    
    [self _valueDidChange];
}

- (void)setObjectValue:(id <QuickCoding, SymbolicCoding>)value
{
    NSAssert(_type == SWStorageTypeObject, @"Setting value of type %@, incompatible with instance attribute type %@",NSStringFromSWStorageType(SWStorageTypeObject), NSStringFromSWStorageType(_type));
    
    if ((__bridge id)_myValueContainer.object == value)
        return;
    
    [self _valueWillChange];
    [self _reset];
    
    CFTypeRef obj = (__bridge_retained CFTypeRef)value;
    _myValueContainer.object = obj;
    
    [self _valueDidChange];
}

// ------------------------------------------------------------------------------------------ // 
// ----------------------------------------- METHODS ---------------------------------------- // 
// ------------------------------------------------------------------------------------------ // 

#pragma mark - Other Methods

- (NSString*)name
{
    return [_holder nameForValue:self];
}

- (NSString*)symbol
{
    return [_holder symbolForValue:self];
}

// ------------------------------------------------------------------------------------------ // 
// ---------------------------------------- OBSERVING --------------------------------------- // 
// ------------------------------------------------------------------------------------------ // 

#pragma mark - Observation

- (void)addValueObserver:(id<SWValueObserver>)observer
{
    if (observer == nil) 
        return;
    
    NSAssert(![self isValueObserver:observer], @"OBSERVER ALREADY IN THE OBSERVER'S ARRAY.");
    
    if (_observers == NULL) 
        _observers = CFArrayCreateMutable(NULL, 0, NULL);
    
    CFArrayAppendValue( _observers, (__bridge CFTypeRef)observer);
}

- (void)removeValueObserver:(id<SWValueObserver>)observer
{    
    if (observer == nil) 
        return;
    
    if (_observers)
    {
        CFIndex length = CFArrayGetCount(_observers);
        CFIndex index = CFArrayGetLastIndexOfValue(_observers, CFRangeMake(0,length), (__bridge CFTypeRef)observer);
        if (index >= 0) 
            CFArrayRemoveValueAtIndex(_observers, index);
    }
}

- (BOOL)isValueObserver:(id<SWValueObserver>)observer
{
    if (observer == nil) 
        return NO;
    
    if (_observers)
    {
        CFIndex length = CFArrayGetCount(_observers);
        CFIndex index = CFArrayGetLastIndexOfValue(_observers, CFRangeMake(0,length), (__bridge CFTypeRef)observer);
        if (index >= 0) 
            return YES;
    }
    
    return NO;
}

// ------------------------------------------------------------------------------------------ // 
// ----------------------------------------- PRIVATE ---------------------------------------- // 
// ------------------------------------------------------------------------------------------ // 

#pragma mark - Private Methods

- (void)_reset
{
    if ((_type == SWStorageTypeObject || _type == SWStorageTypeString) && _myValueContainer.object != NULL) 
        CFRelease(_myValueContainer.object);
    
    bzero(&_myValueContainer, sizeof(_myValueContainer));
}

- (void)_valueWillChange
{
    if ([_holder respondsToSelector:@selector(registerToUndoManagerCurrentValue:)])
        [_holder registerToUndoManagerCurrentValue:self];
    
    if (_observers)
    {
        CFIndex count = CFArrayGetCount(_observers);
        for (CFIndex i=0; i<count; i++)
        {
            id<SWValueObserver> observer = (__bridge id)CFArrayGetValueAtIndex(_observers, i);
            [observer willChangeValue:self] ;
        }
    }
}

- (void)_valueDidChange
{
    if (_observers)
    {
        CFIndex count = CFArrayGetCount(_observers);
        for (CFIndex i=0; i<count; i++)
        {
            id<SWValueObserver> observer = (__bridge id)CFArrayGetValueAtIndex(_observers, i);
            [observer didChangeValue:self] ;
        }
    }
}

@end
 
 */

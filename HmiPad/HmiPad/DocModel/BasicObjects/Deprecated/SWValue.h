//
//  SWObjectProperty.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 5/25/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

/*
#import <Foundation/Foundation.h>

#import "SymbolicCoder.h"
#import "QuickCoder.h"
#import "SWValueTypes.h"

@class SWValue;
@class SWAttributeDescription;

// ------------------------------------------------------------------------------------------ // 
// ---------------------------------------- PROTOCOLS --------------------------------------- // 
// ------------------------------------------------------------------------------------------ // 

@protocol SWValueHolder <NSObject>

@required
- (SWValue*)valueWithSymbol:(NSString*)sym name:(NSString*)name;
- (NSString*)symbolForValue:(SWValue*)value;
- (NSString*)nameForValue:(SWValue*)value;
- (SWAttributeDescription*)descriptionForValue:(SWValue*)value;

@optional
- (void)registerToUndoManagerCurrentValue:(SWValue*)value;

@end

@protocol SWValueObserver <NSObject>

@required
- (void)willChangeValue:(SWValue*)value;
- (void)didChangeValue:(SWValue*)value;

@end

// ------------------------------------------------------------------------------------------ // 
// ------------------------------------------ CLASS ----------------------------------------- // 
// ------------------------------------------------------------------------------------------ // 

@interface SWValue : NSObject <QuickCoding> 
{
    union ValueContainer
    {
        NSInteger integerValue;
        CGFloat floatValue;
        double doubleValue;
        CGPoint pointValue;
        CGSize sizeValue;
        CGRect rectValue;
        CFTypeRef object;
    } _myValueContainer;
    
    SWStorageType _type;
    CFMutableArrayRef _observers;
}

// ------------------------------------------------------------------------------------------ // 
// --------------------------------------- PROPERTIES --------------------------------------- // 
// ------------------------------------------------------------------------------------------ // 

@property (nonatomic, readonly) SWStorageType type;
@property (nonatomic, weak) id <SWValueHolder> holder;

// ------------------------------------------------------------------------------------------ // 
// -------------------------------------- INITIALIZERS -------------------------------------- // 
// ------------------------------------------------------------------------------------------ // 

- (id)initWithType:(SWStorageType)type;

- (id)initWithInteger:(NSInteger)value;
- (id)initWithBool:(BOOL)value;
- (id)initWithFloat:(CGFloat)value;
- (id)initWithDouble:(double)value;
- (id)initWithCGPoint:(CGPoint)value;
- (id)initWithCGSize:(CGSize)value;
- (id)initWithCGRect:(CGRect)value;
- (id)initWithString:(NSString*)value;
- (id)initWithObject:(id <QuickCoding, SymbolicCoding>)value;

// ------------------------------------------------------------------------------------------ // 
// ----------------------------------------- STATICS ---------------------------------------- // 
// ------------------------------------------------------------------------------------------ // 

+ (SWValue*)valueWithType:(SWStorageType)type;

+ (SWValue*)valueWithInteger:(NSInteger)value;
+ (SWValue*)valueWithBool:(BOOL)value;
+ (SWValue*)valueWithFloat:(CGFloat)value;
+ (SWValue*)valueWithDouble:(double)value;
+ (SWValue*)valueWithCGPoint:(CGPoint)value;
+ (SWValue*)valueWithCGSize:(CGSize)value;
+ (SWValue*)valueWithCGRect:(CGRect)value;
+ (SWValue*)valueWithString:(NSString*)value;
+ (SWValue*)valueWithObject:(id <QuickCoding, SymbolicCoding>)value;

// ------------------------------------------------------------------------------------------ // 
// ----------------------------------------- GETTERS ---------------------------------------- // 
// ------------------------------------------------------------------------------------------ // 

- (NSInteger)integerValue;
- (BOOL)boolValue;
- (CGFloat)floatValue;
- (double)doubleValue;
- (CGPoint)pointValue;
- (CGSize)sizeValue;
- (CGRect)rectValue;
- (NSString*)stringValue;
- (id <QuickCoding, SymbolicCoding>)objectValue;

// ------------------------------------------------------------------------------------------ // 
// ----------------------------------------- SETTERS ---------------------------------------- // 
// ------------------------------------------------------------------------------------------ // 

- (void)setIntegerValue:(NSInteger)value;
- (void)setBoolValue:(BOOL)value;
- (void)setFloatValue:(CGFloat)value;
- (void)setDoubleValue:(double)value;
- (void)setPointValue:(CGPoint)value;
- (void)setSizeValue:(CGSize)value;
- (void)setRectValue:(CGRect)value;
- (void)setStringValue:(NSString*)value;
- (void)setObjectValue:(id <QuickCoding, SymbolicCoding>)value;

// ------------------------------------------------------------------------------------------ // 
// ----------------------------------------- METHODS ---------------------------------------- // 
// ------------------------------------------------------------------------------------------ // 

- (NSString*)name;
- (NSString*)symbol;

// ------------------------------------------------------------------------------------------ // 
// ---------------------------------------- OBSERVING --------------------------------------- // 
// ------------------------------------------------------------------------------------------ // 

- (void)addValueObserver:(id<SWValueObserver>)observer;
- (void)removeValueObserver:(id<SWValueObserver>)observer;
- (BOOL)isValueObserver:(id<SWValueObserver>)observer;

@end
 */

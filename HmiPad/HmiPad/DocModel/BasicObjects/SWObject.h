//
//  SWItem.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 2/14/12.
//  Copyright (c) 2012 SweetWilliam SL. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "QuickCoder.h"
#import "SymbolicCoder.h"

#import "SWAsleepCapable.h"
#import "SWObjectDescription.h"

#import "SWExpression.h"


@class SWDocumentModel;
@class SWObject;

@protocol SWObjectObserver <NSObject>

@optional
- (void)identifierDidChangeForObject:(SWObject*)object;
- (void)willRemoveObject:(SWObject*)object;

@end


//@protocol SWObject <NSObject>
//
//@required
//
//// Incluir aquest macro o implementar directament el mateix codi
//#define SWObjectDescriptionCreateInstanceMacro                                                             \
//                                                                                                \
//static SWObjectDescription *_objectDescription = nil;                                           \
//+ (SWObjectDescription *)objectDescription                                                      \
//{                                                                                               \
//    if ( _objectDescription == nil )                                                            \
//        _objectDescription = [[SWObjectDescription alloc] initWithObjectClass:[self class]];    \
//    return _objectDescription ;                                                                 \
//}
//
//@end

@protocol SWObjectGrouping<NSObject>

@required
@property (nonatomic, readonly) BOOL isGroupItem;  // On any SWObject returns NO by default

@end

extern NSString * const SWObjectIdentifierKey;

extern BOOL BitFromIntAtIndex(NSInteger integer, NSUInteger index);
extern void SetBitFromIntAtIndex(NSInteger *integer, NSUInteger index, BOOL bit);
extern void SetAllBitsTo(NSInteger *integer, BOOL bit);

@interface SWObject : NSObject <SWObjectDescriptionDataSource, SWObjectGrouping, QuickCoding, SymbolicCoding, ValueHolder, SWAsleepCapable>
{
    NSMutableArray *_properties;
    NSMutableArray *_observers;
    __weak SWDocumentModel *_docModel;
    BOOL _asleep;
}

// class mehods
+ (BOOL)isValidIdentifier:(NSString*)ident outErrString:(NSString**)outErrStr;

// init
- (id)initInDocument:(SWDocumentModel*)docModel;

// Coding Properties
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, weak, readonly) SWDocumentModel *docModel;
@property (nonatomic, readonly) NSString* redeemedName;
@property (nonatomic, readonly) NSMutableArray *properties;

// Other Properties
@property (nonatomic, assign) NSInteger configurationTag;

// Observing
- (void)addObjectObserver:(id<SWObjectObserver>)itemObserver;
- (void)removeObjectObserver:(id<SWObjectObserver>)itemObserver;

// SWObjectDescriptionDataSource
- (NSArray*)propertyDescriptions;

// SWExpressionHandling
- (void)updateExpression:(SWExpression*)expression fromString:(NSString*)string;
- (RpnBuilder*)builder;
- (BOOL)isCommitingWithMoveToGlobal;

// -- Searching -- //
- (BOOL)matchesSearchWithString:(NSString*)string;

@end


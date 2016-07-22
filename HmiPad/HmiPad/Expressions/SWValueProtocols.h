//
//  SWValueProtocols.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 6/4/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SWValue;
@class SWPropertyDescriptor;

// ---------- VALUE OBSERVER ---------- //
#pragma mark - Value Observer

@protocol ValueObserver <NSObject>

@required
- (void)value:(SWValue*)value didEvaluateWithChange:(BOOL)changed;

@optional
- (void)valueDidChangeName:(SWValue*)value;

@end

// ---------- VALUE HOLDER ---------- //
#pragma mark - Value Holder

@protocol ValueHolder <NSObject>

@required
- (SWValue *)valueWithSymbol:(NSString *)sym property:(NSString *)prop; // requerit per rpnBuilder al compilar una expressio
- (NSString *)symbolForValue:(SWValue*)value;
- (NSString *)identifier;  // identifica el holder

@optional
- (NSString *)propertyForValue:(SWValue*)value;
- (void)value:(SWValue*)value didTriggerWithChange:(BOOL)changed;
- (void)setGlobalIdentifier:(NSString*)ident;  // requerit per rpnBuilder a commitExpressionsByConvertingLocalSymbolsToGlobalOutError

@optional
- (SWPropertyDescriptor*)valueDescriptionForValue:(SWValue*)value;
- (SWValue*)defaultValueForValue:(SWValue*)value;
- (void)registerToUndoManagerCurrentValue:(SWValue*)value;

@optional
- (void)valuePerformRetain:(SWValue*)value;
- (void)valuePerformRelease:(SWValue*)value;
- (BOOL)canPerformRetainForValue:(SWValue*)value;
- (BOOL)canPerformReleaseForValue:(SWValue*)value;

@end

// ---------- VALUE DEPENDENCES ---------- //
#pragma mark - Value Dependences

@protocol ValueDependant <NSObject>

@required
- (void)sourceSymbolDidChange;

@end

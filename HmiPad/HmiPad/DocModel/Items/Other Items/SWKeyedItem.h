//
//  SWKeyedItem.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 2/27/12.
//  Copyright (c) 2012 SweetWilliam SL. All rights reserved.
//

#import "SWItem.h"

@class Expression;

/**
 * This class extends the Item class adding a "keyed" based behaviour to manipulate expressions. 
 * Simply by adding a new name, the class will create an expression. Also, it is possible to add multiple names to handle one expression.
 * When adding a new expression, the class will add the same observers to the new expressions added before in other expressions.
 * The class implements fast enumeration, enumerating the contained expressions.
 */
@interface SWKeyedItem : SWItem <NSFastEnumeration> {
    // -- Persistent attributes -- //
    NSMutableDictionary *_dic;
    NSMutableArray *_editableExpressions;
    
    // -- Unpersistent attributes -- //
    // NSMutableArray *_observers; 
}

/* Adding, removing and editing expressions by name */
- (BOOL)addExpressionWithName:(NSString*)name;
- (void)removeExpressionWithName:(NSString*)name;
- (BOOL)addName:(NSString*)newName toExpressionWithName:(NSString*)name;
- (void)setExpressionWithName:(NSString*)name editable:(BOOL)editable;

/* Editing expressions*/
- (BOOL)setValueExpression:(NSString*)text forExpressionWithName:(NSString*)name outError:(NSError**)error;

/* Getters */
- (SWExpression*)expressionWithName:(NSString*)name;
- (NSArray*)namesForExpression:(SWExpression*)expression;

@property (nonatomic, readonly) NSUInteger count;
@property (nonatomic, readonly) NSArray *allExpressions;
@property (nonatomic, readonly) NSArray *allNames;
@property (nonatomic, readonly) SWItemControllerType controllerType;
@property (nonatomic, assign) SWItemResizeMask resizeMask;

@end

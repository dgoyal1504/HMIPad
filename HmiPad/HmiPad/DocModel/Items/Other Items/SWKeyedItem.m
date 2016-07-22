//
//  SWKeyedItem.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 2/27/12.
//  Copyright (c) 2012 SweetWilliam SL. All rights reserved.
//

#import "SWKeyedItem.h"

@interface SWKeyedItem (Private)

- (void)_deleteExpression:(SWExpression*)expression;

@end

@implementation SWKeyedItem

@dynamic count;
@dynamic allExpressions;
@dynamic allNames;

@synthesize controllerType = _controllerType;
@synthesize mask = _mask;

/*
- (id)initInDocument:(SWDocumentModel *)docModel
{
    self = [super initInDocument:docModel];
    if (self) {
        _dic = [NSMutableDictionary dictionary];
        _editableExpressions = [NSMutableArray array];
    }
    return self;
}
*/

- (id)initInPage:(SWPage *)page
{
    self = [super initInPage:page];
    if (self) {
        _dic = [NSMutableDictionary dictionary];
        _editableExpressions = [NSMutableArray array];
    }
    return self;
}

#pragma mark - QuickCoding

- (id)initWithQuickCoder:(QuickUnarchiver *)decoder
{
    self = [super initWithQuickCoder:decoder];
    if (self) {
        
        _dic = [decoder decodeObject];
        _editableExpressions = [decoder decodeObject];
        _controllerType = [decoder decodeObject];
        _mask = [decoder decodeInt];
        
        //JLZ _observers = [NSMutableArray array];
        
    }
    return self;
}

- (void)encodeWithQuickCoder:(QuickArchiver *)encoder
{
    [super encodeWithQuickCoder:encoder];
    
    [encoder encodeObject:_dic];
    [encoder encodeObject:_editableExpressions];
    [encoder encodeObject:_controllerType];
    [encoder encodeInt:_mask];
}

#pragma mark - Properties

- (NSUInteger)count
{
    return _properties.count;
}

- (NSArray*)allExpressions
{
    return [_properties copy];
}

- (NSArray*)allNames
{
    return _dic.allKeys;
}

#pragma mark - Main Methods

- (BOOL)addExpressionWithName:(NSString*)name
{
    if ([_dic valueForKey:name]) {
        return NO;
    }
    
    SWExpression *exp = [[SWExpression alloc] initWithDouble:0.0];
    [exp setHolder:self];
    
    /*
    for (id<ExpressionObserver> observer in _observers) {
        [exp addObserver:observer];
    }
    JLZ*/
    
    NSMutableArray *exps = [_properties mutableCopy];
    [exps addObject:exp];
    _properties = [exps copy];
//    [_properties addObject:exp];
    
    [_dic setValue:exp forKey:name];
    
    return YES;
}

- (void)removeExpressionWithName:(NSString*)name
{
    SWExpression *exp = [_dic valueForKey:name];
    
    [_dic removeObjectForKey:name];
    
    NSMutableArray *exps = [_properties mutableCopy];
    
    if (![_dic.allValues containsObject:exp]) {
        [exps removeObjectIdenticalTo:exp];
        [self _deleteExpression:exp];
    }
    
    _properties = [exp copy];
}

- (BOOL)addName:(NSString*)newName toExpressionWithName:(NSString*)name
{
    SWExpression *exp = [_dic valueForKey:name];
    
    if (!exp)
        return NO;
    
    if ([_dic valueForKey:newName]) {
        return NO;
    }
    
    [_dic setValue:exp forKey:newName];
    
    return YES;
}

- (void)setExpressionWithName:(NSString*)name editable:(BOOL)editable
{
    SWExpression *exp = [_dic valueForKey:name];
    
    if (!exp)
        return;
    
    if (editable) {
        if (![_editableExpressions containsObject:exp]) {
            [_editableExpressions addObject:exp];
        }
    } else {
        [_editableExpressions removeObjectIdenticalTo:exp];
    }
}

- (SWExpression*)expressionWithName:(NSString*)name
{
    return [_dic valueForKey:name];
}

- (BOOL)setValueExpression:(NSString*)text forExpressionWithName:(NSString*)name outError:(NSError**)error
{
    SWExpression *exp = [_dic valueForKey:name];
    if (!exp)
        return NO;
    
    return [[self builder] updateExpression:exp fromString:text outError:error] ;
}

- (NSArray*)namesForExpression:(SWExpression*)expression
{
    NSMutableArray *array = [NSMutableArray array];
    
    for (NSString *name in _dic) {
        SWExpression *exp = [_dic valueForKey:name];
        if (expression == exp) {
            [array addObject:name];
        }
    }
    
    return [array copy];
}

#pragma mark - Overriden Methods

//+ (NSString*)defaultIdentifier
//{
//    return @"item";
//}

//- (BOOL)setIdentifier:(NSString*)text outError:(NSError**)error
//{
//    BOOL result = [super setIdentifier:text outError:error];
//    if (result) {
//       // [_properties makeObjectsPerformSelector:@selector(promoteSymbol)];  // fora, ja ho fa el SWItem
//    }
//    return result;
//}

/*
- (void)addItemObserver:(id<ItemObserver>)itemObserver
{
    [super addItemObserver:itemObserver];
    
    [_observers addObject:itemObserver];
    
    for (SWExpression *exp in _properties) {
        [exp addObserver:itemObserver];
    }
}
*/

/*
- (void)removeItemObserver:(id<ItemObserver>)itemObserver
{    
    [super removeItemObserver:itemObserver];
    
    [_observers removeObjectIdenticalTo:itemObserver];
    
    for (SWExpression *exp in _properties) {
        [exp removeObserver:itemObserver];
    }
}
*/

#pragma mark SWExpressionHolder

- (SWExpression*)expressionWithSymbol:(NSString *)sym property:(NSString *)property
{        
    SWExpression *exp = [_dic valueForKey:property];
    
    if (exp) {
        return exp;
    }
    
    return (id)[super valueWithSymbol:sym property:property];
}

- (NSString *)propertyForExpression:(SWExpression*)expr
{
    NSString *__block theKey = nil ;
    [_dic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) 
    {
        if ( expr == obj )
        {
            theKey = key ;
            *stop = YES ;
        }
    }] ;
    
    return theKey ;
}

- (void)expression:(SWExpression*)expression didTriggerWithChange:(BOOL)changed
{
    // To Override
}

#pragma mark - Fast Enumeration 

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id *)stackbuf count:(NSUInteger)len
{
    return [_properties countByEnumeratingWithState:state objects:stackbuf count:len];
}

@end

@implementation SWKeyedItem (Private)

- (void)_deleteExpression:(SWExpression*)expression
{
    // Removing the known observers
    /*for (id<ExpressionObserver> observer in _observers) {
        [expression removeObserver:observer];
    }
    JLZ*/
    
    // TODO : S'ha de fer alguna cosa en especial si es vol eliminar una expressió?
}

@end


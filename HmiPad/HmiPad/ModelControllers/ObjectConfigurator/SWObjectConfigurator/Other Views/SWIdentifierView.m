//
//  SWIdentifierView.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 6/7/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWIdentifierView.h"

@implementation SWIdentifierView

@synthesize modelObject = _modelObject;
@synthesize name = _name;
@synthesize identifierField = _identifierField;

#pragma mark Properties

//- (void)setModelObject:(SWObject *)modelObject
//{
//    if (self.superview) {
//        [_modelObject removeItemObserver:self];
//        [modelObject addItemObserver:self];
//    }
//    
//    _modelObject = modelObject;
//    
//    [self refresh];
//}
//
//#pragma mark Overriden Methods
//
//- (void)dealloc
//{
//    //[_modelObject removeItemObserver:self];
//}
//
//- (void)willMoveToSuperview:(UIView *)newSuperview
//{
//    [super willMoveToSuperview:newSuperview];
//    
//    if (newSuperview) {
//        [_modelObject addItemObserver:self];
//    } else {
//        [_modelObject removeItemObserver:self];
//    }
//}
//
//#pragma mark Public Methods
//
//- (void)refresh
//{
//    _identifierField.text = _modelObject.identifier;
//}
//
//#pragma mark Protocol SWObjectObserver
//
//- (void)object:(SWObject *)item didChangeValueForKey:(NSString *)key // <---- Mètode deprecat. usar identifierDidChangeForObject
//{
//    if ([key isEqualToString:SWObjectIdentifierKey]) {
//        [self refresh];
//    }
//}

@end

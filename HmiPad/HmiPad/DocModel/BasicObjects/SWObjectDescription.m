//
//  SWObjectDescription.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 5/23/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWObjectDescription.h"
#import "SWObject.h"
#import "SWPropertyDescriptor.h"
#import "NSArray+Additions.h"

@implementation SWObjectDescription

@synthesize objectClass = _objectClass;

@synthesize defaultIdentifier = _defaultIdentifier;
@synthesize localizedName = _localizedName;

@synthesize propertyDescriptions = _valueDescriptions;
@synthesize allPropertyDescriptions = _allValueDescriptions;
@synthesize firstClassPropertyIndex = _firstSelfValueIndex;

@synthesize superClassInfo = _superClassInfo;
@synthesize depth = _depth;


- (id)initWithObjectClass:(Class <SWObjectDescriptionDataSource>)objectClass
{
    self = [super init];
    if ( self ) 
    {
        // Storing the main class
        _objectClass = objectClass;
        _controllerClass = [_objectClass defaultControllerClass];
        
        // Asking the dataSource for main properties
        _defaultIdentifier = [_objectClass defaultIdentifier];
        _localizedName = [_objectClass localizedName];
        
        // Getting names     
        _valueDescriptions = [_objectClass propertyDescriptions];
        
        // Searching for the super itemInfoClass
        
        Class superClass = [_objectClass superclass];
        if ([superClass isSubclassOfClass:[SWObject class]])
            _superClassInfo = [superClass objectDescription];
        
        // Setting SWValue Names
        
        if ( _superClassInfo ) 
            _allValueDescriptions = [_superClassInfo.allPropertyDescriptions arrayByAddingObjectsFromArray:_valueDescriptions];
        else
            _allValueDescriptions = [_valueDescriptions copy];
        
        // Setting firstClassPropertyIndex
        
        if ( _valueDescriptions.count > 0 )
            _firstSelfValueIndex = _superClassInfo.allPropertyDescriptions.count;
        else
            _firstSelfValueIndex = NSNotFound;
        
        // Setting the detph
        
        if (_superClassInfo)
            _depth = 1 + _superClassInfo.depth;
        else
            _depth = 0;
        
        
//        for ( SWPropertyDescriptor *descriptor in _allValueDescriptions )
//        {
//            SWValue *overridenDefaultValue = [_objectClass overridenDefaultValueForPropertyName:descriptor.name];
//            if ( overridenDefaultValue != nil )
//                descriptor.defaultValue = overridenDefaultValue;
//        }
    }
    return self;
}

//- (SWObjectDescription*)superclassInfoAtLevel:(NSInteger)superLevel
//{
//    SWObjectDescription *classInfo = self;
//    
//    for (NSInteger i=0; i<superLevel; ++i)
//    {
//        classInfo = classInfo.superClassInfo;
//        
//        if (classInfo == nil)
//            return nil;
//    }
//    
//    return classInfo;
//}

@end
//
//  AppModel+DatabaseManager.m
//  HmiPad
//
//  Created by Joan Lluch on 03/04/14.
//  Copyright (c) 2014 SweetWilliam, SL. All rights reserved.
//

#import "AppModelDatabase.h"
#import "AppModelFilesEx.h"

#import "SWDatabaseContext.h"

@implementation AppModelDatabase


- (id)initWithLocalFilesModel:(AppModel*)filesModel
{
    self = [super init];
    if ( self )
    {
        _filesModel = filesModel;
        //_observers = CFBridgingRelease(CFArrayCreateMutable(NULL, 0, NULL));
        _activeDBNames = [NSMutableSet set];
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(databaseContextNotification:) name:SWDatabaseContextDidOpenDatabaseNotification object:nil];
        [nc addObserver:self selector:@selector(databaseContextNotification:) name:SWDatabaseContextDidCloseDatabaseNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
}


# pragma mark - observation

//- (void)_notifyActiveDatabasesDidChange
//{
//    for ( id<AppModelDatabaseObserver>observer in _observers )
//    {
//        if ( [observer respondsToSelector:@selector(appModelDatabaseActiveDatabasesDidChange:)])
//        {
//            [observer appModelDatabaseActiveDatabasesDidChange:self];
//        }
//    }
//}

//
//#pragma mark - AppModelDatabase observers
//
//- (void)addObserver:(id<AppModelDatabaseObserver>)observer
//{
//    [_observers addObject:observer];
//}
//
//- (void)removeObserver:(id<AppModelDatabaseObserver>)observer
//{
//    [_observers removeObjectIdenticalTo:observer];
//}


#pragma mark - Methods

- (void)refreshActiveDatabaseFileMDs
{
    NSArray *databaseMDs = [_filesModel.files filesMDArrayForCategory:kFileCategoryDatabase];
    
    for ( FileMD *fileMD in databaseMDs )
    {
        BOOL active = [_activeDBNames containsObject:fileMD.fileName];
        fileMD.isDisabled = active;
    }
}

#pragma mark - databaseContext notification

- (void)databaseContextNotification:(NSNotification*)note
{
    NSString *name = note.name;
    NSDictionary *userInfo = note.userInfo;
    NSString *dbName = [userInfo objectForKey:SWDatabaseContextDBNameKey];
    
    if ( [name isEqualToString:SWDatabaseContextDidOpenDatabaseNotification] )
    {
        [_activeDBNames addObject:dbName];
    }
    
    else if ( [name isEqualToString:SWDatabaseContextDidCloseDatabaseNotification] )
    {
        [_activeDBNames removeObject:dbName];
    }

    [_filesModel.files resetMDArrayForCategory:kFileCategoryDatabase];
    [_filesModel.files refreshMDArrayForCategory:kFileCategoryDatabase];
}

@end

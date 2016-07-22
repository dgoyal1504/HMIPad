//
//  AppModel+DatabaseManager.h
//  HmiPad
//
//  Created by Joan Lluch on 03/04/14.
//  Copyright (c) 2014 SweetWilliam, SL. All rights reserved.
//

#import "AppModel.h"



//@class AppModelDatabase;
//
//@protocol AppModelDatabaseObserver<NSObject>
//
//@optional
//
//- (void)appModelDatabaseActiveDatabasesDidChange:(AppModelDatabase*)amDatabase;
//
//@end


@interface AppModelDatabase : NSObject
{
    __weak AppModel *_filesModel;
    //NSMutableArray *_observers; // List of observers
    NSMutableSet *_activeDBNames;
}

//- (void)addObserver:(id<AppModelDatabaseObserver>)observer;
//- (void)removeObserver:(id<AppModelDatabaseObserver>)observer;

- (id)initWithLocalFilesModel:(AppModel*)filesModel;


- (void)refreshActiveDatabaseFileMDs;

@end

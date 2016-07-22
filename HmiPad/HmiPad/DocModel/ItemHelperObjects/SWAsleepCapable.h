//
//  SWAleepCapable.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 3/20/12.
//  Copyright (c) 2012 SweetWilliam SL. All rights reserved.
//

#import <Foundation/Foundation.h>

//@protocol SWAsleepCapable;
//
//@protocol SWAsleepObserver<NSObject>
//- (void)willPutToSleep:(id<SWAsleepCapable>)object;   // generalment associat a esborrat inminent de l'objecte
//@end


@protocol SWAsleepCapable<NSObject>

@property  (nonatomic, readonly, getter = isAsleep) BOOL asleep;
- (void)putToSleep;
- (void)awakeFromSleepIfNeeded;

//- (void)addAsleepObserver:(id<SWAsleepObserver>)observer;
//- (void)removeAsleepObserver:(id<SWAsleepObserver>)observer;

@end



//
//  SWFloatingPopoverManager.h
//  HmiPad
//
//  Created by Joan Martin on 8/6/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SWFloatingPopoverController.h"

@interface SWFloatingPopoverManager : NSObject <SWFloatingPopoverControllerDelegate>
{
    // Utilitzem un CFMutableDictionaryRef en lloc de NSMutableDictionary per evitar haver de implementar
    // el protocol NSCopying en les keys donat que una key pot ser qualsevol objecte arbitrari
    // El CFMutableDictionaryRef amb els callbacks adequats utilitza simplement
    // retain/relesase en lloc de copy per amagatzemar les keys, i per tant es perfecte per
    // aquesta finalitat.
    // Una altra possibilitat seria utilitzar string keys basades en el punter del objecte key en un
    // NSMutableDictionary, pero aleshores perderiem la funcionalitat de detectar keys iguals
    // des del punt de vista de isEqual. Amb la solucio adoptada mantenim aquesta funcionalitat. 
    CFMutableDictionaryRef _floatingPopoversDict;
}

//+ (SWFloatingPopoverManager*)defaultManager;

- (void)dismissAllPopoversAnimated:(BOOL)animated;
- (void)dismissFloatingPopoversWithKeys:(NSArray*)keys animated:(BOOL)animated;

- (void)presentFloatingPopover:(SWFloatingPopoverController*)fpc animated:(BOOL)animated; // withKey:(id)key;
- (void)presentFloatingPopover:(SWFloatingPopoverController*)fpc atPoint:(CGPoint)point animated:(BOOL)animated; //withKey:(id)key;

- (SWFloatingPopoverController*)floatingPopoverControllerWithKey:(id)key;

- (NSArray*)presentedFloatingPopovers;

@end
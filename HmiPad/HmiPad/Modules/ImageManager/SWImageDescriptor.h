//
//  SWImageDescriptor.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 7/10/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QuickCoder.h"


extern UIImage *EmptyImage;

@interface SWImageDescriptor : NSObject <QuickCoding>

- (id)initWithOriginalPath:(NSString*)path size:(CGSize)size contentMode:(UIViewContentMode)contentMode;
- (id)initWithOriginalPath:(NSString*)path size:(CGSize)size contentMode:(UIViewContentMode)contentMode contentScale:(CGFloat)scale;
- (id)initWithOriginalImage:(UIImage*)image uuid:(NSString*)uuid;

// -- Coding Properties -- //
@property (nonatomic, strong, readonly) NSString* originalPath;
@property (nonatomic, assign, readonly) CGSize size;
@property (nonatomic, assign, readonly) UIViewContentMode contentMode;
@property (nonatomic, assign, readonly) CGFloat scale;

// podem asignar una contentImage en que s'utilitzara com a original en lloc de buscar-la en el originalPath
// en aquest cas el originalPath s'utilitza com una 'key' per la llista de imatges manejades
@property (nonatomic, retain) UIImage *contentImage;

// podem asignar prioritat alta
@property (nonatomic, assign) BOOL hasPriority;
@end

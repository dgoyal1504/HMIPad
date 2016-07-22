//
//  SWManagedImage.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 7/9/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWManagedImage.h"

#import "SWImageManager.h"

#import "UIImage+Resize.h"


@implementation SWManagedImage

@synthesize path = _path;
@synthesize creationDate = _creationDate;
@synthesize accessDate = _accessDate;

- (id)initWithDescriptor:(SWImageDescriptor*)descriptor
{
    self = [self initWithOriginalPath:descriptor.originalPath size:descriptor.size
        contentMode:descriptor.contentMode contentScale:descriptor.scale];
    
    if ( self )
    {
        // no copiem el contentImage
        self.hasPriority = descriptor.hasPriority;
    }
    return self;
}


#pragma mark Overriden Methods

- (NSString*)description
{
    return [NSString stringWithFormat:@"[%@, <path:%@>, <accesDate:%@>, <creationDate:%@>]",[super description],_path.lastPathComponent,[[NSDate dateWithTimeIntervalSinceReferenceDate:_accessDate] description],[[NSDate dateWithTimeIntervalSinceReferenceDate:_creationDate] description]];
}

- (BOOL)isEqual:(id)object
{
    return [super isEqual:object];
}

- (NSUInteger)hash
{
    return [super hash];
}


#pragma mark Protocol QuickCoding

- (id)initWithQuickCoder:(QuickUnarchiver *)decoder
{
    self = [super initWithQuickCoder:decoder];
    if (self) 
    {
        _path = [decoder decodeObject];
        _creationDate = [decoder decodeDouble];
        _accessDate = [decoder decodeDouble];
    }
    return self;
}

- (void)encodeWithQuickCoder:(QuickArchiver *)encoder
{
    [super encodeWithQuickCoder:encoder];
    
    [encoder encodeObject:_path];
    [encoder encodeDouble:_creationDate];
    [encoder encodeDouble:_accessDate];
}

@end

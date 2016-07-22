//
//  SWImageDescriptor.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 7/10/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWImageDescriptor.h"

@implementation SWImageDescriptor


@synthesize originalPath = _originalPath;
@synthesize size = _size;
@synthesize contentMode = _contentMode;
@synthesize scale = _scale;


UIImage *EmptyImage;

+ (void)initialize
{
    EmptyImage = [[UIImage alloc] init];
}


- (id)initWithOriginalPath:(NSString*)path size:(CGSize)size contentMode:(UIViewContentMode)contentMode
{
    self = [self initWithOriginalPath:path size:size contentMode:contentMode contentScale:0];
    return self;
}


- (id)initWithOriginalPath:(NSString*)path size:(CGSize)size contentMode:(UIViewContentMode)contentMode contentScale:(CGFloat)scale
{
    self = [super init];
    if ( self )
    {
        _originalPath = path;
        _size = size;
        _contentMode = contentMode;
        if ( scale == 0 ) scale = [[UIScreen mainScreen] scale];
        _scale = scale;
    }
    return self;
}


- (id)initWithOriginalImage:(UIImage*)image uuid:(NSString*)uuid
{
    self = [super init];
    if (self)
    {
        _originalPath = uuid;
        _contentImage = image;
        if ( image == nil ) _contentImage = EmptyImage;  // <- indica que es tracta de un descriptor referenciat per uuid
        _size = CGSizeZero;
        _contentMode = UIViewContentModeCenter;
        _scale = [[UIScreen mainScreen] scale];
    }
    return self;
}

#pragma mark Overriden Methods

- (NSString*)description
{
    return [NSString stringWithFormat:@"[%@, <OriginalPath:%@>, <size:%@>, <contentMode:%ld>, <scale:%g>]",
        [super description], [_originalPath description] /*.lastPathComponent*/, NSStringFromCGSize(_size), _contentMode, _scale];
}

- (BOOL)isEqual:(SWImageDescriptor*)object
{
    if (object == self)
        return YES;
    
    if (![_originalPath isEqualToString:object.originalPath])
        return NO;
    
    if (_contentMode != object.contentMode)
        return NO;
    
    if ( _scale != object.scale )
        return NO;
    
    if ( !CGSizeEqualToSize(_size, object.size) )
        return NO;
    
    return YES;
}


- (NSUInteger)hash
{
    return [_originalPath hash] + 17*(int)_size.width + 31*(int)_size.height + 23*_contentMode;
}

#pragma mark QuickCoding

- (id)initWithQuickCoder:(QuickUnarchiver *)decoder
{
    self = [super init];
    if (self)
    {
        _originalPath = [decoder decodeObject];
        _size = CGSizeMake([decoder decodeFloat], [decoder decodeFloat]);
        _contentMode = [decoder decodeInt];
        _scale = [decoder decodeFloat];
        _hasPriority = [decoder decodeInt];
    }
    return self;
}

- (void)encodeWithQuickCoder:(QuickArchiver *)encoder
{
    [encoder encodeObject:_originalPath];
    [encoder encodeFloat:_size.width];
    [encoder encodeFloat:_size.height];
    [encoder encodeInt:_contentMode];
    [encoder encodeFloat:_scale];
    [encoder encodeInt:_hasPriority];
}

@end

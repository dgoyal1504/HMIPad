//
//  SWEvent.m
//  HmiPad
//
//  Created by Joan Martin on 8/7/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWEvent.h"

@implementation SWEvent

@synthesize holder = _holder;
@synthesize active = _active;
@synthesize acknowledged = _acknowledged;
@synthesize timeStamp = _timeStamp;
@synthesize labelText = _labelText;
@synthesize commentText = _commentText;

- (id)initWithHolder:(id<SWEventHolder>)holder
{
    self = [super init];
    if (self)
    {
        _holder = holder;
        //_active = YES;
        _active = [holder activeStateForEvent];
        _acknowledged = NO;
        _timeStamp = CFAbsoluteTimeGetCurrent();
        _labelText = [holder titleForEvent];
        _commentText = [holder commentForEvent];
    }
    return self;
}

- (id)initWithLabel:(NSString*)labelText comment:(NSString*)commentText
{
    self = [self initWithLabel:labelText comment:commentText active:YES];
    return self;
}


- (id)initWithLabel:(NSString*)labelText comment:(NSString*)commentText active:(BOOL)active
{
    self = [self initWithLabel:labelText comment:commentText active:active timeStamp:CFAbsoluteTimeGetCurrent()];
    return self;
}

- (id)initWithLabel:(NSString*)labelText comment:(NSString*)commentText active:(BOOL)active timeStamp:(CFAbsoluteTime)timeStamp
{
    self = [super init];
    if ( self )
    {
        _holder = nil;
        _active = active;
        _acknowledged = NO;
        _timeStamp = timeStamp;
        _labelText = labelText;
        _commentText = commentText;
    } 
    return self;
}

//#pragma mark - QuickCoding
//
//- (id)initWithQuickCoder:(QuickUnarchiver *)decoder
//{
//    self = [super init];
//    if (self)
//    {
//        _holder = [decoder decodeObject];
//        _active = [decoder decodeInt];
//        _acknowledged = [decoder decodeInt];
//        _timeStamp = [decoder decodeDouble];
//        _labelText = [decoder decodeObject];
//        _commentText = [decoder decodeObject];
//    }
//    return self;
//}
//
//- (void)encodeWithQuickCoder:(QuickArchiver *)encoder
//{
//    [encoder encodeObject:_holder];
//    [encoder encodeInt:_active];
//    [encoder encodeInt:_acknowledged];
//    [encoder encodeDouble:_timeStamp];
//    [encoder encodeObject:_labelText];
//    [encoder encodeObject:_commentText];
//}
//
//- (void)retrieveWithQuickCoder:(QuickUnarchiver *)decoder
//{
//    [decoder retrieveForObject:_holder];
//    _active = [decoder decodeInt];
//    _acknowledged = [decoder decodeInt];
//    _timeStamp = [decoder decodeDouble];
//    _labelText = [decoder decodeObject];
//    _commentText = [decoder decodeObject];
//}
//
//- (void)storeWithQuickCoder:(QuickArchiver *)encoder
//{
//    //[encoder encodeObject:_holder];
//    [encoder encodeInt:_active];
//    [encoder encodeInt:_acknowledged];
//    [encoder encodeDouble:_timeStamp];
//    [encoder encodeObject:_labelText];
//    [encoder encodeObject:_commentText];
//}
//
//
//#pragma mark Symbolic Coding
//
//- (id)initWithSymbolicCoder:(SymbolicUnarchiver *)decoder identifier:(NSString *)ident parentObject:(id<SymbolicCoding>)parent
//{
//    return [super init];
//}
//
//- (void)encodeWithSymbolicCoder:(SymbolicArchiver *)encoder
//{
//}
//
//- (void)retrieveWithSymbolicCoder:(SymbolicUnarchiver *)decoder identifier:(NSString *)ident parentObject:(id<SymbolicCoding>)parent
//{
//    _active = [decoder decodeIntForKey:@"active"];
//    _acknowledged = [decoder decodeIntForKey:@"acknowledged"];
//    _timeStamp = [decoder decodeDoubleForKey:@"timeStamp"];
//    _labelText = [decoder decodeStringForKey:@"labelText"];
//    _commentText = [decoder decodeStringForKey:@"commentText"];
//}
//
//- (void)storeWithSymbolicCoder:(SymbolicArchiver *)encoder
//{
//    [encoder encodeInt:_active forKey:@"active"];
//    [encoder encodeInt:_acknowledged forKey:@"acknowledged"];
//    [encoder encodeDouble:_timeStamp forKey:@"timeStamp"];
//    [encoder encodeString:_labelText forKey:@"labelText"];
//    [encoder encodeString:_commentText forKey:@"commentText"];
//}


#pragma mark - Properties

- (void)setActive:(BOOL)value
{
    if ( value )
        _timeStamp = CFAbsoluteTimeGetCurrent();
    
    _active = value;
}

#pragma mark - Public Methods

- (NSString *)getTimeStampString
{
    static CFDateFormatterRef staticDateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
            staticDateFormatter = CFDateFormatterCreate( NULL, NULL, kCFDateFormatterNoStyle, kCFDateFormatterNoStyle );
            CFDateFormatterSetFormat( staticDateFormatter, CFSTR("yy-MM-dd HH:mm:ss") );
        });

    //CFDateFormatterRef dateFormatter = CFDateFormatterCreate( NULL, NULL, kCFDateFormatterNoStyle, kCFDateFormatterNoStyle );
    //CFDateFormatterSetFormat( dateFormatter, CFSTR("yyyy-MM-dd HH:mm:ss ZZ") );
    //CFDateRef date = CFDateCreate(NULL, _timeStamp);
    //CFStringRef dateFormatterStr = CFDateFormatterCreateStringWithDate( NULL, dateFormatter, date );
    
    CFStringRef dateFormatterStr = CFDateFormatterCreateStringWithAbsoluteTime(NULL, staticDateFormatter, _timeStamp);
    return CFBridgingRelease(dateFormatterStr);
    
//    //CFStringRef dateCFStr = CFStringCreateWithSubstring(NULL, dateFormatterStr, CFRangeMake(2, 17));
//    
//    //NSString *dateStr = [(__bridge NSString*)dateFormatterStr substringWithRange:NSMakeRange(2, 17)];
//    
//    //CFRelease( dateFormatter );
//    //CFRelease( date );
//    CFRelease( dateFormatterStr );
//    
//    NSString *dateStr = (__bridge NSString*)dateCFStr;
//    CFRelease( dateCFStr );
//    
//    return dateStr;
}

@end

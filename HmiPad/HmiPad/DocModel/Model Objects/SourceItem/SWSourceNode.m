//
//  SWSourceNode.m
//  HmiPad
//
//  Created by Joan on 22/08/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWPropertyDescriptor.h"
#import "SWSourceNode.h"
#import "SWReadExpression.h"
#import "SWPlcTag.h"
#import "SWSourceItem.h"
#import "RpnBuilder.h"

//#define SOURCE_NODE_LOGS
#ifdef SOURCE_NODE_LOGS
    #define NSLog1(args...) NSLog(args)
#else
    #define NSLog1(...) {}
#endif 

@implementation SWSourceNode

@synthesize sourceItem = _sourceItem ;
@synthesize name = _name ;
@synthesize plcTag = _plcTag ;
@synthesize readExpression = _readExpression ;
@synthesize writeExpression = _writeExpression ;
@synthesize timeStamp = _timeStamp ;
@synthesize tagErrNum = _tagErrNum ;

static SWPropertyDescriptor *_writeExpressionDescriptor = nil;


+ (void)initialize
{
    _writeExpressionDescriptor = [SWPropertyDescriptor propertyDescriptorWithName:@"write_expression" type:SWTypeAny
        propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithDouble:0]];
}


-(id)initWithSourceItem:(SWSourceItem*)sourceItem
{
    self = [super init];
    if ( self )
    {
        _sourceItem = sourceItem;
    }
    return self;
}

- (void)dealloc
{
    NSLog1( @"sourceNode dealloc: %@", _readExpression.fullReference);
    [_readExpression invalidate];
    [_writeExpression invalidate];
    [_plcTag setItem:nil];   // <-- El PlcTag ens guarda com a referencia __unsafe_unretained, o sigui que hem de resetejar-lo a nil explicitament aqui.
}

- (void)setPlcTag:(SWPlcTag *)plcTag
{
    [_plcTag setItem:nil];
    _plcTag = plcTag;
    [_plcTag setItem:self];
}

- (void)setReadExpression:(SWReadExpression *)readExpression
{
    _readExpression = readExpression;
    _readExpression.node = self;
}


//- (SWSourceNode*)commRetain
//{
//    if ( _commRetainCount == 0 )
//    {
//        [_sourceItem _tagsSetAddTag:_plcTag];
//    }
//    _commRetainCount += 1;
//    
//    NSLog( @"commRetain:%d :%@", _commRetainCount, self ) ;
//    return self;
//}
//
//- (void)commRelease
//{
//    //NSAssert(_commRetainCount>0, @"commRelease over release!");
//    
//    _commRetainCount -= 1;
//    if ( _commRetainCount == 0 )
//    {
//        [_sourceItem _tagsSetRemoveTag:_plcTag];
//    }
//    
//    NSLog( @"commRelease:%d :%@", _commRetainCount, self ) ;
//}


#pragma mark - QuickCoding

- (id)initWithQuickCoder:(QuickUnarchiver *)decoder
{
    self = [super init];
    if (self) 
    {
        _sourceItem = [decoder decodeObject];
        _name = [decoder decodeObject];
        _plcTag = [decoder decodeObject];
        [_plcTag setItem:self];
        SWReadExpression *readExp = [decoder decodeObject];
        [self setReadExpression:readExp];
        _writeExpression = [decoder decodeObject];
        _timeStamp = [decoder decodeDouble];
        _tagErrNum = [decoder decodeInt];    
    }
    return self;
}

- (void)encodeWithQuickCoder:(QuickArchiver *)encoder
{
    [encoder encodeObject:_sourceItem];
    [encoder encodeObject:_name];
    [encoder encodeObject:_plcTag];
    [encoder encodeObject:_readExpression];
    [encoder encodeObject:_writeExpression];
    [encoder encodeDouble:_timeStamp];
    [encoder encodeInt:_tagErrNum];
}


#pragma mark - SymbolicCoding

-(id)initWithSymbolicCoder:(SymbolicUnarchiver *)decoder identifier:(NSString*)ident parentObject:(SWSourceItem*)parent
{
    self = [super init];
    if (self) 
    {
        _sourceItem = parent;
        _name = [decoder decodeStringForKey:@"name"];
        _plcTag = [decoder decodeObjectForKey:@"tag"];
        [_plcTag setItem:self];
        
        _writeExpression = [decoder decodeExpressionForKey:@"write_expression"];
        
        SWReadExpression *readExp = [[SWReadExpression alloc] initWithDouble:0];
        [readExp setHolder:parent];  // el holder es el sourceItem
        [self setReadExpression:readExp];
        
        [[decoder builder] registerExpressionForCommit:_readExpression];
    }
    return self;
}

-(void)encodeWithSymbolicCoder:(SymbolicArchiver *)encoder 
{
    [encoder encodeString:_name forKey:@"name"];
    [encoder encodeObject:_plcTag forKey:@"tag"];
    [encoder encodeValue:_writeExpression forKey:@"write_expression"];
}


#pragma mark - ExpressionHolder

// la expressio de escritura no s'utilitza ni es accesible com a source d'altres
// per tant alguns dels metodes seguents, tot i que son required no es cridaran mai,
// altres s'implementen per el retorn appropiat de fullReference durant el report de errors

- (SWValue *)valueWithSymbol:(NSString *)sym property:(NSString *)prop
{
    return nil;
}

- (NSString *)symbolForValue:(SWValue*)value
{
    return [NSString stringWithFormat:@"%@<%@>", _sourceItem.identifier, _name];
}

- (NSString *)propertyForValue:(SWValue*)value
{
    return _writeExpressionDescriptor.name;
}

- (NSString *)identifier
{
    return nil;
}

- (SWPropertyDescriptor*)valueDescriptionForValue:(SWValue*)value
{
    return _writeExpressionDescriptor;
}

// ens interesa coneixer la execucio de la expressio d'escritura
- (void)value:(SWExpression*)expression didTriggerWithChange:(BOOL)changed
{
    // evitem escriure si el canvi ve de la propagacio de la propia readExpression
    BOOL isPromoting = [_readExpression isPromoting];
    if ( isPromoting ) return;
    
    // evitem escriure si el canvi ve de la descodificacio (ex paste, duplicate, open)
    BOOL isDecoding = [_sourceItem.builder isCommitingWithMoveToGlobal];
    if ( isDecoding ) return;
    
    // evitem escriure si el canvi ve de una promocio d'error
    ExpressionStateCode state = [expression state] ;
    if ( state != ExpressionStateOk ) return ;
    
    NSLog1( @"Node Write SWExpressiontrigger, Name:%@ Value:%@", _name, expression.valueAsString );
    
    CFDataRef values = NULL;
    CFArrayRef texts = NULL;
    
    // en funcio del tipus de plcTag enviar la dada al PlcTag
    
    if ( [_plcTag isNumeric] )
        values = [_writeExpression createDataWithValuesAsDoubles];
    else
        texts = [_writeExpression createArrayWithValuesAsStringsWithFormat:nil];
    
    [_sourceItem _wTagsSetAddTag:_plcTag values:values texts:texts];
    
    if ( values ) CFRelease( values );
    if ( texts ) CFRelease( texts );
}


//- (BOOL)resultIsInvalid
//{
//    return [_readExpression resultIsInvalid];
//}

- (NSString *)tagErrorString
{
    NSString *errorStr = nil;
    //BOOL invalid = [_readExpression resultIsInvalid];
    BOOL invalid = (_readExpression.state != ExpressionStateOk);
    if ( invalid )
    {
    
        if ( _sourceItem.monitorOn )
        {
            if ( _sourceItem.plcObjectLinked )
            {
                UInt8 plcError = _plcTag->errNum;
                
                if ( plcError )
                {
                    errorStr = [_plcTag infoStringForErrNum:plcError];
                }
                else
                {
                       //errorStr = [_readExpression getResultErrorString];
                       //errorStr = @"loading...";
                    // res
                }
            }
            else
            {
                errorStr = NSLocalizedString(@"NoActiveConnection", nil);
            }
        }
        else 
        {
            errorStr = NSLocalizedString(@"MonitorSwitchedOff", nil);
        }
    }    
    return errorStr;
}

- (BOOL)matchesSearchWithString:(NSString*)searchString
{
    NSComparisonResult result1 = [_name compare:searchString
                                        options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)
                                          range:NSMakeRange(0, [searchString length])];
    
    NSComparisonResult result2 = [_plcTag.addressAsString compare:searchString
                                                          options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)
                                                            range:NSMakeRange(0, [searchString length])];
    
    return  (result1 == NSOrderedSame) || (result2 == NSOrderedSame);
}

@end



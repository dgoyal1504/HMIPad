//
//  AppModelSource.m
//  HmiPad
//
//  Created by Joan Lluch on 31/03/14.
//  Copyright (c) 2014 SweetWilliam, SL. All rights reserved.
//

#import "AppModelSource.h"

#import "AppModelFilePaths.h"
#import "AppModelDocument.h"

#import "Quickcoder.h"


#define SWProjectSourcesVersion 3

@implementation AppModelSource

#define SWSourceNameKey "name"
#define SWSourceFlagKey "rd"

+ (NSMutableArray *)_defaultSources
{
    NSMutableArray *defSources = [[NSMutableArray alloc] initWithObjects:
    
    #if HMiPadDev
        //@"Example-ControlsSuite.hmipad",
        @"Example-Promotional.hmipad",
    #endif
    
    nil ] ;
    return defSources ;
}


- (id)initWithLocalFilesModel:(AppModel*)filesModel
{
    self = [super init];
    if ( self )
    {
        _filesModel = filesModel;
        _observers = CFBridgingRelease(CFArrayCreateMutable(NULL, 0, NULL));
    }
    return self;
}


//- (void)setDispatchQueue:(dispatch_queue_t)dQueue key:(const char *)key
//{
//    _queueKey = key;
//    _queueContext = dispatch_queue_get_specific(dQueue, key);
//    _dQueue = dQueue;
//}


- (void)_notifySourcesChange
{
    for ( id<AppModelSourceObserver>observer in _observers )
    {
        if ( [observer respondsToSelector:@selector(appsFileModelSourcesDidChange:)])
        {
            [observer appsFileModelSourcesDidChange:self];
        }
    }
}


#pragma mark - File Document observation

- (void)addObserver:(id<AppModelSourceObserver>)observer
{
    [_observers addObject:observer];
}

- (void)removeObserver:(id<AppModelSourceObserver>)observer
{
    [_observers removeObjectIdenticalTo:observer];
}


#pragma mark - Methods

- (NSArray *)_projectSources
{
    if ( _projectSources == nil )
    {
        [self _loadSourcesFromDiskOutError:NULL] ;
    }
    return _projectSources;
}


- (NSArray*)getProjectSources
{
    [self _projectSources];

    NSMutableArray *sourceStrings = [NSMutableArray array];
    
    for ( NSDictionary *dict in _projectSources )
    {
        NSNumber *rd = [dict objectForKey:@SWSourceFlagKey];
        NSInteger rdValue = [rd integerValue];
        if ( rdValue != 0 )
        {
            NSString *name = [dict objectForKey:@SWSourceNameKey];
            [sourceStrings addObject:name];
        }
    }

    return sourceStrings;
}


- (void)setProjectSources:(NSArray*)newSources
{
    if ( _projectSources == newSources ) return ;
    
    [self _primitiveSetProjectSources:newSources withFlag:SWDefaultSourceFlagValue];
    
    [_filesModel.fileDocument closeDocumentWithCompletion:nil];  // this is synchronous
    [_filesModel.fileDocument openDocumentWithCompletion:^(BOOL success)
    {
        [self _notifySourcesChange];
    }];
}



- (void)projectSource:(NSString*)source setFlag:(NSInteger)flag
{
    NSArray *sources = [self _projectSources];
    NSMutableArray *sourceDicts = [NSMutableArray array];
    
    NSInteger count = sources.count;
    for ( NSInteger i = 0 ; i<count ; i++  )
    {
        NSDictionary *dict = [sources objectAtIndex:i];
        NSString *name = _dict_objectForKey(dict, @SWSourceNameKey);
        if ( [name isEqualToString:source] )
            dict = @{@SWSourceNameKey:name,@SWSourceFlagKey:@(flag)};
        
        [sourceDicts addObject:dict];
    }
    
    [self _primitiveSetSourceDicts:sourceDicts];
}


- (NSInteger)projectSourceGetFlag:(NSString*)source
{
    NSInteger flag = 0;
    NSArray *sources = [self _projectSources];
    
    NSInteger count = sources.count;
    for ( NSInteger i = 0 ; i<count ; i++  )
    {
        NSDictionary *dict = [sources objectAtIndex:i];
        NSString *name = _dict_objectForKey(dict, @SWSourceNameKey);
        if ( [name isEqualToString:source] )
        {
            NSNumber *nFlag = _dict_objectForKey(dict, @SWSourceFlagKey );
            flag = [nFlag integerValue];
            break;
        }
    }
    
    return flag;
}


- (NSString*)exclusiveProjectSource
{
    NSDictionary *dict = nil;
    [self _projectSources];
    if ( _projectSources.count == 1 )
        dict = [_projectSources objectAtIndex:0];
    
    NSString *source = nil;
    
    NSNumber *flag = _dict_objectForKey(dict, @SWSourceFlagKey );
    if ( [flag integerValue] != 0 )
        source = _dict_objectForKey(dict, @SWSourceNameKey);
        
    return source;
}


#pragma mark - Private




- (void)_primitiveSetProjectSources:(NSArray*)newSources withFlag:(NSInteger)flag
{
    NSMutableArray *sourceDicts = [NSMutableArray array];
    
    for ( NSString *name in newSources )
    {
        NSDictionary *dict = @{@SWSourceNameKey:name,@SWSourceFlagKey:@(flag)};
        [sourceDicts addObject:dict];
    }
    
    [self _primitiveSetSourceDicts:sourceDicts];
}


- (void)_primitiveSetSourceDicts:(NSArray*)sourceDicts
{
    _projectSources = sourceDicts;
    
    NSError *error ;
    if ( [self _saveSourcesToDiskOutError:&error] == NO )  //gestioerror
    {
        NSLog1( @"Error: Could not save Sources" ) ;
    }
}





- (NSString *)_sourcesFilePath
{
	NSString *rootPath = [_filesModel.filePaths internalFilesDirectory] ;
    NSString *filePath = [rootPath stringByAppendingPathComponent:@"sources.swq"];
    return filePath ;
}


- (BOOL)_loadSourcesFromDiskOutError:(NSError**)outError
{
    NSLog1( @"Model loadSourcesFromDisk" ) ;

    // alliberem els sources actuals doncs en crearem uns de nous
    //[sources release];
    _projectSources = nil ;
    
    // admetem NULL com a entrada de outError, per tant en creem un de temporal
    NSError *error = nil ;
    
    // paths check
    NSString *fileName = [self _sourcesFilePath] ;
    
    if ( fileName != nil )
    {  
        NSData *dataArchive = [[NSData alloc] initWithContentsOfFile:fileName options:0 error:&error];
        
        // read chek
        if ( dataArchive )
        {
            QuickUnarchiver *unarchiver = [[QuickUnarchiver alloc] initForReadingWithData:dataArchive];
            int version = [unarchiver version] ;
            if ( version == SWProjectSourcesVersion )
            {
                _projectSources = [unarchiver decodeObject]; // a la versio >=200 hauria de tornar un mutablearray
            }
                
            // unarchive check
            if ( _projectSources )
            {
                // tornem ara mateix
                return YES ;
            }
                
            NSString *errMsg = NSLocalizedString(@"Inconsistent or corrupted sources file", nil) ;
            NSDictionary *info = [NSDictionary dictionaryWithObject:errMsg forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:@"com.SweetWilliam.ScadaMobile" code:2 userInfo:info];
        }
    }
    
    // si som aqui es que ho hem pogut crear els sources a partir de fitxer
    
    // crea els sources per defecte
    NSArray *defaultSources = [[self class] _defaultSources] ;
    [self _primitiveSetProjectSources:defaultSources withFlag:SWDefaultSourceFlagValue];
    
    // actualitza el error si no es NULL i torna NO    
    if ( outError != NULL ) *outError = error ;
    return NO;
}


- (BOOL)_saveSourcesToDiskOutError:(NSError**)outError
{
    NSLog1( @"Model saveSourcesToDisk" ) ;
    NSString *fileName = [self _sourcesFilePath] ;
    
    // paths check
    if ( fileName != nil )
    {  
        // write
        NSMutableData *dataArchive = [[NSMutableData alloc] init] ;

        QuickArchiver *archiver = [[QuickArchiver alloc] initForWritingWithMutableData:dataArchive version:SWProjectSourcesVersion] ;
        [archiver encodeObject:_projectSources] ;
        [archiver finishEncoding] ;
        
        BOOL didWrite = [dataArchive writeToFile:fileName options:NSAtomicWrite error:outError] ;
        
        // write check
        if ( didWrite )
        {
            return YES ;
        }
    }
    
    // create a suitable NSError object to return in outError
    return NO;
}


- (void)_deleteSourcesFromDisk
{
    NSString *fileName = [self _sourcesFilePath] ;
    NSError *error ;
    [[NSFileManager defaultManager] removeItemAtPath:fileName error:&error] ;    //gestioerror
}



@end

//
//  HTTPServerSubclass.m
//  ScadaMobile_100704b
//
//  Created by Joan on 08/07/10.
//  Copyright 2010 SweetWilliam, S.L. All rights reserved.
//

#import "HTTPServerSubclass.h"
#import "HTTPConnectionSubclass.h"

#import "Reachability.h"

#import "AppModelFilePaths.h"
#import "UserDefaults.h"

NSString *kHTTPServerReachabilityErrorNotification = @"HTTPServerReachabilityErrorNotification" ;
NSString *kHTTPServerServiceDidPublishNotification = @"HTTPServerServiceDidPublishNotification" ;
NSString *kHTTPServerServiceDidNotPublishNotification = @"HTTPServerServiceDidNotPublishNotification" ;
NSString *kHTTPServerDidExecuteStartNotification = @"HTTPServerDidExecuteStartNotification" ;
NSString *kHTTPServerDidStopNotification = @"HTTPServerDidStopNotification" ;

//----------------------------------------------------------------------------------------
@implementation HTTPServerSubclass

//----------------------------------------------------------------------------------------
//- (id)initWithOwner:(id<HTTPServerSubclassOwner>)owner reachability:(Reachability*)aReach;
- (id)init
{
    if ( (self = [super init]) )
    {
        reachability = [Reachability sharedReachability] ;
        isStarted = NO ;
    
        [self setPort:8080] ;   // en posem un per defecte, al enjegar agafem el de preferencies
        [self setType:@"_http._tcp."] ;
        [self setConnectionClass:[HTTPConnectionSubclass class]];
        
        NSString *root = [filesModel().filePaths documentsDirectoryPath] ;
        [self setDocumentRoot:[NSURL fileURLWithPath:root]];
    }
    return self ;
}

//----------------------------------------------------------------------------------------
- (HTTPConfig *)config
{
	// Override me if you want to provide a custom config to the new connection.
	// 
	// Generally this involves overriding the HTTPConfig class to include any custom settings,
	// and then having this method return an instance of 'MyHTTPConfig'.
	
	// Note: Think you can make the server faster by putting each connection on its own queue?
	// Then benchmark it before and after and discover for yourself the shocking truth!
	// 
	// Try the apache benchmark tool (already installed on your Mac):
	// $  ab -n 1000 -c 1 http://localhost:<port>/some_path.html
    
    
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
	return [[HTTPConfig alloc] initWithServer:self documentRoot:documentRoot queue:mainQueue];
}

//----------------------------------------------------------------------------------------
- (void)dealoc
{
   // [super dealloc] ;
}

//----------------------------------------------------------------------------------------
- (BOOL)isStarted
{
    return isStarted ;
}

//-----------------------------------------------------------------------------
// Torna un error indicant que no hi ha reachabilitat local

- (NSError *)reachabilityError
{
    NSString *errMsg = NSLocalizedString(@"HTTPServerWifiReachabilityError", nil) ;
    NSDictionary *info = [NSDictionary dictionaryWithObject:errMsg forKey:NSLocalizedDescriptionKey];
    return [NSError errorWithDomain:@"SWReachabilityDomain" code:1 userInfo:info];
}


//-----------------------------------------------------------------------------
// Notifica de un error de reachabilitat
- (void)notifyError:(NSError *)error
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter] ;
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:error forKey:@"error"] ;
    [nc postNotificationName:kHTTPServerReachabilityErrorNotification object:self userInfo:userInfo] ;
}


//-----------------------------------------------------------------------------
// Es cridada quan canvia la reachabilitat
- (void)reachabilityChangedNotification:(NSNotification *)notification
{
    // sabem que el objecte es el mateix que el que retenim per la manera que ens hem 
    // subscrit, pero no esta de mes una comprovacio
    NSAssert( reachability == [notification object], @"L'objecte reachabilitat no es el mateix?!" ) ;
    
    // busquem els estats
    ReachabilityStatus status = [reachability status] ;
    
    // si ara no tenim wifi local pleguem
    if ( status != kWiFiReachability )
    {
	    NSError *error = [self reachabilityError] ;
    	[self notifyError:error] ;
        [self stop] ;
    }
}


//----------------------------------------------------------------------------------------
- (BOOL)start:(NSError **)outError
{
    // si no hi ha reachabilitat local immediata generem un error i tornem que no
    // si n'hi ha ens registrem per notificacions no fos que es perdi
    NSError *error = nil ;
    if ( isStarted ) return YES ;
    
    if ( reachability && [reachability status] == kWiFiReachability )
    {
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter] ;
        [nc addObserver:self selector:@selector(reachabilityChangedNotification:) name:kReachabilityChangedNotification object:reachability] ;
    
        UInt16 thePort = [[defaults() fileServerPort] intValue] ;
        [self setPort:thePort] ; // agafem el port especificat a preferencies
        isStarted = [super start:&error] ;
    
        NSDictionary *userInfo = nil ;
        if ( !isStarted && error ) userInfo = [NSDictionary dictionaryWithObject:error forKey:@"error"] ;
        [nc postNotificationName:kHTTPServerDidExecuteStartNotification object:self userInfo:userInfo] ;
    }
    else
    {          
        isStarted = NO ;
        error = [self reachabilityError] ;
        [self notifyError:error] ;
    }
    
    if ( outError ) *outError = error ;
    return isStarted ;
}


//----------------------------------------------------------------------------------------
- (void)stop
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    if ( reachability ) [nc removeObserver:self] ;
    
    if ( isStarted )
    {
        isStarted = NO ;
      
        [nc postNotificationName:kHTTPServerDidStopNotification object:self] ;
    }
    [super stop] ;  
    return ;
}

//----------------------------------------------------------------------------------------
/**
 * Called when our bonjour service has been successfully published.
 * This method does nothing but output a log message telling us about the published service.
**/
- (void)netServiceDidPublish:(NSNetService *)ns
{
	// Simplement notifica els observadors
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter] ;
    [nc postNotificationName:kHTTPServerServiceDidPublishNotification object:self] ;
}

//----------------------------------------------------------------------------------------
/**
 * Called if our bonjour service failed to publish itself.
 * This method does nothing but output a log message telling us about the published service.
**/
- (void)netService:(NSNetService *)ns didNotPublish:(NSDictionary *)errorDict
{
	// Simplement notifica els observadors
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter] ;
    [nc postNotificationName:kHTTPServerServiceDidNotPublishNotification object:self] ;
}

@end


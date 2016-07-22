//
//  AppModelCommon.m
//  HmiPad
//
//  Created by Joan on 05/05/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import "AppModelCommon.h"
#import "SWBlockAlertView.h"

@import CloudKit;

#pragma mark - File extensions

NSString *SWFileTypeBinary                  = @"com.sweetwilliam.hmipad.smb";
NSString *SWFileTypeSymbolic                = @"com.sweetwilliam.hmipad.smst";
NSString *SWFileExtensionBinary             = @"smb";
NSString *SWFileExtensionSymbolic           = @"smst";

NSString *SWFileTypeWrappBinary             = @"com.sweetwilliam.hmipad.bin.hmipad";
NSString *SWFileTypeWrappSaveSymbolic       = @"com.sweetwilliam.hmipad.sym.hmipad";
NSString *SWFileTypeWrappSaveThumbnail      = @"com.sweetwilliam.hmipad.thu.hmipad";
NSString *SWFileExtensionWrapp              = @"hmipad";

NSString *SWFileTypeWrappValuesBinary       = @"com.sweetwilliam.hmipad.valuesbin.hmipad";
NSString *SWFileTypeWrappValuesSymbolic     = @"com.sweetwilliam.hmipad.valuessym.hmipad";

NSString *SWFileKeyWrappBinary              = @"binary";
NSString *SWFileKeyWrappSymbolic            = @"symbolic";
NSString *SWFileKeyWrappEncryptedSymbolic   = @"rsymbolic";
NSString *SWFileKeyWrappThumbnail           = @"thumbnail.png";

NSString *SWFileKeyWrappValuesBinary        = @"valuesbinary";
NSString *SWFileKeyWrappValuesSymbolic      = @"valuessymbolic";
NSString *SWFileKeyWrappValuesEncryptedSymbolic      = @"rvaluessymbolic";

NSString *SWFileExtensionActivationCode     = @"hmipadcode";


# pragma mark - Dictionary

id _dict_objectForKey(NSDictionary* fileDict, NSString* key)
{
    id value = nil;
    if ( [fileDict isKindOfClass:[NSDictionary class]] )
    {
        value = [fileDict objectForKey:key];
        if ( value == [NSNull null] ) value = nil;
    }
    return value;
}


# pragma mark - Errors

//NSError *_completeErrorWithError_title( NSError *error, NSString *title)
//{
//    if ( title != nil && error != nil )
//    {
//        NSString *message = [error localizedDescription];
//        NSString *ok = NSLocalizedString( @"Ok", nil );
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:ok, nil];
//        [alert show];
//    }
//    return error;
//}


NSError *_completeErrorWithError_title( NSError *error, NSString *title)
{
    if ( title != nil && error != nil )
    {
        NSString *message = [error localizedDescription];
        NSString *ok = NSLocalizedString( @"Ok", nil );

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *actionOk = [UIAlertAction actionWithTitle:ok style:UIAlertActionStyleDefault handler:nil];
        
        [alert addAction:actionOk];
        
        UIViewController *topPresentedController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    
        UIViewController *controller=nil;
        while ( (controller=topPresentedController.presentedViewController) != nil )
            topPresentedController = controller;
        
        [topPresentedController presentViewController:alert animated:YES completion:nil];
    }
    return error;
}


NSError *_errorWithLocalizedDescription_title( NSString *message, NSString *title)
{
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey:message};
    NSError *error = [[NSError alloc] initWithDomain:@"my" code:0 userInfo:userInfo];
    return _completeErrorWithError_title( error, title);
}


//void _errorWithLocalizedDescription_title_resultBlock( NSString *message, NSString *title, void (^result)(NSError *error) )
//{
//    if ( title != nil )
//    {
//        NSString *ok = NSLocalizedString( @"Ok", nil );
//        NSString *cancel = NSLocalizedString( @"Cancel", nil );
//        SWBlockAlertView *alert = [[SWBlockAlertView alloc] initWithTitle:title
//            message:message delegate:nil cancelButtonTitle:cancel otherButtonTitles:ok, nil];
//        
//        //alert.delegate = alert;
//        [alert setResultBlock:^(BOOL success, NSInteger index)
//        {
//            NSError *error = nil;
//            if ( !success )
//            {
//                NSDictionary *userInfo = @{NSLocalizedDescriptionKey:message};
//                error = [[NSError alloc] initWithDomain:@"my" code:0 userInfo:userInfo];
//            }
//            
//            if (result)
//                result( error );
//        }];
//
//        [alert show];
//    }
//}


void _errorWithLocalizedDescription_title_resultBlock( NSString *message, NSString *title, void (^result)(NSError *error) )
{
    if ( title != nil )
    {
        NSString *ok = NSLocalizedString( @"Ok", nil );
        NSString *cancel = NSLocalizedString( @"Cancel", nil );
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
        UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:cancel style:UIAlertActionStyleCancel handler:^(UIAlertAction *a)
        {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey:message};
            NSError *error = [[NSError alloc] initWithDomain:@"my" code:0 userInfo:userInfo];
    
            if (result)
                result( error );
        }];
        
        [alert addAction:actionCancel];
        
        UIAlertAction *actionOk = [UIAlertAction actionWithTitle:ok style:UIAlertActionStyleDefault handler:^(UIAlertAction *a)
        {
            if (result)
                result( nil );
        }];
        
        [alert addAction:actionOk];
        
        UIViewController *rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
        [rootViewController presentViewController:alert animated:YES completion:nil];
    }
}



NSError *_completeErrorFromResponse_json_withError_title_message( NSHTTPURLResponse *response, id JSON, NSError *error, NSString *title, NSString *message)
{
    NSInteger statusCode = [response statusCode];
    BOOL errorResponse = statusCode > 0 && (statusCode < 200 || statusCode >= 300);

    if ( errorResponse )
    {
        NSMutableString *errStr = [NSMutableString string];
        
        NSDictionary *jsonDict = JSON;
        if ( [jsonDict isKindOfClass:[NSDictionary class]] )
        {
            BOOL first = YES;
            for ( NSString *key in jsonDict )
            {
                if ( !first )
                    first = NO, [errStr appendString:@"\n"];
                
                NSString *msg = nil;
                
                NSString *dictMsg = _dict_objectForKey(jsonDict, key);
                if ( [dictMsg isKindOfClass:[NSArray class]]) dictMsg = [(NSArray*)dictMsg lastObject];
                if ( [dictMsg isKindOfClass:[NSString class]])
                {
                    if ( [key isEqualToString:@"username"] )
                    {
                        if ( [dictMsg hasPrefix:@"User with this Username"])
                            msg = NSLocalizedString( @"User with this Username already exists.", nil);
                    }
                    
                    else if ( [key isEqualToString:@"detail"] )
                    {
                        if ( [dictMsg hasPrefix:@"This Access Code may not be used"])
                            msg = NSLocalizedString( @"This Activation Code may not be used for further redemptions.", nil);
                        
                        if ( [dictMsg hasPrefix:@"Invalid token"])
                            msg = NSLocalizedString( @"Unknown User.", nil);
                    }
                    
                    else if ( [key isEqualToString:@"non_field_errors"] )
                    {
                        if ( [dictMsg hasPrefix:@"Unable to login with provided credentials"])
                            msg = NSLocalizedString( @"Unable to login with provided credentials.", nil);
                    
                    }
                }
                
                if ( msg )
                    [errStr appendFormat:@"%@\n", msg];
                else
                    [errStr appendFormat:@"%@: %@\n", key, dictMsg];
            }
        }
        else
        {
            errStr = [NSMutableString stringWithString:NSLocalizedString(@"Unknown Error",nil)];
        }
        
        if ( errStr.length > 0 || message.length > 0)
        {
            NSString *descr = errStr;
            NSString *reason = @"";
            if ( message.length > 0 )
            {
                descr = message;
                reason = errStr;
            }
        
            NSDictionary *userInfo = @
            {
                NSLocalizedDescriptionKey:descr,
                NSLocalizedFailureReasonErrorKey:reason,
            };
            
            error = [NSError errorWithDomain:@"HMiPad" code:0 userInfo:userInfo];
        }
        
//        if ( title != nil )
//        {
//            NSString *descr = [error localizedDescription];
//            NSString *ok = NSLocalizedString( @"Ok", nil );
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:descr delegate:nil cancelButtonTitle:nil otherButtonTitles:ok, nil];
//            [alert show];
//        }
        _completeErrorWithError_title(error, title);

    }
    
    NSLog1( @"completeErrorFromResponse Error:%@", error);
    return error;
}


NSError *_completeErrorFromResponse_json_withError_title( NSHTTPURLResponse *response, id JSON, NSError *error, NSString *title )
{
    return _completeErrorFromResponse_json_withError_title_message( response, JSON, error, title, nil);
}


#pragma mark - cloudKit

NSError *_completeErrorFromCloudKitError_message_title( NSError* operationError, NSString *message, NSString *title)
{
    NSDictionary *userInfo = [operationError userInfo];
    NSDictionary *partialErrors = [userInfo objectForKey:CKPartialErrorsByItemIDKey];
    NSString *partialErrorsStr = nil;
    if ( partialErrors.count > 0 )
    {
        NSError *oneError = partialErrors.allValues[0];
        NSString *format = @"At least %ld errors were found while processing data to iCloud, for example: \"%@\"";
        partialErrorsStr = [NSString stringWithFormat:format, partialErrors.count, oneError.localizedDescription];
    }
    else
    {
        partialErrorsStr = operationError.localizedDescription;
    }
    
    NSString *format = NSLocalizedString(@"%@. Reason: %@", nil );
    NSString *finalMessage = [NSString stringWithFormat:format, message, partialErrorsStr];
    NSError *error = _errorWithLocalizedDescription_title(finalMessage, title);

    return error;
}


#pragma mark - Atributs

NSString *fileSizeStrForSizeValue(unsigned long long size )
{
	NSString *sizeStr=nil ;
    if ( size < 1024*1024 ) sizeStr = [NSString stringWithFormat:@"%1.1f KB", (double)size/1024] ;
    else  sizeStr = [NSString stringWithFormat:@"%1.1f MB", (double)(size/1024)/1024] ;
	return sizeStr ;
}


BOOL fileExtensionIsProject(NSString *file)
{
    BOOL isSource = NO ; ;
    NSString *extension = [file pathExtension] ;
    isSource = isSource || ([extension caseInsensitiveCompare:SWFileExtensionWrapp] == NSOrderedSame) ;
    isSource = isSource || ([extension caseInsensitiveCompare:SWFileExtensionBinary] == NSOrderedSame) ;
    isSource = isSource || ([extension caseInsensitiveCompare:SWFileExtensionSymbolic] == NSOrderedSame) ;
    return isSource ;
}


BOOL fileExtensionIsImage(NSString *file)
{
    static NSArray *array = nil;

    if (!array)
        array = [NSArray arrayWithObjects:@"png",@"jpg",@"jpeg",@"gif",@"tif",@"tiff",@"bmp",@"bmpf",@"ico",@"cur",@"xbm",nil];
    
    NSString *extension = [file pathExtension];
    return [array containsObject:[extension lowercaseString]];
}


BOOL fileExtensionIsActivationCode(NSString *file)
{
    BOOL isSource = NO ; ;
    NSString *extension = [file pathExtension] ;
    isSource = isSource || ([extension caseInsensitiveCompare:SWFileExtensionActivationCode] == NSOrderedSame);
    return isSource ;
}


//BOOL fileFullPathIsWrappedSource(NSString *fullPath)
//{
//    BOOL isWrappedSource = NO ; ;
//    NSString *extension = [fullPath pathExtension] ;
//    if ( [extension caseInsensitiveCompare:SWFileExtensionWrapp] == NSOrderedSame)
//    {
//        NSFileManager *fileManager = [NSFileManager defaultManager];
//        NSDictionary *fileDict = [fileManager attributesOfItemAtPath:fullPath error:nil];
//        isWrappedSource = [[fileDict objectForKey:NSFileType] isEqualToString:NSFileTypeDirectory] ;
//    }
//    
//    return isWrappedSource ;
//}


BOOL fileFullPathIsWrappedSource(NSString *fullPath)
{
    BOOL isWrappedSource = NO ; ;
    NSString *extension = [fullPath pathExtension] ;
    if ( [extension caseInsensitiveCompare:SWFileExtensionWrapp] == NSOrderedSame)
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL isDirectory = NO;
        BOOL exists = [fileManager fileExistsAtPath:fullPath isDirectory:&isDirectory];
        isWrappedSource = exists && isDirectory;
    }
    
    return isWrappedSource ;
}



//
//  This class was created by Nonnus,
//  who graciously decided to share it with the CocoaHTTPServer community.
//

#import <Foundation/Foundation.h>
#import "HTTPConnection.h"


@interface HTTPConnectionSubclass : HTTPConnection
{
	int dataStartIndex;
    int tableRowIndex ;
	//NSMutableArray* multipartData;
    
	BOOL postHeaderOK;
    int postFileLocation ;
    int postContentKind ;
    int postResponseKind ;
    UInt64 postContentLength ;
    UInt64 postContentLenghtCounter ;
    NSMutableData *postSeparatorData;
    Byte *postSeparatorBytes ;
    int postSeparatorLength ;
    
    
    BOOL displayCompanyLogo ;
    BOOL resetCompanyLogo ;
    BOOL selectCompanyLogo ;
    
    NSString *postContentDispositionPart; 
    NSString *postContent ;    // a eliminar
    NSFileHandle *postFileHandle;
    //NSString *postDestinationPath;
    NSString *postFileName;
}

//- (BOOL)isBrowseable:(NSString *)path;
//- (NSString *)createBrowseableIndex:(NSString *)path;
//- (NSString *) createBrowseableIndex:(NSString *)path directoryName: (NSString *)dirName;


@end

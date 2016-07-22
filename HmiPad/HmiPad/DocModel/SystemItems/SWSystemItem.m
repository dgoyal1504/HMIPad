//
//  SWSystemItem.m
//  HmiPad
//
//  Created by Joan Martin on 9/3/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWSystemItem.h"

#import "SWPropertyDescriptor.h"
#import "SWSystemTable.h"

@implementation SWSystemItem

#pragma mark - Init and Properties

- (id)initInDocument:(SWDocumentModel*)docModel
{
    self = [super initInDocument:docModel];
    if (self)
    {
        // Nothing to do
    }
    return self;
}

//- (id)initForAddingToSystemTable:(SWSystemTable*)systemTable
//{
//    self = [super initInDocument:nil];
//    if (self)
//    {
//        NSArray *descriptions = [[self class] objectDescription].allPropertyDescriptions;
//        NSInteger count = _properties.count;
//        
//        for (int i=0 ; i<count ; i++)
//        {
//            SWPropertyDescriptor *descriptor = [descriptions objectAtIndex:i];
//            [systemTable symbolTableAddObject:self forKey:descriptor.name];
//        }
//    }
//    return self;
//}

#pragma mark Public Methods

- (void)addToSystemTable:(SWSystemTable*)systemTable
{
    NSArray *descriptions = [[self class] objectDescription].allPropertyDescriptions;
    NSInteger count = _properties.count;
    
    for ( int i=0 ; i<count ; i++ )
    {
        SWPropertyDescriptor *descriptor = [descriptions objectAtIndex:i];
        [systemTable symbolTableAddObject:self forKey:descriptor.name];
    }
}

#pragma mark Symbolic Coding

- (id)initWithSymbolicCoder:(SymbolicUnarchiver *)decoder identifier:(NSString*)ident parentObject:(SWDocumentModel*)parent
{
    // ATENCIO, les system expressions es un cas especial, no volem cridar el super,
    // volem que la cadena de execucio quedi tallada aqui
    return self;
}

- (void)encodeWithSymbolicCoder:(SymbolicArchiver *)encoder
{
    // ATENCIO, les system expressions es un cas especial, no volem cridar el super,
    // volem que la cadena de execucio quedi tallada aqui
}

#pragma mark Overriden Methods

- (BOOL)matchesSearchWithString:(NSString*)searchString
{
    NSString *cleanIdentifier = [self.identifier stringByReplacingOccurrencesOfString:@"$" withString:@""]; // <---- Comparem amb el identificador sense "$"
    NSComparisonResult result1 = [cleanIdentifier compare:searchString
                                                  options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)
                                                    range:NSMakeRange(0, [searchString length])];
    
    BOOL somePropertyFitsSearch = NO;
    SWObjectDescription *objectDescription = [self.class objectDescription];
    NSArray *array = objectDescription.allPropertyDescriptions;
    
    for (SWPropertyDescriptor *pd in array) // <---- Mirem el nom de totes les propietats per veure si alguna és valida
    {
        NSComparisonResult result = [pd.name compare:searchString
                                             options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)
                                               range:NSMakeRange(0, [searchString length])];
        
        if (result == NSOrderedSame)
        {
            somePropertyFitsSearch = YES;
            break;
        }
    }
    
    return  (result1 == NSOrderedSame) || somePropertyFitsSearch || [super matchesSearchWithString:searchString];
}


@end

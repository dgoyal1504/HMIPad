//
//  SWStructures.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 7/6/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

struct __Pair
{
    const void *ptr;
    int number;
};
typedef const struct __Pair Pair;


static const void* PairPtrForNumber( const Pair pairs[], int count, int number)
{
    for ( int i=0 ; i<count ; i++ )
        if ( pairs[i].number == number ) 
            return pairs[i].ptr;
    
    return NULL;
}

static NSString* PairStringForNumber( const Pair pairs[], int count, int number)
{
    NSString *str = (__bridge NSString*)PairPtrForNumber(pairs, count, number);
    return str;
}


static const int PairNumberForString( const Pair pairs[], int count, NSString *string )
{
    for ( int i=0 ; i<count ; i++ )
        if ( [(__bridge NSString*)pairs[i].ptr isEqualToString:string] ) 
            return pairs[i].number;
    
    return 0;
}


struct __Tuple
{
    Pair value;
    int key;
};
typedef const struct __Tuple Tuple;

static Pair PairForKey( const Tuple tuples[], int count, int key)
{
    for ( int i=0 ; i<count ; i++ )
        if ( tuples[i].key == key ) 
            return tuples[i].value;
            
    Pair pairZero = { NULL, 0 };
    return pairZero;
}

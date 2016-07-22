//
//  FinsProtocol.h
//  ScadaMobile_091014
//
//  Created by Joan on 14/10/09.
//  Copyright 2009 SweetWilliam, S.L.. All rights reserved.
//

#import "PlcProtocol.h"


@interface FinsProtocol : PlcProtocol<PlcProtocolProtocol>
{
    UInt8 clientNodeAddr ;    
    UInt8 serverNodeAddr ;
}

@end

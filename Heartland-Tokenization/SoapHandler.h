//
//  SoapHandler.h
//  SecureSubmit
//
//  Created by Roberts, Jerry on 7/10/14.
//  Copyright (c) 2014 Heartland Payment Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString *const PorticoDefaultXmlns;

FOUNDATION_EXPORT NSString *const PorticoDefaultSchemaUri;

@interface SoapHandler : NSObject

+ (NSString *) toSoap:(NSDictionary *) request
            namespace:(NSString *) xmlns
            schemaUri:(NSString *) uri;

+ (NSDictionary *) fromSoap:(NSString *) response;

@end

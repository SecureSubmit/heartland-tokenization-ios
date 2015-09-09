//
//  HpsService.h
//  SecureSubmit
//
//  Created by Roberts, Jerry on 7/21/14.
//  Copyright (c) 2014 Heartland Payment Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HpsServicesConfig;

@interface HpsService : NSObject

- (id) initWithConfig:(HpsServicesConfig *) config;

- (NSDictionary *) doTransaction:(NSDictionary *)transaction;

@end

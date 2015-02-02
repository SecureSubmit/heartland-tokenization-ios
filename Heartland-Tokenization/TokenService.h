//
//  TokenService.h
//  Heartland-Tokenization
//
//  Created by Roberts, Jerry on 2/2/15.
//  Copyright (c) 2015 Heartland Payment Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TokenResponse.h"

@interface TokenService : NSObject

- (id) initWithPublicKey:(NSString*)publicKey;

- (void) getTokenWithCardNumber:(long long)cardNumber
                            cvc:(int)cvc
                       expMonth:(int)expMonth
                        expYear:(int)expYear
               andResponseBlock:(void(^)(TokenResponse*))responseBlock;

@end

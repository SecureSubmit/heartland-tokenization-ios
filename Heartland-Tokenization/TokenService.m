//
//  TokenService.m
//  Heartland-Tokenization
//
//  Created by Roberts, Jerry on 2/2/15.
//  Copyright (c) 2015 Heartland Payment Systems. All rights reserved.
//

#import "TokenService.h"
#import "TokenResponse.h"


@interface TokenService()

@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) NSString *publicKey;
@property (nonatomic, strong) NSString *serviceURL;



@end

@implementation TokenService

@synthesize publicKey = _publicKey;


- (id) initWithPublicKey:(NSString *)publicKey
{
    if((self = [super init]))
    {
        self.publicKey = publicKey;
        self.queue = [[NSOperationQueue alloc] init];
        
        if(!publicKey)
        {
            [NSException raise:NSInvalidArgumentException format:@"publicKey can not be nil"];
        }
        
        NSArray *components = [self.publicKey componentsSeparatedByString:@"_"];
        NSString *env = [components[1] lowercaseString];
        
        if([env isEqual:@"prod"]) {
            self.serviceURL = @"https://api.heartlandportico.com/SecureSubmit.v1/api/token";
        }
        else if ([env isEqualToString:@"cert"]) {
            self.serviceURL = @"https://posgateway.cert.secureexchange.net/Hps.Exchange.PosGateway.Hpf.v1/api/token";
        }
        else {
            self.serviceURL = @"http://gateway.e-hps.com/Hps.Exchange.PosGateway.Hpf.v1/api/token";
            //[NSException raise:NSInvalidArgumentException format:@"publicKey unrecognized environment"];
        }
        
    }
    return self;
}

- (void) getTokenWithCardNumber:(long long)cardNumber
                            cvc:(int)cvc
                       expMonth:(int)expMonth
                        expYear:(int)expYear
               andResponseBlock:(void(^)(TokenResponse*))responseBlock
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.serviceURL]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60];
    
    NSData *apiKey = [[NSString stringWithFormat:@"%@:", self.publicKey] dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString *authorization = [NSString stringWithFormat:@"Basic %@", [apiKey base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength]];
    
    NSDictionary *card = [NSDictionary dictionaryWithObjectsAndKeys:
                          [@(cardNumber) stringValue], @"number",
                          [@(cvc) stringValue], @"cvc",
                          [@(expMonth) stringValue], @"exp_month",
                          [@(expYear) stringValue], @"exp_year", nil];
    
    NSDictionary *token = [NSDictionary dictionaryWithObjectsAndKeys:
                           @"token", @"object",
                           @"supt", @"token_type",
                           card, @"card", nil];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:token
                                                       options:0
                                                         error:nil];
    
    [request setHTTPMethod:@"POST"];
    
    [request setValue:authorization forHTTPHeaderField:@"Authorization"];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [request setValue:[@([jsonData length]) stringValue] forHTTPHeaderField:@"Content-Length"];
    
    [request setHTTPBody:jsonData];
    
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:self.queue
                           completionHandler:^(NSURLResponse *urlResponse, NSData *data, NSError *error) {
                               
                               NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                                                    options:NSJSONReadingAllowFragments
                                                                                      error:nil];
                               
                               TokenResponse *response = [[TokenResponse alloc] init];
                               
                               if(json[@"error"])
                               {
                                   response.code = json[@"error"][@"code"];
                                   response.message = json[@"error"][@"message"];
                                   response.param = json[@"error"][@"param"];
                                   response.type = @"error";
                               }
                               else
                               {
                                   response.tokenValue = json[@"token_value"];
                                   response.tokenType = json[@"token_type"];
                                   response.tokenExpire = json[@"token_expire"];
                                   response.cardNumber = json[@"card"][@"number"];
                                   response.type = @"token";
                               }
                               
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   responseBlock(response);
                               });
                               
                           }];
}

@end
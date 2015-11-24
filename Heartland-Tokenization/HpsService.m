//
//  HpsService.m
//  SecureSubmit
//
//  Created by Roberts, Jerry on 7/21/14.
//  Copyright (c) 2014 Heartland Payment Systems. All rights reserved.
//

#import "HpsService.h"
#import "HpsServicesConfig.h"
#import "SoapHandler.h"

@interface HpsService()

@property (strong, nonatomic) HpsServicesConfig *config;

-(BOOL) isConfigInvalid;

@end

@implementation HpsService

- (id) initWithConfig:(HpsServicesConfig *)config
{
    if(self = [super init])
    {
        self.config = config;
    }
    
    return self;
}

- (NSDictionary *) doTransaction:(NSDictionary *)transaction
{
    if( [self isConfigInvalid] )
    {
        // TODO: throw sdk exception
    }
    
    NSDictionary *header;
    
    if( self.config.secretApiKey )
    {
        header = @{
            @"SecretAPIKey": self.config.secretApiKey,
            @"DeveloperID": self.config.developerId,
            @"VersionNbr": self.config.versionNumber,
            @"SiteTrace": self.config.siteTrace
        };
        
        if( [self.config.secretApiKey localizedCaseInsensitiveContainsString:@"_prod_"] )
        {
            self.config.serviceUri = @"https://posgateway.secureexchange.net/Hps.Exchange.PosGateway/PosGatewayService.asmx";
        }
        else
        {
            self.config.serviceUri = @"https://cert.api2.heartlandportico.com/Hps.Exchange.PosGateway/PosGatewayService.asmx";
        }
    }
    else
    {        
        header = @{
            @"LicenseId": self.config.licenseId,
            @"SiteId": self.config.siteId,
            @"DeviceId": self.config.deviceId,
            @"UserName": self.config.userName,
            @"Password": self.config.password,
            @"SiteTrace": self.config.siteTrace,
            @"DeveloperId": self.config.developerId,
            @"VersionNbr": self.config.versionNumber
        };
    }
    
    
    NSDictionary *posRequest = @{ @"PosRequest": @{ @"Ver1.0": @{ @"Header": header, @"Transaction": transaction }}};
    
    NSString *requestXML = [SoapHandler toSoap:posRequest
                                     namespace:PorticoDefaultXmlns
                                     schemaUri:PorticoDefaultSchemaUri];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.config.serviceUri]];
    
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    

    NSData *data = [requestXML dataUsingEncoding:NSUTF8StringEncoding];
    
    [request setHTTPBody:data];
    
    [request setValue:[@([data length]) stringValue] forHTTPHeaderField:@"Content-Length"];

    [request setHTTPMethod:@"POST"];
    
    [request setValue:@"text/xml; charset=utf-8;" forHTTPHeaderField:@"Content-Type"];
    
    NSURLResponse *response;
    
    NSError *responseError;
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request
                                                 returningResponse:&response
                                                             error:&responseError];
    
    if( responseError )
    {
        // TODO: parse *error
        
        return nil;
    }
    
    // TODO: is this always good?
    NSString *responseXML = [[NSString alloc] initWithData:responseData
                                                  encoding:NSUTF8StringEncoding];
    
    
    // TODO: better error handling?
    return [SoapHandler fromSoap:responseXML];
}

- (BOOL) isConfigInvalid
{
    return  !self.config.secretApiKey &&
    (
      !self.config.deviceId ||
      !self.config.siteId ||
      !self.config.userName ||
      !self.config.password ||
      !self.config.serviceUri
    );
}

@end

//
//  Heartland_GatewayTests.m
//  Heartland-Tokenization
//
//  Created by Roberts, Jerry on 9/8/15.
//  Copyright (c) 2015 Heartland Payment Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "hps.h"

@interface Heartland_GatewayTests : XCTestCase

@end

@implementation Heartland_GatewayTests

- (void) testCreditSale
{
    HpsServicesConfig *config = [[HpsServicesConfig alloc]
                                 initWithSecretApiKey:@"skapi_cert_MYl2AQAowiQAbLp5JesGKh7QFkcizOP2jcX9BrEMqQ"
                                 developerId:@"123456"
                                 versionNumber:@"1234"];
    
    HpsService *service = [[HpsService alloc] initWithConfig:config];
    
    NSDictionary *transaction =
      @{ @"CreditSale":
      @{ @"Block1":
      @{ @"CardHolderData": @{
          @"CardHolderFirstName": @"John",
          @"CardHolderLastName": @"Doe",
          @"CardHolderAddr": @"123 This Way",
          @"CardHolderCity": @"Anytown",
          @"CardHolderState": @"Anywhere",
          @"CardHolderZip": @"12345" },  // Zip is the minimum amount of data required for AVS
         @"CardData":
          @{ @"TokenRequest": @"Y", // Flag to request multi-use token
             @"ManualEntry": @{
                 @"CardNbr": @"4242424242424242",
                 @"ExpMonth": @"6",
                 @"ExpYear": @"2021",
                 @"CardPresent": @"N",
                 @"ReaderPresent": @"N" },
         },
         @"Amt": @"100",
         @"AllowDup": @"N",
         @"AllowPartialAuth": @"N",
         @"AdditionalTxnFields": @{  // Additional "optional" fields to pass custom data through
                 @"Description": @"test",
                 @"InvoiceNbr": @"123456",
                 @"CustomerID": @"123" },
         
         }}};
    
    NSDictionary *gatewayResponse = [service doTransaction:transaction];
    
    NSDictionary *tokenData = gatewayResponse[@"soap:Body"][@"PosResponse"][@"Ver1.0"][@"Header"][@"TokenData"];
    XCTAssertEqualObjects(tokenData[@"TokenRspCode"], @"0");
    XCTAssertNotNil(tokenData[@"TokenValue"]);
                                                                                                  
    NSDictionary *creditSale = gatewayResponse[@"soap:Body"][@"PosResponse"][@"Ver1.0"][@"Transaction"][@"CreditSale"];
    XCTAssertEqualObjects(creditSale[@"RspCode"], @"00");
    XCTAssertNotNil(creditSale[@"AuthCode"]);
}

@end
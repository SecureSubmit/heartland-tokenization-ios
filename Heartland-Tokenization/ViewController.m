//
//  ViewController.m
//  Heartland-Tokenization
//
//  Created by Roberts, Jerry on 2/2/15.
//  Copyright (c) 2015 Heartland Payment Systems. All rights reserved.
//

#import "ViewController.h"
#import "hps.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize cardNumberField=_cardNumberField;
@synthesize cvvField=_cvvField;
@synthesize expDatePicker=_expDatePicker;
@synthesize tokenResultLabel=_tokenResultLabel;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (IBAction)submitButtonClicked:(id)sender {
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitMonth|NSCalendarUnitYear
                                                                   fromDate:self.expDatePicker.date];
    
    long cardNumber = [self.cardNumberField.text longLongValue];
    int cvv = [self.cvvField.text intValue];
    int expMonth = (int)[components month];
    int expYear = (int)[components year];
    
    TokenService *service = [[TokenService alloc] initWithPublicKey:@"pkapi_cert_P6dRqs1LzfWJ6HgGVZ"];
    
    [service getTokenWithCardNumber:cardNumber
                                cvc:cvv
                           expMonth:expMonth
                            expYear:expYear
                   andResponseBlock:^(TokenResponse *response) {
                       
                       if([response.type isEqualToString:@"error"]) {
                           self.tokenResultLabel.text = response.message;
                       }
                       else {
                           self.tokenResultLabel.text = response.tokenValue;
                       }
                       
                   }];
}

@end

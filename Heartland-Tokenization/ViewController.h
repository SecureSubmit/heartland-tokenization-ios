//
//  ViewController.h
//  Heartland-Tokenization
//
//  Created by Roberts, Jerry on 2/2/15.
//  Copyright (c) 2015 Heartland Payment Systems. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITextField *cardNumberField;
@property (strong, nonatomic) IBOutlet UITextField *cvvField;
@property (strong, nonatomic) IBOutlet UIDatePicker *expDatePicker;
@property (strong, nonatomic) IBOutlet UILabel *tokenResultLabel;

- (IBAction)submitButtonClicked:(id)sender;

@end


## Heartland SecureSubmit Tokenization for iOS
>This project makes it easy to convert sensitive card data to single-use payment tokens 


#### Simple TokenService
Below is an example of all that is required to convert sensitive card information into a single-use token.  The request is asynchronous so you can safely run this code on the UI thread.
```objective-c
    TokenService *service = [[TokenService alloc] initWithPublicKey:@"YOUR PUBLIC KEY GOES HERE"];
    
    [service getTokenWithCardNumber:4242424242424242
                                cvc:123
                           expMonth:12
                            expYear:2015
                   andResponseBlock:^(TokenResponse *response) {
                       
                       if([response.type isEqualToString:@"error"]) {
                           self.tokenResultLabel.text = response.message;
                       }
                       else {
                           self.tokenResultLabel.text = response.tokenValue;
                       }
                       
                   }];
```
## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
[DeveloperPortal]: https://developer.heartlandpaymentsystems.com/securesubmit

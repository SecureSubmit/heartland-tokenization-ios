## Heartland SecureSubmit Tokenization for iOS
>This project makes it easy to convert sensitive card data to single-use payment tokens 

#####For iOS 9 and above: Whitelist heartlandportico.com

If you compile your app with iOS SDK 9.0, you will be affected by App Transport Security. Currently, you will need to whitelist heartlandportico.com in your app by adding the following to your application's plist:

```Objective-C
<key>NSAppTransportSecurity</key>  
<dict>  
<key>NSExceptionDomains</key>  
    <dict>  
      <key>heartlandportico.com</key>  
      <dict>  
        <key>NSIncludesSubdomains</key>  
        <true/>  
        <key>NSTemporaryExceptionAllowsInsecureHTTPLoads</key>  
        <true/>  
        <key>NSTemporaryExceptionMinimumTLSVersion</key>  
        <string>1.0</string>  
        <key>NSTemporaryExceptionRequiresForwardSecrecy</key>  
        <false/>  
      </dict>  
  </dict>  
</dict>  

```

#### Simple TokenService
Below is an example of all that is required to convert sensitive card information into a single-use token.  The request is asynchronous so you can safely run this code on the UI thread.
```objective-c

    //import our umbrella class
    #import "hps.h"


    //For serialized data as NSStrings instead of integers
    //Initialize with your key
    TokenService *service = [[TokenService alloc] initWithPublicKey:self.publicKey];
    
    //Call the service
    [service getTokenFromStringsWithCardNumber:@"4242424242424242"
                                           cvc:@"023"
                                      expMonth:@"12"
                                       expYear:@"2017"
                              andResponseBlock:^(HpsTokenResponse *response) {
                                  
                                  //finished callback
                                  if([response.type isEqualToString:@"error"]) {
                                      self.tokenResultLabel.text = response.message;
                                  }
                                  else {
                                      self.tokenResultLabel.text = response.tokenValue;
                                  }
                                  
                              }];



    //DEPRECATED - Integer based
    //Integers for CVC with leading zeros are not padded correctly, and we will be deprecating this method in our new SDK. 

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

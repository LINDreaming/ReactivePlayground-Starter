//
//  RWViewController.m
//  RWReactivePlayground
//
//  Created by Colin Eberhardt on 18/12/2013.
//  Copyright (c) 2013 Colin Eberhardt. All rights reserved.
//

#import "RWViewController.h"
#import "RWDummySignInService.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface RWViewController ()

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;
@property (weak, nonatomic) IBOutlet UILabel *signInFailureText;


@property (strong, nonatomic) RWDummySignInService *signInService;

@end

@implementation RWViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  
  self.signInService = [RWDummySignInService new];
  
  // handle text changes for both text fields
  
  
  // initially hide the failure message
  self.signInFailureText.hidden = YES;
    
    RACSignal *vaildUsernameSignal = [self.usernameTextField.rac_textSignal map:^id(id value) {
        return @([self isValidUsername:value]);
    }];
    RACSignal *validPasswordSignal = [self.passwordTextField.rac_textSignal map:^id(id value) {
        return @([self isValidPassword:value]);
    }];
    
 RAC(self.passwordTextField,backgroundColor) = [validPasswordSignal map:^id(NSNumber *passwordValid) {
     return [passwordValid boolValue]?[UIColor clearColor]:[UIColor yellowColor];
 }];
RAC(self.usernameTextField,backgroundColor) = [vaildUsernameSignal map:^id(NSNumber *usernameValid) {
        return [usernameValid boolValue]?[UIColor clearColor]:[UIColor yellowColor];
    }];

    RACSignal *signUpActiveSignal =
    [RACSignal combineLatest:@[vaildUsernameSignal, validPasswordSignal]
                      reduce:^id(NSNumber *usernameValid, NSNumber *passwordValid) {
                          return @([usernameValid boolValue] && [passwordValid boolValue]);
                      }];
    [signUpActiveSignal subscribeNext:^(id x) {
        self.signInButton.enabled = [x boolValue];
    }];
    
    [[[self.signInButton rac_signalForControlEvents:UIControlEventTouchUpInside] map:^id(id value) {
        return [self signinSignal];
    }]subscribeNext:^(id x) {
        NSLog(@"button clivked");
    }];
    

    
}

- (BOOL)isValidUsername:(NSString *)username {
  return username.length > 3;
}

- (BOOL)isValidPassword:(NSString *)password {
  return password.length > 3;
}

- (RACSignal *)signinSignal{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [self.signInService signInWithUsername:self.usernameTextField.text password:self.passwordTextField.text complete:^(BOOL success) {
            [subscriber sendNext:@(success)];
            [subscriber sendCompleted];
            
        }];
        return nil;
    }];
}


// updates the enabled state and style of the text fields based on whether the current username
// and password combo is valid




@end

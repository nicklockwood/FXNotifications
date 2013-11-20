//
//  ViewController.m
//  NotificationsTest
//
//  Created by Nick Lockwood on 20/11/2013.
//  Copyright (c) 2013 Charcoal Design. All rights reserved.
//

#import "ViewController.h"
#import "FXNotifications.h"


static NSString *const IncrementCountNotification = @"IncrementCountNotification";


@interface ViewController ()

@property (nonatomic, strong) IBOutlet UILabel *label;
@property (nonatomic, assign) NSInteger count;

@end


@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    //using the built-in method (in a naive way), we would leak like hell
//    [[NSNotificationCenter defaultCenter] addObserverForName:IncrementCountNotification
//                                                      object:nil
//                                                       queue:[NSOperationQueue mainQueue]
//                                                  usingBlock:^(NSNotification *note) {
//        
//        UILabel *label = note.object;
//        label.text = [NSString stringWithFormat:@"Presses: %@", @(++self.count)];
//    }];
    
    //using the FXNotifications method, this approach doesn't leak and just works as expected
    [[NSNotificationCenter defaultCenter] addObserver:self
                                              forName:IncrementCountNotification
                                               object:self.label
                                                queue:[NSOperationQueue mainQueue]
                                           usingBlock:^(NSNotification *note, __weak ViewController *self) {
        
        UILabel *label = note.object;
        label.text = [NSString stringWithFormat:@"Presses: %@", @(++self.count)];
    }];
}

- (IBAction)increment
{
    [[NSNotificationCenter defaultCenter] postNotificationName:IncrementCountNotification object:self.label];
}

- (IBAction)removeObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IncrementCountNotification object:self.label];
}

@end

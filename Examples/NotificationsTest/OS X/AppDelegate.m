//
//  AppDelegate.m
//  NotificationsTest
//
//  Created by James Clarke on 3/11/14.
//  Copyright (c) 2014 Caffeine and Cocoa. All rights reserved.
//

#import "AppDelegate.h"

#import "WindowController.h"


@interface AppDelegate ()

@property (nonatomic, strong) WindowController *windowController;

@end

@implementation AppDelegate

- (IBAction)showSheet:(__unused id)sender
{
    WindowController *windowController = [[WindowController alloc] initWithWindowNibName:@"WindowController"];
    
    [NSApp beginSheet:windowController.window
       modalForWindow:self.window
        modalDelegate:self
       didEndSelector:@selector(didEndSheet:returnCode:contextInfo:)
          contextInfo:nil];
    
    self.windowController = windowController;
}

- (void)didEndSheet:(NSWindow *)sheet returnCode:(__unused NSInteger)returnCode contextInfo:(__unused void *)contextInfo
{
    self.windowController = nil;
    [sheet orderOut:nil];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(__unused NSApplication *)sender
{
    return YES;
}

@end

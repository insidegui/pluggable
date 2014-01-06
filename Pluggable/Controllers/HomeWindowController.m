//
//  HomeWindowController.m
//  Pluggable
//
//  Created by Guilherme Rambo on 03/01/14.
//  Copyright (c) 2014 Guilherme Rambo. All rights reserved.
//

#import "HomeWindowController.h"
#import "PluginCore.h"

@interface HomeWindowController ()

@property (unsafe_unretained) IBOutlet NSTextView *textView;

@end

@implementation HomeWindowController

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    NSFileWrapper *rtfd = [[NSFileWrapper alloc] initWithPath:[[NSBundle mainBundle] pathForResource:@"sample" ofType:@"rtfd"]];
    [self.textView.textStorage setAttributedString:[[NSAttributedString alloc] initWithRTFDFileWrapper:rtfd documentAttributes:nil]];
    
    [self installPluginSupport];
}

- (void)installPluginSupport
{
    [[PluginCore sharedPluginCore] exposeFunctionWithName:@"setTextColor" block:^(NSDictionary *params) {
        NSColor *color = [NSColor colorWithCalibratedRed:[params[@"red"] doubleValue] green:[params[@"green"] doubleValue] blue:[params[@"blue"] doubleValue] alpha:[params[@"alpha"] doubleValue]];
        [self.textView.textStorage addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, self.textView.textStorage.length)];
    }];
}

@end

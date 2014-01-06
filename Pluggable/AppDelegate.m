//
//  AppDelegate.m
//  Pluggable
//
//  Created by Guilherme Rambo on 03/01/14.
//  Copyright (c) 2014 Guilherme Rambo. All rights reserved.
//

#import "AppDelegate.h"
#import "HomeWindowController.h"
#import "PluginCore.h"

@interface AppDelegate ()

@property (strong) HomeWindowController *homeWC;
@property (strong) JSContext *pluginsContext;

@end

@implementation AppDelegate

- (void)awakeFromNib
{
    [[PluginCore sharedPluginCore] setPluginsMenu:self.pluginsMenu];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.homeWC = [[HomeWindowController alloc] initWithWindowNibName:@"HomeWindowController"];
    [self.homeWC showWindow:self];
    
    [self initializeJavascript];
}

- (void)initializeJavascript
{    
    [[PluginCore sharedPluginCore] loadAllPlugins];
}

@end

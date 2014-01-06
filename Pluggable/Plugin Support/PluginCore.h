//
//  PluginCore.h
//  Pluggable
//
//  Created by Guilherme Rambo on 03/01/14.
//  Copyright (c) 2014 Guilherme Rambo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

@class PluginCore;

@protocol PluggableExports <JSExport>

// logs a message to the standard output
+ (void)log:(NSString *)message;

// installs a menu item for the plugin in the "plugins" menu
// params:
// "title" - a title for the menu item (string)
// "keyEquivalent" - the key equivalent for the menu item (string)
// "tag" - a tag (integer)
// "callback" - the name of the function to be called when the menu is selected (string)
+ (void)installPluginMenuItem:(NSDictionary *)params;

@end

@interface PluginCore : NSObject <PluggableExports>

+ (PluginCore *)sharedPluginCore;

// loads all the plugins inside the app bundle's "plugins" folder
- (void)loadAllPlugins;

// makes a function available to be called from javascript
- (void)exposeFunctionWithName:(NSString *)functionName block:(void(^)(NSDictionary *params))block;

@property (strong) JSContext *jsContext;

// set this to a NSMenu which will hold the plugins' menu items
@property (weak) NSMenu *pluginsMenu;



@end

//
//  PluginCore.m
//  Pluggable
//
//  Created by Guilherme Rambo on 03/01/14.
//  Copyright (c) 2014 Guilherme Rambo. All rights reserved.
//

#import "PluginCore.h"

@interface PluginCore ()

@property (strong) NSMutableDictionary *pluginMenuCallbacks;

@end

@implementation PluginCore

+ (PluginCore *)sharedPluginCore
{
    static dispatch_once_t onceToken;
    static PluginCore *_sharedPluginCore;
    
    dispatch_once(&onceToken, ^{
        _sharedPluginCore = [[PluginCore alloc] init];
    });
    
    return _sharedPluginCore;
}

- (instancetype)init
{
    self = [super init];
    if(!self) return nil;
    
    // initialize javascript context
    self.jsContext = [[JSContext alloc] init];
    self.jsContext[@"Pluggable"] = [self class];
    
    // this is used to hold a reference to the plugins' callback function's names
    self.pluginMenuCallbacks = [[NSMutableDictionary alloc] init];
    
    return self;
}

- (void)loadAllPlugins
{
    // the Plugins directory inside the app's bundle
    NSString *pluginsPath = [[NSBundle mainBundle] builtInPlugInsPath];

    // we will make a non-recursive enumeration
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtURL:[NSURL fileURLWithPath:pluginsPath] includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsSubdirectoryDescendants errorHandler:nil];
    
    // enumerate all the bundles inside the plugins directory
    NSURL *pluginBundleURL;
    while (pluginBundleURL = [enumerator nextObject]) [self loadPluginWithBundleURL:pluginBundleURL];
}

- (void)loadPluginWithBundleURL:(NSURL *)bundleURL
{
    // get the javascript filename, basically the bundle's name without the extension
    NSString *jsFileName = [[bundleURL URLByDeletingPathExtension] lastPathComponent];
    
    // try to initialize a bundle instance
    NSBundle *pluginBundle = [NSBundle bundleWithURL:bundleURL];
    if(!pluginBundle) {
        NSRunAlertPanel(NSLocalizedString(@"Plugin Error", @"Plugin Error"), NSLocalizedString(@"Unable to load plugin", @"Unable to load plugin"), NSLocalizedString(@"Ok", @"Ok"), nil, nil);
        return;
    }
    
    // get the path to the plugin's ".js" file, a ".js" file inside it's resources with the same name as the bundle
    NSString *pluginCodePath = [pluginBundle pathForResource:jsFileName ofType:@"js"];
    
    // try to load the js into a NSString
    NSError *codeError;
    NSString *pluginCode = [NSString stringWithContentsOfFile:pluginCodePath encoding:NSUTF8StringEncoding error:&codeError];
    if (codeError) {
        [[NSAlert alertWithError:codeError] runModal];
        return;
    }
    
    // execute the plugin's javascript
    [self.jsContext evaluateScript:pluginCode];
    
    // call the plugin's initialization function, a function with the same name as the bundle, without any arguments
    JSValue *pluginInit = self.jsContext[jsFileName];
    [pluginInit callWithArguments:@[]];
}

- (void)exposeFunctionWithName:(NSString *)functionName block:(void(^)(NSDictionary *params))block
{
    self.jsContext[functionName] = block;
}

- (void)performPluginMenuAction:(id)sender
{
    // find the name of the callback function based on the menu item's title
    NSString *callbackName = self.pluginMenuCallbacks[[sender title]];
    
    // get a JSValue and call the function without any parameters
    JSValue *callback = self.jsContext[callbackName];
    [callback callWithArguments:@[]];
}

#pragma mark Functions Available to Javascript

+ (void)log:(NSString *)message
{
    NSLog(@"[PluginCore] %@", message);
}

+ (void)installPluginMenuItem:(NSDictionary *)params
{
    PluginCore *pluginCore = [PluginCore sharedPluginCore];
    
    NSMenuItem *item = [[NSMenuItem alloc] init];
    item.target = pluginCore;
    item.title = params[@"title"];
    item.action = @selector(performPluginMenuAction:);
    item.keyEquivalent = params[@"keyEquivalent"];
    item.tag = [params[@"tag"] integerValue];
    
    [[pluginCore pluginsMenu] addItem:item];
    
    [[pluginCore pluginMenuCallbacks] setObject:params[@"callback"] forKey:params[@"title"]];
}

@end

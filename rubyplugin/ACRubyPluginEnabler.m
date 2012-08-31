// -*- mode:objc; indent-tabs-mode:nil; coding:utf-8 -*-
//
//  ACRubyPluginEnabler.m
//  RubyPluginEnabler
//
//  Created by Fujimoto Hisa on 07/02/02.
//  Copyright 2007 Fujimoto Hisa. All rights reserved.

#import <Cocoa/Cocoa.h>
#import <RubyCocoa/RubyCocoa.h>
#import "ACPlugin.h"

@interface ACRubyPluginEnabler : NSObject <ACPlugin> {
    id<ACPluginManager> manager;
}
- (void) didRegister;
@end

@implementation ACRubyPluginEnabler

+ (id) plugin {
    return [[[self alloc] init] autorelease];
}

- (void) didRegister {
    
    static int installed = 0;
    if (! installed) {
        if (RBBundleInit("acr_init.rb", [self class], self))
            NSLog(@"ACRubyPluginEnabler#didRegister failed.");
        else
            installed = 1;
    }
}

- (id<ACPluginManager>) manager {
    return manager;
}

- (void) willRegister:(id<ACPluginManager>)thePluginManager {
    manager = thePluginManager;
}

- (NSNumber*) worksOnShapeLayers:(id)userObject {
    return [NSNumber numberWithBool:NO];
}

- (NSNumber*)validateForLayer:(id<ACLayer>)layer {
    return [NSNumber numberWithBool:[layer layerType] == ACBitmapLayer];
}

@end

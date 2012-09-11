//
//  Kernelr.m
//  Kernelr
//
//  Created by August Mueller on 10/10/07.
//  Copyright Flying Meat Inc 2007 . All rights reserved.
//

#import "Kernelr.h"

@implementation Kernelr

+ (id)plugin {
    return [[[self alloc] init] autorelease];
}

- (void)willRegister:(id<ACPluginManager>)pluginManager {
    
    [pluginManager addFilterMenuTitle:@"Show Kernelr"
                   withSuperMenuTitle:nil
                               target:self
                               action:@selector(showKernelr:userObject:)
                        keyEquivalent:@"K"
            keyEquivalentModifierMask:NSCommandKeyMask | NSShiftKeyMask
                           userObject:nil];
}

- (void)didRegister {
    
}

- (CIImage*)showKernelr:(CIImage*)image userObject:(id)uo {
    
    if (!kontroler) {
        kontroler = [[KernelrKontroler alloc] initWithWindowNibName:@"Kernelr"];
        [[kontroler window] center];
    }
    
    [kontroler setInputImage:image];
    [[kontroler window] makeKeyAndOrderFront:self];
    
    return nil;
}

- (NSNumber*)worksOnShapeLayers:(id)userObject {
    return [NSNumber numberWithBool:NO];
}

@end

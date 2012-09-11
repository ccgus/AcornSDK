//
//  Created by August Mueller on 11/14/06.
//  Copyright 2006 Flying Meat Inc.. All rights reserved.
//

#import "SPGrayscalePlugin.h"

@implementation SPGrayscalePlugin

+ (id)plugin {
    return [[[self alloc] init] autorelease];
}

- (void)willRegister:(id<ACPluginManager>)pluginManager {
    
    [pluginManager addFilterMenuTitle:@"Convert to Grayscale"
                   withSuperMenuTitle:@"Color Effect"
                               target:self
                               action:@selector(convert:userObject:)
                        keyEquivalent:@""
            keyEquivalentModifierMask:0
                           userObject:nil];
}

- (void)didRegister {
    
}

- (CIImage*)convert:(CIImage*)image userObject:(id)uo {
    
    CIFilter *filter = [CIFilter filterWithName: @"CIColorMonochrome" keysAndValues:@"inputImage", image, nil];
    
    CIColor *color = [CIColor colorWithRed:0.5f green:0.5f blue:0.5f];
    
	[filter setDefaults];
	[filter setValue:color forKey:@"inputColor"];
    [filter setValue:[NSNumber numberWithFloat:1] forKey:@"inputIntensity"];
    
    return [filter valueForKey: @"outputImage"];
}

- (NSNumber*)worksOnShapeLayers:(id)userObject {
    return [NSNumber numberWithBool:NO];
}

- (NSNumber*)validateForLayer:(id<ACLayer>)layer {
    
    if ([layer layerType] == ACBitmapLayer) {
        [NSNumber numberWithBool:YES];
    }
    
    return [NSNumber numberWithBool:NO];
}

@end

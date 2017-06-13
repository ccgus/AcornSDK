//
//  SimpleIO.m
//  SimpleIO
//
//  Created by August Mueller on 2/5/09.
//  Copyright Flying Meat Inc 2009 . All rights reserved.
//

#import "SimpleIO.h"

#define debug NSLog

@implementation SimpleIO

+ (id) plugin {
    return [[[self alloc] init] autorelease];
}

- (void)willRegister:(id<ACPluginManager>)pluginManager {
    debug(@"%s:%d", __FUNCTION__, __LINE__);
    [pluginManager registerIOProviderForReading:self forUTI:(id)kUTTypePICT];
    [pluginManager registerIOProviderForWriting:self forUTI:(id)kUTTypePICT];
    
    
}

- (void)didRegister {
    
}

- (BOOL)writeDocument:(id<ACDocument>)document toURL:(NSURL *)absoluteURL ofType:(NSString *)type forSaveOperation:(NSSaveOperationType)saveOperation error:(NSError **)outError {
    
    CGImageRef composite = [document newCGImage];
    
    CGImageDestinationRef imageDestination = CGImageDestinationCreateWithURL((CFURLRef)absoluteURL, (CFStringRef)type , 1, NULL);
    CGImageDestinationAddImage(imageDestination, composite, (CFDictionaryRef)[NSDictionary dictionary]);
    CGImageDestinationFinalize(imageDestination);
    CFRelease(imageDestination);
    
    CGImageRelease(composite);
    
    return YES;
}

- (BOOL)readImageForDocument:(id<ACDocument>)document fromURL:(NSURL *)absoluteURL ofType:(NSString *)type error:(NSError **)outError {
    
    NSImage *i = [[NSImage alloc] initWithContentsOfURL:absoluteURL];
    
    NSPICTImageRep *r = (NSPICTImageRep*)[[i representations] firstObject];
    
    FMDrawContext  *dc = [FMDrawContext drawContextWithSize:[r size]];
    [dc lockFocus];
    [r draw];
    [dc unlockFocus];
    
    
    CGImageRef imageRef = [dc CGImage];
    
    NSSize s = NSMakeSize(CGImageGetWidth(imageRef), CGImageGetHeight(imageRef));
    
    [document setCanvasSize:s];
    
    id <ACGroupLayer> baseGroup = [document baseGroup];
    
    NSString *fileName = [[[absoluteURL path] lastPathComponent] stringByDeletingPathExtension];
    
    [baseGroup insertCGImage:imageRef atIndex:0 withName:fileName];
    
    return YES;
}

- (NSNumber*)worksOnShapeLayers:(id)userObject {
    return @(NO);
}

- (NSNumber *)validateForLayer:(id<ACLayer>)layer {
    return @(NO);
}


@end

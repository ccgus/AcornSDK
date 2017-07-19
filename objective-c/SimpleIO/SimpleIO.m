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
    
    if (!i) {
        return [self readUnknownImageForDocument:document fromURL:absoluteURL ofType:type error:outError];
    }
    
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

- (BOOL)readUnknownImageForDocument:(id<ACDocument>)document fromURL:(NSURL *)absoluteURL ofType:(NSString *)type error:(NSError **)outError {
    
    // OK, this might not be a pict file! However, it might be something else that we're testing out deep image support for. Like… say a 16 bit tiff with the extension .pict.
    // So let's let imageio handle this, and see what happens.
    // Really, this whole method is to show how to load up and create a document for an image source with greater than 8bpc.
    
    CGImageSourceRef imageSourceRef = CGImageSourceCreateWithData((__bridge CFDataRef)[NSData dataWithContentsOfURL:absoluteURL], (__bridge CFDictionaryRef)[NSDictionary dictionary]);
    CGImageRef img                  = CGImageSourceCreateImageAtIndex(imageSourceRef, 0, (__bridge CFDictionaryRef)[NSDictionary dictionary]);
    CFRelease(imageSourceRef);
    
    if (!img) {
        return NO;
    }
    
    [document setCanvasSize:NSMakeSize(CGImageGetWidth(img), CGImageGetHeight(img))];
    
    [document setBitsPerPixel:CGImageGetBitsPerComponent(img) * 4];
    
    id <ACGroupLayer> baseGroup = [document baseGroup];
    
    NSString *fileName = [[[absoluteURL path] lastPathComponent] stringByDeletingPathExtension];
    
    [baseGroup insertCGImage:img atIndex:0 withName:fileName];
    
    [(NSDocument *)document setFileURL:nil];
    [(NSDocument *)document setFileType:nil];
    
    CGImageRelease(img);
    
    return YES;
}

- (NSNumber*)worksOnShapeLayers:(id)userObject {
    return @(NO);
}

- (NSNumber *)validateForLayer:(id<ACLayer>)layer {
    return @(NO);
}


@end

//
//  ACImageAgent.h
//  AcornImage
//
//  Created by August Mueller on 4/17/09.
//  Copyright 2009 Flying Meat Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ACImageAgent : NSObject {
    @private;
    id _delegate;
    id _userInfo;
    NSString *_imagePath;
    NSSize _imageSize;
    NSString *_fileNameHint;
    FSEventStreamRef _streamRef;
    BOOL _shouldDeleteOnDealloc;
}


@property (retain) id delegate;
@property (retain) id userInfo;
@property (retain) NSString *imagePath;
@property (assign) NSSize imageSize;
@property (retain) NSString *fileNameHint;
@property (assign) BOOL shouldDeleteOnDealloc;


- (void) openNewImageInAcornWithData:(NSData*)data uti:(NSString*)dataUTI;

- (CIImage*) CIImage;
- (CGImageRef) createCGImage;
- (NSImage*) NSImage;

+ (id) editCIImageInAcorn:(CIImage*)img fileNameHint:(NSString*)hint withDelegate:(id)delegate;
+ (id) editCGImageInAcorn:(CGImageRef)img fileNameHint:(NSString*)hint withDelegate:(id)delegate;
+ (id) editNSImageInAcorn:(NSImage*)img fileNameHint:(NSString*)hint withDelegate:(id)delegate;
+ (id) editImageAtURL:(NSURL*)fileURL withDelegate:(id)delegate;

+ (void) getAcornFree;
+ (void) getAcorn;
@end


@interface NSObject (ACImageAgentCallbacks)
- (void) acornImageDidUpdate:(ACImageAgent*)agent;
- (void) acornIsNotInstalledForAgent:(ACImageAgent*)agent;
@end



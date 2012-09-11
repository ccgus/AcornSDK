//
//  ACImageAgent.m
//  AcornImage
//
//  Created by August Mueller on 4/17/09.
//  Copyright 2009 Flying Meat Inc. All rights reserved.
//

#import "ACImageAgent.h"
#import "ACImage.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import <QuartzCore/QuartzCore.h>

//#define debug NSLog

@implementation ACImageAgent
@synthesize delegate=_delegate;
@synthesize userInfo=_userInfo;
@synthesize imagePath=_imagePath;
@synthesize imageSize=_imageSize;
@synthesize fileNameHint=_fileNameHint;
@synthesize shouldDeleteOnDealloc=_shouldDeleteOnDealloc;

- (void) closeUp {
    
    if (_shouldDeleteOnDealloc) {
        [[NSFileManager defaultManager] removeFileAtPath:[_imagePath stringByDeletingLastPathComponent] handler:nil];
    }
    
    [_delegate release];
    _delegate = 0x00;
    
    [_imagePath release];
    _imagePath = 0x00;
    
    [_userInfo release];
    _userInfo = 0x00;
    
    if (_streamRef) {
        FSEventStreamStop(_streamRef);
        FSEventStreamInvalidate(_streamRef);
        FSEventStreamRelease(_streamRef);
    }
    
}

- (void) finalize {
    NSLog(@"%s:%d", __FUNCTION__, __LINE__);
    
    [self closeUp];
    
    [super finalize];
}

- (void)dealloc {
    
    NSLog(@"%s:%d", __FUNCTION__, __LINE__);
    [self closeUp];
    
    [super dealloc];
}


- (CIImage*) CIImage {
    
    CGImageRef cgimg        = [self createCGImage];
    
    CIImage *img = [CIImage imageWithCGImage:cgimg];
    
    CGImageRelease(cgimg);
    
    return img;
}

- (CGImageRef) createCGImage {
    
    ACImage *acimg      = [ACImage imageWithFilePath:_imagePath];
    
    CGImageRef img      = [acimg createCGImage];
    
    _imageSize.width    = CGImageGetWidth(img);
    _imageSize.height   = CGImageGetHeight(img);
    
    return img;
    
}

- (NSImage*) NSImage {
    
    CGImageRef cgimg = [self createCGImage];
    
    NSBitmapImageRep *ir = [[[NSBitmapImageRep alloc] initWithCGImage:cgimg] autorelease];
    
    CGImageRelease(cgimg);
    
    NSImage *img = [[[NSImage alloc] initWithSize:_imageSize] autorelease];
    
    [img addRepresentation:ir];
    
    return img;
}

- (NSString*) makeUUID {
    
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    NSString *uuidString = (NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
    CFRelease(uuid);
    [uuidString autorelease];
    return [uuidString lowercaseString];
}


static void fsevents_callback(FSEventStreamRef streamRef, ACImageAgent *ia, int numEvents, const char *const eventPaths[], const FSEventStreamEventFlags *eventMasks, const uint64_t *eventIDs)
{
    
    if (ia->_streamRef != streamRef) {
        NSLog(@"mixed up streams!");
    }
    
    id delegate = [ia delegate];
    
    if (delegate && [delegate respondsToSelector:@selector(acornImageDidUpdate:)]) {
        [delegate acornImageDidUpdate:ia];
    }
    
}

- (void) watchFile {
    
    FSEventStreamContext  context = {0, (void *)self, NULL, NULL, NULL};
    NSArray              *pathsToWatch = [NSArray arrayWithObject:[_imagePath stringByDeletingLastPathComponent]];
    
    _streamRef = FSEventStreamCreate(kCFAllocatorDefault,
                                    (FSEventStreamCallback)&fsevents_callback,
                                    &context,
                                    (CFArrayRef)pathsToWatch,
                                    kFSEventStreamEventIdSinceNow,
                                    2,
                                    0);
    
    FSEventStreamScheduleWithRunLoop(_streamRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    
    FSEventStreamStart(_streamRef);
}

- (void) openImageInAcorn {
    if (!_imagePath) {
        NSBeep();
        NSLog(@"I don't have an image path to open");
        return;
    }
    
    NSString *acornBundleId     = @"com.flyingmeat.Acorn";
    NSString *acornFreeBundleId = @"com.flyingmeat.AcornFree";
    
    NSString *appPath = [[NSWorkspace sharedWorkspace] absolutePathForAppBundleWithIdentifier:acornBundleId];
    if (!appPath) {
        appPath = [[NSWorkspace sharedWorkspace] absolutePathForAppBundleWithIdentifier:acornFreeBundleId];
    }
    
    if (!appPath) {
        
        if (_delegate && [_delegate respondsToSelector:@selector(acornIsNotInstalledForAgent:)]) {
            [_delegate acornIsNotInstalledForAgent:self];
        }
        return;
    }
    
    [[NSWorkspace sharedWorkspace] openFile:_imagePath withApplication:appPath];
    
    [self watchFile];
    
}

- (void) openNewImageInAcornWithData:(NSData*)data uti:(NSString*)dataUTI {
    
    NSString *dirUUID  = [self makeUUID];
    NSString *layerId  = [self makeUUID];
    
    if (!_fileNameHint) {
        self.fileNameHint = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
        
        if (!_fileNameHint) {
            self.fileNameHint = [self makeUUID];
        }
    }
    
    NSString *tempDir = [NSTemporaryDirectory() stringByAppendingPathComponent:dirUUID];
    
    [[NSFileManager defaultManager] createDirectoryAtPath:tempDir attributes:nil];
    
    self.imagePath = [tempDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.acorn", _fileNameHint]];
    
    PXFMDatabase *db = [PXFMDatabase databaseWithPath:_imagePath];
    
    if (![db open]) {
        NSLog(@"Could not create an acorn file at %@", _imagePath);
        return;
    }
    
    // make our tables.
    [db executeUpdate:@"create table image_attributes ( name text, value blob)"];
    [db executeUpdate:@"create table layers (id text, parent_id text, sequence integer, uti text, name text, data blob)"];
    [db executeUpdate:@"create table layer_attributes ( id text, name text, value blob)"];
    
    // set our canvas size.
    [db executeUpdate:@"insert into image_attributes (name, value) values (?,?)", @"imageSize", NSStringFromSize(_imageSize)];
    [db executeUpdate:@"insert into image_attributes (name, value) values (?,?)", @"dpi", @"72"]; // we're always 72 (for now)
    [db executeUpdate:@"insert into image_attributes (name, value) values (?,?)", @"composite", data]; // the image has a composited version of the layers.
    
    [db executeUpdate:@"insert into layers (id, parent_id, sequence, uti, name, data) values (?,?,?,?,?,?)", layerId, nil, [NSNumber numberWithInt:0], dataUTI, @"Background", data];
    [db executeUpdate:@"insert into layer_attributes (id, name, value) values (?,?, ?)", layerId, @"frame", NSStringFromRect(NSMakeRect(0, 0, _imageSize.width, _imageSize.height))];
    
    [db close];
    
    [self openImageInAcorn];
    
}



+ (id) editCIImageInAcorn:(CIImage*)img fileNameHint:(NSString*)hint withDelegate:(id)delegate {
    
    CGImageRef cgimg = [[[NSGraphicsContext currentContext] CIContext] createCGImage:img fromRect:[img extent]];
    
    ACImageAgent *agent = [self editCGImageInAcorn:cgimg fileNameHint:hint withDelegate:delegate];
    
    CGImageRelease(cgimg);
    
    return agent;
}

+ (id) editCGImageInAcorn:(CGImageRef)img fileNameHint:(NSString*)hint withDelegate:(id)delegate {

    
    NSString *uti = (id)kUTTypePNG;
    NSMutableData *data = [NSMutableData data];
    CGImageDestinationRef imageDestination = CGImageDestinationCreateWithData((CFMutableDataRef)data, (CFStringRef)uti, 1, nil);
    
    if (!imageDestination) {
        return nil;
    }
    
    CGImageDestinationAddImage(imageDestination, img, nil);
    CGImageDestinationFinalize(imageDestination);
    CFRelease(imageDestination);
    
    ACImageAgent *agent = [[[self alloc] init] autorelease];
    agent.imageSize = NSMakeSize(CGImageGetWidth(img), CGImageGetHeight(img));
    
    [agent setDelegate:delegate];
    
    [agent setFileNameHint:hint];
    
    [agent setShouldDeleteOnDealloc:YES];
    
    [agent openNewImageInAcornWithData:data uti:uti];
    
    return agent;
}

+ (id) editImageAtURL:(NSURL*)fileURL withDelegate:(id)delegate {
    
    
    
    ACImageAgent *agent = [[[self alloc] init] autorelease];
    
    [agent setDelegate:delegate];
    [agent setShouldDeleteOnDealloc:NO];
    [agent setImagePath:[fileURL path]];
    [agent openImageInAcorn];
    
    return agent;
}

+ (id) editNSImageInAcorn:(NSImage*)img fileNameHint:(NSString*)hint withDelegate:(id)delegate {
    
    ACImageAgent *agent = [[[self alloc] init] autorelease];
    NSImageRep *rep     = [img bestRepresentationForDevice:nil];
    
    agent.imageSize     = NSMakeSize([rep pixelsWide], [rep pixelsHigh]);
    
    [agent setDelegate:delegate];
    
    [agent setFileNameHint:hint];
    
    [agent setShouldDeleteOnDealloc:YES];
    
    [agent openNewImageInAcornWithData:[img TIFFRepresentation] uti:(id)kUTTypeTIFF];
    
    return agent;
}

+ (void) getAcornFree {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://flyingmeat.com/acorn/acornfree.html"]];
}

+ (void) getAcorn {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://flyingmeat.com/acorn/"]];
}


@end

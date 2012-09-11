//
//  AFUAppDelegate.m
//  AcornFileUpdate
//
//  Created by August Mueller on 3/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AFUAppDelegate.h"
#import "sqlite3.h"

@implementation AFUAppDelegate

@synthesize window = _window;
@synthesize imageView = _imageView;

- (void)dealloc
{
    
    if (_watcherSource) {
        dispatch_source_cancel(_watcherSource);
        dispatch_release(_watcherSource);
        _watcherSource = 0x00;
    }
    
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    
    
    
}

- (NSData*)grabAcornCompositeDataAtPath:(NSString*)path {
    
    // we should really be using something like FMDB, but I just wanted to 
    // show you how you can grab the bitmap data out with the least amount of code.
    
    sqlite3 *db;
    int err = sqlite3_open([path fileSystemRepresentation], &db);
    
    if (err != SQLITE_OK) {
        NSLog(@"error opening!: %d", err);
        return nil;
    }
    
    sqlite3_stmt *pStmt     = nil;
    
    NSString *sql = @"select value from image_attributes where name = 'composite'";
    
    BOOL retry = YES;
    int numberOfRetries = 0;
    
    do {
        retry   = NO;
        err = sqlite3_prepare_v2(db, [sql UTF8String], -1, &pStmt, 0);
        
        if (SQLITE_OK == err) {
            // hurray!
        }
        else if (SQLITE_BUSY == err || SQLITE_LOCKED == err) {
            // this will happen if the db is locked, like if we are doing an update or insert.
            // in that case, retry the step... and maybe wait just 10 milliseconds.
            retry = YES;
            
            usleep(50);
            
            if (numberOfRetries++ > 100) {
                NSLog(@"Database too busy, returning nil data");
                sqlite3_finalize(pStmt);
                retry = NO;
                return nil;
            }
        }
        
    } while (retry);
    
    err = sqlite3_step(pStmt);
    
    // FIXME: check the error in the future.
    int dataSize = sqlite3_column_bytes(pStmt, 0);
    
    NSMutableData *data = [NSMutableData dataWithLength:dataSize];
    
    memcpy([data mutableBytes], sqlite3_column_blob(pStmt, 0), dataSize);
    
    sqlite3_finalize(pStmt);
    
    sqlite3_close(db);
    
    return data;
}

- (void)imageUpdatedAtPath:(NSString*)path {
    
    NSData *d = nil;
    
    if ([path hasSuffix:@".acorn"]) {
        d = [self grabAcornCompositeDataAtPath:path];
    }
    else {
        d = [NSData dataWithContentsOfFile:path];
    }
    
    NSImage *img = [[[NSImage alloc] initWithData:d] autorelease];
    
    [_imageView setImage:img];
}

- (BOOL)application:(NSApplication *)sender openFile:(NSString *)filename {
    
    [self imageUpdatedAtPath:filename];
    
    [self watchImageAtPath:filename];
    
    return YES;
}

- (void)scheduleUpdateForPath:(NSString*)path {
    
    if (_updateScheduled) {
        return;
    }
    
    _updateScheduled = YES;
    
    double delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self imageUpdatedAtPath:path];
        _updateScheduled = NO;
    });
}

- (void)watchImageAtPath:(NSString*)path {
    
    int fildes = open([path UTF8String], O_RDONLY);
    
    unsigned long watchMask = DISPATCH_VNODE_WRITE;
    
    _watcherSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_VNODE, fildes, watchMask, dispatch_get_main_queue());
    
    if (!_watcherSource) {
        NSLog(@"Could not watch %@", path);
        return;
    }
    
    dispatch_source_set_event_handler(_watcherSource, ^ {
        [self scheduleUpdateForPath:path];
    });
    
    dispatch_source_set_cancel_handler(_watcherSource, ^ {
        close(fildes);
    });
    
    dispatch_resume(_watcherSource);
}

@end

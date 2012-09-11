//
//  ACImageUpdateListener.m
//  AcornImageChangeListener
//
//  Created by August Mueller on 3/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

/*
 Important note: This class requires Acorn 3.2.2
 */

#import "ACImageUpdateListener.h"

@interface ACImageUpdateListener ()

@property (retain) id<ACApplication> acornApp;
@property (retain) NSConnection *acornConnection;

@end

@implementation ACImageUpdateListener

@synthesize acornApp = _acornApp;
@synthesize acornConnection = _acornConnection;
@synthesize delegate = _delegate;


+ (id)sharedListener {
    
    static dispatch_once_t once;
    static id myInstance;
    
    dispatch_once(&once, ^{
        myInstance = [[self alloc] init];
    });
    
    return myInstance;
    
}

- (void)dealloc {
    [self stopListening];
    [super dealloc];
}

- (void)startListening {
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self
                                                        selector:@selector(acornImageWasUpdated:)
                                                            name:@"com.flyingmeat.Acorn.ACImageUpdated"
                                                          object:nil
                                              suspensionBehavior:NSNotificationSuspensionBehaviorDeliverImmediately];

}

- (void)stopListening {
    [[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
}



- (void)updateImageWithUUID:(NSString*)documentUUID {
    
    _fetching = YES;
    
    if (![_acornConnection isValid]) {
        [_acornConnection release];
        _acornConnection = nil;
        _acornApp = nil;
    } 
    
    if (!_acornApp) {
        _acornConnection = [[NSConnection connectionWithRegisteredName:@"com.flyingmeat.Acorn.ImageDelivery" host:nil] retain];
        [_acornConnection setRequestTimeout:3];
        
        _acornApp = (id)[[_acornConnection rootProxy] retain];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSData *data = nil;
        
        @try {
            data = [_acornApp tiffDataForOpenDocumentWithUUID:documentUUID];
        }
        @catch (NSException *exception) {
            // looks like Acorn quit behind us?
            
            if (![[exception name] isEqualToString:NSPortTimeoutException]) {
                
                [_acornApp release];
                _acornApp = nil;
                
                [_acornConnection release];
                _acornConnection = nil;
            }
            else {
                NSLog(@"Exception talking to Acorn: %@", exception);
            }
        }
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (data) {
                [_delegate listenerRecievedDataFromAcorn:data];
            }
            
            _fetching = NO;
            
            if (_refetchImageUUID) {
                
                NSString *temp = [[_refetchImageUUID copy] autorelease];
                [_refetchImageUUID release];
                _refetchImageUUID = nil;
                
                [self updateImageWithUUID:temp];
            }
            
        });
    });
}

- (void)acornImageWasUpdated:(NSNotification*)note {
    
    if (!_delegate) {
        NSLog(@"No delegate set for ACImageUpdateListener!");
        return;
    }
    
    if (![_delegate respondsToSelector:@selector(listenerRecievedDataFromAcorn:)]) {
        NSLog(@"Delegate has not implemented listenerRecievedDataFromAcorn:!");
        return;
    }
    
    
    // we coalesce the updates, since we can do a better job than NSDistributedNotificationCenter
    NSString *documentUUID = [note object];
    
    if (_fetching) {
        
        if (!_refetchImageUUID) {
            _refetchImageUUID = [documentUUID retain];
        }
        
        return;
    }
    
    [self updateImageWithUUID:documentUUID];
}


@end

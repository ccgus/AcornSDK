//
//  ACImageUpdateListener.h
//  AcornImageChangeListener
//
//  Created by August Mueller on 3/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ACApplication <NSObject>
- (bycopy NSData*)tiffDataForOpenDocumentWithUUID:(NSString*)path;
@end

@interface ACImageUpdateListener : NSObject {
    NSString *_refetchImageUUID;
    BOOL _fetching;
    
    id _delegate;
}

@property (assign) id delegate;

+ (id)sharedListener;

- (void)startListening;
- (void)stopListening;

@end

@interface NSObject (ACImageUpdateListenerDelegate)
- (void)listenerRecievedDataFromAcorn:(NSData*)data;
@end

//
//  Server.h
//  Socket-Server
//
//  Created by Alonso Zhang on 16/3/17.
//  Copyright © 2016年 Alonso Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Connection.h"

@class Server, Connection;

@protocol ServerDelegate
// Server has been terminated because of an error
- (void) serverFailed;
// Server has accepted a new connection and it needs to be processed
- (void) serverstatus:(NSString *)status;
- (void) handleNewConnectionformNSNetService:(Connection *)connection;
@end

@interface Server : NSObject <NSNetServiceDelegate>
{
    uint16_t           port;
    CFSocketRef        listeningSocket;
}

@property(nonatomic, retain) id<ServerDelegate> delegate;
// Initialize and start listening for connections
- (BOOL) startwithport:(NSString*) Port;
- (void) stop;
@end

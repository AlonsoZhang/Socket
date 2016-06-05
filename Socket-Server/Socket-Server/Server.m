//
//  Server.m
//  Socket-Server
//
//  Created by Alonso Zhang on 16/3/17.
//  Copyright © 2016年 Alonso Zhang. All rights reserved.
//

#import "Server.h"
#include <netinet/in.h>
#include <unistd.h>
#include <CFNetwork/CFSocketStream.h>

@implementation Server

#pragma mark -
#pragma mark Lifecycle
// Create server and announce it
- (BOOL) startwithport:(NSString *) Port
{
    // Start the socket server
    BOOL succeed = [self createServerwith:(uint16_t) [Port intValue]];
    if ( !succeed )
    {
        return NO;
    }
    return YES;
}

// Close everything
- (void) stop
{
    [self terminateServer];
}

#pragma mark -
#pragma mark  Callbacks
// Handle new connections
- (void) handleNewNativeSocket:(CFSocketNativeHandle)nativeSocketHandle
{
    Connection *connection = [[Connection alloc] initWithCFSocketNativeHandle:nativeSocketHandle];
    // In case of errors, close native socket handle
    if ( connection == nil )
    {
        close(nativeSocketHandle);
        return;
    }
    // finish connecting
    BOOL succeed = [connection open];
    if ( !succeed )
    {
        [connection close];
        return;
    }
    // Pass this on to our delegate
    [_delegate handleNewConnectionformNSNetService: connection];
}

// This function will be used as a callback while creating our listening socket via 'CFSocketCreate'
static void serverAcceptCallback(CFSocketRef socket, CFSocketCallBackType type, CFDataRef address, const void *data, void *info)
{
    // We can only process "connection accepted" calls here
    if ( type != kCFSocketAcceptCallBack )
    {
        return;
    }
    // for an AcceptCallBack, the data parameter is a pointer to a CFSocketNativeHandle
    CFSocketNativeHandle nativeSocketHandle = *(CFSocketNativeHandle *)data;
    Server *server = (__bridge Server *)info;
    [server handleNewNativeSocket:nativeSocketHandle];
}

#pragma mark -
#pragma mark  Sockets and streams
- (BOOL) createServerwith:(uint16_t)  Port
{
    CFSocketContext socketCtxt = {0, (__bridge void *) self, NULL, NULL, NULL};
    listeningSocket = CFSocketCreate(kCFAllocatorDefault, AF_INET,  SOCK_STREAM, 0, kCFSocketAcceptCallBack,
                                     (CFSocketCallBack)&serverAcceptCallback, &socketCtxt);
    static const int yes = 1;
    (void) setsockopt(CFSocketGetNative(listeningSocket), SOL_SOCKET, SO_REUSEADDR, (const void *) &yes, sizeof(yes));
    // Set up the IPv4 listening socket; port is 0, which will cause the kernel to choose a port for us.
    struct sockaddr_in addr4;
    memset(&addr4, 0, sizeof(addr4));
    addr4.sin_len = sizeof(addr4);
    addr4.sin_family = AF_INET;
    addr4.sin_port = htons(Port);
    addr4.sin_addr.s_addr = htonl(INADDR_ANY);
    CFSocketSetAddress(listeningSocket, (__bridge CFDataRef) [NSData dataWithBytes:&addr4 length:sizeof(addr4)]);
    // Now that the IPv4 binding was successful, we get the port number to check.
    NSData *addr = (__bridge_transfer NSData *)CFSocketCopyAddress(listeningSocket);
    assert([addr length] == sizeof(struct sockaddr_in));
    self->port = ntohs(((const struct sockaddr_in *)[addr bytes])->sin_port);
    // Set up the run loop sources for the sockets.
    CFRunLoopSourceRef source4 = CFSocketCreateRunLoopSource(kCFAllocatorDefault, listeningSocket, 0);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), source4, kCFRunLoopCommonModes);
    CFRelease(source4);
    return YES;
}

- (void) terminateServer
{
    if ( listeningSocket != nil )
    {
        CFSocketInvalidate(listeningSocket);
        CFRelease(listeningSocket);
        listeningSocket = nil;
    }
}
@end


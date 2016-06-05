//
//  Connection.h
//  Socket-Server
//
//  Created by Alonso Zhang on 16/3/17.
//  Copyright © 2016年 Alonso Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>

@class Connection;

@protocol ConnectionDelegate <NSObject>
- (void) connectionwillclose;
- (void) receivedNetworkPacket:(NSString*)Packet;
@end

@interface Connection : NSObject <NSNetServiceDelegate,NSStreamDelegate>

@property (nonatomic, retain) id<ConnectionDelegate> delegate;
@property (nonatomic, strong, readwrite) NSInputStream  *  inputStream;
@property (nonatomic, strong, readwrite) NSOutputStream *  outputStream;
@property (nonatomic, strong, readwrite) NSMutableData  *  inputBuffer;
@property (nonatomic, strong, readwrite) NSMutableData  *  outputBuffer;

- (id)initWitHost:(NSString*)host Port:(NSString*)port;
- (id)initWithCFSocketNativeHandle:(CFSocketNativeHandle)nativeSocketHandle;
- (BOOL)open;
- (void)close;
- (void) sendNetworkPacket:(NSString *)packet;

@end

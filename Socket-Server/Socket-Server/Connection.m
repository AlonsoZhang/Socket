//
//  Connection.m
//  Socket-Server
//
//  Created by Alonso Zhang on 16/3/17.
//  Copyright © 2016年 Alonso Zhang. All rights reserved.
//

#import "Connection.h"

@implementation Connection

- (id)initWithCFSocketNativeHandle:(CFSocketNativeHandle)nativeSocketHandle
{
    self = [super init];
    if (self != nil)
    {
        CFReadStreamRef readStream = NULL;
        CFWriteStreamRef writeStream = NULL;
        CFStreamCreatePairWithSocket(kCFAllocatorDefault, nativeSocketHandle, &readStream, &writeStream);
        if (readStream && writeStream)
        {
            CFReadStreamSetProperty(readStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
            CFWriteStreamSetProperty(writeStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
            _inputStream  = (__bridge NSInputStream *) readStream;
            _outputStream = (__bridge NSOutputStream *) writeStream;
        }
        else
        {
            (void) close(nativeSocketHandle);
        }
        if (readStream) CFRelease(readStream);
        if (writeStream) CFRelease(writeStream);
    }
    return self;
}


- (id)initWitHost:(NSString*)host Port:(NSString*)port
{
    self = [super init];
    if (self != nil)
    {
        CFReadStreamRef  readStream = NULL;
        CFWriteStreamRef writeStream = NULL;
        CFStreamCreatePairWithSocketToHost(NULL,(__bridge CFStringRef)host ,(UInt32)[port intValue],&readStream, &writeStream);
        if (readStream && writeStream)
        {
            CFReadStreamSetProperty(readStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
            CFWriteStreamSetProperty(writeStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
            _inputStream  = (__bridge NSInputStream *) readStream;
            _outputStream = (__bridge NSOutputStream *) writeStream;
        }
        if (readStream) CFRelease(readStream);
        if (writeStream) CFRelease(writeStream);
    }
    return self;
}

- (BOOL)open
{
    [_inputStream  setDelegate: self];
    [_outputStream setDelegate: self];
    [_inputStream  scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_inputStream  open];
    [_outputStream open];
    NSLog(@"Connection open!");
    return YES;
}

- (void)close
{
    [_inputStream  close];
    [_outputStream close];
    [_inputStream  removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    self.inputStream  = nil;
    self.outputStream = nil;
    self.inputBuffer  = nil;
    self.outputBuffer = nil;
    NSLog(@"Connection closed!");
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)streamEvent
{
    assert(aStream == _inputStream || aStream == _outputStream);
    switch(streamEvent)
    {
        case NSStreamEventHasBytesAvailable:
        {
            [self readinputStream];
        }
            break;
        case NSStreamEventEndEncountered:
        case NSStreamEventErrorOccurred:
        {
            [self connectionwillclose];
        }
            break;
        case NSStreamEventHasSpaceAvailable:
        {
            if ([self.outputBuffer length] != 0)
            {
                [self wirteoutputStream];
            }
        }
            break;
        case NSStreamEventOpenCompleted:
        {
            if (aStream == self.inputStream)
            {
                self.inputBuffer = [[NSMutableData alloc] init];
            }
            else
            {
                self.outputBuffer = [[NSMutableData alloc] init];
            }
        }
            break;
        default:
            break;
    }
}

- (void) readinputStream
{
    int    packetBodySize=0;
    while([self.inputStream hasBytesAvailable])
    {
        uint8_t buffer[2048000];
        NSInteger actuallyRead = [self.inputStream read:(uint8_t *)buffer maxLength:sizeof(buffer)];
        if (actuallyRead > 0)
        {
            [_inputBuffer  appendBytes:buffer length:actuallyRead];
        }
        while( YES )
        {
            // Did we read the header yet?
            if ( packetBodySize == 0 )
            {
                // Do we have enough bytes in the buffer to read the header?
                if ( [_inputBuffer length] >= sizeof(int) )
                {
                    // extract length
                    memcpy(&packetBodySize, [_inputBuffer bytes], sizeof(int));
                    // remove that chunk from buffer
                    NSRange rangeToDelete = {0, sizeof(int)};
                    [_inputBuffer replaceBytesInRange:rangeToDelete withBytes:NULL length:0];
                }
                else
                {
                    break;
                }
            }
            // We should now have the header. Time to extract the body.
            if ( [_inputBuffer length] >= packetBodySize )
            {
                // We now have enough data to extract a meaningful packet.
                NSData* raw = [NSData dataWithBytes:[_inputBuffer bytes] length:packetBodySize];
                NSString * packet = [[NSString alloc] initWithData:raw encoding:NSUTF8StringEncoding];
                // Tell our delegate about it
                //[_delegate receivedNetworkPacket:packet ];
                [_delegate receivedNetworkPacket: [NSString stringWithFormat:@"Receive : %@\n",packet]];
                //[self receivedNetworkPacket:packet];
                // Remove that chunk from buffer
                NSRange rangeToDelete = {0, packetBodySize};
                [_inputBuffer replaceBytesInRange:rangeToDelete withBytes:NULL length:0];
                // We have processed the packet. Resetting the state.
                packetBodySize = 0 ;
            }
            else
            {
                break;
            }
        }
    }
}

- (void) wirteoutputStream
{
    assert([self.outputBuffer length] != 0);
    NSInteger actuallyWritten = [self.outputStream write:[self.outputBuffer bytes] maxLength:[self.outputBuffer length]];
    if (actuallyWritten > 0)
    {
        [self.outputBuffer replaceBytesInRange:NSMakeRange(0, (NSUInteger) actuallyWritten) withBytes:NULL length:0];
    }
    else
    {
        [self close];
    }
}

// Send network message
- (void) sendNetworkPacket:(NSString *)packet
{
    NSData *rawPacket = [packet dataUsingEncoding:NSUTF8StringEncoding];
    // Write header: lengh of raw packet
    NSInteger packetLength = [rawPacket length];
    [_outputBuffer appendBytes:&packetLength length:sizeof(int)];
    // Write body: encoded NSDictionary
    [_outputBuffer appendData:rawPacket];
    // Try to write to stream
    [self wirteoutputStream];
}

- (void) receivedNetworkPacket:(NSString*)packet
{
    [_delegate receivedNetworkPacket: [NSString stringWithFormat:@"%@",packet]];
}

- (void) connectionwillclose
{
    [_delegate connectionwillclose];
}

@end

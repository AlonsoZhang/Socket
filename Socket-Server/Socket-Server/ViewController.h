//
//  ViewController.h
//  Socket-Server
//
//  Created by Alonso Zhang on 16/3/17.
//  Copyright © 2016年 Alonso Zhang. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Server.h"
#import "Connection.h"

@interface ViewController : NSViewController<ServerDelegate,ConnectionDelegate>
{
    Server *server;
    Connection *connection;
}

@property (weak) IBOutlet NSTextField  *ListeningPort;
@property (unsafe_unretained) IBOutlet NSTextView *MessageText;
@property (weak) IBOutlet NSTextField  *SendMessages;
@property (weak) IBOutlet NSButton *Stop;
@property (weak) IBOutlet NSButton *Start;
@property (weak) IBOutlet NSTextField *SeverStaus;
@property (weak) IBOutlet NSImageView *ConnectionStaus;

- (IBAction)Severstop:(id)sender;
- (IBAction)Severstart:(id)sender;
- (IBAction)Sendinfo:(id)sender;

@end


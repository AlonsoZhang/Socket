//
//  ViewController.h
//  Socket-Client
//
//  Created by Alonso Zhang on 16/3/17.
//  Copyright © 2016年 Alonso Zhang. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Connection.h"

@interface ViewController : NSViewController <ConnectionDelegate>
{
    Connection *connection;
}

@property (weak) IBOutlet NSTextField *serverip;
@property (weak) IBOutlet NSTextField *serverport;
@property (weak) IBOutlet NSButton *ConnectButton;
@property (weak) IBOutlet NSButton *DisconnectButton;
@property (unsafe_unretained) IBOutlet NSTextView *message;
@property (weak) IBOutlet NSImageView *connectimage;
@property (weak) IBOutlet NSTextField *sendmessage;
@property (weak) IBOutlet NSButton *AutoReply;

- (IBAction)doconnect:(id)sender;
- (IBAction)dodisconnect:(id)sender;
- (IBAction)dosend:(id)sender;

@end
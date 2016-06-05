//
//  ViewController.m
//  Socket-Client
//
//  Created by Alonso Zhang on 16/3/17.
//  Copyright © 2016年 Alonso Zhang. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.sendmessage.enabled = NO;
}

#pragma mark -
#pragma mark ConnectionDelegate

- (void)connectionwillclose
{
    [connection close];
    connection=nil;
    [self.sendmessage setBackgroundColor: [NSColor redColor]];
    self.sendmessage.enabled=NO;
    self.sendmessage.placeholderString = @"The connection/port is not useful.";
    [self.connectimage setImage:[NSImage imageNamed:@"disconnect.png"]];
    self.DisconnectButton.enabled = NO;
    self.ConnectButton.enabled = YES;
}

- (void) receivedNetworkPacket:(NSString*)packet
{
    NSString * currentString = [NSString stringWithFormat:@"%@%@",
                                [_message string], packet];
    [_message setString:currentString];
    NSRange range = [currentString rangeOfString:packet options:NSBackwardsSearch];
    [_message scrollRangeToVisible:range];
    if (_AutoReply.state)
    {
        [self AutomaticReply:@"Here is auto reply!"];
    }
}

- (void) AutomaticReply:(NSString*)packet
{
    [connection sendNetworkPacket: packet];
    packet=[NSString stringWithFormat:@"Send      : %@\n",packet];
    NSString * currentString = [NSString stringWithFormat:@"%@%@",
                                [_message string], packet];
    [_message setString:currentString];
    NSRange range = [currentString rangeOfString:packet options:NSBackwardsSearch];
    [_message scrollRangeToVisible:range];
}

- (IBAction)doconnect:(id)sender
{
    connection= [[Connection alloc]initWitHost:_serverip.stringValue Port:_serverport.stringValue];
    connection.delegate=self;
    [connection open];
    [self.sendmessage setBackgroundColor: [NSColor greenColor]];
    self.sendmessage.enabled = YES;
    self.sendmessage.placeholderString = @"Press \"Enter\" to send message";
    [self.connectimage setImage:[NSImage imageNamed:@"connect.png"]];
    self.DisconnectButton.enabled = YES;
    self.ConnectButton.enabled    = NO;
}

- (IBAction)dodisconnect:(id)sender
{
    [connection close];
    connection=nil;
    [self.sendmessage setBackgroundColor: [NSColor redColor]];
    self.sendmessage.enabled = NO;
    self.sendmessage.placeholderString = @"You disconnected.";
    NSImage *image = [NSImage imageNamed:@"disconnect.png"];
    [self.connectimage setImage:image];
    self.DisconnectButton.enabled = NO;
    self.ConnectButton.enabled = YES;
}

- (IBAction)dosend:(id)sender
{
    NSTextField * textField = (NSTextField *)sender;
    NSString * text = [textField stringValue];
    [textField setStringValue:@""];
    if (text && [text length] > 0 &&  connection != nil )
    {
        [connection sendNetworkPacket: text];
        [self receivedNetworkPacket: [NSString stringWithFormat:@"Send      : %@\n",text]];
    }
}

@end

//
//  ViewController.m
//  Socket-Server
//
//  Created by Alonso Zhang on 16/3/17.
//  Copyright © 2016年 Alonso Zhang. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    server = [[Server alloc] init];
    server.delegate=self;
    [self Severstart:self];
    self.SendMessages.enabled = NO;
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    // Update the view, if already loaded.
}

- (IBAction)Severstop:(id)sender
{
    [server stop];
    self.Start.enabled = YES;
    self.Stop.enabled = NO;
    self.SeverStaus.stringValue = @"Stop Sever succeed!";
    [self.SeverStaus setBackgroundColor:[NSColor grayColor]];
}

- (IBAction)Severstart:(id)sender
{
    BOOL succeed =[server startwithport:self.ListeningPort.stringValue];
    if ( succeed )
    {
        NSString *checkport=[server valueForKey:@"port"];
        if ( [checkport intValue] == [self.ListeningPort.stringValue intValue])
        {
            self.Start.enabled = NO;
            self.Stop.enabled  = YES;
            self.SeverStaus.stringValue = @"Start Sever succeed!";
            [self.SeverStaus setBackgroundColor:[NSColor greenColor]];
        }
        else
        {
            [server stop];
            self.SeverStaus.stringValue = @"ListeningPort is not userful!";
            [self.SeverStaus setBackgroundColor:[NSColor redColor]];
        }
    }
    else
    {
        self.SeverStaus.stringValue = @"Start sever failed!";
        [self.SeverStaus setBackgroundColor:[NSColor redColor]];
    }
}

- (IBAction)Sendinfo:(id)sender
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

#pragma mark -
#pragma mark ServerDelegate
- (void) serverstatus:(NSString *)status
{
    
}

- (void) serverFailed
{
    
}

- (void) handleNewConnectionformNSNetService:(Connection *)PassConnection
{
    if ( PassConnection != nil )
    {
        connection = [[Connection alloc]init];
        connection = PassConnection;
        connection.delegate=self;
        [self.ConnectionStaus setImage:[NSImage imageNamed:@"connect.png"]];
        self.SendMessages.enabled = YES ;
        [self.SendMessages setBackgroundColor:[NSColor greenColor]];
        self.SendMessages.placeholderString = @"Press \"Enter\" to send message";
        [server stop];
        self.Start.enabled = NO;
        self.Stop.enabled = NO;
        self.SeverStaus.stringValue = @"Lock Sever!";
        [self.SeverStaus setBackgroundColor:[NSColor yellowColor]];
    }
}

#pragma mark -
#pragma mark ConnectionDelegate
- (void)connectionwillclose
{
    [connection close];
    connection=nil;
    [self Severstart:self];
    [self.ConnectionStaus setImage:[NSImage imageNamed:@"disconnect.jpeg"]];
    self.SendMessages.enabled = NO;
    [self.SendMessages setBackgroundColor:[NSColor redColor]];
    self.SendMessages.placeholderString = @"Disconnect.";
}

- (void) receivedNetworkPacket:(NSString*)packet
{
    //packet=[NSString stringWithFormat:@"Send      : %@\n",packet];
    NSString * currentString = [NSString stringWithFormat:@"%@%@",
                                [_MessageText string], packet];
    [_MessageText setString:currentString];
    NSRange range = [currentString rangeOfString:packet options:NSBackwardsSearch];
    [_MessageText scrollRangeToVisible:range];
}

@end

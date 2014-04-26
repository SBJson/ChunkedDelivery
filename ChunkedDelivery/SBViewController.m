//
//  SBViewController.m
//  ChunkedDelivery
//
//  Created by Stig Brautaset on 26/04/2014.
//  Copyright (c) 2014 Stig Brautaset. All rights reserved.
//

#import "SBViewController.h"
#import <SBJson4.h>

@interface SBViewController ()< NSURLSessionDataDelegate >

@property (weak) IBOutlet UITextField *urlField;
@property (weak) IBOutlet UITextView *textView;
@property (strong) SBJson4Parser *parser;

@end

@implementation SBViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)go {
    NSLog(@"Go is a-go!: %@", self.urlField.text);

    id block = ^(id item, BOOL *stop) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.textView.text = [item description];
        });
    };

    id eh = ^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.textView.text = [NSString stringWithFormat:@"There was an error downloading: %@", error.localizedDescription];
        });
    };

    self.parser = [SBJson4Parser unwrapRootArrayParserWithBlock:block
                                                   errorHandler:eh];

    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                             delegate:self
                                                        delegateQueue:nil];

    NSURL *url = [NSURL URLWithString:self.urlField.text];
    NSURLSessionDataTask *urlSessionDataTask = [urlSession dataTaskWithURL:url];

    [urlSessionDataTask resume];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {

    switch ([self.parser parse:data]) {
        case SBJson4ParserError:
            NSLog(@"Found an error");
            [session invalidateAndCancel];
            self.parser = nil;
            break;
        case SBJson4ParserComplete:
        case SBJson4ParserStopped:
            self.parser = nil;
            break;
        case SBJson4ParserWaitingForData:
            NSLog(@"Waiting for more data!");
            break;
    }
}


@end
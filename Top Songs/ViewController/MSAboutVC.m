//
//  MSAboutVC.m
//  Top Songs
//
//  Created by Maksym Savisko on 5/7/16.
//  Copyright © 2016 Maksym Savisko. All rights reserved.
//

#import "MSAboutVC.h"
#import <MessageUI/MessageUI.h>

@interface MSAboutVC () <MFMailComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *sendFeedbackButton;

@end

@implementation MSAboutVC
#pragma mark - Action
- (IBAction)sendFeedbackButtonPressed:(id)sender {
    [self sendFeedback];
    
}

#pragma mark - MFMailComposeViewControllerDelegate
- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            //Mail cancelled
            break;
        case MFMailComposeResultSaved:
            //Mail saved
            break;
        case MFMailComposeResultSent:
            //Mail sent
            break;
        case MFMailComposeResultFailed:
            //NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - HelperMethod
- (void) sendFeedback {
    NSString *emailTitle = @"Top Songs App. Feedback";
    NSArray *toRecipents = [NSArray arrayWithObject:@"stowyn@gmail.com"];
    MFMailComposeViewController *email = [[MFMailComposeViewController alloc] init];
    email.mailComposeDelegate = self;
    [email setSubject:emailTitle];
    [email setToRecipients:toRecipents];
    [self presentViewController:email animated:YES completion:NULL];
}


@end

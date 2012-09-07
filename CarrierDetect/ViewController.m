//
//  ViewController.m
//  CarrierDetect
//
//  Created by Kane on 7/9/12.
//
//

#import "ViewController.h"
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

@interface ViewController ()
@property (nonatomic, strong) IBOutlet UILabel *textLabel;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
  // Setup the Network Info and create a CTCarrier object
  CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
  CTCarrier *carrier = [networkInfo subscriberCellularProvider];
  
  // Get carrier name
  NSString *carrierName = [carrier carrierName];
  if (carrierName != nil)
    NSLog(@"Carrier: %@", carrierName);
  self.textLabel.text = carrierName;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return YES;
}

@end

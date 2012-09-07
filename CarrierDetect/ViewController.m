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
@synthesize textLabel;

- (void)viewDidLoad
{
  [super viewDidLoad];
}

- (void)viewDidUnload
{
  [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  
  // Setup the Network Info and create a CTCarrier object
  CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
  CTCarrier *carrier = [networkInfo subscriberCellularProvider];
  
  // Get carrier name
  NSString *carrierName = [carrier carrierName];
  if (carrierName == nil)
    carrierName = @"No carrier";
  
  self.textLabel.text = carrierName;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return YES;
}

@end

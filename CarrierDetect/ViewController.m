//
//  ViewController.m
//  CarrierDetect
//
//  Created by Kane on 7/9/12.
//
//

#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import "ViewController.h"
#import "NetworkInfo.h"
#import "Reachability.h"

@interface ViewController ()
@property (nonatomic, strong) IBOutlet UILabel *textLabel;
@property (nonatomic, assign) BOOL is3G;
@property (nonatomic, strong) NetworkInfo *networkInfo;
@end

@implementation ViewController
@synthesize textLabel;
@synthesize networkInfo;

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.is3G = NO;
  self.networkInfo = [[NetworkInfo alloc] initWithDelegate:self];
}

- (void)viewDidUnload
{
  [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  
  NSString *carrier = [self getCarrierName];
  if (carrier == nil) {
    self.textLabel.text = @"No carrier";
    return;
  }
  
  self.textLabel.text = carrier;
  [self.networkInfo update];
  [self updateUI];
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  
  [self checkReachability];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return YES;
}


#pragma mark - Helpers

- (NSString*)getCarrierName
{
  // Setup the Network Info and create a CTCarrier object
  CTTelephonyNetworkInfo *carrierInfo = [[CTTelephonyNetworkInfo alloc] init];
  CTCarrier *carrier = [carrierInfo subscriberCellularProvider];
  
  // Get carrier name
  NSString *carrierName = [carrier carrierName];
  
  return carrierName;
}

- (void)checkReachability
{
  Reachability* reach = [Reachability reachabilityForInternetConnection];
  reach.reachableOnWWAN = YES;
  
  reach.reachableBlock = ^(Reachability*reach)
  {
    self.is3G = [reach isReachableViaWWAN] == YES && [reach isReachableViaWiFi] == NO;
    
    [self.networkInfo update];
  };
  
  reach.unreachableBlock = ^(Reachability*reach)
  {
    
  };
}

- (void)updateUI
{
  NSString *textString = [self getCarrierName];
  if (textString == nil) {
    self.textLabel.text = @"No carrier";
    return;
  }
  
  textString = [NSString stringWithFormat:@"Home Carrier: %@", textString];

  //Not accurate at all
  //Wifi, don't need to find more information
  //if (self.is3G == NO)
  //  textString = [textString stringByAppendingString:@"\n(on WiFi)"];
  
  if (self.networkInfo.publicIP != nil)
    textString = [textString stringByAppendingFormat:@"\n%@", self.networkInfo.publicIP];
  
  if (self.networkInfo.netname != nil)
    textString = [textString stringByAppendingFormat:@"\n%@", self.networkInfo.netname];
  
  if (self.networkInfo.mntIrt != nil)
    textString = [textString stringByAppendingFormat:@"\n%@", self.networkInfo.mntIrt];
  
  self.textLabel.text = textString;
}


#pragma mark - NetworkInfoDelegate

- (void)didReceivedPublicIpAddress:(NSString*)publicIP
{
  [self updateUI];
}

- (void)didReceivedWhoIsInfo
{
  [self updateUI];
}

- (void)failedToObtainPublicIpAddress:(NSError*)error
{
  [self updateUI];
}

- (void)failedToObtainWhoIsInfo:(NSError*)error
{
  [self updateUI]; 
}

@end

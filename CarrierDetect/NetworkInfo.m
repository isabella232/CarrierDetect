//
//  NetworkInfo.m
//  CarrierDetect
//
//  Created by Torin on 7/9/12.
//
//

#import "NetworkInfo.h"
#import "NSString+Additions.h"

#define STATE_IP          1
#define STATE_ISP         2
#define IP_URL            @"http://api.externalip.net/ip/"
#define GEO_IP_URL        @"http://www.whoisxmlapi.com/whoisserver/WhoisService?outputFormat=JSON&domainName=%@"

@interface NetworkInfo () <NSURLConnectionDataDelegate>

@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, assign) int requestState;

@end

@implementation NetworkInfo
@synthesize delegate;
@synthesize publicIP, netname, mntIrt;
@synthesize requestState;

- (id)initWithDelegate:(id)theDelegate
{
  self = [super init];
  if (self == nil)
    return self;
  
  self.delegate = theDelegate;
  
  return self;
}

- (void)update
{
  self.publicIP = nil;
  self.netname = nil;
  self.mntIrt = nil;
  
  [self getpublicIPAddress];
}


#pragma mark -

- (void)getpublicIPAddress
{
  self.requestState = STATE_IP;
  self.publicIP = nil;
  
  NSString *requestUrl = [NSString stringWithFormat:IP_URL];
  NSLog(@"requestUrl: %@", requestUrl);
  
  NSURL *myURL = [NSURL URLWithString:requestUrl];
  NSMutableURLRequest *myRequest = [[NSMutableURLRequest alloc] initWithURL:myURL];
  NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:myRequest delegate:self];
  
  connection = nil;
}

- (void)getISPForIP:(NSString*)ipaddress
{
  self.requestState = STATE_ISP;
  self.netname = nil;
  self.mntIrt = nil;
  
  NSString *requestUrl = [NSString stringWithFormat:GEO_IP_URL, ipaddress];
  NSLog(@"requestUrl: %@", requestUrl);
  
  NSURL *myURL = [NSURL URLWithString:requestUrl];
  NSMutableURLRequest *myRequest = [[NSMutableURLRequest alloc] initWithURL:myURL];
  NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:myRequest delegate:self];
  
  connection = nil;
}

- (NSString*)extractStringFrom:(NSString*)rawString stringBetweenString:(NSString*)start andString:(NSString*)end
{
  NSRange startRange = [rawString rangeOfString:start];
  if (startRange.location == NSNotFound)
    return nil;
  
  NSRange targetRange;
  targetRange.location = startRange.location + startRange.length;
  targetRange.length = [rawString length] - targetRange.location;
  NSRange endRange = [rawString rangeOfString:end options:0 range:targetRange];
  if (endRange.location != NSNotFound) {
    targetRange.length = endRange.location - targetRange.location;
    NSString *substring = [rawString substringWithRange:targetRange];
    NSString *trimmed = [self trim:substring];
    return trimmed;
  }
  
  return nil;
}

- (NSString*)trim:(NSString*)rawString
{
  NSArray* newLineChars = [NSArray arrayWithObjects:@"\\u000a", @"\\u000b", @"\\u000c", @"\\u000d", @"\\u0085", nil];
  for (NSString *newline in newLineChars)
    rawString = [rawString stringByReplacingOccurrencesOfString:newline withString:@""];
  
  NSString *trimmed = [rawString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  return trimmed;
}


#pragma mark - NSURLConnection delegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{  
  if (self.requestState == STATE_IP)
  {
    if ([self.delegate respondsToSelector:@selector(failedToObtainPublicIpAddress:)])
      [self.delegate failedToObtainPublicIpAddress:error];
  }
  else if (self.requestState == STATE_ISP)
  {
    if ([self.delegate respondsToSelector:@selector(failedToObtainWhoIsInfo:)])
      [self.delegate failedToObtainWhoIsInfo:error];
  }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
  self.responseData = [NSMutableData data];
  [self.responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
  [self.responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
  NSString *stringData = [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding];
  
  if (self.requestState == STATE_IP)
  {
    self.publicIP = stringData;
    NSLog(@"public IP: %@", self.publicIP);
    
    if ([self.delegate respondsToSelector:@selector(didReceivedPublicIpAddress:)])
      [self.delegate didReceivedPublicIpAddress:self.publicIP];
    
    [self getISPForIP:self.publicIP];
    return;
  }
  
  if (self.requestState == STATE_ISP)
  {
    NSArray *chunks = [stringData componentsSeparatedByString:@"\\u000a"];
    
    for (NSString *string in chunks)
    {
      if ([string contains:@"netname:"])
        self.netname = [self trim:[string stringByReplacingOccurrencesOfString:@"netname:" withString:@""]];
      if ([string contains:@"mnt-irt:"])
        self.mntIrt = [self trim:[string stringByReplacingOccurrencesOfString:@"mnt-irt:" withString:@""]];
    }
    
    NSLog(@"netname: %@", self.netname);
    NSLog(@"mnt-irt: %@", self.mntIrt);

    if ([self.delegate respondsToSelector:@selector(didReceivedWhoIsInfo)])
      [self.delegate didReceivedWhoIsInfo];
    
    return;
  }
}

@end
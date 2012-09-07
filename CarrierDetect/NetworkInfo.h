//
//  NetworkInfo.h
//  CarrierDetect
//
//  Created by Torin on 7/9/12.
//
//

#import <Foundation/Foundation.h>

@class NetworkInfo;

@protocol NetworkInfoDelegate <NSObject>
@optional
- (void)didReceivedPublicIpAddress:(NSString*)publicIP;
- (void)didReceivedWhoIsInfo;
- (void)failedToObtainPublicIpAddress:(NSError*)error;
- (void)failedToObtainWhoIsInfo:(NSError*)error;
@end

@interface NetworkInfo : NSObject

@property (nonatomic, unsafe_unretained) id delegate;
@property (nonatomic, strong) NSString *publicIP;
@property (nonatomic, strong) NSString *netname;
@property (nonatomic, strong) NSString *mntIrt;

- (id)initWithDelegate:(id)theDelegate;
- (void)update;

@end

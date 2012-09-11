//
//  main.m
//  CarrierDetect
//
//  Created by Kane on 7/9/12.
//
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"

int main(int argc, char *argv[])
{
  //Tall mode for iPhone5
  setenv("CLASSIC", "0", 1);
  
  @autoreleasepool {
      return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
  }
}

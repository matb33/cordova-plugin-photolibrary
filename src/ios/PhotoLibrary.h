#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLLocationManager.h>
#import <Cordova/CDVPlugin.h>

@interface PhotoLibrary : CDVPlugin
{}

- (void)getPhotos:(CDVInvokedUrlCommand*)command;

@end
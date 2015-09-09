#import <Foundation/Foundation.h>
#import <Cordova/CDVPlugin.h>

@interface PhotoLibrary : CDVPlugin
{}

@property (strong, nonatomic) NSMutableArray *mutableArrayContainingNumbers;

- (void)getRandomPhotos:(CDVInvokedUrlCommand*)command;

@end
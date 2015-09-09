#import "PhotoLibrary.h"
#import <Photos/Photos.h>

@implementation PhotoLibrary

@synthesize mutableArrayContainingNumbers;

- (NSInteger) getRandomNumber:(NSUInteger)maxRandomNumber {
    NSUInteger randomNumber = (NSInteger) arc4random_uniform(maxRandomNumber);
    if ([self.mutableArrayContainingNumbers containsObject: [NSNumber numberWithInteger:randomNumber]]) {
        return [self getRandomNumber:maxRandomNumber]; // call the method again and get a new object
    } else {
        [self.mutableArrayContainingNumbers addObject: [NSNumber numberWithInteger:randomNumber]];
        return randomNumber;
    }
}

- (void)getRandomPhotos:(CDVInvokedUrlCommand*)command {
    NSNumber* howMany = [command argumentAtIndex:0 withDefault:nil];
    
    [self.commandDelegate runInBackground:^{
        PHFetchResult *fetchResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:nil];
        
        // generate howMany randomIndexes with a maximum based on fetchResult.count
        NSMutableIndexSet *randomIndexes = [NSMutableIndexSet indexSet];
        for (int i = 0; i < (int)howMany; i++) {
            [randomIndexes addIndex:[self getRandomNumber:fetchResult.count]];
        }
        
        NSMutableArray *randomPhotos = [[NSMutableArray alloc] init];
        [fetchResult enumerateObjectsAtIndexes:randomIndexes options:NSEnumerationConcurrent usingBlock:^(PHAsset *asset, NSUInteger idx, BOOL *stop) {
            [[PHImageManager defaultManager] requestImageForAsset:asset
                                             targetSize:CGSizeMake(1920, 1080)
                                             contentMode:PHImageContentModeAspectFill
                                             options:PHImageRequestOptionsVersionCurrent
                                             resultHandler:^(UIImage *result, NSDictionary *info) {
                                                 NSURL* imageURL = [info objectForKey:UIImagePickerControllerReferenceURL];
                                                [randomPhotos addObject:imageURL];
                                             }];
        }];

        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsMultipart:randomPhotos];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

@end
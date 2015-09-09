#import <Cordova/CDV.h>
#import <Photos/Photos.h>

#import "PhotoLibrary.h"

@implementation PhotoLibrary

@synthesize mutableArrayContainingNumbers;

- (NSInteger) getRandomNumber:(NSUInteger)maxRandomNumber {
    NSUInteger randomNumber = (NSInteger) arc4random_uniform((int)maxRandomNumber);
    if ([self.mutableArrayContainingNumbers containsObject: [NSNumber numberWithInteger:randomNumber]]) {
        return [self getRandomNumber:maxRandomNumber];
    } else {
        [self.mutableArrayContainingNumbers addObject: [NSNumber numberWithInteger:randomNumber]];
        return randomNumber;
    }
}

- (NSMutableIndexSet*) generateRandomIndexes:(NSNumber*)howMany :(NSUInteger)maxRandomNumber {
    NSMutableIndexSet *randomIndexes = [[NSMutableIndexSet alloc] init];
    for (int i = 0; i < [howMany intValue]; i++) {
        [randomIndexes addIndex:[self getRandomNumber:maxRandomNumber]];
    }
    return randomIndexes;
}

- (void)getRandomPhotos:(CDVInvokedUrlCommand*)command {
    NSNumber *howMany = [command argumentAtIndex:0];

    NSLog(@"[getRandomPhotos] howMany: %@", howMany);

    [self.commandDelegate runInBackground:^{
        PHFetchResult *fetchResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:nil];
        NSUInteger fetchResultCount = fetchResult.count;
        NSMutableArray *randomPhotos = [[NSMutableArray alloc] init];

        if (fetchResultCount > 0) {
            while (randomPhotos.count < howMany.intValue) {
                NSMutableIndexSet *randomIndexes = [self generateRandomIndexes:howMany :fetchResultCount];
                NSLog(@"[getRandomPhotos] randomIndexes: %@", randomIndexes);

                [fetchResult enumerateObjectsAtIndexes:randomIndexes options:0 usingBlock:^(PHAsset *asset, NSUInteger idx, BOOL *stop) {
                    NSLog(@"[getRandomPhotos] asset: %@", asset);

                    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
                    options.version = PHImageRequestOptionsVersionOriginal;
                    options.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
                    options.resizeMode = PHImageRequestOptionsResizeModeFast;
                    options.synchronous = YES;
                    options.networkAccessAllowed = NO;

                    [[PHImageManager defaultManager] requestImageForAsset:asset
                                                               targetSize:CGSizeMake(asset.pixelWidth * 0.5, asset.pixelHeight * 0.5)
                                                              contentMode:PHImageContentModeAspectFill
                                                                  options:options
                                                            resultHandler:^(UIImage *image, NSDictionary *info) {

                                                                NSData *imageData = UIImagePNGRepresentation(image);
                                                                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                                                                NSString *documentsDirectory = [paths objectAtIndex:0];
                                                                NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", [NSString stringWithFormat:@"cached-%@", @(idx)]]];

                                                                if (![imageData writeToFile:imagePath atomically:YES]) {
                                                                    NSLog(@"[getRandomPhotos] Failed to cache image data to disk");
                                                                } else {
                                                                    NSLog(@"[getRandomPhotos] imagePath: %@", imagePath);
                                                                    [randomPhotos addObject:imagePath];
                                                                }
                                                            }];
                }];
            }
        }

        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:randomPhotos];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

@end
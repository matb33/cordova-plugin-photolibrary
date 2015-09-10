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

- (UIImage*) normalizeImage:(UIImage*)image {
    if (image.imageOrientation == UIImageOrientationUp) return image;
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    [image drawInRect:(CGRect){0, 0, image.size}];
    UIImage *normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return normalizedImage;
}

- (void)getRandomPhotos:(CDVInvokedUrlCommand*)command {
    NSNumber *howMany = [command argumentAtIndex:0];
    
    NSLog(@"[getRandomPhotos] howMany: %@", howMany);
    
    [self.commandDelegate runInBackground:^{
        NSMutableArray *randomPhotos = [[NSMutableArray alloc] init];
        
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus authorizationStatus) {
            if (authorizationStatus == PHAuthorizationStatusAuthorized) {
                
                PHFetchResult *fetchResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:nil];
                NSUInteger fetchResultCount = fetchResult.count;
                
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
                                                                        NSLog(@"[getRandomPhotos] Normalizing image...");
                                                                        UIImage *normalizedImage = [self normalizeImage:image];
                                                                        NSLog(@"[getRandomPhotos] Generating JPEG representation...");
                                                                        NSData *imageData = UIImageJPEGRepresentation(normalizedImage, 0.6);
                                                                        if (imageData) {
                                                                            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                                                                            NSString *documentsDirectory = [paths objectAtIndex:0];
                                                                            NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg", [NSString stringWithFormat:@"Picture %@", @(idx)]]];
                                                                            NSError* error;
                                                                            
                                                                            NSLog(@"[getRandomPhotos] Writing to disk: %@", imagePath);
                                                                            BOOL written = [imageData writeToFile:imagePath options:NSDataWritingAtomic error:&error];
                                                                            if (written) {
                                                                                NSLog(@"[getRandomPhotos] Successfully cached: %@", imagePath);
                                                                                [randomPhotos addObject:imagePath];
                                                                            } else {
                                                                                NSLog(@"[getRandomPhotos] Failed to cache: %@ %@", imagePath, error);
                                                                            }
                                                                        } else {
                                                                            NSLog(@"[getRandomPhotos] Could not convert to JPEG, skipping...");
                                                                        }
                                                                    }];
                        }];
                    }
                }
            }
            
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:randomPhotos];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
    }];
}

@end
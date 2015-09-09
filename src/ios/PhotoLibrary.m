#import <Cordova/CDV.h>
#import <Photos/Photos.h>

#import "PhotoLibrary.h"

@implementation PhotoLibrary

@synthesize mutableArrayContainingNumbers;

- (NSInteger) getRandomNumber:(NSUInteger)maxRandomNumber {
    NSUInteger randomNumber = (NSInteger) arc4random_uniform((int)maxRandomNumber);
    if ([self.mutableArrayContainingNumbers containsObject: [NSNumber numberWithInteger:randomNumber]]) {
        return [self getRandomNumber:maxRandomNumber]; // call the method again and get a new object
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
    NSNumber *targetWidth = [command argumentAtIndex:1 withDefault:@(1280)];
    NSNumber *targetHeight = [command argumentAtIndex:2 withDefault:@(720)];
    
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
                    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
                    options.resizeMode = PHImageRequestOptionsResizeModeNone;
                    options.synchronous = YES;
                    options.networkAccessAllowed = NO;
                    
                    [[PHImageManager defaultManager] requestImageForAsset:asset
                                                               targetSize:CGSizeMake(targetWidth.floatValue, targetHeight.floatValue)
                                                              contentMode:PHImageContentModeAspectFill
                                                                  options:options
                                                            resultHandler:^(UIImage *result, NSDictionary *info) {
                                                                NSURL *imageFileURL = [info objectForKey:@"PHImageFileURLKey"];
                                                                NSString *imageURL = [imageFileURL relativePath];
                                                                NSLog(@"[getRandomPhotos] imageURL: %@", imageURL);
                                                                if (imageURL) {
                                                                    [randomPhotos addObject:imageURL];
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

/*
 - (void)showSquareImageForAsset:(PHAsset *)asset
 {
 NSInteger retinaScale = [UIScreen mainScreen].scale;
 CGSize retinaSquare = CGSizeMake(100*retinaScale, 100*retinaScale);
 
 PHImageRequestOptions *cropToSquare = [[PHImageRequestOptions alloc] init];
 cropToSquare.resizeMode = PHImageRequestOptionsResizeModeExact;
 
 CGFloat cropSideLength = MIN(asset.pixelWidth, asset.pixelHeight);
 CGRect square = CGRectMake(0, 0, cropSideLength, cropSideLength);
 CGRect cropRect = CGRectApplyAffineTransform(square,
 CGAffineTransformMakeScale(1.0 / asset.pixelWidth,
 1.0 / asset.pixelHeight));
 
 cropToSquare.normalizedCropRect = cropRect;
 
 [[PHImageManager defaultManager]
 requestImageForAsset:(PHAsset *)asset
 targetSize:retinaSquare
 contentMode:PHImageContentModeAspectFit
 options:cropToSquare
 resultHandler:^(UIImage *result, NSDictionary *info) {
 self.imageView.image = result;
 }];
 }
 */
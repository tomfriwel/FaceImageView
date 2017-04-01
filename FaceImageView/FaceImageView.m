//
//  FaceImageView.m
//  FaceImageView
//
//  Created by tomfriwel on 01/04/2017.
//  Copyright © 2017 tomfriwel. All rights reserved.
//

#import "FaceImageView.h"

#import <ImageIO/ImageIO.h>

@implementation FaceImageView

-(void)awakeFromNib {
    [super awakeFromNib];
//    self.contentMode = UIViewContentModeScaleAspectFill;
    self.clipsToBounds = YES;
}

-(void)setImage:(UIImage *)image {
    [super setImage:image];
    
    [self setupFaceMask];
}

-(void)setupFaceMask {
    if (self.image) {
        UIImage *image = self.image;
        NSData *imageData = UIImagePNGRepresentation(image);
        CIImage *ciImage = [CIImage imageWithData:imageData];
        
        [self anonymous:ciImage];
        
        //    Creating a face detector
        CIContext *context = [CIContext context];
        NSDictionary *options = @{ CIDetectorAccuracy : CIDetectorAccuracyHigh };
        
        if([[ciImage properties] valueForKey:(NSString *)kCGImagePropertyOrientation] == nil) {
            options = @{CIDetectorImageOrientation : [NSNumber numberWithInt:1]};
        }
        else
        {
            options = @{CIDetectorImageOrientation : [[ciImage properties] valueForKey:(NSString *)kCGImagePropertyOrientation]};
        }
        
        CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace context:context options:options];
        
        NSArray *features = [detector featuresInImage:ciImage options:options];
        
        NSLog(@"%@", features);
        
        CGRect centerRect = CGRectZero;
        
        int i=0;
        for (CIFaceFeature *f in features) {
            NSLog(@"%@", NSStringFromCGRect(f.bounds));
            
            
            CGRect frame = f.bounds;
            frame.origin.y = image.size.height - frame.origin.y - frame.size.height;
            if (i==0) {
                centerRect = frame;
                i++;
            }
            else{
                centerRect = [self calculateCenter:centerRect rect:frame];
                i++;
            }
            
            UIView *view = [[UIView alloc] initWithFrame:frame];
            view.backgroundColor = [UIColor grayColor];
            [self addSubview:view];
            
            if (f.hasLeftEyePosition) {
                NSLog(@"Left eye %g %g", f.leftEyePosition.x, f.leftEyePosition.y);
            }
            if (f.hasRightEyePosition) {
                NSLog(@"Right eye %g %g", f.rightEyePosition.x, f.rightEyePosition.y);
            }
            if (f.hasMouthPosition) {
                NSLog(@"Mouth %g %g", f.mouthPosition.x, f.mouthPosition.y);
            }
        }
        
//        CGRect frame = centerRect;
//        UIView *view = [[UIView alloc] initWithFrame:frame];
//        view.backgroundColor = [UIColor grayColor];
//        [self addSubview:view];
    }
}

-(CGRect)calculateCenter:(CGRect)rect0 rect:(CGRect)rect1 {
    CGFloat x0 = rect0.origin.x, x1 = rect1.origin.x;
    CGFloat y0 = rect0.origin.y, y1 = rect1.origin.y;
    
    CGFloat weight0 = rect0.size.height * rect0.size.width;
    CGFloat weight1 = rect1.size.height * rect1.size.width;
    
    CGFloat weight = weight0 + weight1;
    
    CGFloat distanceX = fabs(x0 - x1);
    CGFloat distanceY = fabs(y0 - y1);
    
    CGFloat x, y;
    
    if (x0 < x1) {
        x = x0 + distanceX * (weight0/weight);
    }
    else {
        x = x1 + distanceX * (weight1/weight);
    }
    
    if (y0 < y1) {
        y = y0 + distanceY * (weight0/weight);
    }
    else {
        y = y1 + distanceY * (weight1/weight);
    }
    
    return CGRectMake(x, y, rect0.size.width+rect1.size.width, rect0.size.height+rect1.size.height);
}

-(void)anonymous:(CIImage *)image {
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace
                                              context:nil
                                              options:nil];
    NSArray *faceArray = [detector featuresInImage:image options:nil];
    
    // Create a green circle to cover the rects that are returned.
    
    CIImage *maskImage = nil;
    
    for (CIFeature *f in faceArray) {
        CGFloat centerX = f.bounds.origin.x + f.bounds.size.width / 2.0;
        CGFloat centerY = f.bounds.origin.y + f.bounds.size.height / 2.0;
        CGFloat radius = MIN(f.bounds.size.width, f.bounds.size.height) / 1.5;
        CIFilter *radialGradient = [CIFilter filterWithName:@"CIRadialGradient" withInputParameters:@{
                                                                                                      @"inputRadius0": @(radius),
                                                                                                      @"inputRadius1": @(radius + 1.0f),
                                                                                                      @"inputColor0": [CIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:1.0],
                                                                                                      @"inputColor1": [CIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0],
                                                                                                      kCIInputCenterKey: [CIVector vectorWithX:centerX Y:centerY],
                                                                                                      }];
        CIImage *circleImage = [radialGradient valueForKey:kCIOutputImageKey];
        if (nil == maskImage)
            maskImage = circleImage;
        else
            maskImage = [[CIFilter filterWithName:@"CISourceOverCompositing" withInputParameters:@{
                                                                                                   kCIInputImageKey: circleImage,
                                                                                                   kCIInputBackgroundImageKey: maskImage,
                                                                                                   }] valueForKey:kCIOutputImageKey];
    }

}

@end

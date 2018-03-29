//
//  OpenCVWrapper.mm
//  AugmentedCamera
//
//  Created by 大山 貴史 on 2018/03/29.
//  Copyright © 2018年 Takafumi Oyama. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#import "OpenCVWrapper.hpp"

@implementation OpenCVWrapper

-(UIImage *)toGrayscale:(UIImage *)src {
    cv::Mat srcImg;
    cv::Mat dstImg;
    UIImageToMat(src, srcImg);
    cv::cvtColor(srcImg, dstImg, CV_BGR2GRAY);
    
    return MatToUIImage(dstImg);
}

@end

//
//  OpenCVWrapper.hpp
//  AugmentedCamera
//
//  Created by 大山 貴史 on 2018/03/29.
//  Copyright © 2018年 Takafumi Oyama. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface OpenCVWrapper : NSObject

-(UIImage*)toGrayscale:(UIImage*)src;

@end

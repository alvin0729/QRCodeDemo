//
//  QRScanViewController.h
//  TongxingSdk
//
//  Created by 刘芳友 on 16/2/25.
//  Copyright © 2016年 NNK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QRCodeHelper.h"


typedef void(^ScanResultBlock)(NSString *scanResultStr);

@interface QRScanViewController : UIViewController

@property (nonatomic, copy) ScanResultBlock scanResultBlock;

@end

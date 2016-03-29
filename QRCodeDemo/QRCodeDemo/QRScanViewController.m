//
//  QRScanViewController.m
//  TongxingSdk
//
//  Created by 刘芳友 on 16/2/25.
//  Copyright © 2016年 NNK. All rights reserved.
//

#import "QRScanViewController.h"

@interface QRScanViewController ()
{
    QRCodeHelper *qrCodeHelper;
}
@property (strong, nonatomic) UIImageView *scanView;

@end

@implementation QRScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"二维码扫描";
    self.view.backgroundColor = [UIColor whiteColor];
    _scanView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0,[UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    [self.view addSubview:_scanView];
    
    qrCodeHelper = [QRCodeHelper new];
    [qrCodeHelper initParaWithPreView:_scanView ObjectType:nil cropRect:CGRectMake(0, 0, 200, 200) handle:^(NSString *resultStr) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"扫码结果" message:resultStr delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
    }];
}

- (void)viewWillAppear:(BOOL)animated{
    [qrCodeHelper refreshViewAndScan];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end

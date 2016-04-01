//
//  QRCodeViewController.m
//  TongxingSdk
//
//  Created by 刘芳友 on 16/2/24.
//  Copyright © 2016年 NNK. All rights reserved.
//

#import "QRCodeViewController.h"
#import "QRCodeGenerator.h"
#import "QRCodeHelper.h"

@interface QRCodeViewController ()
@property (weak, nonatomic) IBOutlet UITextField *qContextText;
@property (weak, nonatomic) IBOutlet UIImageView *qImageView;

@end

@implementation QRCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"二维码功能";
    _qImageView.userInteractionEnabled = YES;
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
    longPress.minimumPressDuration = 1;
    [_qImageView addGestureRecognizer:longPress];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}


- (IBAction)createQRImage:(UIButton *)sender {
    if (_qContextText.text.length == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请输入需要转换的字符串" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
        return;
    }
//    _qImageView.image = [QRCodeGenerator qrImageForString:_qContextText.text imageSize:200];
    _qImageView.image = [QRCodeHelper createQRWithString:_qContextText.text size:CGSizeMake(100, 100)];     
//    _qImageView.image = [QRCodeHelper createCodeWithString:_qContextText.text size:CGSizeMake(200, 200) CodeFomart:kBarcodeFormatQRCode ];
    

}


- (IBAction)openPhoneAlbum:(UIButton *)sender {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    picker.delegate = self;
    
    
    picker.allowsEditing = YES;
    
    
    [self presentViewController:picker animated:YES completion:nil];
}


- (void)longPressAction:(UIGestureRecognizer*)gesture
{

    [QRCodeHelper recognizeImage:_qImageView.image block:^(ZXBarcodeFormat barcodeFormat, NSString *str) {
        UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"提示" message:str delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
        [view show];
    }];
    UIImageWriteToSavedPhotosAlbum(_qImageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);

}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [_qContextText resignFirstResponder];
}

#pragma mark - UIPickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    __block UIImage* image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    if (!image){
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }

    
    [QRCodeHelper recognizeImage:image block:^(ZXBarcodeFormat barcodeFormat, NSString *str) {
        
        NSLog(@"%@",str);
        _qContextText.text = str;
    }];
    
//    //系统自带的二维码识别功能
//    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{ CIDetectorAccuracy : CIDetectorAccuracyHigh }];
//    NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
//    if (features.count >=1)
//    {
//        CIQRCodeFeature *feature = [features objectAtIndex:0];
//        NSString *scanResult = feature.messageString;
//        
//        NSLog(@"%@",scanResult);
//    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
{
    NSLog(@"%@",image);
    if (!error) {
        NSLog(@"保存成功");
    }else{
        NSLog(@"保存失败");
    }
}

@end

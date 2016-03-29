//
//  QRCodeHelper.m
//  TongxingSdk
//
//  Created by 刘芳友 on 16/2/25.
//  Copyright © 2016年 NNK. All rights reserved.
//

#import "QRCodeHelper.h"
#import <AVFoundation/AVFoundation.h>

typedef void(^QRBlock)(NSString *resultStr);

@interface QRCodeHelper()<AVCaptureMetadataOutputObjectsDelegate>

@property (assign,nonatomic)AVCaptureDevice * device;
@property (strong,nonatomic)AVCaptureDeviceInput * input;
@property (strong,nonatomic)AVCaptureMetadataOutput * output;
@property (strong,nonatomic)AVCaptureSession * session;
@property (strong,nonatomic)AVCaptureVideoPreviewLayer * preview;

@property(nonatomic, copy) QRBlock qblock;
@property(nonatomic,strong)  AVCaptureStillImageOutput *stillImageOutput;//拍照

@property(nonatomic,assign)BOOL isNeedCaputureImage;

//扫码类型
@property (nonatomic, strong) NSArray* arrayBarCodeType;

/**
 @brief  视频预览显示视图
 */
@property (nonatomic,weak) UIView  *videoPreView;

@end


@implementation QRCodeHelper


- (void)initParaWithPreView:(UIView*)videoPreView ObjectType:(NSArray*)objType cropRect:(CGRect)cropRect handle:(void(^)(NSString *resultStr))qBlock;
{
    self.arrayBarCodeType = objType;
    self.videoPreView = videoPreView;
  
    [self setOverlayPickerView:videoPreView];
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    if (!_device) {

        return;
    }
    
    // Input
    _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    if (!_input)
        return ;
    
    // Output
    _output = [[AVCaptureMetadataOutput alloc]init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    
    if ( !CGRectEqualToRect(cropRect,CGRectZero) )
    {
        _output.rectOfInterest = cropRect;
    }
    //扫描生效区域
//    [_output setRectOfInterest:CGRectMake((124)/_videoPreView.frame.size.height,((_videoPreView.frame.size.width-220)/2)/_videoPreView.frame.size.width,220/_videoPreView.frame.size.height,220/_videoPreView.frame.size.width)];
    [_output setRectOfInterest:CGRectMake(0.25, 0.25, 0.5, 0.5)];
//
    /*
     // Setup the still image file output
     */
    
    _firstScan = YES;
    
    _stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    AVVideoCodecJPEG, AVVideoCodecKey,
                                    nil];
    [_stillImageOutput setOutputSettings:outputSettings];
    
    // Session
    _session = [[AVCaptureSession alloc]init];
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    
    // _session.
    
    // videoScaleAndCropFactor
    
    if ([_session canAddInput:_input])
    {
        [_session addInput:_input];
    }
    
    if ([_session canAddOutput:_output])
    {
        [_session addOutput:_output];
    }
    
    if ([_session canAddOutput:_stillImageOutput])
    {
        [_session addOutput:_stillImageOutput];
    }
    
    
    
    
    // 条码类型 AVMetadataObjectTypeQRCode
     _output.metadataObjectTypes =@[AVMetadataObjectTypeQRCode];
    
//    if (!objType) {
//        objType = [self defaultMetaDataObjectTypes];
//    }
//    
//    _output.metadataObjectTypes = objType;
    
    // Preview
    _preview =[AVCaptureVideoPreviewLayer layerWithSession:_session];
    _preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    
    CGRect frame = videoPreView.frame;
    frame.origin = CGPointZero;
    _preview.frame = frame;
    
    
    videoPreView.backgroundColor = [UIColor redColor];
    [videoPreView.layer insertSublayer:self.preview atIndex:0];
    
    
    //先进行判断是否支持控制对焦,不开启自动对焦功能，很难识别二维码。
    if (_device.isFocusPointOfInterestSupported &&[_device isFocusModeSupported:AVCaptureFocusModeAutoFocus])
    {
        [_input.device lockForConfiguration:nil];
        [_input.device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
        [_input.device unlockForConfiguration];
    }
    
    [_session startRunning];
    _qblock = qBlock;
    
}

- (void)refreshViewAndScan
{
    _firstScan = YES;
}


/**
 @brief  默认支持码的类别
 @return 支持类别 数组
 */
- (NSArray *)defaultMetaDataObjectTypes
{
    NSMutableArray *types = [@[AVMetadataObjectTypeQRCode,
                               AVMetadataObjectTypeUPCECode,
                               AVMetadataObjectTypeCode39Code,
                               AVMetadataObjectTypeCode39Mod43Code,
                               AVMetadataObjectTypeEAN13Code,
                               AVMetadataObjectTypeEAN8Code,
                               AVMetadataObjectTypeCode93Code,
                               AVMetadataObjectTypeCode128Code,
                               AVMetadataObjectTypePDF417Code,
                               AVMetadataObjectTypeAztecCode] mutableCopy];
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1)
    {
        [types addObjectsFromArray:@[
                                     AVMetadataObjectTypeInterleaved2of5Code,
                                     AVMetadataObjectTypeITF14Code,
                                     AVMetadataObjectTypeDataMatrixCode
                                     ]];
    }
    
    return types;
}


/**
 *  @author Whde
 *
 *  创建扫码页面
 */
- (void)setOverlayPickerView:(UIView*)view
{
    //左侧的view
    UIImageView *leftView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 108/2, view.frame.size.height)];
    leftView.alpha = 0.5;
    leftView.backgroundColor = [UIColor blackColor];
    [view addSubview:leftView];
    //右侧的view
    UIImageView *rightView = [[UIImageView alloc] initWithFrame:CGRectMake(view.frame.size.width-54, 0,54, view.frame.size.height)];
    rightView.alpha = 0.5;
    rightView.backgroundColor = [UIColor blackColor];
    [view addSubview:rightView];
    
    //最上部view
    UIImageView* upView = [[UIImageView alloc] initWithFrame:CGRectMake(54, 0, view.frame.size.width-108, (view.center.y-(view.frame.size.width-108)/2))];
    upView.alpha = 0.5;
    upView.backgroundColor = [UIColor blackColor];
    [view addSubview:upView];
    
    //底部view
    UIImageView * downView = [[UIImageView alloc] initWithFrame:CGRectMake(54, (view.center.y+(view.frame.size.width-108)/2), (view.frame.size.width-108), (view.frame.size.height-(view.center.y-(view.frame.size.width-108)/2)))];
    downView.alpha = 0.5;
    downView.backgroundColor = [UIColor blackColor];
    [view addSubview:downView];
    
    UIImageView *centerView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, view.frame.size.width-108, view.frame.size.width-108)];
    centerView.center = view.center;
    centerView.image = [UIImage imageNamed:@"scanR.png"];
    centerView.contentMode = UIViewContentModeScaleAspectFit;
    centerView.backgroundColor = [UIColor clearColor];
    [view addSubview:centerView];
    
    UILabel *msg = [[UILabel alloc] initWithFrame:CGRectMake(30, CGRectGetMinY(downView.frame)+10, view.frame.size.width-60, 60)];
    msg.backgroundColor = [UIColor clearColor];
    msg.textColor = [UIColor whiteColor];
    msg.textAlignment = NSTextAlignmentCenter;
    msg.font = [UIFont systemFontOfSize:16];
    msg.text = @"将二维码放入框内,即可自动扫描";
    [view addSubview:msg];
    
}



#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    
    NSString *stringValue;
    
    if ([metadataObjects count] >0)
    {
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        stringValue = metadataObject.stringValue;
        if (_firstScan) {
            _firstScan = NO;
            NSLog(@"%@",stringValue);
            _qblock(stringValue);
        }
    }
    
}



#pragma mark - 二维码图片转换成字符串
+ (void)recognizeImage:(UIImage*)image block:(void(^)(ZXBarcodeFormat barcodeFormat,NSString *str))block;
{
    ZXCGImageLuminanceSource *source = [[ZXCGImageLuminanceSource alloc] initWithCGImage:image.CGImage];
    
    ZXHybridBinarizer *binarizer = [[ZXHybridBinarizer alloc] initWithSource: source];
    
    ZXBinaryBitmap *bitmap = [[ZXBinaryBitmap alloc] initWithBinarizer:binarizer];
    
    NSError *error;
    
    id<ZXReader> reader;
    
    if (NSClassFromString(@"ZXMultiFormatReader")) {
        reader = [NSClassFromString(@"ZXMultiFormatReader") performSelector:@selector(reader)];
    }
    
    ZXDecodeHints *_hints = [ZXDecodeHints hints];
    ZXResult *result = [reader decode:bitmap hints:_hints error:&error];
    
    NSLog(@"%@",result.text);

    if (result == nil) {
        
        block(kBarcodeFormatQRCode,nil);
        return;
    }
    
    block(result.barcodeFormat,result.text);
}



#pragma mark - InterpolatedUIImage
+ (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size {
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    // 创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CGColorSpaceRelease(cs);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    // 保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    UIImage *aImage = [UIImage imageWithCGImage:scaledImage];
    CGImageRelease(scaledImage);
    return aImage;
}

#pragma mark - QRCodeGenerator 根据字符串生成CoreImage二维码图片
+ (CIImage *)createQRForString:(NSString *)qrString {
    NSData *stringData = [qrString dataUsingEncoding:NSUTF8StringEncoding];
    // 创建filter
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // 设置内容和纠错级别
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"M" forKey:@"inputCorrectionLevel"];
    // 返回CIImage
    return qrFilter.outputImage;
}

/*!
 *  生成二维码
 *
 *  @param str  二维码字符串
 *  @param size 二维码图片大小
 *
 *  @return 返回生成的图像
 */
+ (UIImage*)createQRWithString:(NSString*)str size:(CGSize)size
{
    
    return [QRCodeHelper createNonInterpolatedUIImageFormCIImage:[QRCodeHelper createQRForString:str] withSize:size.width];
}


/*!
 *  通过Zxing库生成二维码
 *
 *  @param str    需要转换成二维码图片的字符串
 *  @param size   二维码图片尺寸
 *  @param format 格式
 *
 *  @return 二维码图片
 */
+ (UIImage*)createCodeWithString:(NSString*)str size:(CGSize)size CodeFomart:(ZXBarcodeFormat)format
{
    ZXMultiFormatWriter *writer = [[ZXMultiFormatWriter alloc] init];
    ZXBitMatrix *result = [writer encode:str
                                  format:format
                                   width:size.width
                                  height:size.width
                                   error:nil];
    
    if (result) {
        ZXImage *image = [ZXImage imageWithMatrix:result];
        return [UIImage imageWithCGImage:image.cgimage];
    } else {
        return nil;
    }
}




@end

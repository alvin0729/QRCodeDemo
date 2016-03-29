//
//  QRCodeHelper.h
//  TongxingSdk
//
//  Created by 刘芳友 on 16/2/25.
//  Copyright © 2016年 NNK. All rights reserved.
//  二维码扫码工具类

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ZXingObjC.h"



@interface QRCodeHelper : NSObject

@property (nonatomic,assign) BOOL firstScan;

/**
 @brief  初始化采集相机
 @param preView 视频显示区域
 @param objType 识别码类型：如果为nil，默认支持很多类型。
 @param cropRect 识别区域，值CGRectZero 全屏识别
 @param block   识别结果
 @return LBXScanNative的实例
 */
- (void)initParaWithPreView:(UIView*)videoPreView ObjectType:(NSArray*)objType cropRect:(CGRect)cropRect handle:(void(^)(NSString *resultStr))qBlock;



/**
 *  刷新视图并重新扫码
 */
- (void)refreshViewAndScan;


/**
 *  创建二维码图片
 *
 *  @param str    需要转换的字符串
 *  @param size   二维码图片大小
 *  @param format 码类型  二维码 ：kBarcodeFormatQRCode
 *
 *  @return 二维码图片对象
 */
+ (UIImage*)createCodeWithString:(NSString*)str size:(CGSize)size CodeFomart:(ZXBarcodeFormat)format;
+ (UIImage*)createQRWithString:(NSString*)str size:(CGSize)size;


/**
 *  识别图片中的二维码
 *
 *  @param image 图片
 *  @param block 识别之后的回调
 */
+ (void)recognizeImage:(UIImage*)image block:(void(^)(ZXBarcodeFormat barcodeFormat,NSString *str))block;


@end


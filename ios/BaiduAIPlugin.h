//
//  BaiduAIPlugin.h
//  ESOP
//
//  Created by 张锐平 on 2018/11/15.
//  Copyright © 2018年 asiainfo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cordova/CDVPlugin.h>
#import <Cordova/CDV.h>
#import "AipOcrService.h"
#import "AipAsrService.h"
@interface BaiduAIPlugin : CDVPlugin

/**
 * 文字识别
 */
- (void)ocr:(CDVInvokedUrlCommand *)command;
/**
 * 语音识别
 */
- (void)speech:(CDVInvokedUrlCommand *)command;
@end

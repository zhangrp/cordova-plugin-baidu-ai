//
//  BaiduAIPlugin.m
//  ESOP
//
//  Created by 张锐平 on 2018/11/15.
//  Copyright © 2018年 asiainfo. All rights reserved.
//

#import "BaiduAIPlugin.h"

@implementation BaiduAIPlugin
/**
 * 文字识别
 */
- (void)ocr:(CDVInvokedUrlCommand *)command{
    
    
    NSString* callbackId = command.callbackId;
    __weak BaiduAIPlugin* weakSelf = self;
    
    [self.commandDelegate runInBackground:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"BaiduAIPlugin ocr in");
            
            NSString *appId = [command argumentAtIndex:0];
            NSString *apiKey = [command argumentAtIndex:1];
            NSString *secrtKey = [command argumentAtIndex:2];
            
            NSString *orcType = [command argumentAtIndex:3];
            NSString *image = [command argumentAtIndex:4];
            NSString *options = [command argumentAtIndex:5];
            
            NSLog(@"BaiduAIPlugin appId=%@", appId);
            NSLog(@"BaiduAIPlugin apiKey=%@", apiKey);
            NSLog(@"BaiduAIPlugin orcType=%@", orcType);
            NSLog(@"BaiduAIPlugin image=%@", image);

            [[AipOcrService shardService] authWithAK:apiKey andSK:secrtKey];
            
            [self doOCR:image widthType:orcType withOptions:[self JsonStringTONSDictionary:options] successHandler:^(id success) {
                CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[self NSDictionaryTOJsonString:success]];
                [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
            } failHandler:^(NSError *err){
                CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[self NSDictionaryTOJsonString:[err userInfo]]];
                [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
            }];
            
        });
    }];
}



- (NSDictionary *)JsonStringTONSDictionary:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

-(NSString*)NSDictionaryTOJsonString:(id)object
{
    NSString *jsonString = nil;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}

- (UIImage *) imageFromURLString:(NSString *) urlstring {
    return [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:urlstring]]];
}

- (void)doOCR:(NSString *)image
          widthType:(NSString *)ocrType
        withOptions:(NSDictionary *)options
     successHandler:(void (^)(id result))successHandler
        failHandler:(void (^)(NSError *err))failHandler{
    UIImage *uiImage = [self imageFromURLString:image];
    AipOcrService *aipOcrService = [AipOcrService shardService];
    if ([ocrType isEqualToString:@"general"]) {
        [aipOcrService detectTextFromImage:uiImage withOptions:options successHandler:successHandler failHandler:failHandler];
    } else if ([ocrType isEqualToString:@"basicAccurateGeneral"]) {
        [aipOcrService detectTextAccurateBasicFromImage:uiImage withOptions:options successHandler:successHandler failHandler:failHandler];
    } else if ([ocrType isEqualToString:@"accurateGeneral"]) {
        [aipOcrService detectTextAccurateFromImage:uiImage withOptions:options successHandler:successHandler failHandler:failHandler];
    } else if ([ocrType isEqualToString:@"enhancedGeneral"]) {
        [aipOcrService detectTextEnhancedFromImage:uiImage withOptions:options successHandler:successHandler failHandler:failHandler];
    } else if ([ocrType isEqualToString:@"handwriting"]) {
        //todo
    } else if ([ocrType isEqualToString:@"idcard"]) {
        if (options != nil && options[@"id_card_side"] != nil && [options[@"id_card_side"] isEqualToString:@"back"]) {
            [aipOcrService detectIdCardBackFromImage:uiImage withOptions:options successHandler:successHandler failHandler:failHandler];
        } else {
            [aipOcrService detectIdCardFrontFromImage:uiImage withOptions:options successHandler:successHandler failHandler:failHandler];
        }
    } else if ([ocrType isEqualToString:@"bankcard"]) {
        [aipOcrService detectBankCardFromImage:uiImage successHandler:successHandler failHandler:failHandler];
    } else if ([ocrType isEqualToString:@"drivingLicense"]) {
        [aipOcrService detectDrivingLicenseFromImage:uiImage withOptions:options successHandler:successHandler failHandler:failHandler];
    } else if ([ocrType isEqualToString:@"vehicleLicense"]) {
        [aipOcrService detectVehicleLicenseFromImage:uiImage withOptions:options successHandler:successHandler failHandler:failHandler];
    } else if ([ocrType isEqualToString:@"plateLicense"]) {
        [aipOcrService detectPlateNumberFromImage:uiImage withOptions:options successHandler:successHandler failHandler:failHandler];
    } else if ([ocrType isEqualToString:@"businessLicense"]) {
        [aipOcrService detectBusinessLicenseFromImage:uiImage withOptions:options successHandler:successHandler failHandler:failHandler];
    } else if ([ocrType isEqualToString:@"passport"]) {
        //todo
    } else if ([ocrType isEqualToString:@"businessCard"]) {
        //todo
    } else if ([ocrType isEqualToString:@"receipt"]) {
        [aipOcrService detectReceiptFromImage:uiImage withOptions:options successHandler:successHandler failHandler:failHandler];
    } else if ([ocrType isEqualToString:@"form"]) {
        //todo
    } else if ([ocrType isEqualToString:@"vatInvoice"]) {
        //todo
    } else if ([ocrType isEqualToString:@"qrcode"]) {
        //todo
    } else if ([ocrType isEqualToString:@"numbers"]) {
        //todo
    } else if ([ocrType isEqualToString:@"lottery"]) {
        //todo
    }
}

/**
 * 语音识别
 */
- (void)speech:(CDVInvokedUrlCommand *)command{

    NSString* callbackId = command.callbackId;
    __weak BaiduAIPlugin* weakSelf = self;
    
    [self.commandDelegate runInBackground:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"BaiduAIPlugin speech in");
            
            NSString *appId = [command argumentAtIndex:0];
            NSString *apiKey = [command argumentAtIndex:1];
            NSString *secrtKey = [command argumentAtIndex:2];
            
            NSString *voice = [command argumentAtIndex:3];
            NSString *options = [command argumentAtIndex:4];
            
            NSLog(@"BaiduAIPlugin appId=%@", appId);
            NSLog(@"BaiduAIPlugin apiKey=%@", apiKey);
            NSLog(@"BaiduAIPlugin voice=%@", voice);
            
            apiKey = @"cT8Y1MKP5D5gcex5AYbjzQFW";
            secrtKey = @"GmVrjKP0Tfb7x5Tq04GIzdKs8z8Hcfhf";
            
            
            [[AipAsrService shardService] authWithAK:apiKey andSK:secrtKey];
            AipAsrService *aipAsrService = [AipAsrService shardService];
            
            [aipAsrService asr:voice withOptions:[self JsonStringTONSDictionary:options] successHandler:^(id success){
                CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[self NSDictionaryTOJsonString:success]];
                
                NSLog(@"%@", [weakSelf NSDictionaryTOJsonString:success]);
                [weakSelf.commandDelegate sendPluginResult:result callbackId:callbackId];
            } failHandler:^(NSError *err) {
                CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[self NSDictionaryTOJsonString:[err userInfo]]];
                NSLog(@"%@", [weakSelf NSDictionaryTOJsonString:[err userInfo]]);
                [weakSelf.commandDelegate sendPluginResult:result callbackId:callbackId];
            }];
        });
    }];
}

@end

# cordova-plugin-baidu-ai

基于百度在线服务的图片识别和语音识别





# 图片识别

配合[cordova-plugin-camera](https://github.com/apache/cordova-plugin-camera)（拍照）插件使用

ocrType：general, basicAccurateGeneral, accurateGeneral, enhancedGeneral, handwriting, idcard, bankcard, drivingLicense, vehicleLicense, plateLicense, businessLicense, passport, businessCard, receipt, form, vatInvoice, qrcode, numbers, lottery

imageUrl：图片路径

```typescript
doOCR() {
    let temp = {};
    if (this.ocrType == "idcard—front") {
        temp["id_card_side"] = "front";
        this.ocrType = "idcard";
    } else if (this.ocrType == "idcard-back") {
        temp["id_card_side"] = "back";
        this.ocrType = "idcard";
    }
    window["BaiduAI"].ocr(data => {
        this.result = data;
        this.loading = false;
    }, function (data) {
        this.result = data;
        this.loading = false;
    }, "APP_ID", "API_KEY", "SECRET_KEY", this.ocrType, this.imageUrl, temp);
}
```





# 语音识别

配合语音录入插件[cordova-plugin-camera](https://github.com/apache/cordova-plugin-camera)，但这个插件录的音格式问题无法直接识别，可以参考我修改过的[5.0版本](https://github.com/zhangrp/cordova-plugin-media/tree/5.0.x)，录的音可以直接识别。



fileFullPath：录音文件全路径

```typescript
doAsr() {
    let temp = {};
    let fileFullPath = this.fileManager.externalRootDirectory + this.filePath;
    if (this.platform.is("ios")) {
        fileFullPath = this.fileManager.tempDirectory + this.filePath;
    }

    window["BaiduAI"].speech(data => {
        this.zone.run(() => {
            this.result = data;
        });
    }, function (data) {
        this.zone.run(() => {
            this.result = data;
        });
    }, "APP_ID", "API_KEY", "SECRET_KEY", fileFullPath, temp);
}
```



后续可以考虑修改插件实现实时识别，而不是录完之后再识别。


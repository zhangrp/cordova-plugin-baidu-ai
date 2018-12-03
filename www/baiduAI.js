var BaiduAI = function () {

};

/**
 * 文字识别
 * @param success
 * @param fail
 * @param APP_ID
 * @param API_KEY
 * @param SECRET_KEY
 * @param ocrType
 * @param image
 * @param options
 * @returns {RegExpExecArray}
 */
BaiduAI.prototype.ocr = function (success, fail, APP_ID, API_KEY, SECRET_KEY, ocrType, image, options) {
    options = options || {};
    var args = [APP_ID, API_KEY, SECRET_KEY, ocrType, image, JSON.stringify(options)];
    return cordova.exec(success, fail, "BaiduAI", "ocr", args);
};


/**
 * 语音识别
 * @param success
 * @param fail
 * @param APP_ID
 * @param API_KEY
 * @param SECRET_KEY
 * @param options
 * @returns {RegExpExecArray}
 */
BaiduAI.prototype.speech = function (success, fail, APP_ID, API_KEY, SECRET_KEY, filePath, options) {
    options = options || {};
    var args = [APP_ID, API_KEY, SECRET_KEY, filePath, JSON.stringify(options)];
    return cordova.exec(success, fail, "BaiduAI", "speech", args);
};

window.BaiduAI = new BaiduAI();
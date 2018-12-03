/**
 * $Id: BaiduAIPlugin.java,v 1.0 2018/11/2 下午5:38 zhangruiping Exp $
 * Copyright 2018 Asiainfo Technologies(China),Inc. All rights reserved.
 */
package com.asiainfo.cordova.plugin;

import android.util.Log;
import com.baidu.aip.ocr.AipOcr;
import com.baidu.aip.speech.AipSpeech;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Iterator;

/**
 * @author zhangruiping
 * @version $Id: BaiduAIPlugin.java,v 1.1 2018/11/2 下午5:38 zhangruiping Exp $
 * Created on 2018/11/2 下午5:38
 */
public class BaiduAIPlugin extends CordovaPlugin {

    private static String TAG = "BaiduAIPlugin";
    private static final String OCR = "ocr";
    private static final String SPEECH = "speech";
    private static final String SPEECH_START = "speechStart";
    private static final String SPEECH_END = "speechEnd";

    private AipOcr getAipOcr(String appId, String apiKey, String secretKey) {
        // 初始化一个AipOcr
        AipOcr client = new AipOcr(appId, apiKey, secretKey);

        // 可选：设置网络连接参数
        client.setConnectionTimeoutInMillis(2000);
        client.setSocketTimeoutInMillis(60000);

        // 可选：设置代理服务器地址, http和socket二选一，或者均不设置
        // client.setHttpProxy("proxy_host", proxy_port);  // 设置http代理
        // client.setSocketProxy("proxy_host", proxy_port);  // 设置socket代理

        // 可选：设置log4j日志输出格式，若不设置，则使用默认配置
        // 也可以直接通过jvm启动参数设置此环境变量
        // System.setProperty("aip.log4j.conf", "path/to/your/log4j.properties");
        return client;
    }

    private AipSpeech getAipSpeech(String appId, String apiKey, String secretKey) {
        // 初始化一个AipOcr
        AipSpeech client = new AipSpeech(appId, apiKey, secretKey);

        // 可选：设置网络连接参数
        client.setConnectionTimeoutInMillis(2000);
        client.setSocketTimeoutInMillis(60000);

        // 可选：设置代理服务器地址, http和socket二选一，或者均不设置
        // client.setHttpProxy("proxy_host", proxy_port);  // 设置http代理
        // client.setSocketProxy("proxy_host", proxy_port);  // 设置socket代理

        // 可选：设置log4j日志输出格式，若不设置，则使用默认配置
        // 也可以直接通过jvm启动参数设置此环境变量
        // System.setProperty("aip.log4j.conf", "path/to/your/log4j.properties");
        return client;
    }

    private CallbackContext callbackContext;

    public CallbackContext getCallbackContext() {
        return this.callbackContext;
    }

    public BaiduAIPlugin() {

    }

    @Override
    public void initialize(CordovaInterface cordova, final CordovaWebView cordovaWebView) {
        Log.i(TAG, "BaiduAIPlugin init......");
    }

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        this.callbackContext = callbackContext;

        if (args.length() < 3) {
            return false;
        }
        final String appId = args.get(0).toString();
        final String apiKey = args.get(1).toString();
        final String secretKey = args.get(2).toString();


        if (action.equals(OCR)) {
            if (args.length() < 5) {
                return false;
            }
            String ocrType = args.get(3).toString();
            String image = args.get(4).toString();
            image = getPath(image);
            HashMap<String, String> options = new HashMap<String, String>();
            if (args.length() > 5) {
                JSONObject jsonObject = new JSONObject(args.get(5).toString());
                Iterator<String> iterator = jsonObject.keys();
                while (iterator.hasNext()) {
                    String key = iterator.next();
                    options.put(key, jsonObject.getString(key));
                }
            }
            try {
                AipOcr aipOcr = getAipOcr(appId, apiKey, secretKey);
                String message = this.doOCR(aipOcr, ocrType, image, options);
                callbackContext.success(message);
                return true;
            } catch (Exception e) {
                callbackContext.error(e.getMessage());
                return false;
            }
        } else if (action.equals(SPEECH)) {
            if (args.length() < 4) {
                return false;
            }
            String fileName = args.get(3).toString();
            fileName = getPath(fileName);
            HashMap<String, String> options = new HashMap<String, String>();
            if (args.length() > 4) {
                JSONObject jsonObject = new JSONObject(args.get(4).toString());
                Iterator<String> iterator = jsonObject.keys();
                while (iterator.hasNext()) {
                    String key = iterator.next();
                    options.put(key, jsonObject.getString(key));
                }
            }
            try {
                AipSpeech aipSpeech = getAipSpeech(appId, apiKey, secretKey);
                JSONObject res = aipSpeech.asr(fileName, "pcm", 16000, null);
                callbackContext.success(res.toString());
                return true;
            } catch (Exception e) {
                callbackContext.error(e.getMessage());
                return false;
            }
        }
        return false;
    }


    private String getPath(String path) {
        if (path != null && path.startsWith("file://")) {
            path = path.substring(7);
        }
        return path;
    }

    private String doOCR(AipOcr aipOcr, String ocrType, String image, HashMap<String, String> options) throws Exception {
        JSONObject res = null;
        switch (ocrType) {
            case "general":
                res = aipOcr.general(image, options);
                break;
            case "basicAccurateGeneral":
                res = aipOcr.basicAccurateGeneral(image, options);
                break;
            case "accurateGeneral":
                res = aipOcr.accurateGeneral(image, options);
                break;
            case "enhancedGeneral":
                res = aipOcr.enhancedGeneral(image, options);
                break;
            case "handwriting":
                res = aipOcr.handwriting(image, options);
                break;
            case "idcard":
                res = aipOcr.idcard(image, options.get("id_card_side") == null ? "front" : options.get("id_card_side"), options);
                break;
            case "bankcard":
                res = aipOcr.bankcard(image, options);
                break;
            case "drivingLicense":
                res = aipOcr.drivingLicense(image, options);
                break;
            case "vehicleLicense":
                res = aipOcr.vehicleLicense(image, options);
                break;
            case "plateLicense":
                res = aipOcr.plateLicense(image, options);
                break;
            case "businessLicense":
                res = aipOcr.businessLicense(image, options);
                break;
            case "passport":
                res = aipOcr.passport(image, options);
                break;
            case "businessCard":
                res = aipOcr.businessCard(image, options);
                break;
            case "receipt":
                res = aipOcr.receipt(image, options);
                break;
            case "form":
                res = aipOcr.form(image, options);
                break;
            case "vatInvoice":
                res = aipOcr.vatInvoice(image, options);
                break;
            case "qrcode":
                res = aipOcr.qrcode(image, options);
                break;
            case "numbers":
                res = aipOcr.numbers(image, options);
                break;
            case "lottery":
                res = aipOcr.lottery(image, options);
                break;
        }
        return res == null ? "{}" : res.toString(4);
    }
}
package com.pds.native_code;

import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.plugin.common.MethodChannel;

import android.content.ContextWrapper;
import android.content.Intent;
import android.content.IntentFilter;
import android.hardware.camera2.CameraManager;
import android.os.Build.VERSION;
import android.os.Build.VERSION_CODES;
import android.os.Bundle;
import android.util.Log;
import android.os.Environment;

import com.pds.native_code.ImageGrabCutService;

import org.opencv.android.LoaderCallbackInterface;
import org.opencv.android.OpenCVLoader;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "heartbeat.fritz.ai/native";

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler((call, result) -> {
                    Log.e("Editable", "append: ");
                    if (call.method.equals("grabCutImage")) {
                        //load openCV
                        loadOpenCV();

                        String param1 = call.argument("param1");
                        String param2 = call.argument("param2");
                        System.out.println("param1: " + param1 + " param2: " + param2);
                        result.success(ImageGrabCutService.grabCutObject(this, param1, param2));

                    } else if (call.method.equals("isBlurOrTooDarkTooBrightImage")) {
                        //load openCV
                        loadOpenCV();

                        String param1 = call.argument("param1");
                        String param2 = call.argument("param2");
                        System.out.println("param1: " + param1 + " param2: " + param2);

                        result.success(ImageGrabCutService.isBlurOrTooDark(this, param1, param2));

                    } else {
                        result.notImplemented();
                    }

                });
    }


    private void loadOpenCV(){
        if (!OpenCVLoader.initDebug()) {
            Log.d("OpenCV", "Internal OpenCV library not found. Using OpenCV Manager for initialization");
            OpenCVLoader.initAsync("3.4.3", this, (LoaderCallbackInterface) null);
        } else {
            Log.d("OpenCV", "OpenCV library found inside package. Using it!");
        }
    }

    @Override
    protected void onResume() {
        super.onResume();
        requestPermission();
//        if (!OpenCVLoader.initDebug()) {
//            Log.d("OpenCV", "Internal OpenCV library not found. Using OpenCV Manager for initialization");
//            OpenCVLoader.initAsync("3.4.3", this, (LoaderCallbackInterface) null);
//        } else {
//            Log.d("OpenCV", "OpenCV library found inside package. Using it!");
//        }
    }

    public void requestPermission() {
        String[] perms = {"android.permission.ACCESS_NETWORK_STATE", "android.permission.CAMERA", "android.permission.INTERNET",
                "android.permission.READ_EXTERNAL_STORAGE", "android.permission.WRITE_EXTERNAL_STORAGE"};

        int permsRequestCode = 200;
        requestPermissions(perms, permsRequestCode);
    }
}
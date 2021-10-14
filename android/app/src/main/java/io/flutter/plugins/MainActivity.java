package com.example.flutter_complete_guide;

import android.os.Bundle;
import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import android.content.ContextWrapper;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.BatteryManager;
import android.os.Build.VERSION;
import android.os.Build.VERSION_CODES;
import android.os.Bundle;

public class MainActivity extends FlutterActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
      super.onCreate(savedInstanceState);
      GeneratedPluginRegistrant.registerWith(this);
      new MethodChannel(getFlutterView(), "nesa_app/get_all_user_data").setMethodCallHandler(
          new MethodCallHandler(){
              @Override
              public void onMethodCall(MethodCall call, Result result){
                if(call.method.equals("getUserData")){
                    if(userData =! Null){
                        result.sucess(userData);
                    }else{
                        result.error("Fehlgeschlagen!", "User Daten konnten nicht abgerufen werden", null)
                    }
                }else{
                    result.notImplemented();
                }
              }
          }
      ) =
    }

    private Map<String,Dynamic> getUserData(){
        userData = Null;
        if(VERSION.SDK_INT >= VERSION_CODES.LOLLIPOP){
            //Hier kommt der PYTHON Code
        }
        Map<String, Dynamic> test = {"Hallo":2};
        return test;
    }
  }
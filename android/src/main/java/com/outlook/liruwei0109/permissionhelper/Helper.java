package com.outlook.liruwei0109.permissionhelper;


import android.util.Log;

import com.facebook.react.bridge.Dynamic;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.ReadableType;
import com.yanzhenjie.permission.AndPermission;
import com.yanzhenjie.permission.Permission;
import com.yanzhenjie.permission.PermissionListener;
import com.yanzhenjie.permission.Rationale;
import com.yanzhenjie.permission.RationaleListener;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Created by liruwei on 2017/8/16.
 */

public class Helper extends ReactContextBaseJavaModule {
    final String TAG = "Helper_Log";

    private HashMap promiseMap = new HashMap();

    public Helper(ReactApplicationContext reactContext) {
        super(reactContext);
    }

    @Override
    public String getName() {
        return "PermissionHelper";
    }

    @Override
    public Map<String, Object> getConstants() {
        final Map<String, Object> constants = new HashMap<>();
        constants.put("CALENDAR",100);
        constants.put("CAMERA",200);
        constants.put("CONTACTS",300);
        constants.put("LOCATION",400);
        constants.put("MICROPHONE",500);
        constants.put("PHONE",600);
        constants.put("SENSORS",700);
        constants.put("SMS",800);
        constants.put("STORAGE",900);
        return constants;
    }

    @ReactMethod
    public void check(final int checkCode, Promise promise) {
        ReadableArray checkCodes = new ReadableArray() {
            @Override
            public int size() {
                return 1;
            }

            @Override
            public boolean isNull(int index) {
                return false;
            }

            @Override
            public boolean getBoolean(int index) {
                return false;
            }

            @Override
            public double getDouble(int index) {
                return 0;
            }

            @Override
            public int getInt(int index) {
                return checkCode;
            }

            @Override
            public String getString(int index) {
                return null;
            }

            @Override
            public ReadableArray getArray(int index) {
                return null;
            }

            @Override
            public ReadableMap getMap(int index) {
                return null;
            }

            @Override
            public Dynamic getDynamic(int index) {
                return null;
            }

            @Override
            public ReadableType getType(int index) {
                return null;
            }
        };
        multipleCheck(checkCodes,promise);
    }

    @ReactMethod
    public void multipleCheck(ReadableArray checkCodes, Promise promise) {
        int size = checkCodes.size();
        int amountCode = 0;
        ArrayList amountPermission = new ArrayList();

        for (int i = 0; i < checkCodes.size(); ++i) {
            int code = checkCodes.getInt(i);
            amountCode += code;
            amountPermission.addAll(Arrays.asList(getPermissionFromCode(code)));
        }
        andPermission(amountCode, (String[])amountPermission.toArray(new String[amountPermission.size()]),promise);
    }


    private String[] getPermissionFromCode(int code) {
        String[] result = null;
        switch (code) {
            case 100: result = Permission.CALENDAR; break;
            case 200: result = Permission.CAMERA; break;
            case 300: result = Permission.CONTACTS; break;
            case 400: result = Permission.LOCATION; break;
            case 500: result = Permission.MICROPHONE; break;
            case 600: result = Permission.PHONE; break;
            case 700: result = Permission.SENSORS; break;
            case 800: result = Permission.SMS; break;
            case 900: result = Permission.STORAGE; break;
        }
        return result;
    }

    private void andPermission(int checkCode,String[] permission, Promise promise) {
        promiseMap.put(checkCode,promise);
        AndPermission.with(getCurrentActivity())
                .requestCode(checkCode)
                .permission(permission)
                .rationale(rationale)
                .callback(callback)
                .start();
    }

    private RationaleListener rationale = new RationaleListener() {
        @Override
        public void showRequestPermissionRationale(int requestCode,final Rationale rationale) {
            AndPermission.rationaleDialog(getCurrentActivity(), rationale).show();

            /*
            AlertDialog.newBuilder(getCurrentActivity())
                    .setTitle("")
                    .setMessage("你已拒绝过定位权限，沒有定位定位权限无法为你推荐附近的妹子，你看着办！")
                    .setPositiveButton("设置", new DialogInterface.OnClickListener() {
                        @Override
                        public void onClick(DialogInterface dialog, int which) {
                            rationale.resume();
                        }
                    })
                    .setNegativeButton("取消", new DialogInterface.OnClickListener() {
                        @Override
                        public void onClick(DialogInterface dialog, int which) {
                            rationale.cancel();
                        }
                    }).show();
                    */
        }
    };

    private PermissionListener callback = new PermissionListener() {
        @Override
        public void onSucceed(int requestCode, List<String> grantedPermissions) {
            Promise promise = (Promise)promiseMap.get(requestCode);
            promise.resolve(true);
            promiseMap.remove(requestCode);
        }

        @Override
        public void onFailed(int requestCode, List<String> deniedPermissions) {
            Promise promise = (Promise)promiseMap.get(requestCode);
            promise.resolve(false);
            promiseMap.remove(requestCode);

            if (AndPermission.hasAlwaysDeniedPermission(getCurrentActivity(), deniedPermissions)) {
                AndPermission.defaultSettingDialog(getCurrentActivity(), 400).show();
//                AndPermission.defaultSettingDialog(getCurrentActivity(), 400)
//                        .setTitle("")
//                        .setMessage("权限申请失败，前往设置中授权。")
//                        .setPositiveButton("好，去设置")
//                        .show();
            }
        }
    };
}

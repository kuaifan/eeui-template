package app.eeui.framework.extend.module.utilcode.util;

import android.app.Activity;
import android.app.Application;

import java.util.List;

import app.eeui.framework.extend.module.eeui;

/**
 * Created by WDM on 2018/3/13.
 */

public class Utils {

    public static Application getApp() {
        return eeui.getApplication();
    }

    public static List<Activity> getActivityList() {
        return eeui.getActivityList();
    }
}

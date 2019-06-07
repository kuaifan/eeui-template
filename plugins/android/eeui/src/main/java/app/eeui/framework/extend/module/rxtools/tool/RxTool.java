package app.eeui.framework.extend.module.rxtools.tool;

import android.app.Application;

import app.eeui.framework.extend.module.eeui;

/**
 * Created by WDM on 2018/3/24.
 */

public class RxTool {

    public static Application getContext() {
        return eeui.getApplication();
    }
}

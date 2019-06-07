package app.eeui.framework.extend.bean;

import java.util.HashMap;
import java.util.Map;

public class WebCallBean {

    private static Map<String, Class> classData = new HashMap<>();

    public static void addClassData(String name, Class classObj) {
        classData.put(name, classObj);
    }

    public static void removeClassData(String name) {
        classData.remove(name);
    }

    public static Map<String, Class> getClassData() {
        return classData;
    }
}

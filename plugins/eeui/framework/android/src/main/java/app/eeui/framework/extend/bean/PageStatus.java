package app.eeui.framework.extend.bean;

public class PageStatus {

    private String type;
    private String status;
    private String pageName;
    private Object message;

    public PageStatus(String type, String status, String pageName, Object message) {
        this.type = type;
        this.status = status;
        this.pageName = pageName;
        this.message = message;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getType() {
        return type;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getStatus() {
        return status;
    }


    public void setPageName(String pageName) {
        this.pageName = pageName;
    }

    public String getPageName() {
        return pageName;
    }

    public void setMessage(Object message) {
        this.message = message;
    }

    public Object getMessage() {
        return message;
    }

}

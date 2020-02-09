package app.eeui.framework.ui.component.recyler.bean;


import android.view.View;

import app.eeui.framework.ui.component.scrollHeader.ScrollHeaderView;

public class ViewItem {

    private View view;
    private boolean scrollHeader;
    private boolean post;

    public ViewItem(View v) {
        view = v;
        scrollHeader = view instanceof ScrollHeaderView;
    }

    public void setView(View view) {
        this.view = view;
    }

    public View getView() {
        return view;
    }

    public void setScrollHeader(boolean scrollHeader) {
        this.scrollHeader = scrollHeader;
    }

    public boolean isScrollHeader() {
        return scrollHeader;
    }

    public boolean isPost() {
        return post;
    }

    public void setPost(boolean post) {
        this.post = post;
    }
}

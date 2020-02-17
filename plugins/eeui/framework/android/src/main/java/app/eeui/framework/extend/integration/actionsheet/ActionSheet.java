package app.eeui.framework.extend.integration.actionsheet;

import android.content.Context;
import android.content.res.Resources;
import android.content.res.TypedArray;
import android.graphics.Color;
import android.graphics.Typeface;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.Drawable;
import android.graphics.drawable.StateListDrawable;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentManager;
import androidx.fragment.app.FragmentTransaction;
import androidx.core.content.ContextCompat;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.animation.AlphaAnimation;
import android.view.animation.Animation;
import android.view.animation.TranslateAnimation;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.TextView;

import java.lang.reflect.Method;
import java.util.List;

import app.eeui.framework.R;

@SuppressWarnings("ResourceType")
public class ActionSheet extends Fragment implements View.OnClickListener {

    private static final String ARG_TITLE = "title";
    private static final String ARG_SUB_TITLE = "sub_title";
    private static final String ARG_CANCEL_BUTTON_TITLE = "cancel_button_title";
    private static final String ARG_ACTION_ITEMS = "action_items";
    private static final String ARG_CANCELABLE_ONTOUCHOUTSIDE = "cancelable_ontouchoutside";
    private static final int TITLE_ID = 99;
    private static final int SUB_TITLE_ID = 98;
    private static final int CANCEL_BUTTON_ID = 100;
    private static final int BG_VIEW_ID = 10;
    private static final int TRANSLATE_DURATION = 200;
    private static final int ALPHA_DURATION = 300;

    private static final String EXTRA_DISMISSED = "extra_dismissed";

    private boolean mDismissed = true;
    private ActionSheetListener mListener;
    private View mView;
    private LinearLayout mPanel;
    private ViewGroup mGroup;
    private View mBg;
    private Attributes mAttrs;
    private boolean isCancel = true;

    public void show(final FragmentManager manager, final String tag) {
        if (!mDismissed || manager.isDestroyed()) {
            return;
        }
        mDismissed = false;
        new Handler().post(new Runnable() {
            public void run() {
                FragmentTransaction ft = manager.beginTransaction();
                ft.add(ActionSheet.this, tag);
                ft.addToBackStack(null);
                ft.commitAllowingStateLoss();
            }
        });
    }

    public void dismiss() {
        if (mDismissed) {
            return;
        }
        mDismissed = true;
        new Handler().post(new Runnable() {
            public void run() {
                getFragmentManager().popBackStack();
                FragmentTransaction ft = getFragmentManager().beginTransaction();
                ft.remove(ActionSheet.this);
                ft.commitAllowingStateLoss();
            }
        });
    }

    @Override
    public void onSaveInstanceState(Bundle outState) {
        outState.putBoolean(EXTRA_DISMISSED, mDismissed);
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (savedInstanceState != null) {
            mDismissed = savedInstanceState.getBoolean(EXTRA_DISMISSED);
        }
        getActivity().setTheme(R.style.ActionSheetStyle);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {

        InputMethodManager imm = (InputMethodManager) getActivity()
                .getSystemService(Context.INPUT_METHOD_SERVICE);
        if (imm != null && imm.isActive()) {
            View focusView = getActivity().getCurrentFocus();
            if (focusView != null) {
                imm.hideSoftInputFromWindow(focusView.getWindowToken(), 0);
            }
        }

        mAttrs = readAttribute();

        mView = createView();
        mGroup = (ViewGroup) getActivity().getWindow().getDecorView();

        createItems();

        mGroup.addView(mView);
        mBg.startAnimation(createAlphaInAnimation());
        mPanel.startAnimation(createTranslationInAnimation());
        return super.onCreateView(inflater, container, savedInstanceState);
    }

    @Override
    public void onDestroyView() {
        mPanel.startAnimation(createTranslationOutAnimation());
        mBg.startAnimation(createAlphaOutAnimation());
        mView.postDelayed(new Runnable() {
            @Override
            public void run() {
                mGroup.removeView(mView);
            }
        }, ALPHA_DURATION);
        if (mListener != null) {
            mListener.onDismiss(this, isCancel);
        }
        super.onDestroyView();
    }

    private Animation createTranslationInAnimation() {
        int type = TranslateAnimation.RELATIVE_TO_SELF;
        TranslateAnimation an = new TranslateAnimation(type, 0, type, 0, type,
                1, type, 0);
        an.setDuration(TRANSLATE_DURATION);
        return an;
    }

    private Animation createAlphaInAnimation() {
        AlphaAnimation an = new AlphaAnimation(0, 1);
        an.setDuration(ALPHA_DURATION);
        return an;
    }

    private Animation createTranslationOutAnimation() {
        int type = TranslateAnimation.RELATIVE_TO_SELF;
        TranslateAnimation an = new TranslateAnimation(type, 0, type, 0, type,
                0, type, 1);
        an.setDuration(TRANSLATE_DURATION);
        an.setFillAfter(true);
        return an;
    }

    private Animation createAlphaOutAnimation() {
        AlphaAnimation an = new AlphaAnimation(1, 0);
        an.setDuration(ALPHA_DURATION);
        an.setFillAfter(true);
        return an;
    }

    private View createView() {
        FrameLayout parent = new FrameLayout(getActivity());
        parent.setLayoutParams(new FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT));
        mBg = new View(getActivity());
        mBg.setLayoutParams(new FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT));
        mBg.setBackgroundColor(Color.argb(136, 0, 0, 0));
        mBg.setId(ActionSheet.BG_VIEW_ID);
        mBg.setOnClickListener(this);

        mPanel = new LinearLayout(getActivity());
        FrameLayout.LayoutParams params = new FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.WRAP_CONTENT);
        params.gravity = Gravity.BOTTOM;
        mPanel.setLayoutParams(params);
        mPanel.setOrientation(LinearLayout.VERTICAL);
        parent.setPadding(0, 0, 0, getNavBarHeight(getActivity()));
        parent.addView(mBg);
        parent.addView(mPanel);
        return parent;
    }

    public int getNavBarHeight(Context context) {
        int navigationBarHeight = 0;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            Resources rs = context.getResources();
            int id = rs.getIdentifier("navigation_bar_height", "dimen", "android");
            if (id > 0 && checkDeviceHasNavigationBar(context)) {
                navigationBarHeight = rs.getDimensionPixelSize(id);
            }
        }
        return navigationBarHeight;
    }

    private boolean checkDeviceHasNavigationBar(Context context) {
        boolean hasNavigationBar = false;
        Resources rs = context.getResources();
        int id = rs.getIdentifier("config_showNavigationBar", "bool", "android");
        if (id > 0) {
            hasNavigationBar = rs.getBoolean(id);
        }
        try {
            Class systemPropertiesClass = Class.forName("android.os.SystemProperties");
            Method m = systemPropertiesClass.getMethod("get", String.class);
            String navBarOverride = (String) m.invoke(systemPropertiesClass, "qemu.hw.mainkeys");
            if ("1".equals(navBarOverride)) {
                hasNavigationBar = false;
            } else if ("0".equals(navBarOverride)) {
                hasNavigationBar = true;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return hasNavigationBar;

    }

    private void createBottomLine(){
        View view = new View(getActivity());
        view.setBackground(getActivity().getResources().getDrawable(R.drawable.slt_as_bottom_line));
        LinearLayout.LayoutParams params = createButtonLayoutParams();
        params.height = 1;
        view.setAlpha(0.5f);
        mPanel.addView(view, params);
    }

    private void createItems() {
        String title = getTitle();
        String subTitle = getSubTitle();
        boolean isTitle = title != null && !title.equals("");
        boolean isSubTitle = subTitle != null && !subTitle.equals("");
        boolean isTitleEmpty = false;

        // Create title
        TextView txtTitle = new TextView(getActivity());
        txtTitle.setId(TITLE_ID);
        txtTitle.setText(title);
        txtTitle.setGravity(Gravity.CENTER);
        txtTitle.setTextSize(20);
        txtTitle.setTypeface(txtTitle.getTypeface(), Typeface.BOLD);
        txtTitle.setPadding(20, 30, 20, 10);
        txtTitle.setTextColor(mAttrs.actionTitleTextColor);
        txtTitle.setBackground(mAttrs.actionTitleBackground);

        // Create subtitle
        TextView txtSubTitle = new TextView(getActivity());
        txtSubTitle.setId(SUB_TITLE_ID);
        txtSubTitle.setText(subTitle);
        txtSubTitle.setGravity(Gravity.CENTER);
        txtSubTitle.setTextSize(12);
        txtSubTitle.setPadding(20, 0, 20, 20);
        txtSubTitle.setTextColor(mAttrs.actionSubTitleTextColor);
        txtSubTitle.setBackground(mAttrs.actionSubTitleBackground);

        if(isTitle && isSubTitle){
            LinearLayout.LayoutParams params = createButtonLayoutParams();
            txtTitle.setOnClickListener(this);
            mPanel.addView(txtTitle, params);
            txtSubTitle.setOnClickListener(this);
            mPanel.addView(txtSubTitle, params);
        }else if(isTitle && !isSubTitle){
            LinearLayout.LayoutParams params = createButtonLayoutParams();
            txtTitle.setOnClickListener(this);
            mPanel.addView(txtTitle, params);

            txtTitle.setPadding(20, 30, 20, 30);
            txtTitle.setBackground(mAttrs.actionTitleSingleBackground);
        }else if(!isTitle && isSubTitle){
            LinearLayout.LayoutParams params = createButtonLayoutParams();
            txtSubTitle.setOnClickListener(this);
            mPanel.addView(txtSubTitle, params);

            txtSubTitle.setPadding(20, 30, 20, 30);
            txtSubTitle.setBackground(mAttrs.actionTitleSingleBackground);
        }else{
            // Empty
            isTitleEmpty = true;
        }

        // Create actions button
        ActionItem[] actionItems = getActionItems();
        if (actionItems != null) {
            for (int i = 0; i < actionItems.length; i++) {
                if((!isTitleEmpty && i < actionItems.length) || (isTitleEmpty && i > 0 && i < actionItems.length)){
                    createBottomLine();
                }
                Button bt = new Button(getActivity());
                bt.setAllCaps(false);
                bt.setId(CANCEL_BUTTON_ID + i + 1);
                bt.setOnClickListener(this);
                bt.setBackground(getActionButtonBg(actionItems, i, isTitleEmpty));
                bt.setText(actionItems[i].getName());
                bt.setTextColor(mAttrs.actionButtonTextColor);
                if(actionItems[i].isWarning()){
                    bt.setTextColor(ContextCompat.getColor(getActivity(), R.color.eeui_red));
                }
                bt.setTextSize(TypedValue.COMPLEX_UNIT_PX, mAttrs.actionTextSize);
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                    bt.setStateListAnimator(null);
                }
                LinearLayout.LayoutParams params = createButtonLayoutParams();
                params.topMargin = mAttrs.actionButtonSpacing;
                mPanel.addView(bt, params);
            }
        }
        Button bt = new Button(getActivity());
        bt.getPaint().setFakeBoldText(true);
        bt.setTextSize(TypedValue.COMPLEX_UNIT_PX, mAttrs.actionTextSize);
        bt.setId(ActionSheet.CANCEL_BUTTON_ID);
        bt.setBackground(mAttrs.cancelActionBackground);
        bt.setText(getCancelButtonTitle());
        bt.setTextColor(mAttrs.cancelButtonTextColor);
        bt.setOnClickListener(this);
        LinearLayout.LayoutParams params = createButtonLayoutParams();
        params.topMargin = mAttrs.cancelButtonMarginTop;
        mPanel.addView(bt, params);

        mPanel.setBackgroundDrawable(mAttrs.background);
        mPanel.setPadding(mAttrs.padding, mAttrs.padding, mAttrs.padding,
                20);
    }

    public LinearLayout.LayoutParams createButtonLayoutParams() {
        LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.WRAP_CONTENT);
        return params;
    }

    private Drawable getActionButtonBg(ActionItem[] actionItems, int i, boolean isTitleEmpty) {
        if (actionItems.length == 1) {
            if(isTitleEmpty){
                return mAttrs.actionButtonSingleBackground;
            }
            return mAttrs.actionButtonBottomBackground;
        }
        if (actionItems.length == 2) {
            switch (i) {
                case 0:
                    if(isTitleEmpty){
                        return mAttrs.actionButtonTopBackground;
                    }
                    return mAttrs.getActionButtonMiddleBackground();
                case 1:
                    return mAttrs.actionButtonBottomBackground;
            }
        }
        if (actionItems.length > 2) {
            if (i == 0) {
                if(isTitleEmpty){
                    return mAttrs.actionButtonTopBackground;
                }
                return mAttrs.getActionButtonMiddleBackground();
            }
            if (i == (actionItems.length - 1)) {
                return mAttrs.actionButtonBottomBackground;
            }
            return mAttrs.getActionButtonMiddleBackground();
        }
        return null;
    }

    private Attributes readAttribute() {
        Attributes attrs = new Attributes(getActivity());
        TypedArray a = getActivity().getTheme().obtainStyledAttributes(null,
                R.styleable.ActionSheet, R.attr.actionSheetStyle, 0);
        Drawable background = a
                .getDrawable(R.styleable.ActionSheet_actionBackground);
        if (background != null) {
            attrs.background = background;
        }
        Drawable actionTitleBackground = a
                .getDrawable(R.styleable.ActionSheet_actionTitleBackground);
        if (actionTitleBackground != null) {
            attrs.actionTitleBackground = actionTitleBackground;
        }
        Drawable actionTitleSingleBackground = a
                .getDrawable(R.styleable.ActionSheet_actionTitleSingleBackground);
        if (actionTitleSingleBackground != null) {
            attrs.actionTitleSingleBackground = actionTitleSingleBackground;
        }
        Drawable actionSubTitleBackground = a
                .getDrawable(R.styleable.ActionSheet_actionSubTitleBackground);
        if (actionSubTitleBackground != null) {
            attrs.actionSubTitleBackground = actionSubTitleBackground;
        }
        Drawable cancelActionBackground = a
                .getDrawable(R.styleable.ActionSheet_cancelActionBackground);
        if (cancelActionBackground != null) {
            attrs.cancelActionBackground = cancelActionBackground;
        }
        Drawable actionButtonTopBackground = a
                .getDrawable(R.styleable.ActionSheet_actionButtonTopBackground);
        if (actionButtonTopBackground != null) {
            attrs.actionButtonTopBackground = actionButtonTopBackground;
        }
        Drawable actionButtonMiddleBackground = a
                .getDrawable(R.styleable.ActionSheet_actionButtonMiddleBackground);
        if (actionButtonMiddleBackground != null) {
            attrs.actionButtonMiddleBackground = actionButtonMiddleBackground;
        }
        Drawable actionButtonBottomBackground = a
                .getDrawable(R.styleable.ActionSheet_actionButtonBottomBackground);
        if (actionButtonBottomBackground != null) {
            attrs.actionButtonBottomBackground = actionButtonBottomBackground;
        }
        Drawable actionButtonSingleBackground = a
                .getDrawable(R.styleable.ActionSheet_actionButtonSingleBackground);
        if (actionButtonSingleBackground != null) {
            attrs.actionButtonSingleBackground = actionButtonSingleBackground;
        }
        attrs.actionTitleTextColor = a.getColor(
                R.styleable.ActionSheet_actionTitleTextColor,
                attrs.actionTitleTextColor);
        attrs.actionSubTitleTextColor = a.getColor(
                R.styleable.ActionSheet_actionSubTitleTextColor,
                attrs.actionSubTitleTextColor);
        attrs.cancelButtonTextColor = a.getColor(
                R.styleable.ActionSheet_cancelActionTextColor,
                attrs.cancelButtonTextColor);
        attrs.actionButtonTextColor = a.getColor(
                R.styleable.ActionSheet_actionButtonTextColor,
                attrs.actionButtonTextColor);
        attrs.padding = (int) a.getDimension(
                R.styleable.ActionSheet_actionPadding, attrs.padding);
        attrs.actionButtonSpacing = (int) a.getDimension(
                R.styleable.ActionSheet_actionButtonSpacing,
                attrs.actionButtonSpacing);
        attrs.cancelButtonMarginTop = (int) a.getDimension(
                R.styleable.ActionSheet_cancelActionMarginTop,
                attrs.cancelButtonMarginTop);
        attrs.actionTextSize = a.getDimensionPixelSize(R.styleable.ActionSheet_actionTextSize, (int) attrs.actionTextSize);

        a.recycle();
        return attrs;
    }

    private String getCancelButtonTitle() {
        return getArguments().getString(ARG_CANCEL_BUTTON_TITLE);
    }

    private String getTitle() {
        return getArguments().getString(ARG_TITLE);
    }

    private String getSubTitle() {
        return getArguments().getString(ARG_SUB_TITLE);
    }

    private ActionItem[] getActionItems() {
        return (ActionItem[]) getArguments().getParcelableArray(ARG_ACTION_ITEMS);
    }

    private boolean getCancelableOnTouchOutside() {
        return getArguments().getBoolean(ARG_CANCELABLE_ONTOUCHOUTSIDE);
    }

    public void setActionSheetListener(ActionSheetListener listener) {
        mListener = listener;
    }

    @Override
    public void onClick(View v) {
        if (v.getId() == ActionSheet.BG_VIEW_ID && !getCancelableOnTouchOutside()) {
            return;
        }
        if(v.getId() == ActionSheet.TITLE_ID || v.getId() == ActionSheet.SUB_TITLE_ID){
            return;
        }
        dismiss();
        if (v.getId() != ActionSheet.CANCEL_BUTTON_ID && v.getId() != ActionSheet.BG_VIEW_ID) {
            if (mListener != null) {
                mListener.onActionButtonClick(this, v.getId() - CANCEL_BUTTON_ID
                        - 1);
            }
            isCancel = false;
        }
    }

    public static Builder createBuilder(Context context,
                                        FragmentManager fragmentManager) {
        return new Builder(context, fragmentManager);
    }

    private static class Attributes {
        private Context mContext;

        public Attributes(Context context) {
            mContext = context;
            this.background = new ColorDrawable(Color.TRANSPARENT);
            this.cancelActionBackground = new ColorDrawable(Color.BLACK);
            ColorDrawable gray = new ColorDrawable(Color.GRAY);
            this.actionButtonTopBackground = gray;
            this.actionButtonMiddleBackground = gray;
            this.actionButtonBottomBackground = gray;
            this.actionButtonSingleBackground = gray;
            this.cancelButtonTextColor = Color.WHITE;
            this.actionButtonTextColor = Color.BLACK;
            this.padding = dp2px(20);
            this.actionButtonSpacing = dp2px(0);
            this.cancelButtonMarginTop = dp2px(10);
            this.actionTextSize = dp2px(16);
        }

        private int dp2px(int dp) {
            return (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP,
                    dp, mContext.getResources().getDisplayMetrics());
        }

        public Drawable getActionButtonMiddleBackground() {
            if (actionButtonMiddleBackground instanceof StateListDrawable) {
                TypedArray a = mContext.getTheme().obtainStyledAttributes(null,
                        R.styleable.ActionSheet, R.attr.actionSheetStyle, 0);
                actionButtonMiddleBackground = a
                        .getDrawable(R.styleable.ActionSheet_actionButtonMiddleBackground);
                a.recycle();
            }
            return actionButtonMiddleBackground;
        }

        Drawable background;
        Drawable actionTitleBackground;
        Drawable actionTitleSingleBackground;
        Drawable actionSubTitleBackground;
        Drawable cancelActionBackground;
        Drawable actionButtonTopBackground;
        Drawable actionButtonMiddleBackground;
        Drawable actionButtonBottomBackground;
        Drawable actionButtonSingleBackground;
        int actionTitleTextColor;
        int actionSubTitleTextColor;
        int cancelButtonTextColor;
        int actionButtonTextColor;
        int padding;
        int actionButtonSpacing;
        int cancelButtonMarginTop;
        float actionTextSize;
    }

    public static class Builder {

        private Context mContext;
        private FragmentManager mFragmentManager;
        private String mTitle;
        private String mSubTitle;
        private String mCancelButtonTitle;
        private ActionItem[] actionItems;
        private String mTag = "actionSheet";
        private boolean mCancelableOnTouchOutside;
        private ActionSheetListener mListener;

        public Builder(Context context, FragmentManager fragmentManager) {
            mContext = context;
            mFragmentManager = fragmentManager;
        }

        public Builder setTitle(String title) {
            mTitle = title;
            return this;
        }

        public Builder setSubTitle(String subTitle) {
            mSubTitle = subTitle;
            return this;
        }

        public Builder setCancelActionTitle(String title) {
            mCancelButtonTitle = title;
            return this;
        }

        public Builder setCancelActionTitle(int strId) {
            return setCancelActionTitle(mContext.getString(strId));
        }

        public Builder setActionItems(List<ActionItem> actionItems) {
            ActionItem[] temp = new ActionItem[actionItems.size()];
            for (int i = 0; i < actionItems.size(); i++) {
                temp[i] = actionItems.get(i);
            }
            this.actionItems = temp;
            return this;
        }

        public Builder setActionItems(ActionItem[] actionItems) {
            this.actionItems = actionItems;
            return this;
        }

        public Builder setTag(String tag) {
            mTag = tag;
            return this;
        }

        public Builder setListener(ActionSheetListener listener) {
            this.mListener = listener;
            return this;
        }

        public Builder setCancelableOnTouchOutside(boolean cancelable) {
            mCancelableOnTouchOutside = cancelable;
            return this;
        }

        public Bundle prepareArguments() {
            Bundle bundle = new Bundle();
            bundle.putString(ARG_TITLE, mTitle);
            bundle.putString(ARG_SUB_TITLE, mSubTitle);
            bundle.putString(ARG_CANCEL_BUTTON_TITLE, mCancelButtonTitle);
            bundle.putParcelableArray(ARG_ACTION_ITEMS, actionItems);
            bundle.putBoolean(ARG_CANCELABLE_ONTOUCHOUTSIDE,
                    mCancelableOnTouchOutside);
            return bundle;
        }

        public ActionSheet show() {
            ActionSheet actionSheet = (ActionSheet) Fragment.instantiate(
                    mContext, ActionSheet.class.getName(), prepareArguments());
            actionSheet.setActionSheetListener(mListener);
            actionSheet.show(mFragmentManager, mTag);
            return actionSheet;
        }

    }

    public static interface ActionSheetListener {

        void onDismiss(ActionSheet actionSheet, boolean isCancel);

        void onActionButtonClick(ActionSheet actionSheet, int index);
    }

}

package app.eeui.framework.extend.integration.iconify.widget;

import android.annotation.SuppressLint;
import android.content.Context;
import android.util.AttributeSet;
import android.util.TypedValue;
import android.widget.TextView;
import app.eeui.framework.extend.integration.iconify.Iconify;
import app.eeui.framework.extend.integration.iconify.internal.HasOnViewAttachListener;

@SuppressLint("AppCompatCustomView")
public class IconTextView extends TextView implements HasOnViewAttachListener {

    private boolean autoSize = false;
    private HasOnViewAttachListenerDelegate delegate;

    public IconTextView(Context context) {
        super(context);
        init();
    }

    public IconTextView(Context context, AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public IconTextView(Context context, AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);
        init();
    }

    private void init() {
        setTransformationMethod(null);
    }

    @Override
    public void setText(CharSequence text, BufferType type) {
        super.setText(Iconify.compute(getContext(), text, this), type);
    }

    @Override
    public void setOnViewAttachListener(OnViewAttachListener listener) {
        if (delegate == null) delegate = new HasOnViewAttachListenerDelegate(this);
        delegate.setOnViewAttachListener(listener);
    }

    @Override
    protected void onAttachedToWindow() {
        super.onAttachedToWindow();
        delegate.onAttachedToWindow();
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        delegate.onDetachedFromWindow();
    }

    @Override
    protected void onTextChanged(final CharSequence text, final int start, final int before, final int after)
    {
        this.refitText(text.toString(), this.getWidth());
    }

    @Override
    protected void onSizeChanged(int width, int height, int oldwidth, int oldheight)
    {
        if (width != oldwidth) {
            this.refitText(this.getText().toString(), width);
        }
    }

    public boolean isAutoSize() {
        return autoSize;
    }

    /**
     * 开启自适应调整字体大小
     * @param autoSize
     */
    public void setAutoSize(boolean autoSize) {
        this.autoSize = autoSize;
    }

    /**
     * 自适应调整字体大小
     * @param text
     * @param textWidth
     */
    private void refitText(String text, int textWidth)
    {
        if (!isAutoSize() || textWidth <= 0 || text == null || text.length() == 0) {
            return;
        }
        int targetWidth = textWidth - this.getPaddingLeft() - this.getPaddingRight();
        this.setTextSize(TypedValue.COMPLEX_UNIT_PX, targetWidth);
    }
}

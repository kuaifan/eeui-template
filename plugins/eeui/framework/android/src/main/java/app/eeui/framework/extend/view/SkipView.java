package app.eeui.framework.extend.view;


import android.content.Context;
import android.content.res.TypedArray;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Rect;
import android.graphics.RectF;
import androidx.annotation.Nullable;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.View;

import app.eeui.framework.R;
import app.eeui.framework.extend.module.utilcode.util.SizeUtils;

/**
 * Create By ZZY on 2019/5/14
 */
public class SkipView extends View {
    // 圆实心的颜色
    private int circleSolidColor;

    // 圆边框的颜色
    private int circleFrameColor;

    // 圆的半径
    private int circleRadius;

    // 进度条的颜色
    private int progressColor;

    // 进度条的宽度
    private int progressWidth;

    // 文字的颜色
    private int textColor;

    // 文字的大小
    private int textSize;

    // 代表内部圆边框到文字的距离
    private int textPadding;

    private Rect mBounds;
    private Paint mPaint;
    private RectF mArcRectF;

    // 位置坐标
    private int mCenterX;
    private int mCenterY;

    // 文字内容
    private String text;

    // 进度倒计时时间
    private long totalTime;

    // 跳过通知
    private OnSkipListener mListener;

    // 当前的进度
    private int mProgress;

    // 开始的位置
    private int startPosition;

    // 进度条类型
    private int progressType;

    // 进度条类型的枚举型
    public enum ProgressType {
        CLOCKWISE,
        COUNTERCLOCKWISE
    }

    // 开始的位置的枚举型

    public enum StartPosition {
        TOP(-90),
        BOTTOM(90),
        LEFT(180),
        RIGHT(0);
        private final int value;

        // 构造器默认也只能是private, 从而保证构造函数只能在内部使用
        StartPosition(int value) {
            this.value = value;
        }

        public int getValue() {
            return value;
        }

    }

    public void setCircleSolidColor(int circleSolidColor) {
        this.circleSolidColor = circleSolidColor;
    }

    public void setCircleFrameColor(int circleFrameColor) {
        this.circleFrameColor = circleFrameColor;
    }

    public void setProgressColor(int progressColor) {
        this.progressColor = progressColor;
    }

    public void setProgressWidth(int progressWidth) {
        this.progressWidth = progressWidth;
    }

    public void setTextColor(int textColor) {
        this.textColor = textColor;
    }

    public void setTextSize(int textSize) {
        this.textSize = textSize;
    }

    public void setTextPadding(int textPadding) {
        this.textPadding = textPadding;
    }

    public void setText(String text) {
        this.text = text;
    }

    public void setTotalTime(long totalTime) {
        this.totalTime = totalTime;
    }

    public void setOnSkipListener(OnSkipListener mListener) {
        this.mListener = mListener;
    }

    public void setStartPosition(StartPosition startPosition) {
        this.startPosition = startPosition.getValue();
    }

    public void setProgressType(ProgressType progressType) {
        this.progressType = progressType.ordinal();
    }

    public SkipView(Context context) {
        super(context);
        initValue();
        initAttrs(context, null);
    }

    private void initValue() {
        mPaint = new Paint();
        mBounds = new Rect();
        mArcRectF = new RectF();
    }

    public SkipView(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        initValue();
        initAttrs(context, attrs);
    }

    private void initAttrs(Context context, AttributeSet attrs) {
        TypedArray typedArray = context.obtainStyledAttributes(attrs, R.styleable.SkipView);
        if (typedArray != null) {
            System.out.println("if");
            circleSolidColor = typedArray.getColor(R.styleable.SkipView_circleSolidColor, 0x00000000);
            circleFrameColor = typedArray.getColor(R.styleable.SkipView_circleFrameColor, Color.parseColor("#A9A9A9"));
            textColor = typedArray.getColor(R.styleable.SkipView_textColor, Color.WHITE);
            progressColor = typedArray.getColor(R.styleable.SkipView_progressColor, Color.RED);
            progressWidth = typedArray.getInt(R.styleable.SkipView_progressWidth, 6);
            textSize = typedArray.getInt(R.styleable.SkipView_textSize, 13);
            textPadding = typedArray.getInt(R.styleable.SkipView_textPadding, 7);
            totalTime = typedArray.getInt(R.styleable.SkipView_totalTime, 4 * 1000);
            text = typedArray.getString(R.styleable.SkipView_text);
            startPosition = typedArray.getInt(R.styleable.SkipView_startPosition, StartPosition.TOP.getValue());
            progressType = typedArray.getInt(R.styleable.SkipView_progressType, ProgressType.CLOCKWISE.ordinal());
            if(TextUtils.isEmpty(text)){
                text = "跳过";
            }
            // 回收
            typedArray.recycle();
        } else {
            System.out.println("else");
            circleSolidColor = 0x00000000;
            circleFrameColor = Color.parseColor("#A9A9A9");
            progressColor = Color.RED;
            textColor = Color.WHITE;
            progressWidth = 6;
            textSize = 13;
            textPadding = 7;
            totalTime = 4 * 1000;
            text = "跳过";
            startPosition = StartPosition.TOP.getValue();
            progressType = ProgressType.CLOCKWISE.ordinal();
        }
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec);

        mPaint.setTextSize(SizeUtils.sp2px(textSize));
        circleRadius = (int) mPaint.measureText(text) / 2 + SizeUtils.dp2px(textPadding)
                + progressWidth;
        setMeasuredDimension(circleRadius * 2, circleRadius * 2);
    }

    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);

        getDrawingRect(mBounds);

        mCenterX = mBounds.centerX();
        mCenterY = mBounds.centerY();

        // 画实心圆
        mPaint.setAntiAlias(true); //设置抗锯齿
        mPaint.setStyle(Paint.Style.FILL); //实心填充style
        mPaint.setColor(circleSolidColor);
        canvas.drawCircle(mBounds.centerX(), mBounds.centerY(), circleRadius, mPaint);

        // 画外边框(空心圆,即圆边框)
        mPaint.setAntiAlias(true);//设置抗锯齿
        mPaint.setStyle(Paint.Style.STROKE);//空心style
        mPaint.setStrokeWidth(progressWidth);//设置空心线宽度
        mPaint.setColor(circleFrameColor);
        canvas.drawCircle(mBounds.centerX(), mBounds.centerY(), circleRadius - progressWidth, mPaint);

        // 画文字
        mPaint.setColor(textColor);
        mPaint.setAntiAlias(true);
        mPaint.setTextAlign(Paint.Align.CENTER);
        mPaint.setTextSize(SizeUtils.sp2px(textSize));
        mPaint.setStyle(Paint.Style.FILL);
        mPaint.setStrokeWidth(2);
        float textY = mCenterY - (mPaint.descent() + mPaint.ascent()) / 2;
        canvas.drawText(text, mCenterX, textY, mPaint);


        // 画进度条
        mPaint.setColor(progressColor);
        mPaint.setStyle(Paint.Style.STROKE);
        mPaint.setStrokeWidth(progressWidth);
        mPaint.setStrokeCap(Paint.Cap.ROUND);
        mArcRectF.set(mBounds.left + progressWidth, mBounds.top + progressWidth,
                mBounds.right - progressWidth, mBounds.bottom - progressWidth);
        if(progressType == 0){
            canvas.drawArc(mArcRectF, startPosition, 360 * mProgress / 100, false, mPaint);
        }else{
            canvas.drawArc(mArcRectF, startPosition, 360 * (100 - mProgress) / 100, false, mPaint);
        }

    }

    /**
     * 进度更新task
     */
    private Runnable mProgressChangeTask = new Runnable() {
        @Override
        public void run() {
            removeCallbacks(this);
            mProgress++;
            if (mProgress > 0 && mProgress < 100) {
                invalidate();
                postDelayed(mProgressChangeTask, totalTime / 100);
            } else {
                if (mListener != null) {
                    mListener.onFinish();
                }
            }
        }
    };

    public void start() {
        stop();
        mProgress = 0;
        post(mProgressChangeTask);
    }

    private void stop() {
        removeCallbacks(mProgressChangeTask);
    }


    //接口声明
    public interface OnSkipListener {
        //跳过的时候回调,返回跳过的时的进度
        void onSkip(int progress);

        //未跳过且完成时回调
        void onFinish();
    }

    @Override
    public boolean onTouchEvent(MotionEvent event) {
        int eventAction = event.getAction();
        switch (eventAction) {
            case MotionEvent.ACTION_DOWN:
                setAlpha(0.5f);
                break;
            case MotionEvent.ACTION_MOVE:
                break;
            case MotionEvent.ACTION_UP:
                setAlpha(1f);
                stop();
                if (mListener != null) {
                    mListener.onSkip(mProgress);
                }
                break;
        }
        return true;
    }
}

package app.eeui.framework.extend.view.loading.spinkit;

import app.eeui.framework.extend.view.loading.spinkit.sprite.Sprite;
import app.eeui.framework.extend.view.loading.spinkit.style.ChasingDots;
import app.eeui.framework.extend.view.loading.spinkit.style.Circle;
import app.eeui.framework.extend.view.loading.spinkit.style.CubeGrid;
import app.eeui.framework.extend.view.loading.spinkit.style.DoubleBounce;
import app.eeui.framework.extend.view.loading.spinkit.style.FadingCircle;
import app.eeui.framework.extend.view.loading.spinkit.style.FoldingCube;
import app.eeui.framework.extend.view.loading.spinkit.style.MultiplePulse;
import app.eeui.framework.extend.view.loading.spinkit.style.MultiplePulseRing;
import app.eeui.framework.extend.view.loading.spinkit.style.Pulse;
import app.eeui.framework.extend.view.loading.spinkit.style.PulseRing;
import app.eeui.framework.extend.view.loading.spinkit.style.RotatingCircle;
import app.eeui.framework.extend.view.loading.spinkit.style.RotatingPlane;
import app.eeui.framework.extend.view.loading.spinkit.style.ThreeBounce;
import app.eeui.framework.extend.view.loading.spinkit.style.WanderingCubes;
import app.eeui.framework.extend.view.loading.spinkit.style.Wave;

/**
 * Created by ybq.
 */
public class SpriteFactory {

    public static Sprite create(Style style) {
        Sprite sprite = null;
        switch (style) {
            case ROTATING_PLANE:
                sprite = new RotatingPlane();
                break;
            case DOUBLE_BOUNCE:
                sprite = new DoubleBounce();
                break;
            case WAVE:
                sprite = new Wave();
                break;
            case WANDERING_CUBES:
                sprite = new WanderingCubes();
                break;
            case PULSE:
                sprite = new Pulse();
                break;
            case CHASING_DOTS:
                sprite = new ChasingDots();
                break;
            case THREE_BOUNCE:
                sprite = new ThreeBounce();
                break;
            case CIRCLE:
                sprite = new Circle();
                break;
            case CUBE_GRID:
                sprite = new CubeGrid();
                break;
            case FADING_CIRCLE:
                sprite = new FadingCircle();
                break;
            case FOLDING_CUBE:
                sprite = new FoldingCube();
                break;
            case ROTATING_CIRCLE:
                sprite = new RotatingCircle();
                break;
            case MULTIPLE_PULSE:
                sprite = new MultiplePulse();
                break;
            case PULSE_RING:
                sprite = new PulseRing();
                break;
            case MULTIPLE_PULSE_RING:
                sprite = new MultiplePulseRing();
                break;
            default:
                break;
        }
        return sprite;
    }
}

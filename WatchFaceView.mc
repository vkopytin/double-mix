import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Weather;
import Toybox.Time;
import Toybox.Application;
import Toybox.Graphics;
using Toybox.Time.Gregorian as Date;

const WEEK_DAYS = ["", "SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"];
const MONTHS = {
    Date.MONTH_JANUARY => "JAN",
    Date.MONTH_FEBRUARY => "FEB",
    Date.MONTH_MARCH => "MAR",
    Date.MONTH_APRIL => "APR",
    Date.MONTH_MAY => "MAY",
    Date.MONTH_JUNE => "JUN",
    Date.MONTH_JULY => "JUL",
    Date.MONTH_AUGUST => "AUG",
    Date.MONTH_SEPTEMBER => "SEP",
    Date.MONTH_OCTOBER => "OCT",
    Date.MONTH_NOVEMBER => "NOV",
    Date.MONTH_DECEMBER => "DEC"
};

class WatchFaceView extends WatchUi.WatchFace {
    private const ONE_RAD = Math.PI * 2.0 / 60.0;
    private const timer = MainTimer.create(self);
    private var sleepMode = false;
    private const initBufferOptions = {
        :width => 260,
        :height => 260,
    };
    private var width = 260;
    private var height = 260;
    private var seconds = 0;
    private var quota = 1010;

    private var backLayout = [] as Array<Toybox.WatchUi.Drawable>;
    private var analogClock = null as AnalogClockView;

    private var hand = null as WatchUi.BitmapResource;
    private var handDisk = null as WatchUi.BitmapResource;
    private var buffer = null as Graphics.BufferedBitmap;
    private var buffer2 = null as Graphics.BufferedBitmap;
    private var backBuffer = null as Graphics.BufferedBitmap;
    private var infoBuffer = null as Graphics.BufferedBitmap;
    private var frontBuffer = null as Graphics.BufferedBitmap;

    private const transform = new Graphics.AffineTransform();
    private const transform2 = new Graphics.AffineTransform();
    private const transformMove = new Graphics.AffineTransform();
    private const transformDayNight = new Graphics.AffineTransform();

    private const drawBitmapOptions = {
        :transform => self.transform
    };
    private const drawBitmapOptions2 = {
        :transform => self.transform2
    };
    private const initBufferOptions1 = {
        :width => 16,
        :height => 151,
    };
    private const initBufferOptions2 = {
        :width => 260,
        :height => 260,
    };
    private const drawDayNightOptions = {
        :transform => self.transformDayNight
    };
    //private var initClip = [[0.0, 145.0],[0.0, 0.0], [16.0, 0.0], [16.0, 145.0]];
    private const initClip = [[-5.0, 50.0],[-5.0, 0.0], [14.0, 0.0], [14.0, 50.0]];
    private const clearRange = [79, 53, 103, 24];
    private const emptyOpts = {};
    private var lastTime = 0;
    private var clockTime = null as System.ClockTime?;

    private var currentTime = null as Toybox.WatchUi.Text?;
    private var weekDay = null as Toybox.WatchUi.Text?;
    private var monthAndDate = null as Toybox.WatchUi.Text?;
    private var background = null as Toybox.WatchUi.Drawable?;
    private var dayNightBand = null as WatchUi.BitmapResource?;
    private var secondsClock = null as SecondsClockView?;

    function initialize() {
        WatchFace.initialize();
        self.transformMove.translate(103.0, 137.0);
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        self.width = dc.getWidth();
        self.height = dc.getHeight();
        self.initBufferOptions[:width] = self.width;
        self.initBufferOptions[:height] = self.height;
        dc.setAntiAlias(true);
        self.backLayout = Rez.Layouts.main(dc);
        setLayout(self.backLayout);

        self.dayNightBand = WatchUi.loadResource(Rez.Drawables.dayNightBand);
        self.background = View.findDrawableById("background");
        self.currentTime = View.findDrawableById("currentTime");
        self.weekDay = View.findDrawableById("weekDay");
        self.monthAndDate = View.findDrawableById("monthAndDate");
        self.analogClock = View.findDrawableById("analogClock") as AnalogClockView;
        self.secondsClock = View.findDrawableById("secondsClock") as SecondsClockView;
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
        self.timer.nextTick();
        if (self.sleepMode == false) {
            self.timer.start();
        }
    }

    function updateBackBuffer(dc as Dc) as Void {
        var backBufferdc = null as Graphics.Dc?;

        if (self.backBuffer != null && self.seconds != 0) {
            return;
        }

        self.backBuffer = Graphics.createBufferedBitmap(
            self.initBufferOptions
        ).get();

        backBufferdc = self.backBuffer.getDc();

        backBufferdc.setAntiAlias(true);

        backBufferdc.drawBitmap2(0, 98, self.dayNightBand, self.drawDayNightOptions);
        self.background.draw(backBufferdc);

        backBufferdc = null;
    }

    function updateFrontBuffer(dc as Dc) as Void {
        var frontBufferdc = null as Graphics.Dc?;

        if (self.frontBuffer != null && self.seconds != 0) {
            return;
        }

        self.frontBuffer = Graphics.createBufferedBitmap(
            self.initBufferOptions
        ).get();

        frontBufferdc = self.frontBuffer.getDc();

        frontBufferdc.setAntiAlias(true);

        //self.stepsComplication.draw(frontBufferdc);
        //self.foreground.draw(frontBufferdc);

        frontBufferdc = null;
    }

    function updateInfoBuffer(dc as Dc) as Void {
        var infoBufferdc = null as Graphics.Dc?;

        self.infoBuffer = Graphics.createBufferedBitmap(
            self.initBufferOptions
        ).get();

        infoBufferdc = self.infoBuffer.getDc();

        infoBufferdc.setAntiAlias(true);

        self.weekDay.draw(infoBufferdc);
        self.monthAndDate.draw(infoBufferdc);
        self.currentTime.draw(infoBufferdc);
        self.analogClock.draw(infoBufferdc);
        self.secondsClock.draw(infoBufferdc);
        //self.bg.draw(bufferdc);
        //self.infoWeekDay.draw(bufferdc);
        //self.infoStress.draw(bufferdc);
        //self.bodyBattery.draw(bufferdc);
        //self.infoWeather.draw(bufferdc);
        //self.infoMoon.draw(bufferdc);
        //infoBufferdc.drawBitmap(0, 0, self.frontBuffer);
        //self.infoDateStatus.draw(bufferdc);
        //self.analogClock.draw(bufferdc);

        infoBufferdc = null;
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        dc.clearClip();
        dc.setAntiAlias(true);

        try {
            var activityMonitor = ActivityMonitor.getInfo();
            if (activityMonitor != null && activityMonitor.steps != null) {
                // toDO: update activity (activityMonitor.steps);
            }

            var now = Time.now();
            var date = Date.info(now, Time.FORMAT_SHORT);
            // set (date.day_of_week);
            // set (date.day, date.month);

            var stressIterator = Toybox.SensorHistory.getHeartRateHistory({ :period => 1 });
            var sample = stressIterator.next();
            if (sample != null && sample.data != null) {
                // set (sample.data);
            }
            var activityInfo = Activity.getActivityInfo();
            if (activityInfo != null && activityInfo.currentHeartRate != null) {
                // set (activityInfo.currentHeartRate);
            }

            var bodyBatteryIterator = Toybox.SensorHistory.getBodyBatteryHistory({ :period => 1 });
            sample = bodyBatteryIterator.next();
            if (sample != null && sample.data != null) {
                // set (sample.data);
            }

            self.clockTime = System.getClockTime();
            self.seconds = self.clockTime.sec;
            self.quota = 1030;

            self.background.draw(dc);
            self.currentTime.setText(Lang.format("$1$:$2$", [self.clockTime.hour.format("%02d"), self.clockTime.min.format("%02d")]));
            self.weekDay.setText(WEEK_DAYS[date.day_of_week]);
            self.weekDay.setColor(date.day_of_week == Date.DAY_SUNDAY ? 0xFF5500 : Graphics.COLOR_LT_GRAY);
            self.monthAndDate.setText(Lang.format("$1$ $2$", [MONTHS[date.month], date.day.format("%02d")]));

            self.secondsClock.setSeconds(clockTime.sec);

            var dayNightPosition = (self.clockTime.hour + self.clockTime.min / 60.0) / 24.0 * 240.0 - 200.0;
            self.transformDayNight.initialize();
            self.transformDayNight.translate(dayNightPosition, 70.0);

            self.updateBackBuffer(dc);
            self.updateFrontBuffer(dc);
            self.updateInfoBuffer(dc);

            dc.drawBitmap(0, 0, self.backBuffer);
            dc.drawBitmap(0, 0, self.infoBuffer);
            dc.drawBitmap(0, 0, self.frontBuffer);

            self.secondsClock.drawSecondsHand(dc, self.backBuffer, self.frontBuffer);
        } catch (ex) {
            var message = ex.getErrorMessage();
            System.println(message);
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(10, 120, Graphics.FONT_TINY, message, Graphics.TEXT_JUSTIFY_LEFT|Graphics.TEXT_JUSTIFY_VCENTER);
        }
    }

    // Handle the partial update event
    function onPartialUpdate( dc as Dc ) {
        dc.clearClip();
        self.lastTime = System.getTimer();
        var angle = self.seconds * self.ONE_RAD;

        self.transform2.initialize();
        self.transform2.rotate(-angle);
        self.transform2.translate(-130.0, -130.0);
        //dc.setClip(self.clearRange[0], self.clearRange[1], self.clearRange[2], self.clearRange[3]);

        if (self.quota < 999) {
            self.seconds++;
            self.quota += 2 - (System.getTimer() - self.lastTime);
            //return;
        }

        var clip = self.transformMove.transformPoints(
            self.transform.transformPoints(self.initClip)
        );
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon(clip);
        var minX = clip[0][0] < clip[2][0] ? clip[0][0] : clip[2][0] < clip[1][0] ? clip[2][0] : clip[1][0];
        var minY = clip[0][1] < clip[2][1] ? clip[0][1] : clip[2][1] < clip[1][1] ? clip[2][1] : clip[1][1];
        var maxX = clip[0][0] > clip[2][0] ? clip[0][0] : clip[2][0] > clip[1][0] ? clip[2][0] : clip[1][0];
        var maxY = clip[0][1] > clip[2][1] ? clip[0][1] : clip[2][1] > clip[1][1] ? clip[2][1] : clip[1][1];
        //dc.setClip(minX, minY, maxX - minX, maxY - minY);

        // if (seconds < 16) {
        //     dc.setClip(clip[0][0], clip[1][1], clip[2][0] - clip[0][0], clip[3][1] - clip[1][1]);
        // } else if (seconds < 31) {
        //     dc.setClip(clip[3][0], clip[0][1], clip[1][0] - clip[3][0], clip[2][1] - clip[0][1]);
        // } else if (seconds < 46) {
        //     dc.setClip(clip[2][0], clip[3][1], clip[0][0] - clip[2][0], clip[1][1] - clip[3][1]);
        // } else {
        //     dc.setClip(clip[1][0], clip[2][1], clip[3][0] - clip[1][0], clip[0][1] - clip[2][1]);
        // }

        self.transform.initialize();
        self.transform.rotate(angle);
        self.transform.translate(-8.0, -46.0);

        self.seconds++;
        self.quota += 1 - (System.getTimer() - self.lastTime);
    }

    function engineTick(deltaTime) as Void {
        self.clockTime = System.getClockTime();
        // self.secondsDisk.setSeconds(clockTime.sec);
        self.analogClock.setTime(self.clockTime.hour, self.clockTime.min, self.clockTime.sec);

        WatchUi.requestUpdate();
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
        self.timer.stop();
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
        self.sleepMode = false;
        self.timer.nextTick();
        self.timer.start();
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
        self.sleepMode = true;
        self.timer.stop();
    }
}

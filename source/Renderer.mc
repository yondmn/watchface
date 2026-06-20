import Toybox.Graphics;
import Toybox.Lang;

class Renderer {

    function initialize() {
    }

    function draw(dc as Dc, data as WatchFaceData) as Void {
        dc.setColor(Settings.PRIMARY_COLOR, Settings.BACKGROUND_COLOR);
        dc.clear();

        drawDate(dc, data);
        drawTime(dc, data);
        drawMetrics(dc, data);
    }

    function drawDate(dc as Dc, data as WatchFaceData) as Void {
        var text = Lang.format(
            "$1$ $2$ $3$",
            [
                Settings.dayName(data.dayOfWeek),
                formatNumber(data.day, 2),
                Settings.monthName(data.month)
            ]
        );

        drawCenteredText(dc, text, Settings.CENTER_X, Settings.DATE_Y, Settings.TOP_FONT, Settings.SECONDARY_COLOR);
    }

    function drawTime(dc as Dc, data as WatchFaceData) as Void {
        var timeText = Lang.format(
            "$1$:$2$",
            [
                formatNumber(data.hour, 2),
                formatNumber(data.minute, 2)
            ]
        );
        var timeFont = getTimeFont(dc, timeText);
        var timeWidth = dc.getTextWidthInPixels(timeText, timeFont);
        var secondsText = formatNumber(data.second, 2);

        drawCenteredText(dc, timeText, Settings.CENTER_X, Settings.TIME_Y, timeFont, Settings.PRIMARY_COLOR);

        dc.setColor(Settings.SECONDARY_COLOR, Settings.BACKGROUND_COLOR);
        dc.drawText(
            Settings.CENTER_X + (timeWidth / 2) + Settings.SECONDS_X_GAP,
            Settings.SECONDS_Y,
            Settings.SECONDS_FONT,
            secondsText,
            Graphics.TEXT_JUSTIFY_LEFT
        );
    }

    function drawMetrics(dc as Dc, data as WatchFaceData) as Void {
        drawMetric(dc, Settings.COLUMN_1_X, Settings.ICON_HEART, formatValue(data.heartRate, "--"));
        drawMetric(dc, Settings.COLUMN_2_X, Settings.ICON_STEPS, compactNumber(data.steps));
        drawMetric(dc, Settings.COLUMN_3_X, Settings.ICON_TEMP, formatWeather(data.temperature));
        drawMetric(dc, Settings.COLUMN_4_X, Settings.ICON_BATTERY, formatBattery(data.batteryPercent));
    }

    function drawMetric(dc as Dc, x as Number, icon as Number, value as String) as Void {
        drawMetricIcon(dc, icon, x, Settings.METRIC_ICON_Y);
        drawCenteredText(dc, value, x, Settings.METRIC_VALUE_Y, Settings.METRIC_FONT, Settings.PRIMARY_COLOR);
    }

    function drawMetricIcon(dc as Dc, icon as Number, x as Numeric, y as Numeric) as Void {
        dc.setColor(Settings.PRIMARY_COLOR, Settings.BACKGROUND_COLOR);
        dc.setPenWidth(1);

        switch (icon) {
            case Settings.ICON_HEART:
                drawHeartIcon(dc, x, y);
                break;
            case Settings.ICON_STEPS:
                drawStepsIcon(dc, x, y);
                break;
            case Settings.ICON_TEMP:
                drawSunIcon(dc, x, y);
                break;
            case Settings.ICON_BATTERY:
                drawBatteryIcon(dc, x, y);
                break;
        }

        dc.setPenWidth(1);
    }

    function drawHeartIcon(dc as Dc, x as Numeric, y as Numeric) as Void {
        dc.fillPolygon([
            [x, y + 7],
            [x - 8, y],
            [x - 6, y - 6],
            [x, y - 3],
            [x + 6, y - 6],
            [x + 8, y]
        ]);
    }

    function drawStepsIcon(dc as Dc, x as Numeric, y as Numeric) as Void {
        dc.fillCircle(x - 5, y + 2, 3);
        dc.fillCircle(x - 6, y - 4, 2);
        dc.fillCircle(x - 3, y - 5, 2);
        dc.fillCircle(x + 5, y - 1, 3);
        dc.fillCircle(x + 4, y - 7, 2);
        dc.fillCircle(x + 7, y - 8, 2);
    }

    function drawSunIcon(dc as Dc, x as Numeric, y as Numeric) as Void {
        dc.drawCircle(x, y, 4);
        dc.drawLine(x, y - 9, x, y - 7);
        dc.drawLine(x, y + 7, x, y + 9);
        dc.drawLine(x - 9, y, x - 7, y);
        dc.drawLine(x + 7, y, x + 9, y);
        dc.drawLine(x - 6, y - 6, x - 5, y - 5);
        dc.drawLine(x + 5, y - 5, x + 6, y - 6);
        dc.drawLine(x - 6, y + 6, x - 5, y + 5);
        dc.drawLine(x + 5, y + 5, x + 6, y + 6);
    }

    function drawBatteryIcon(dc as Dc, x as Numeric, y as Numeric) as Void {
        dc.drawLine(x - 9, y - 5, x + 6, y - 5);
        dc.drawLine(x - 9, y + 5, x + 6, y + 5);
        dc.drawLine(x - 9, y - 5, x - 9, y + 5);
        dc.drawLine(x + 6, y - 5, x + 6, y + 5);
        dc.drawLine(x + 8, y - 2, x + 8, y + 2);
    }

    function drawCenteredText(dc as Dc, text as String, x as Numeric, y as Numeric, font as FontDefinition, color as ColorType) as Void {
        dc.setColor(color, Settings.BACKGROUND_COLOR);
        dc.drawText(
            x,
            y,
            font,
            text,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    function getTimeFont(dc as Dc, text as String) as FontDefinition {
        if (dc.getTextWidthInPixels(text, Settings.TIME_FONT) <= Settings.TIME_MAX_WIDTH) {
            return Settings.TIME_FONT;
        }

        if (dc.getTextWidthInPixels(text, Settings.TIME_FALLBACK_FONT) <= Settings.TIME_MAX_WIDTH) {
            return Settings.TIME_FALLBACK_FONT;
        }

        return Settings.TIME_COMPACT_FONT;
    }

    function compactNumber(value as Number?) as String {
        if (value == null) {
            return "0";
        }

        if (value > 9999) {
            return (value.toFloat() / 1000.0).format("%.1f") + "k";
        }

        return value.format("%d");
    }

    function formatNumber(value as Number?, width as Number) as String {
        if (value == null) {
            return "--";
        }

        return value.format("%0" + width + "d");
    }

    function formatValue(value as Number?, placeholder as String) as String {
        if (value == null) {
            return placeholder;
        }

        return value.format("%d");
    }

    function formatWeather(value as Numeric?) as String {
        if (value == null) {
            return "--";
        }

        return value.format("%d") + "°";
    }

    function formatBattery(value as Numeric?) as String {
        if (value == null) {
            return "--";
        }

        return value.format("%d");
    }
}

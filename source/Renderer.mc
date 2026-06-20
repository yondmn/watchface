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
        var dayName = Settings.dayName(data.dayOfWeek);
        var dayText = formatNumber(data.day, 2);
        var monthName = Settings.monthName(data.month);

        dc.setColor(Settings.MUTED_COLOR, Settings.BACKGROUND_COLOR);
        dc.setPenWidth(1);
        dc.drawLine(42, Settings.DATE_RULE_Y, 62, Settings.DATE_RULE_Y);
        dc.drawLine(218, Settings.DATE_RULE_Y, 238, Settings.DATE_RULE_Y);

        drawCenteredText(dc, dayName, 80, Settings.DATE_Y, Settings.TOP_FONT, Settings.PRIMARY_COLOR);
        drawCenteredText(dc, dayText, Settings.CENTER_X, Settings.DATE_Y, Settings.TOP_FONT, Settings.ACCENT_ORANGE);
        drawCenteredText(dc, monthName, 200, Settings.DATE_Y, Settings.TOP_FONT, Settings.PRIMARY_COLOR);
    }

    function drawTime(dc as Dc, data as WatchFaceData) as Void {
        var rightEdge = drawLargeTime(dc, data.hour, data.minute);
        var secondsText = formatNumber(data.second, 2);

        dc.setColor(Settings.SECONDARY_COLOR, Settings.BACKGROUND_COLOR);
        dc.drawText(
            rightEdge + Settings.SECONDS_GAP,
            Settings.TIME_Y + 24,
            Settings.SECONDS_FONT,
            secondsText,
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    function drawLargeTime(dc as Dc, hour as Number, minute as Number) as Number {
        var digitWidth = 38;
        var digitHeight = 76;
        var stroke = 10;
        var gap = 6;
        var colonWidth = 8;
        var totalWidth = (digitWidth * 4) + (gap * 4) + colonWidth;
        var x = Settings.CENTER_X - (totalWidth / 2);
        var y = Settings.TIME_Y - (digitHeight / 2);

        drawDigit(dc, hour / 10, x, y, digitWidth, digitHeight, stroke);
        x += digitWidth + gap;
        drawDigit(dc, hour % 10, x, y, digitWidth, digitHeight, stroke);
        x += digitWidth + gap;
        drawColon(dc, x + (colonWidth / 2), Settings.TIME_Y);
        x += colonWidth + gap;
        drawDigit(dc, minute / 10, x, y, digitWidth, digitHeight, stroke);
        x += digitWidth + gap;
        drawDigit(dc, minute % 10, x, y, digitWidth, digitHeight, stroke);

        return x + digitWidth;
    }

    function drawDigit(dc as Dc, digit as Number, x as Number, y as Number, width as Number, height as Number, stroke as Number) as Void {
        dc.setColor(Settings.PRIMARY_COLOR, Settings.BACKGROUND_COLOR);

        if (digit != 1 && digit != 4) {
            drawHorizontalSegment(dc, x, y, width, stroke);
        }

        if (digit != 5 && digit != 6) {
            drawVerticalSegment(dc, x + width - stroke, y, height / 2, stroke);
        }

        if (digit != 2) {
            drawVerticalSegment(dc, x + width - stroke, y + (height / 2), height / 2, stroke);
        }

        if (digit != 1 && digit != 4 && digit != 7) {
            drawHorizontalSegment(dc, x, y + height - stroke, width, stroke);
        }

        if (digit == 0 || digit == 2 || digit == 6 || digit == 8) {
            drawVerticalSegment(dc, x, y + (height / 2), height / 2, stroke);
        }

        if (digit == 0 || digit == 4 || digit == 5 || digit == 6 || digit == 8 || digit == 9) {
            drawVerticalSegment(dc, x, y, height / 2, stroke);
        }

        if (digit != 0 && digit != 1 && digit != 7) {
            drawHorizontalSegment(dc, x, y + ((height - stroke) / 2), width, stroke);
        }
    }

    function drawHorizontalSegment(dc as Dc, x as Number, y as Number, width as Number, stroke as Number) as Void {
        dc.fillRoundedRectangle(x, y, width, stroke, stroke / 2);
    }

    function drawVerticalSegment(dc as Dc, x as Number, y as Number, height as Number, stroke as Number) as Void {
        dc.fillRoundedRectangle(x, y, stroke, height, stroke / 2);
    }

    function drawColon(dc as Dc, x as Number, y as Number) as Void {
        dc.setColor(Settings.PRIMARY_COLOR, Settings.BACKGROUND_COLOR);
        dc.fillRoundedRectangle(x - 4, y - 18, 8, 8, 2);
        dc.fillRoundedRectangle(x - 4, y + 10, 8, 8, 2);
    }

    function drawMetrics(dc as Dc, data as WatchFaceData) as Void {
        drawMetricFrame(dc);

        drawMetric(dc, Settings.COLUMN_1_X, Settings.METRIC_Y, Settings.ICON_HEART, formatValue(data.heartRate, "--"), data.batteryPercent);
        drawMetric(dc, Settings.COLUMN_2_X, Settings.METRIC_Y, Settings.ICON_STEPS, compactNumber(data.steps), data.batteryPercent);
        drawMetric(dc, Settings.COLUMN_3_X, Settings.METRIC_Y, Settings.ICON_TEMP, formatWeather(data.temperature), data.batteryPercent);
        drawMetric(dc, Settings.COLUMN_4_X, Settings.METRIC_Y, Settings.ICON_BATTERY, formatBattery(dc, data.batteryPercent), data.batteryPercent);
    }

    function drawMetricFrame(dc as Dc) as Void {
        dc.setColor(Settings.MUTED_COLOR, Settings.BACKGROUND_COLOR);
        dc.setPenWidth(1);
        dc.drawLine(80, Settings.METRIC_SEPARATOR_TOP, 80, Settings.METRIC_SEPARATOR_BOTTOM);
        dc.drawLine(140, Settings.METRIC_SEPARATOR_TOP, 140, Settings.METRIC_SEPARATOR_BOTTOM);
        dc.drawLine(200, Settings.METRIC_SEPARATOR_TOP, 200, Settings.METRIC_SEPARATOR_BOTTOM);
        dc.drawLine(48, Settings.METRIC_RULE_Y, 232, Settings.METRIC_RULE_Y);
    }

    function drawMetric(dc as Dc, x as Number, y as Number, icon as Number, value as String, batteryPercent as Numeric?) as Void {
        var iconY = y + Settings.METRIC_ICON_Y_OFFSET;
        var valueY = y + Settings.METRIC_VALUE_Y_OFFSET;

        switch (icon) {
            case Settings.ICON_HEART:
                drawHeartIcon(dc, x, iconY, Settings.HEART_RED);
                break;
            case Settings.ICON_STEPS:
                drawStepsIcon(dc, x, iconY, Settings.STEPS_GREEN);
                break;
            case Settings.ICON_TEMP:
                drawSunIcon(dc, x, iconY, Settings.WEATHER_YELLOW);
                break;
            case Settings.ICON_BATTERY:
                drawBatteryIcon(dc, x, iconY, batteryPercent, Settings.PRIMARY_COLOR);
                break;
        }

        drawCenteredText(dc, value, x, valueY, Settings.METRIC_FONT, Settings.PRIMARY_COLOR);
    }

    function drawCenteredText(dc as Dc, text as String, x as Numeric, y as Numeric, font as FontDefinition or VectorFont, color as ColorType) as Void {
        dc.setColor(color, Settings.BACKGROUND_COLOR);
        dc.drawText(
            x,
            y,
            font,
            text,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    function drawHeartIcon(dc as Dc, x as Numeric, y as Numeric, color as ColorType) as Void {
        dc.setColor(color, Settings.BACKGROUND_COLOR);
        dc.fillPolygon([[x, y + 11], [x - 12, y - 1], [x - 7, y - 9], [x, y - 5], [x + 7, y - 9], [x + 12, y - 1]]);
    }

    function drawStepsIcon(dc as Dc, x as Numeric, y as Numeric, color as ColorType) as Void {
        dc.setColor(color, Settings.BACKGROUND_COLOR);
        dc.fillCircle(x - 6, y + 2, 4);
        dc.fillCircle(x - 8, y - 6, 2);
        dc.fillCircle(x - 4, y - 7, 2);
        dc.fillCircle(x + 6, y - 1, 4);
        dc.fillCircle(x + 4, y - 9, 2);
        dc.fillCircle(x + 8, y - 10, 2);
    }

    function drawSunIcon(dc as Dc, x as Numeric, y as Numeric, color as ColorType) as Void {
        dc.setColor(color, Settings.BACKGROUND_COLOR);
        dc.setPenWidth(2);
        dc.fillCircle(x, y - 4, 6);
        dc.drawLine(x, y - 15, x, y - 12);
        dc.drawLine(x - 11, y - 4, x - 8, y - 4);
        dc.drawLine(x + 8, y - 4, x + 11, y - 4);
        dc.drawLine(x - 8, y - 12, x - 6, y - 10);
        dc.drawLine(x + 6, y - 10, x + 8, y - 12);

        dc.setColor(Settings.WEATHER_CLOUD, Settings.BACKGROUND_COLOR);
        dc.fillCircle(x - 7, y + 5, 5);
        dc.fillCircle(x, y + 3, 7);
        dc.fillCircle(x + 8, y + 5, 5);
        dc.fillRectangle(x - 12, y + 5, 24, 6);
        dc.setPenWidth(1);
    }

    function drawBatteryIcon(dc as Dc, x as Numeric, y as Numeric, percent as Numeric?, color as ColorType) as Void {
        dc.setColor(color, Settings.BACKGROUND_COLOR);
        dc.setPenWidth(2);
        dc.drawLine(x - 14, y - 7, x + 10, y - 7);
        dc.drawLine(x - 14, y + 7, x + 10, y + 7);
        dc.drawLine(x - 14, y - 7, x - 14, y + 7);
        dc.drawLine(x + 10, y - 7, x + 10, y + 7);
        dc.drawLine(x + 13, y - 3, x + 13, y + 3);

        if (percent != null) {
            var pct = percent;

            if (pct < 0) {
                pct = 0;
            } else if (pct > 100) {
                pct = 100;
            }

            var fillWidth = (pct * 20) / 100;

            if (fillWidth > 0) {
                dc.setColor(Settings.BATTERY_GREEN, Settings.BACKGROUND_COLOR);
                dc.fillRectangle(x - 11, y - 4, fillWidth, 8);
            }
        }

        dc.setPenWidth(1);
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

    function formatBattery(dc as Dc, value as Numeric?) as String {
        if (value == null) {
            return "--";
        }

        var text = value.format("%d") + "%";

        if (dc.getTextWidthInPixels(text, Settings.METRIC_FONT) <= Settings.COLUMN_WIDTH) {
            return text;
        }

        return value.format("%d");
    }
}

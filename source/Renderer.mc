import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;

class Renderer {

    function initialize() {
    }

    function draw(dc as Dc, data as WatchFaceData) as Void {
        dc.setColor(Settings.PRIMARY_COLOR, Settings.BACKGROUND_COLOR);
        dc.clear();

        drawOuterRings(dc);
        drawTopInfo(dc);
        drawDate(dc, data);
        drawTime(dc, data);
        drawMetrics(dc, data);
        drawBodyBattery(dc);

        // 暂时不画底部距离，280x280 空间不够。
        // 后续等主体稳定后再恢复。
        // drawBottomDistance(dc);
    }

    function drawOuterRings(dc as Dc) as Void {
        // Rings are pushed near the bezel to avoid crossing the content area.
        drawSegmentRange(dc, 314, 358, 130, 136, 4, Settings.ORANGE);
        drawSegmentRange(dc, 2, 54, 130, 136, 4, Settings.ORANGE);

        drawSegmentRange(dc, 82, 145, 130, 136, 4, Settings.BLUE);
        drawSegmentRange(dc, 210, 278, 130, 136, 4, Settings.GREEN);

        // Muted guide arcs.
        drawSegmentRange(dc, 58, 78, 130, 136, 8, Settings.DARK_RING);
        drawSegmentRange(dc, 148, 205, 130, 136, 8, Settings.DARK_RING);
        drawSegmentRange(dc, 282, 310, 130, 136, 8, Settings.DARK_RING);
    }

    function drawSegmentRange(dc as Dc, startDeg as Number, endDeg as Number, innerR as Number, outerR as Number, step as Number, color as ColorType) as Void {
        dc.setColor(color, Settings.BACKGROUND_COLOR);
        dc.setPenWidth(3);

        var a = startDeg;

        while (a <= endDeg) {
            drawRadialSegment(dc, a, innerR, outerR);
            a += step;
        }

        dc.setPenWidth(1);
    }

    function drawRadialSegment(dc as Dc, angleDeg as Number, innerR as Number, outerR as Number) as Void {
        var rad = ((angleDeg - 90).toFloat() * 3.1415926) / 180.0;

        var x1 = Settings.CENTER_X + (Math.cos(rad) * innerR);
        var y1 = Settings.CENTER_Y + (Math.sin(rad) * innerR);
        var x2 = Settings.CENTER_X + (Math.cos(rad) * outerR);
        var y2 = Settings.CENTER_Y + (Math.sin(rad) * outerR);

        dc.drawLine(x1, y1, x2, y2);
    }

    function drawTopInfo(dc as Dc) as Void {
        var moveText = Lang.format("MOVE $1$%", [Settings.MOVE_VALUE]);
        drawCenteredText(dc, moveText, Settings.CENTER_X, Settings.MOVE_Y, Settings.TOP_META_FONT, Settings.ORANGE);

        drawMountainIcon(dc, Settings.CENTER_X - 34, Settings.ALTITUDE_Y, Settings.PRIMARY_COLOR);

        var altitudeText = Lang.format("$1$ m", [Settings.ALTITUDE_VALUE]);
        dc.setColor(Settings.PRIMARY_COLOR, Settings.BACKGROUND_COLOR);
        dc.drawText(
            Settings.CENTER_X - 16,
            Settings.ALTITUDE_Y,
            Settings.TOP_META_FONT,
            altitudeText,
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    function drawMountainIcon(dc as Dc, x as Numeric, y as Numeric, color as ColorType) as Void {
        dc.setColor(color, Settings.BACKGROUND_COLOR);
        dc.fillPolygon([
            [x - 10, y + 7],
            [x - 3, y - 7],
            [x + 2, y + 1],
            [x + 6, y - 5],
            [x + 14, y + 7]
        ]);
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

        dc.setColor(Settings.GRID_LINE, Settings.BACKGROUND_COLOR);
        dc.setPenWidth(1);
        dc.drawLine(42, Settings.DATE_Y, 82, Settings.DATE_Y);
        dc.drawLine(198, Settings.DATE_Y, 238, Settings.DATE_Y);

        drawCenteredText(dc, text, Settings.CENTER_X, Settings.DATE_Y, Settings.DATE_FONT, Settings.SECONDARY_COLOR);
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
        var secondsText = formatNumber(data.second, 2);

        drawCenteredText(dc, timeText, Settings.CENTER_X, Settings.TIME_Y, timeFont, Settings.PRIMARY_COLOR);

        dc.setColor(Settings.SECONDARY_COLOR, Settings.BACKGROUND_COLOR);
        dc.drawText(
            Settings.SECONDS_X,
            Settings.SECONDS_Y,
            Settings.SECONDS_FONT,
            secondsText,
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    function drawMetrics(dc as Dc, data as WatchFaceData) as Void {
        drawMetricSeparators(dc);

        drawMetric(dc, Settings.COLUMN_1_X, Settings.ICON_HEART, formatValue(data.heartRate, "--"), Settings.RED);
        drawMetric(dc, Settings.COLUMN_2_X, Settings.ICON_STEPS, compactNumber(data.steps), Settings.GREEN);
        drawMetric(dc, Settings.COLUMN_3_X, Settings.ICON_TEMP, formatWeather(data.temperature), Settings.YELLOW);
        drawMetric(dc, Settings.COLUMN_4_X, Settings.ICON_BATTERY, formatBattery(data.batteryPercent), Settings.GREEN);
    }

    function drawMetricSeparators(dc as Dc) as Void {
        dc.setColor(Settings.GRID_LINE, Settings.BACKGROUND_COLOR);
        dc.setPenWidth(1);

        dc.drawLine(78, Settings.METRIC_SEPARATOR_TOP, 78, Settings.METRIC_SEPARATOR_BOTTOM);
        dc.drawLine(140, Settings.METRIC_SEPARATOR_TOP, 140, Settings.METRIC_SEPARATOR_BOTTOM);
        dc.drawLine(202, Settings.METRIC_SEPARATOR_TOP, 202, Settings.METRIC_SEPARATOR_BOTTOM);
    }

    function drawMetric(dc as Dc, x as Number, icon as Number, value as String, iconColor as ColorType) as Void {
        switch (icon) {
            case Settings.ICON_HEART:
                drawHeartIcon(dc, x, Settings.METRIC_ICON_Y, iconColor);
                break;
            case Settings.ICON_STEPS:
                drawStepsIcon(dc, x, Settings.METRIC_ICON_Y, iconColor);
                break;
            case Settings.ICON_TEMP:
                drawWeatherIcon(dc, x, Settings.METRIC_ICON_Y, iconColor);
                break;
            case Settings.ICON_BATTERY:
                drawBatteryIcon(dc, x, Settings.METRIC_ICON_Y, iconColor);
                break;
        }

        drawCenteredText(dc, value, x, Settings.METRIC_VALUE_Y, Settings.METRIC_FONT, Settings.PRIMARY_COLOR);
    }

    function drawHeartIcon(dc as Dc, x as Numeric, y as Numeric, color as ColorType) as Void {
        dc.setColor(color, Settings.BACKGROUND_COLOR);
        dc.fillPolygon([
            [x, y + 11],
            [x - 12, y],
            [x - 10, y - 7],
            [x - 5, y - 10],
            [x, y - 5],
            [x + 5, y - 10],
            [x + 10, y - 7],
            [x + 12, y]
        ]);
    }

    function drawStepsIcon(dc as Dc, x as Numeric, y as Numeric, color as ColorType) as Void {
        dc.setColor(color, Settings.BACKGROUND_COLOR);

        // Left foot
        dc.fillCircle(x - 7, y + 3, 4);
        dc.fillCircle(x - 10, y - 5, 2);
        dc.fillCircle(x - 6, y - 7, 2);

        // Right foot
        dc.fillCircle(x + 7, y - 1, 4);
        dc.fillCircle(x + 4, y - 9, 2);
        dc.fillCircle(x + 9, y - 9, 2);
    }

    function drawWeatherIcon(dc as Dc, x as Numeric, y as Numeric, color as ColorType) as Void {
        dc.setColor(color, Settings.BACKGROUND_COLOR);
        dc.setPenWidth(2);

        // Sun
        dc.fillCircle(x - 3, y - 4, 5);
        dc.drawLine(x - 3, y - 15, x - 3, y - 12);
        dc.drawLine(x - 14, y - 4, x - 11, y - 4);
        dc.drawLine(x + 4, y - 4, x + 8, y - 4);
        dc.drawLine(x - 10, y - 11, x - 8, y - 9);
        dc.drawLine(x + 2, y - 9, x + 4, y - 11);

        // Cloud
        dc.setColor(Settings.CLOUD, Settings.BACKGROUND_COLOR);
        dc.fillCircle(x - 8, y + 5, 4);
        dc.fillCircle(x, y + 3, 6);
        dc.fillCircle(x + 8, y + 5, 4);
        dc.fillRectangle(x - 12, y + 5, 24, 5);

        dc.setPenWidth(1);
    }

    function drawBatteryIcon(dc as Dc, x as Numeric, y as Numeric, color as ColorType) as Void {
        dc.setColor(Settings.PRIMARY_COLOR, Settings.BACKGROUND_COLOR);
        dc.setPenWidth(2);

        dc.drawLine(x - 13, y - 7, x + 9, y - 7);
        dc.drawLine(x - 13, y + 7, x + 9, y + 7);
        dc.drawLine(x - 13, y - 7, x - 13, y + 7);
        dc.drawLine(x + 9, y - 7, x + 9, y + 7);
        dc.drawLine(x + 13, y - 3, x + 13, y + 3);

        dc.setColor(color, Settings.BACKGROUND_COLOR);
        dc.fillRectangle(x - 10, y - 4, 14, 8);

        dc.setPenWidth(1);
    }

    function drawBodyBattery(dc as Dc) as Void {
        dc.setColor(Settings.GRID_LINE, Settings.BACKGROUND_COLOR);
        dc.setPenWidth(1);
        dc.drawLine(52, Settings.BODY_RULE_Y, 228, Settings.BODY_RULE_Y);

        drawCenteredText(dc, "BODY BATTERY", Settings.CENTER_X, Settings.BODY_LABEL_Y, Settings.BODY_LABEL_FONT, Settings.BLUE);

        var valueText = Lang.format("$1$", [Settings.BODY_BATTERY_VALUE]);

        dc.setColor(Settings.PRIMARY_COLOR, Settings.BACKGROUND_COLOR);
        dc.drawText(
            Settings.CENTER_X - 8,
            Settings.BODY_VALUE_Y,
            Settings.BODY_VALUE_FONT,
            valueText,
            Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER
        );

        dc.setColor(Settings.MUTED_COLOR, Settings.BACKGROUND_COLOR);
        dc.drawText(
            Settings.CENTER_X - 1,
            Settings.BODY_VALUE_Y + 2,
            Settings.METRIC_FONT,
            "/100",
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
        );

        drawBodyBlocks(dc, Settings.CENTER_X, Settings.BODY_BLOCK_Y, Settings.BODY_BATTERY_VALUE);
    }

    function drawBodyBlocks(dc as Dc, centerX as Number, y as Number, value as Number) as Void {
        var blockCount = 10;
        var blockWidth = 9;
        var blockGap = 3;
        var totalWidth = (blockCount * blockWidth) + ((blockCount - 1) * blockGap);
        var startX = centerX - (totalWidth / 2);
        var filledBlocks = (value * blockCount) / 100;

        for (var i = 0; i < blockCount; i += 1) {
            if (i < filledBlocks) {
                dc.setColor(Settings.BLUE, Settings.BACKGROUND_COLOR);
            } else {
                dc.setColor(Settings.MUTED_COLOR, Settings.BACKGROUND_COLOR);
            }

            dc.fillRectangle(startX + (i * (blockWidth + blockGap)), y, blockWidth, 4);
        }
    }

    function drawBottomDistance(dc as Dc) as Void {
        dc.setColor(Settings.ORANGE, Settings.BACKGROUND_COLOR);
        dc.setPenWidth(2);

        var x = Settings.CENTER_X - 42;
        var y = 274;

        dc.fillCircle(x, y - 10, 3);
        dc.drawLine(x, y - 6, x, y + 2);
        dc.drawLine(x, y - 2, x - 5, y + 5);
        dc.drawLine(x, y - 2, x + 5, y + 5);
        dc.drawLine(x, y - 3, x + 6, y - 6);

        dc.setPenWidth(1);

        dc.setColor(Settings.PRIMARY_COLOR, Settings.BACKGROUND_COLOR);
        dc.drawText(
            Settings.CENTER_X - 25,
            274,
            Settings.BOTTOM_FONT,
            Settings.DISTANCE_TEXT,
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
        );
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
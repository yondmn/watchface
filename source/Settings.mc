import Toybox.Graphics;
import Toybox.Lang;

module Settings {

    const BACKGROUND_COLOR = Graphics.COLOR_BLACK;
    const PRIMARY_COLOR = Graphics.COLOR_WHITE;
    const SECONDARY_COLOR = Graphics.COLOR_LT_GRAY;
    const TOP_FONT = Graphics.FONT_MEDIUM;
    const TIME_FONT = Graphics.FONT_NUMBER_THAI_HOT;
    const TIME_FALLBACK_FONT = Graphics.FONT_NUMBER_HOT;
    const TIME_COMPACT_FONT = Graphics.FONT_NUMBER_MEDIUM;
    const SECONDS_FONT = Graphics.FONT_TINY;
    const METRIC_FONT = Graphics.FONT_SMALL;

    const ICON_HEART = 0;
    const ICON_STEPS = 1;
    const ICON_TEMP = 2;
    const ICON_BATTERY = 3;

    const SCREEN_SIZE = 280;
    const CENTER_X = 140;
    const CENTER_Y = 140;
    const DATE_Y = 38;
    const TIME_Y = 104;
    const TIME_MAX_WIDTH = 128;
    const SECONDS_GAP = 8;
    const METRIC_Y = 194;
    const METRIC_ICON_GAP = 3;
    const COLUMN_1_X = 50;
    const COLUMN_2_X = 110;
    const COLUMN_3_X = 170;
    const COLUMN_4_X = 230;
    const COLUMN_WIDTH = 50;

    function dayName(dayOfWeek as Object) as String {
        if (dayOfWeek instanceof Number) {
            switch (dayOfWeek as Number) {
                case 1:
                    return "SUN";
                case 2:
                    return "MON";
                case 3:
                    return "TUE";
                case 4:
                    return "WED";
                case 5:
                    return "THU";
                case 6:
                    return "FRI";
                case 7:
                    return "SAT";
                default:
                    return "---";
            }
        } else if (dayOfWeek instanceof String) {
            return compactDateToken(dayOfWeek as String);
        }

        return "---";
    }

    function monthName(month as Object) as String {
        if (month instanceof Number) {
            switch (month as Number) {
                case 1:
                    return "JAN";
                case 2:
                    return "FEB";
                case 3:
                    return "MAR";
                case 4:
                    return "APR";
                case 5:
                    return "MAY";
                case 6:
                    return "JUN";
                case 7:
                    return "JUL";
                case 8:
                    return "AUG";
                case 9:
                    return "SEP";
                case 10:
                    return "OCT";
                case 11:
                    return "NOV";
                case 12:
                    return "DEC";
                default:
                    return "---";
            }
        } else if (month instanceof String) {
            return compactDateToken(month as String);
        }

        return "---";
    }

    function compactDateToken(value as String) as String {
        var upper = value.toUpper();

        if (upper.length() > 3) {
            return upper.substring(0, 3) as String;
        }

        return upper;
    }
}

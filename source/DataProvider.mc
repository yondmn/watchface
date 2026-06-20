import Toybox.ActivityMonitor;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.Weather;

class WatchFaceData {

    var hour as Number = 0;
    var minute as Number = 0;
    var second as Number = 0;
    var dayOfWeek as Number = 0;
    var day as Number = 0;
    var month as Number = 0;
    var heartRate as Number?;
    var steps as Number?;
    var temperature as Numeric?;
    var batteryPercent as Numeric?;

    function initialize() {
    }
}

class DataProvider {

    function initialize() {
    }

    function getSnapshot() as WatchFaceData {
        var clock = System.getClockTime();
        var date = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var data = new WatchFaceData();

        data.hour = clock.hour;
        data.minute = clock.min;
        data.second = clock.sec;
        data.dayOfWeek = date.day_of_week as Number;
        data.day = date.day;
        data.month = date.month as Number;
        data.heartRate = getHeartRate();
        data.steps = getSteps();
        data.temperature = getTemperature();
        data.batteryPercent = getBatteryPercent();

        return data;
    }

    function getHeartRate() as Number? {
        var info = ActivityMonitor.getInfo();

        if (info != null && (info has :currentHeartRate) && info.currentHeartRate != null) {
            return info.currentHeartRate as Number;
        }

        return null;
    }

    function getSteps() as Number? {
        var info = ActivityMonitor.getInfo();

        if (info != null && (info has :steps) && info.steps != null) {
            return info.steps;
        }

        return null;
    }

    function getTemperature() as Numeric? {
        if ((Toybox has :Weather) && (Weather has :getCurrentConditions)) {
            var conditions = Weather.getCurrentConditions();

            if (conditions != null && (conditions has :temperature) && conditions.temperature != null) {
                return conditions.temperature;
            }
        }

        return null;
    }

    function getBatteryPercent() as Numeric? {
        var stats = System.getSystemStats();

        if (stats != null && (stats has :battery) && stats.battery != null) {
            return stats.battery;
        }

        return null;
    }
}

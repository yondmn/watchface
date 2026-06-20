import Toybox.Graphics;
import Toybox.WatchUi;

class FenixMinimalWatchFace extends WatchUi.WatchFace {

    var _dataProvider as DataProvider;
    var _renderer as Renderer;

    function initialize() {
        WatchFace.initialize();

        _dataProvider = new DataProvider();
        _renderer = new Renderer();
    }

    function onLayout(dc as Dc) as Void {
    }

    function onShow() as Void {
    }

    function onUpdate(dc as Dc) as Void {
        _renderer.draw(dc, _dataProvider.getSnapshot());
    }

    function onHide() as Void {
    }

    function onExitSleep() as Void {
    }

    function onEnterSleep() as Void {
    }
}

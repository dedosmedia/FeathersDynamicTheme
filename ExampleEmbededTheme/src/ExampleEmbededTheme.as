package {

import flash.display.Sprite;
import starling.core.Starling;


[SWF(width="600", height="600", frameRate="60",  backgroundColor="#FFFFFF")]
public class ExampleEmbededTheme extends Sprite {

    private var _starling:Starling;

    public function ExampleEmbededTheme() {
        startStarling();
    }

    private function startStarling():void
    {
        this._starling = new Starling(EmbededGame,stage);
        this._starling.showStats = true;
        this._starling.showStatsAt("left","bottom");
        this._starling.start();
    }
}
}

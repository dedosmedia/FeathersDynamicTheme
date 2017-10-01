package {

import flash.display.Loader;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.net.URLRequest;
import flash.system.ApplicationDomain;
import flash.system.LoaderContext;
import flash.utils.getDefinitionByName;

import starling.core.Starling;
import starling.events.Event;


[SWF(width="600", height="600", frameRate="60",  backgroundColor="#FFFFFF")]

public class ExampleLoadedTheme extends Sprite {

    private var _starling:Starling;
    private var loader:Loader = new Loader();
    private var availableThemes:Vector.<Class> = new Vector.<Class>();

    public function ExampleLoadedTheme() {

        var url:URLRequest = new URLRequest("CustomTheme.swf");
        var loaderContext:LoaderContext = new LoaderContext(false, ApplicationDomain.currentDomain,null);
        loader.contentLoaderInfo.addEventListener(flash.events.Event.COMPLETE, loader_completeHandler);
        loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loader_ioErrorHandler);
        loader.load(url, loaderContext);
    }



    private function loader_ioErrorHandler(event:IOErrorEvent):void {
        trace("ERROR "+event.toString())
    }

    private function loader_completeHandler(event:flash.events.Event):void
    {
        var definitions:Vector.<String> = loader.contentLoaderInfo.applicationDomain.getQualifiedDefinitionNames();
        definitions.forEach(getThemeDefinitions)

        // Si la queremos agregar sabiendo el nombre exacto dentro del SWF
        //ThemeClass = loader.contentLoaderInfo.applicationDomain.getDefinition("themes.SecondCustomTheme") as Class;

        startStarling();
    }


    // Extraemos solo las clases que están dentro del paquete themes::
    var getThemeDefinitions:Function = function(item:String, index:int, vector:Vector.<String>):void {
        if(item.indexOf("themes::") == 0)
            availableThemes.push(getDefinitionByName( item ) as Class);
    };

    private function startStarling():void
    {
        this._starling = new Starling(LoadedGame,stage);
        this._starling.addEventListener(starling.events.Event.ROOT_CREATED, rootCreatedHandler);
    }

    private function rootCreatedHandler(event:starling.events.Event):void {
        this._starling.start();
        this._starling.showStats = true;
        this._starling.showStatsAt("left","bottom");

        LoadedGame(this._starling.root).availableThemes = this.availableThemes;
        LoadedGame(this._starling.root).start();

    }

}
}

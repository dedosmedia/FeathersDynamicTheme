/**
 * Created by dedosmedia on 26/09/17.
 */
package {
import feathers.controls.Label;
import feathers.controls.TextInput;
import feathers.core.IFeathersControl;
import feathers.themes.StyleNameFunctionTheme;

import flash.utils.getDefinitionByName;
import flash.utils.getQualifiedClassName;

import starling.display.DisplayObject;
import starling.display.DisplayObjectContainer;
import starling.display.Sprite;
import starling.events.Event;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;

public class LoadedGame extends Sprite {

    private var _theme:StyleNameFunctionTheme;
    private var _old_theme:StyleNameFunctionTheme;
    private var _availableThemes:Vector.<Class>;
    private var _availableSubThemes:Vector.<Object> = new <Object>[];

    private var label:Label = new Label();
    private var label2:Label = new Label();
    private var label3:Label = new Label();

    private var input:TextInput = new TextInput();
    private var input2:TextInput = new TextInput();



    public function LoadedGame() {
        super();
    }

    public function start():void
    {
        trace(listAvailableThemes());


        instantiate();

        refreshTheme();

    }

    private function instantiate():void
    {

        label.text = "CHANGE THEME";
        label.name = "label";
        this.addChild(label);
        label.addEventListener(TouchEvent.TOUCH, label_touchHandler)

        label2.text = "PRUEBA 2";
        this.addChild(label2);
        label2.y = 100;
        label2.styleNameList.add("LABEL_WRONG");

        label3.text = "CHANGE SUBTHEME";
        label3.name = "label3";
        this.addChild(label3);
        label3.y = 50;
        label3.addEventListener(TouchEvent.TOUCH, label_touchHandler)


        input.y = 150;
        input.width = 250;
        input.height = 60;
        this.addChild(input);

        input2.y = 250;
        input2.width = 250;
        input2.height = 60;
        input2.styleNameList.add("THIRD-STYLE");
        this.addChild(input2);



    }

    private function label_touchHandler(event:TouchEvent):void {
        var touch:Touch = event.getTouch(stage, TouchPhase.BEGAN);
        if(touch)
        {
            stage.touchable = false;
            switch (DisplayObject(event.currentTarget).name)
            {
                case "label":
                    trace("NEXT THEME");
                    nextTheme();
                    break;
                case "label3":
                    trace("NEXT SUBTHEME");
                    nextSubTheme();
                    break;
            }


        }
    }

    public function set availableThemes(_availableThemes:Vector.<Class>):void
    {
        this._availableThemes = _availableThemes;
    }



    // Retorna un array con los nombres de los temas disponibles
    public function listAvailableThemes():Array
    {
        var listNames:Array = new Array();
        this._availableThemes.forEach(function(item:Class, index:int, vector:Vector.<Class>)
        {
            listNames.push(item.name);
        })
        return listNames;
    }

    // Pone el siguiente tema como elemento 0 del vector
    private function nextTheme():void
    {
        _availableThemes.push(_availableThemes.splice(0,1)[0]);
        _availableSubThemes.length = 0;
        refreshTheme();
    }


    // Pone el siguiente tema como elemento 0 del vector
    private function nextSubTheme():void
    {
        /*
        trace(_availableSubThemes.length)
        trace("SUBTHEMES ",_availableSubThemes);
        if(_availableSubThemes.length > 1)
        {
            _availableSubThemes.push(_availableSubThemes.splice(0,1)[0]);

            refreshTheme();
        }
        else
        {
            stage.touchable = true;
        }
        */


        _availableSubThemes.push(_availableSubThemes.splice(0,1)[0]);
        var subtheme:String = _availableSubThemes[0].path;
        trace("LOAD SUBTHEME ",subtheme);
        _theme["loadSubtheme"](subtheme);

    }


    // Carga el nuevo tema
    private function refreshTheme():void
    {
        if(_theme)
        {
            _theme.removeEventListener(Event.COMPLETE, theme_completeHandler);
            _theme.removeEventListener("UNCHANGED", theme_completeHandler);
            _old_theme = _theme;
            _theme = null;
        }
        var subtheme:String = _availableSubThemes.length>0?_availableSubThemes[0].path:null;
        trace("LOAD SUBTHEME ",subtheme);
        _theme = new _availableThemes[0]("./themes", null, subtheme);
        _theme.addEventListener(Event.COMPLETE, theme_completeHandler)
        _theme.addEventListener("UNCHANGED", theme_completeHandler);
    }

    private function theme_completeHandler(event:Event):void {
        trace(" THEME LOADED")
        stage.touchable = true;
        if(_availableSubThemes.length == 0)
        {
            _availableSubThemes = _theme["availableSubThemes"];
        }


        if(_old_theme)
        {
            _old_theme.dispose();
            _old_theme = null;
        }

        //SystemUtil.updateEmbeddedFonts();
        applyStylesToTree(this);
    }

    private function theme_unchangedHandler(event:Event):void {
        trace("UNCHANGED")
        stage.touchable = true;
    }




    // Obitene el nombre del tema actualmente aplicado
    private function getCurrentThemeName():String
    {
        if(!_theme)
            return null;
        return getDefinitionByName(getQualifiedClassName(_theme)).name;
    }

    // Aplica el nuevo tema a todos los componentes
    public function applyStylesToTree(target:DisplayObjectContainer):void {
        var tree:DisplayObjectContainer = target as DisplayObjectContainer;
        var length:int = tree.numChildren;
        for (var i:int = 0; i < length; ++i) {
            var child:DisplayObjectContainer = tree.getChildAt(i) as DisplayObjectContainer;
            if (child)
                applyStylesToTree(child);
        }
        if(target is IFeathersControl)
        {
            // solo necesario si cambia los estilo pero no cambia de Themes
            IFeathersControl(target).styleProvider = null;
            IFeathersControl(target).resetStyleProvider();
        }
    }
}
}

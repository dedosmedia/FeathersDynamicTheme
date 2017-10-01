/**
 * Created by dedosmedia on 26/09/17.
 */
package {
import feathers.controls.Label;
import feathers.controls.TextInput;
import feathers.core.IFeathersControl;


import starling.display.DisplayObject;
import starling.display.DisplayObjectContainer;
import starling.display.Sprite;
import starling.events.Event;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;

import themes.DynamicTheme;

public class EmbededGame extends Sprite {

    private var _theme:DynamicTheme;
    private var _availableSubThemes:Vector.<Object>;

    private var label:Label = new Label();
    private var label2:Label = new Label();
    private var label3:Label = new Label();
    private var input:TextInput = new TextInput();
    private var input2:TextInput = new TextInput();


    public function EmbededGame() {
        super();
        instantiate();
        _theme = new DynamicTheme("./themes");
        _theme.addEventListener(Event.COMPLETE, theme_completeHandler);
        _theme.addEventListener("UNCHANGED", theme_unchangedHandler);
    }

    private function theme_completeHandler(event:Event):void {
        trace(" THEME LOADED")
        stage.touchable = true;
        _availableSubThemes = _theme.availableSubThemes;
        applyStylesToTree(this);
    }

    private function theme_unchangedHandler(event:Event):void {
        trace("UNCHANGED")
        stage.touchable = true;
    }


    private function instantiate():void
    {

        label.text = "PRUEBA 1";
        label.name = "label";
        this.addChild(label);

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
                case "label3":
                    trace("NEXT SUBTHEME");
                    nextSubTheme();
                    break;
            }
        }
    }

    // Pone el siguiente tema como elemento 0 del vector e intenta cargarlo
    private function nextSubTheme():void
    {
        _availableSubThemes.push(_availableSubThemes.splice(0,1)[0]);
        var subtheme:String = _availableSubThemes[0].path;
        trace("LOAD SUBTHEME ",subtheme);
        _theme.loadSubtheme(subtheme);
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

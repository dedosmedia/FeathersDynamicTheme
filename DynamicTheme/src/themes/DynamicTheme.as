/**
 * Created by dedosmedia on 26/09/17.
 */
package themes {

import feathers.controls.Label;
import feathers.controls.TextInput;
import feathers.controls.text.TextFieldTextEditor;
import feathers.controls.text.TextFieldTextRenderer;
import feathers.core.FeathersControl;
import feathers.core.ITextEditor;
import feathers.core.ITextRenderer;
import feathers.skins.ImageSkin;
import feathers.themes.IAsyncTheme;
import feathers.themes.StyleNameFunctionTheme;

import flash.geom.Rectangle;
import flash.utils.Dictionary;
import flash.utils.Dictionary;
import flash.utils.getDefinitionByName;
import flash.utils.getQualifiedClassName;

import starling.core.Starling;
import starling.display.Image;
import starling.text.TextFormat;
import starling.textures.Texture;
import starling.utils.AssetManager;
import starling.utils.SystemUtil;
import starling.events.Event;

public class DynamicTheme extends StyleNameFunctionTheme implements IAsyncTheme{


    /**
     * The name for this Dynamic Theme
     */
    public static const name:String = "Dynamic Theme";


    /**
     * @private
     */
    protected static const ATLAS_SCALE_FACTOR:int = 1;


    /**
     * The font styles Dictionary to store all required TextFormat
     */
    protected var fontStyles:Dictionary = new Dictionary(true);


    /**
     * @private
     * The paths to each of the assets, relative to the base path.
     */
    protected var assetPaths:Vector.<String> = new <String>[];


    /**
     * @private
     */
    protected var isComplete:Boolean = false;


    /**
     * @private
     */
    private var _availableSubthemes:Vector.<Object>;


    /**
     * @copy feathers.themes.IAsyncTheme#isCompleteForStarling()
     */
    public function isCompleteForStarling(starling:Starling):Boolean
    {
        return this.isComplete;
    }


    /**
     * @private
     */
    protected var assetManager:AssetManager;


    private var _assetsBasePath:String;

    private var _currentSubTheme:String;

    /**
     * @private
     */
    public function set assetsBasePath(_assetsBasePath:String):void
    {
        //add a trailing slash, if needed
        if(_assetsBasePath.lastIndexOf("/") != _assetsBasePath.length - 1)
        {
            _assetsBasePath += "/";
        }
        this._assetsBasePath = _assetsBasePath
    }

    public function get assetsBasePath():String
    {
        return this._assetsBasePath;
    }


    /**
     * @private
     * The defaultTheme's folder name as indicated in config.json
     */
    private var defaultSubTheme:String;


    /**
     * @private
     *  Config.json Theme file converted to object
     */
    private var config:Object;


    /**
     * @private
     *  Indicates an error loading the assets
     */
    private var loadingError:Boolean;

    /**
     * Constructor.
     * @param assetsBasePath The root folder of the assets.
     * @param assetManager An optional pre-created AssetManager. The scaleFactor property must be equal to Starling.contentScaleFactor. To load assets with a different scale factor, use multiple AssetManager instances.
     */
    public function DynamicTheme(assetsBasePath:String = "./", assetManager:AssetManager = null, defaultSubTheme:String = null)
    {
        trace("SUBTHEME TO LOAD: ",defaultSubTheme," DEFAULT BASE PATH",assetsBasePath);

        this.assetsBasePath = assetsBasePath;
        this.defaultSubTheme = defaultSubTheme;

        super();
        this.initializeGlobals();
        assetPaths.push("config.json");
        this.loadAssets(this.assetsBasePath, assetManager);
        this.assetManager.loadQueue(config_onProgress);
    }


    private function initialize():void
    {
        this.initializeFonts()
        this.initializeStyleProviders();
    }


    /**
     * @private
     */
    protected function assetManager_onProgress(progress:Number):void
    {
        if(progress < 1)
        {
            return;
        }

        if(loadingError)
        {
            return;
        }

        removeAssetManagerListeners();

        SystemUtil.updateEmbeddedFonts();

        this.initialize();
        this.isComplete = true;
        this.dispatchEventWith(Event.COMPLETE);
    }


    /**
     * @private
     */
    protected function config_onProgress(progress:Number):void
    {
        if(progress < 1)
        {
            return;
        }
        if(loadingError)
        {
            return;
        }
        config = this.assetManager.getObject("config");
        removeAssetManagerListeners();
        this.assetManager.removeObject("config");

        // look for available themes and the default one
        var path:String;
        for (path in config.themes)
        {
            if(defaultSubTheme)
            {
                break;
            }
            if(config.themes[path].hasOwnProperty("default") && config.themes[path]["default"] == true)
            {
                defaultSubTheme = path;
            }
        }

        // Si no hay un defaultSubtheme en el config.json, poner el último del ciclo
        defaultSubTheme = defaultSubTheme?defaultSubTheme:path;

        this._availableSubthemes = getAvailableSubThemes();
        trace("Default SubTheme: ",defaultSubTheme);
        loadSubtheme(defaultSubTheme);

    }

    public function loadSubtheme(_subtheme:String=null):void
    {
        if(_subtheme == _currentSubTheme)
        {
            dispatchEventWith("UNCHANGED",true);
            return;
        }


        if(!_subtheme)
        {
            trace("Should pass a subtheme")
            return;
        }

        defaultSubTheme = _subtheme;

            //TODO: probar que el subtheme exista

        fontStyles.length = 0;
        if(this.assetManager)
        {
            // TODO: si es un tema externo, no se deb purgar todo
            this.assetManager.purge();
        }

        assetPaths = new <String>[
            "images/" + "theme" + ".xml",
            "images/" + "theme" + ".png",
            "json/" + "theme" + ".json"
        ];

        assetPaths.push.apply(null, config.themes[defaultSubTheme].fonts);
        _currentSubTheme = defaultSubTheme;
        this.loadAssets(this.assetsBasePath+defaultSubTheme, this.assetManager);
        this.assetManager.loadQueue(assetManager_onProgress);
    }


    private function removeAssetManagerListeners():void
    {
        if(this.assetManager)
        {
            this.assetManager.removeEventListener(Event.IO_ERROR, assetManager_errorHandler);
            this.assetManager.removeEventListener(Event.SECURITY_ERROR, assetManager_errorHandler);
            this.assetManager.removeEventListener(Event.PARSE_ERROR, assetManager_errorHandler);
        }

    }

    /**
     * @private
     */
    protected function loadAssets(assetsBasePath:String = "./", assetManager:AssetManager = null):void
    {
        var oldScaleFactor:Number = -1;
        if(assetManager)
        {
            oldScaleFactor = assetManager.scaleFactor;
            assetManager.scaleFactor = ATLAS_SCALE_FACTOR;
        }
        else
        {
            assetManager = new AssetManager(ATLAS_SCALE_FACTOR);
        }

        //add a trailing slash, if needed
        if(assetsBasePath.lastIndexOf("/") != assetsBasePath.length - 1)
        {
            assetsBasePath += "/";
        }

        this.assetManager = assetManager;

        var assetPaths:Vector.<String> = this.assetPaths;
        var assetCount:int = assetPaths.length;
        for(var i:int = 0; i < assetCount; i++)
        {
            var asset:String = assetPaths[i];
            this.assetManager.enqueue(assetsBasePath + asset);
        }

        if(oldScaleFactor != -1)
        {
            //restore the old scale factor, just in case
            this.assetManager.scaleFactor = oldScaleFactor;
        }

        this.assetManager.addEventListener(Event.IO_ERROR, assetManager_errorHandler);
        this.assetManager.addEventListener(Event.SECURITY_ERROR, assetManager_errorHandler);
        this.assetManager.addEventListener(Event.PARSE_ERROR, assetManager_errorHandler);
    }



    /**
     * @private
     */
    protected function assetManager_errorHandler(event:Event):void
    {
        trace("ERROR LOADING ASSETS");
        this.loadingError = true;
        this.dispatchEventWith(event.type, false, event.data);
    }

    /**
     * Initializes font sizes and formats.
     */
    protected function initializeFonts():void {

        var object:Object = assetManager.getObject("theme")["TextFormat"];
        for (var styleFormat:String in object)
        {
            trace("STYLEFORMAT ",styleFormat);
            var textFormat:TextFormat = new TextFormat()
            // Properties
            for (var property:String in object[styleFormat])
            {
                trace("  - TextFormat property: ",property, "\tvalue: ",object[styleFormat][property]);
                textFormat[property] = object[styleFormat][property];
            }
            fontStyles[styleFormat] = textFormat;
        }

    }

    private function initializeGlobals():void
    {
        FeathersControl.defaultTextRendererFactory = function():ITextRenderer
        {
            return new TextFieldTextRenderer();
        };

        FeathersControl.defaultTextEditorFactory = function():ITextEditor
        {
            return new TextFieldTextEditor();
        };
    }

    private function initializeStyleProviders():void
    {
        var theme:Object =  assetManager.getObject("theme");
        var functionStyle:Function;
        for (var component:String in theme.components)
        {
            trace("COMPONENT: ",component)
            var componentClass:Class = getDefinitionByName(component) as Class;
            switch(component)
            {
                case "feathers.controls.TextInput":
                    functionStyle = this.setTextInputStyles;
                    break;
                case "feathers.controls.Label":
                    functionStyle = this.setLabelStyles;
                    break;
            }
            this.getStyleProviderForClass(componentClass).defaultStyleFunction = functionStyle;
            for (var styleName:String in theme.components[component])
            {
                trace("- STYLENAME: ",styleName)
                this.getStyleProviderForClass(componentClass).setFunctionForStyleName(styleName, functionStyle);
            }
        }
    }



    protected function setBaseLabelStyles(component:Label):void {

        trace("SKINING COMPONENT: ", getClassName(component)," NAME: ",component.name, " STYLE_NAME: ",component.styleName);
        var object:Object = getObjectFromJson(component, component.styleName);
        object = object?object:getObjectFromJson(component, "default");
        // Properties

        if(object)
        {
            for (var property:String in object.props)
            {
                trace("  - property: ",property, "\tvalue: ",object.props[property]);
                switch (property)
                {
                    case "fontStyles":
                        // El fontStyle es un TextFormat no un valor que se pueda pasar en JSON
                        component[property] = fontStyles[object.props[property]];
                        break;
                    default:
                        component[property] = object.props[property];

                }
            }
        }

    }

    // Label
    protected function setLabelStyles(label:Label):void
    {
        this.setBaseLabelStyles(label);
        //label.fontStyles = this.lightFontStyles;

    }

    // TextInput
    protected function setBaseTextInputStyles(component:*):void
    {
        trace("SKINING COMPONENT: ", getClassName(component)," NAME: ",component.name, " STYLE_NAME: ",component.styleName);
        var object:Object = getObjectFromJson(component, component.styleName);
        object = object?object:getObjectFromJson(component, "default");
        var skin:ImageSkin = new ImageSkin();

        // State
        for (var state:String in object.state)
        {
            var type:String = object.state[state].type;    // 'Texture'
            switch(type)
            {
                case "Texture":
                    var textureName:String = object.state[state].texture;
                    var grid:Array = object.state[state].scale9Grid;
                    var texture:Texture = getTexture(textureName);
                    // scale9Grid
                    if(grid && grid.length == 4)
                    {
                        var rect:Rectangle = new Rectangle(grid[0], grid[1], grid[2], grid[3]);
                        Image.bindScale9GridToTexture(texture, rect)
                    }
                    skin.setTextureForState(state, texture);
                    break;
                case "Color":
                    var color:String = object.state[state].color;
                    skin.setColorForState(state,parseInt(color,16));
                    break;
                    break;
            }
        }
        component.backgroundSkin = skin;

        setProperty(component,object.props);

        /*

         input.promptFontStyles = this.lightFontStyles;
         input.promptFontStyles.color = GRAY_TEXT_COLOR;

         input.fontStyles = this.lightFontStyles;

         // NO funciona... por qu?
         //input.setFontStylesForState(TextInputState.FOCUSED, this.regCenteredFontStyles);
         input.setFontStylesForState(TextInputState.ERROR, this.lightCenteredRedFontStyle);
         */

    }


    protected function setTextInputStyles(input:TextInput):void
    {
        this.setBaseTextInputStyles(input);
    }



    private function setProperty(component:FeathersControl, object:Object):void
    {
        for (var property:String in object)
        {
            trace("  - property: ",property, "\tvalue: ",object[property]);
            component[property] = object[property];
        }
    }


    // HELPERS

    private function getClassName(_object:Object):String
    {
        var className : String = getQualifiedClassName(_object);
        return className.split('::').join(".");
    }

    private function getObjectFromJson(_object:*, _styleName:String = null):Object
    {

        var _className:String = getClassName(_object);
        if(_styleName == null)
        {
            return  assetManager.getObject("theme")["components"][_className];//name)[_className];
        }
        _styleName = _styleName==""?"default":_styleName;


        // TODO: Cuando invalid JSON, aquí se quiebra la APP
        if( assetManager.getObject("theme")["components"][_className])
        {
            return  assetManager.getObject("theme")["components"][_className][_styleName];//name)[_className][_styleName];
        }
        else
        {
            return null;
        }

    }

    private function getTexture(_textureName:String):Texture
    {
        return  assetManager.getTexture(_textureName);
    }


    private function getAvailableSubThemes():Vector.<Object>
    {
        trace("******* ",config)
        var subthemes:Vector.<Object> =  new <Object>[];
        if(config && config.themes)
        {
            trace("1")
            for (var path:String in config.themes)
            {
                trace("2")
                if(config.themes[path].hasOwnProperty("disabled") && config.themes[path]["disabled"]==true)
                    continue;
                trace("3")
                subthemes.push({"name":config.themes[path].name, "path":path});
            }
        }
        return subthemes;
    }

    public function get availableSubThemes():Vector.<Object>
    {
        return this._availableSubthemes;
    }
    public function set availableSubThemes(_available:Vector.<Object>):void
    {
        this._availableSubthemes = _available;
    }



    /**
     * @private
     */
    override public function dispose():void
    {
        fontStyles = null;
        if(this.assetManager)
        {
            this.assetManager.purge();
            this.assetManager = null;
        }
        super.dispose();
    }
}
}

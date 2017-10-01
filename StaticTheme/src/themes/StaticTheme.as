/**
 * Created by dedosmedia on 26/09/17.
 */
package themes {
import feathers.controls.Label;
import feathers.controls.TextInput;
import feathers.controls.TextInputState;
import feathers.controls.text.TextFieldTextEditor;
import feathers.controls.text.TextFieldTextRenderer;
import feathers.core.FeathersControl;
import feathers.core.ITextEditor;
import feathers.core.ITextRenderer;
import feathers.events.FeathersEventType;
import feathers.layout.HorizontalAlign;
import feathers.layout.VerticalAlign;
import feathers.skins.ImageSkin;
import feathers.themes.IAsyncTheme;
import feathers.themes.StyleNameFunctionTheme;

import flash.display.Bitmap;

import flash.display.BitmapData;

import flash.text.Font;

import starling.core.Starling;


import starling.events.Event;

import starling.text.TextFormat;
import starling.textures.Texture;
import starling.textures.TextureAtlas;
import starling.utils.AssetManager;
import starling.utils.SystemUtil;

public class StaticTheme extends StyleNameFunctionTheme implements IAsyncTheme{

    [Embed(source="../../fonts/Equalize.ttf", fontFamily="Equalize", fontWeight="normal", mimeType="application/x-font", embedAsCFF="false")]
    public static const Equalize_Class:Class;

    /**
     * @private
     */
    [Embed(source="/../images/theme.xml",mimeType="application/octet-stream")]
    protected static const ATLAS_XML:Class;

    /**
     * @private
     */
    [Embed(source="/../images/theme.png")]
    protected static const ATLAS_BITMAP:Class;

    /**
     * @private
     */
    protected static const ATLAS_SCALE_FACTOR:int = 1;


    /**
     * The name of the embedded font used by controls in this theme. Comes
     * in normal and bold weights.
     */
    public static const BETHANIE_SNAKE_NORMAL:String = "Equalize";
    protected static const LIGHT_TEXT_COLOR:uint = 0x0000FF;


    /**
     * The font styles for standard-sized, light text.
     */
    protected var lightFontStyles:TextFormat;


    public static const name:String = "Static Theme 1";



    private var isComplete:Boolean = false;

    /**
     * The texture atlas that contains skins for this theme. This base class
     * does not initialize this member variable. Subclasses are expected to
     * load the assets somehow and set the <code>atlas</code> member
     * variable before calling <code>initialize()</code>.
     */
    protected var atlas:TextureAtlas;


    public function StaticTheme(assetsBasePath:String = "./", assetManager:AssetManager = null, defaultTheme:String = null) {

        trace("SOY STATICT THEME ",this.availableSubThemes);
        Font.registerFont(Equalize_Class);
        SystemUtil.updateEmbeddedFonts();
        super();

        this.initialize();

        // Emulating AsyncTheme
        isComplete = true;
        Starling.juggler.delayCall(dispatchEventWith, 0.1, Event.COMPLETE);

    }

    public function isCompleteForStarling(starling:Starling):Boolean
    {
        return this.isComplete;
    }



    /**
     * @private
     */
    override public function dispose():void
    {
        if(this.atlas)
        {
            //if anything is keeping a reference to the texture, we don't
            //want it to keep a reference to the theme too.
            this.atlas.texture.root.onRestore = null;

            this.atlas.dispose();
            this.atlas = null;
        }

        //don't forget to call super.dispose()!
        super.dispose();
    }


    private function initialize():void
    {
        this.initializeGlobals();
        this.initializeTextureAtlas();
        this.initializeFonts()
        this.initializeStyleProviders();
    }

    /**
     * @private
     */
    protected function initializeTextureAtlas():void
    {
        var atlasBitmapData:BitmapData = Bitmap(new ATLAS_BITMAP()).bitmapData;
        var atlasTexture:Texture = Texture.fromBitmapData(atlasBitmapData, false, false, ATLAS_SCALE_FACTOR);
        atlasTexture.root.onRestore = this.atlasTexture_onRestore;
        atlasBitmapData.dispose();
        this.atlas = new TextureAtlas(atlasTexture, XML(new ATLAS_XML()));
    }

    /**
     * @private
     */
    protected function atlasTexture_onRestore():void
    {
        var atlasBitmapData:BitmapData = Bitmap(new ATLAS_BITMAP()).bitmapData;
        this.atlas.texture.root.uploadBitmapData(atlasBitmapData);
        atlasBitmapData.dispose();
    }

    /**
     * Initializes font sizes and formats.
     */
    protected function initializeFonts():void {
        this.lightFontStyles = new TextFormat(BETHANIE_SNAKE_NORMAL, 16, LIGHT_TEXT_COLOR, HorizontalAlign.LEFT, VerticalAlign.MIDDLE);
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

        // label
        this.getStyleProviderForClass(Label).defaultStyleFunction = this.setLabelStyles;

        // TextInput
        this.getStyleProviderForClass(TextInput).defaultStyleFunction = this.setTextInputStyles;
    }

    protected function setLabelStyles(label:Label):void
    {
        label.fontStyles = this.lightFontStyles;
    }

    // TextInput
    protected function setBaseTextInputStyles(input:TextInput):void
    {

        var skin:ImageSkin = new ImageSkin(this.atlas.getTexture("input-background"));
        skin.setTextureForState(TextInputState.FOCUSED, this.atlas.getTexture("input-background-focused"))
        input.backgroundSkin = skin;

    }
    protected function setTextInputStyles(input:TextInput):void
    {
        this.setBaseTextInputStyles(input);
    }


    public function set availableSubThemes(_available:Vector.<Object>):void
    {
    }

    public function get availableSubThemes():Vector.<Object>
    {
        var styles:Vector.<Object> = new <Object>[];
        return styles;
    }


}
}

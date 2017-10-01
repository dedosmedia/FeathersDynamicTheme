package
{
import flash.display.Sprite;
import flash.text.Font;

public class Fonts extends Sprite
{

    [Embed(source="../BethanieSnake.ttf", embedAsCFF="false", fontFamily="Betha", fontStyle="regular")]
    public static const Betha:Class;

    [Embed(source="../Manksa.ttf", embedAsCFF="false", fontFamily="Manksa", fontStyle="regular")]
    public static const Manksa:Class;


    public function Fonts():void
    {
        Font.registerFont(Betha);
        Font.registerFont(Manksa);

    }
}
}
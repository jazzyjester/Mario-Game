using System;
using System.Collections.Generic;
using System.Text;
using System.Drawing;
using System.IO;

namespace MarioObjects.Objects.Utils
{
    public class ImageGenerator
    {
        public Bitmap Block;
        public Bitmap Ground1;
        public Bitmap Ground2;
        public Bitmap Grass;
        public Bitmap Coin;
        public Bitmap BgLowSky;
        public Bitmap BgBlock;
        public Bitmap Goomba;
        public Bitmap PipeUp;
        public Bitmap MarioSmall;
        public Bitmap MarioBig;
        public Bitmap MarioFire;
        public Bitmap FireBall;
        public Bitmap Mush;
        public Bitmap Flower;
        public Bitmap Brick;
        public Bitmap BrickPiece;
        public Bitmap Koopa;
        public Bitmap Piranah;
        public Bitmap MovingBlock;
        public Bitmap SolidBlock;
        public Bitmap ExitBlock;
        public Bitmap Frame;

        private static ImageGenerator instance = null;


        private ImageGenerator()
        {
            string strNameSpace =
            System.Reflection.Assembly.GetExecutingAssembly().GetName().Name.ToString();

            Stream str = System.Reflection.Assembly.GetExecutingAssembly().GetManifestResourceStream(strNameSpace + "." + "Images.Blocks.itemblock.png");
            Block = new Bitmap(str);

            str = System.Reflection.Assembly.GetExecutingAssembly().GetManifestResourceStream(strNameSpace + "." + "Images.Blocks.brick.png");
            Brick = new Bitmap(str);

            str = System.Reflection.Assembly.GetExecutingAssembly().GetManifestResourceStream(strNameSpace + "." + "Images.Blocks.brickpiece.png");
            BrickPiece = new Bitmap(str);

            str = System.Reflection.Assembly.GetExecutingAssembly().GetManifestResourceStream(strNameSpace + "." + "Images.Blocks.ground1.png");
            Ground1 = new Bitmap(str);

            str = System.Reflection.Assembly.GetExecutingAssembly().GetManifestResourceStream(strNameSpace + "." + "Images.Blocks.ground2.png");
            Ground2 = new Bitmap(str);

            str = System.Reflection.Assembly.GetExecutingAssembly().GetManifestResourceStream(strNameSpace + "." + "Images.Blocks.grass.png");
            Grass = new Bitmap(str);

            str = System.Reflection.Assembly.GetExecutingAssembly().GetManifestResourceStream(strNameSpace + "." + "Images.Blocks.pipeup.png");
            PipeUp = new Bitmap(str);

            str = System.Reflection.Assembly.GetExecutingAssembly().GetManifestResourceStream(strNameSpace + "." + "Images.Blocks.movingblock.png");
            MovingBlock = new Bitmap(str);

            str = System.Reflection.Assembly.GetExecutingAssembly().GetManifestResourceStream(strNameSpace + "." + "Images.Blocks.solidblock.png");
            SolidBlock = new Bitmap(str);

            str = System.Reflection.Assembly.GetExecutingAssembly().GetManifestResourceStream(strNameSpace + "." + "Images.Blocks.exit.png");
            ExitBlock = new Bitmap(str);

            str = System.Reflection.Assembly.GetExecutingAssembly().GetManifestResourceStream(strNameSpace + "." + "Images.Items.coin.png");
            Coin = new Bitmap(str);

            str = System.Reflection.Assembly.GetExecutingAssembly().GetManifestResourceStream(strNameSpace + "." + "Images.Items.mush.png");
            Mush = new Bitmap(str);

            str = System.Reflection.Assembly.GetExecutingAssembly().GetManifestResourceStream(strNameSpace + "." + "Images.Items.fireflower.png");
            Flower = new Bitmap(str);

            str = System.Reflection.Assembly.GetExecutingAssembly().GetManifestResourceStream(strNameSpace + "." + "Images.Backgrounds.bglowsky.png");
            BgLowSky = new Bitmap(str);

            str = System.Reflection.Assembly.GetExecutingAssembly().GetManifestResourceStream(strNameSpace + "." + "Images.Backgrounds.bgblock.png");
            BgBlock = new Bitmap(str);

            str = System.Reflection.Assembly.GetExecutingAssembly().GetManifestResourceStream(strNameSpace + "." + "Images.Backgrounds.Frame.png");
            Frame = new Bitmap(str);

            str = System.Reflection.Assembly.GetExecutingAssembly().GetManifestResourceStream(strNameSpace + "." + "Images.Monsters.goomba.png");
            Goomba = new Bitmap(str);

            str = System.Reflection.Assembly.GetExecutingAssembly().GetManifestResourceStream(strNameSpace + "." + "Images.Monsters.koopa.png");
            Koopa = new Bitmap(str);

            str = System.Reflection.Assembly.GetExecutingAssembly().GetManifestResourceStream(strNameSpace + "." + "Images.Monsters.piranahplant.png");
            Piranah = new Bitmap(str);

            str = System.Reflection.Assembly.GetExecutingAssembly().GetManifestResourceStream(strNameSpace + "." + "Images.Mario.mariosmall.png");
            MarioSmall = new Bitmap(str);

            str = System.Reflection.Assembly.GetExecutingAssembly().GetManifestResourceStream(strNameSpace + "." + "Images.Mario.mariobig.png");
            MarioBig = new Bitmap(str);

            str = System.Reflection.Assembly.GetExecutingAssembly().GetManifestResourceStream(strNameSpace + "." + "Images.Mario.mariofire.png");
            MarioFire = new Bitmap(str);

            str = System.Reflection.Assembly.GetExecutingAssembly().GetManifestResourceStream(strNameSpace + "." + "Images.Mario.fireball.png");
            FireBall = new Bitmap(str);

        }
        public static Bitmap GetImage(ObjectType Type)
        {
            if (instance == null)
                instance = new ImageGenerator();

            switch (Type)
            {
                case ObjectType.OT_BlockQuestion:
                    return instance.Block;
                case ObjectType.OT_BlockQuestionHidden:
                    return instance.Block;
                case ObjectType.OT_Ground1:
                    return instance.Ground1;
                case ObjectType.OT_Ground2:
                    return instance.Ground2;
                case ObjectType.OT_Grass:
                    return instance.Grass;
                case ObjectType.OT_Coin:
                    return instance.Coin;
                case ObjectType.OT_BG_LowSky:
                    return instance.BgLowSky;
                case ObjectType.OT_BG_Block:
                    return instance.BgBlock;
                case ObjectType.OT_Goomba:
                    return instance.Goomba;
                case ObjectType.OT_PipeUp:
                    return instance.PipeUp;
                case ObjectType.OT_Mario:
                    return instance.MarioSmall;
                case ObjectType.OT_MarioSmall:
                    return instance.MarioSmall;
                case ObjectType.OT_MarioBig:
                    return instance.MarioBig;
                case ObjectType.OT_MarioFire:
                    return instance.MarioFire;
                case ObjectType.OT_FireBall:
                    return instance.FireBall;
                case ObjectType.OT_Mush:
                    return instance.Mush;
                case ObjectType.OT_MushLife:
                    return instance.Mush;
                case ObjectType.OT_Flower:
                    return instance.Flower;
                case ObjectType.OT_Brick:
                    return instance.Brick;
                case ObjectType.OT_BrickPiece:
                    return instance.BrickPiece;
                case ObjectType.OT_Koopa:
                    return instance.Koopa;
                case ObjectType.OT_Pirana:
                    return instance.Piranah;
                case ObjectType.OT_MovingBlock:
                    return instance.MovingBlock;
                case ObjectType.OT_SolidBlock:
                    return instance.SolidBlock;
                case ObjectType.OT_Exit:
                    return instance.ExitBlock;
                case ObjectType.OT_Frame:
                    return instance.Frame;
            }

            return null;
        }
    }
}

using System;
using System.Collections.Generic;
using System.Text;
using MarioObjects.Objects.BaseObjects;
using MarioObjects.Objects.Utils;

namespace MarioObjects.Objects.GameObjects
{
    public class CoinBlock : AnimatedGraphicObject
    {
        public Boolean MoveUp;
        public double YOff;
        public static LevelEditorObject GetLEObject()
        {
            return new LevelEditorObject(16, 16, 4, 0, ObjectType.OT_Coin, null);
        }

        public static CoinBlock SetLEObject(LevelEditorObject le)
        {
            return new CoinBlock(le.x, le.y, false);
        }

        public void MoveCoinUp()
        {
            if (MoveUp == false)
            {
                MoveUp = true;
                YOff = 0;
            }

        }

        public override void Draw()
        {
            base.Draw();
        }
        public override void OnAnimate(object sender, EventArgs e)
        {
            base.OnAnimate(sender, e);
            if (MoveUp)
            {
                Visible = true;
                Animated = true;

                YOff += 0.5;
                newy -= 6 + (int)YOff;


                if (YOff >= 2)
                {
                    MoveUp = false;
                    Visible = false;
                    Animated = false;
                }
            }
        }
        public CoinBlock(int x, int y, Boolean MovingCoin)
            : base(ObjectType.OT_Coin)
        {
            if (MovingCoin)
            {
                Visible = false;
                Animated = false;
            }

            AnimatedCount = 4;
            this.x = x;
            this.y = y;
            MoveUp = false;


            SetWidthHeight();
            TimerGenerator.AddTimerEventHandler(TimerType.TT_100, OnAnimate);
        }

    }

}

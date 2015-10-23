using System;
using System.Collections.Generic;
using System.Text;
using MarioObjects.Objects.BaseObjects;
using MarioObjects.Objects.Utils;

namespace MarioObjects.Objects.GameObjects
{
    public class BlockBrickPiece : AnimatedGraphicObject
    {
        public Boolean Running;
        public double StartVelocity;
        public double StartPosition;
        public double TimeCount;
        public int DirX;

        public double CalcBlockBrickPiecePosition()
        {
            return StartPosition + StartVelocity * TimeCount + 4.9 * TimeCount * TimeCount;
        }

        public void OnBrickPieceFall(object sender, EventArgs e)
        {
            if (Running)
            {
                TimeCount += (500.0 / 1000.0);

                newy = (int)CalcBlockBrickPiecePosition();
                newx = newx + DirX * 3;

                if (newy > LevelGenerator.CurrentLevel.height)
                {
                    Running = false;
                    Visible = false;
                }

            }


        }
        public override void OnAnimate(object sender, EventArgs e)
        {
            base.OnAnimate(sender, e);
        }
        public override void Draw()
        {
            if (Running)
                base.Draw();
        }
        public BlockBrickPiece(int x, int y, double SV, int D)
            : base(ObjectType.OT_BrickPiece)
        {
            AnimatedCount = 4;
            this.x = x;
            this.y = y;
            SetWidthHeight();

            StartVelocity = SV;
            DirX = D;
            Running = false;
            TimeCount = 0;
            StartPosition = newy;

            TimerGenerator.AddTimerEventHandler(TimerType.TT_50, OnBrickPieceFall);
            TimerGenerator.AddTimerEventHandler(TimerType.TT_200, OnAnimate);

        }
    }


}

using System;
using System.Collections.Generic;
using System.Text;
using MarioObjects.Objects.BaseObjects;
using MarioObjects.Objects.Utils;

namespace MarioObjects.Objects.GameObjects
{
    public class BlockBrick : AnimatedGraphicObject
    {
        public BlockBrickPiece TopRight;
        public BlockBrickPiece TopLeft;
        public BlockBrickPiece ButtomRight;
        public BlockBrickPiece ButtomLeft;

        public static LevelEditorObject GetLEObject()
        {
            return new LevelEditorObject(16, 16, 4, 0, ObjectType.OT_Brick, null);
        }
        public static BlockBrick SetLEObject(LevelEditorObject le)
        {
            return new BlockBrick(le.x, le.y);
        }


        public void BreakBrick()
        {
            Visible = false;
            Animated = false;

            TopRight.Running = true;
            TopLeft.Running = true;
            ButtomRight.Running = true;
            ButtomLeft.Running = true;


        }

        public override void OnAnimate(object sender, EventArgs e)
        {
            base.OnAnimate(sender, e);
        }
        public override void Draw()
        {
            base.Draw();
        }
        public BlockBrick(int x, int y)
            : base(ObjectType.OT_Brick)
        {
            AnimatedCount = 4;
            this.x = x;
            this.y = y;
            SetWidthHeight();

            TopRight = new BlockBrickPiece(x, y, -30, 1);
            TopLeft = new BlockBrickPiece(x, y, -30, -1);
            ButtomRight = new BlockBrickPiece(x, y, -15, 1);
            ButtomLeft = new BlockBrickPiece(x, y, -15, -1);

            AddObject(TopRight);
            AddObject(TopLeft);
            AddObject(ButtomRight);
            AddObject(ButtomLeft);

            TimerGenerator.AddTimerEventHandler(TimerType.TT_100, OnAnimate);
        }
    }


}

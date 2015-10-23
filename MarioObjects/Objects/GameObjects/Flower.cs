using System;
using System.Collections.Generic;
using System.Text;
using MarioObjects.Objects.BaseObjects;

namespace MarioObjects.Objects.GameObjects
{
    public class Flower : StaticGraphicObject
    {
        public override void Draw()
        {
            base.Draw();
        }
        public Flower(int x, int y)
        {
            OT = ObjectType.OT_Flower;
            Visible = false;
            this.x = x;
            this.y = y;
            SetWidthHeight();

        }
    }

}

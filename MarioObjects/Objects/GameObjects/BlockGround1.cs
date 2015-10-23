using System;
using System.Collections.Generic;
using System.Text;
using MarioObjects.Objects.BaseObjects;

namespace MarioObjects.Objects.GameObjects
{
    public class BlockGround1 : StaticGraphicObject
    {
        public override void Draw()
        {
            base.Draw();
        }
        public BlockGround1(int x, int y)
        {
            this.x = x;
            this.y = y;
            OT = ObjectType.OT_Ground1;

        }
    }

}

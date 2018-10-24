using System;
using System.Collections.Generic;
using System.Text;
using MarioObjects.Objects.BaseObjects;

namespace MarioObjects.Objects.GameObjects
{
    public class MushLife : MoveableAnimatedObject
    {
        public override void OnWalk(object sender, EventArgs e)
        {
            if (Live)
                base.OnWalk(sender, e);
        }

        public MushLife(int x, int y)
            : base(ObjectType.OT_MushLife)
        {
            ImageCount = 2;
            ImageIndex = 1;
            this.x = x;
            this.y = y;
            WalkStep = 2;
            SetWidthHeight();
            Live = false;
            Visible = false;

            TimerGenerator.AddTimerEventHandler(TimerType.TT_50, OnWalk);
        }
    }

   
}

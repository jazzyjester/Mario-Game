using System;
using System.Collections.Generic;
using System.Text;
using MarioObjects.Objects.BaseObjects;

namespace MarioObjects.Objects.GameObjects
{
    public class MushRed : MoveableAnimatedObject
    {

        public override void OnWalk(object sender, EventArgs e)
        {
            if (Live)
                base.OnWalk(sender, e);
        }
        public MushRed(int x, int y)
            : base(ObjectType.OT_Mush)
        {
            ImageCount = 2;
            ImageIndex = 0;
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

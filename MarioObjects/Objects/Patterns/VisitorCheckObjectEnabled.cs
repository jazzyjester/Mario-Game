using System;
using System.Collections.Generic;
using System.Text;
using MarioObjects.Objects.BaseObjects;

namespace MarioObjects.Objects.Patterns
{
    public class VisitorCheckObjectEnabled : VisitorObject
    {
        public override void Action(GraphicObject g)
        {
            base.Action(g);

            g.CheckObjectEnabled();

        }
    }
}

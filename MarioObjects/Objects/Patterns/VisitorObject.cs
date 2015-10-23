using System;
using System.Collections.Generic;
using System.Text;
using MarioObjects.Objects.BaseObjects;

namespace MarioObjects.Objects.Patterns
{
    public class VisitorObject
    {
        public virtual void Action(GraphicObject g) { }
    }
}

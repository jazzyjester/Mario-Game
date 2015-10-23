using System;
using System.Collections.Generic;
using System.Text;
using System.Drawing;
using MarioObjects.Objects.Utils;

namespace MarioObjects.Objects.BaseObjects
{
    public class AnimatedGraphicObject : StaticGraphicObject
    {
        public int AnimatedCount;
        public Boolean Animated;

        public virtual void OnAnimate(Object sender, EventArgs e)
        {
            if (Animated == true)
            {
                ImageIndex++;
                if (ImageIndex >= AnimatedCount)
                    ImageIndex = 0;

                ObjectChangedDrawFlag = true;

            }
        }

        public override void Draw()
        {
            base.Draw();

        }
        public AnimatedGraphicObject(ObjectType Type)
        {
            Animated = true;
            OT = Type;
            Bitmap b = ImageGenerator.GetImage(OT);
            if (b != null)
                ImageCount = (int)Math.Round((double)b.Width / b.Height);
        }

    }

}

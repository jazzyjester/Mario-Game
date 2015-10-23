using System;
using System.Collections.Generic;
using System.Text;
using System.Drawing;
using MarioObjects.Objects.Utils;

namespace MarioObjects.Objects.BaseObjects
{
    public class StaticGraphicObject : GraphicObject
    {
        public int ImageIndex;
        public int OffsetIndex;
        public int ImageCount;

        public StaticGraphicObject()
        {
            ImageCount = 1;
            OffsetIndex = 0;

        }
        public override void Draw()
        {
            if (Visible == true)
            {

                if (ObjectChangedDrawFlag)
                {
                    Graphics xGraph;
                    //xGraph = Graphics.FromImage(Screen.GetScreen);
                    xGraph = Screen.Instance.Background.xGraph;

                    Bitmap b = ImageGenerator.GetImage(OT);

                    //Rectangle dest = new Rectangle(newx - Screen.BackgroundScreen.x, newy - (LevelGenerator.LevelHeight - Screen.BackgroundScreen.height) + Screen.BackgroundScreen.y, b.Width / ImageCount, b.Height);
                    //Rectangle src = new Rectangle(width * (ImageIndex + OffsetIndex), 0, b.Width / ImageCount, b.Height);

                    DEST.X = newx - Screen.BackgroundScreen.x;
                    DEST.Y = newy - (LevelGenerator.LevelHeight - Screen.BackgroundScreen.height) + Screen.BackgroundScreen.y;
                    DEST.Width = b.Width / ImageCount;
                    DEST.Height = b.Height;

                    SRC.X = width * (ImageIndex + OffsetIndex);
                    SRC.Y = 0;
                    SRC.Width = b.Width / ImageCount;
                    SRC.Height = b.Height;

                    xGraph.DrawImage(b, DEST, SRC, GraphicsUnit.Pixel);
                    //xGraph.Dispose();

                    //SetObjectChangeFlag(false);
                    //LevelGenerator.CurrentLevel.DrawCountPerCycle++;
                }
            }
        }

    }

}

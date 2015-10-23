using System;
using System.Collections.Generic;
using System.Text;
using System.Drawing;

namespace MarioObjects.Objects.Utils
{
    public class SubScreen
    {
        public int x, y;
        public int width, height;
        public Bitmap MainImage;
        public Graphics xGraph;
        public SubScreen(int w, int h)
        {
            width = w;
            height = h;
            MainImage = new Bitmap(width, height);
            x = y = 0;
            xGraph = Graphics.FromImage(MainImage);
        }

    }
}

using System;
using System.Collections.Generic;
using System.Text;
using System.Drawing;

namespace MarioObjects.Objects.Utils
{
    public class Screen
    {
        public SubScreen Background;
        public SubScreen Output;

        public static Screen instance = null;

        Rectangle SRC, DEST;
        public static Screen Instance
        {
            get
            {
                if (instance == null)
                    instance = new Screen();
                return instance;
            }
        }

        public static SubScreen BackgroundScreen
        {
            get
            {
                return Instance.Background;
            }
        }
        public static SubScreen OutputScreen
        {
            get
            {
                return Instance.Output;
            }
        }
        public static int Width
        {
            get
            {
                return instance.Background.width;
            }
        }

        public static int Height
        {
            get
            {
                return instance.Background.height;
            }
        }

        public static int X
        {
            get
            {
                return instance.Background.x;
            }
            set
            {
                instance.Background.x = value;
            }
        }

        public static int Y
        {
            get
            {
                return instance.Background.y;
            }
            set
            {
                instance.Background.y = value;
            }
        }

        public void DrawOnGraphic(Graphics xGraph)
        {

            // Final Surface

            //Rectangle src = new Rectangle((Output.x - Background.x), (BackgroundScreen.height - Output.height) - (Output.y - Background.y), Output.width, Output.height);
            //Rectangle dest = new Rectangle(0, 0, Output.width*2, Output.height*2);

            SRC.X = (Output.x - Background.x);
            SRC.Y = (BackgroundScreen.height - Output.height) - (Output.y - Background.y);
            SRC.Width = Output.width;
            SRC.Height = Output.height;

            DEST.X = 0;
            DEST.Y = 0;
            DEST.Width = Output.width;
            DEST.Height = Output.height;

            xGraph.DrawImage(Background.MainImage, DEST, SRC, GraphicsUnit.Pixel);

        }
        public static Bitmap GetScreen
        {
            get
            {
                if (instance == null)
                    instance = new Screen();

                return instance.Background.MainImage;
            }
        }

        public static Bitmap GetSubScreen
        {
            get
            {
                if (instance == null)
                    instance = new Screen();

                instance.Draw_Output();
                return instance.Output.MainImage;
            }
        }

        public void Draw_Output()
        {
            Graphics xGraph;
            Rectangle src = new Rectangle((Output.x - Background.x), (BackgroundScreen.height - Output.height) - (Output.y - Background.y), Output.width, Output.height);
            Rectangle dest = new Rectangle(0, 0, Output.width, Output.height);

            //xGraph = Graphics.FromImage(Output.MainImage);
            xGraph = Screen.Instance.Output.xGraph;
            xGraph.DrawImage(Background.MainImage, dest, src, GraphicsUnit.Pixel);
            //xGraph.Dispose();
        }

        public Screen()
        {
            Background = new SubScreen(400, 304);
            Output = new SubScreen(320, 240);

            SRC = new Rectangle(0, 0, 0, 0);
            DEST = new Rectangle(0, 0, 0, 0);
        }
    }


}

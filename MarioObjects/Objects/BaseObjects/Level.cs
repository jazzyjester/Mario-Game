using System;
using System.Collections.Generic;
using System.Text;
using System.Drawing;
using MarioObjects.Objects.GameObjects;
using MarioObjects.Objects.Utils;
using MarioObjects.Objects.Patterns;

namespace MarioObjects.Objects.BaseObjects
{
    public class Level
    {
        public List<IntersectionClass> IntersectsEvents;

        private Collision MainColision = null;

        public Point ButtomRight;
        public Point ButtomLeft;
        public Point TopRight;
        public Point TopLeft;

        public Boolean ChangeFlagDrawBackground = true;
        public int DrawCountPerCycle = 0;

        public Rectangle AvailableRect;

        public Rectangle DEST;

        public Rectangle SRC;

        public Bitmap LevelBitmap;

        public Mario MarioObject;

        public int width, height;

        public List<GraphicObject> Objects;

        public VisitorCheckObjectEnabled Visitor_Check_Object_Enabled;


        public void AddObject(GraphicObject g)
        {
            if (g.Objects != null)
                for (int i = 0; i < g.Objects.Count; i++)
                    AddObject(g.Objects[i]);

            Objects.Add(g);
        }

        public void CheckLevelCollisions(Object sender, EventArgs e)
        {

            //AcceptVisitor(Visitor_Check_Object_Enabled);
            int cnt = 0;
            int total = 0;
            //IntersectsEvents.Clear();


            foreach (GraphicObject src in Objects)
            {
                cnt = 0;
                src.IntersectsObjects.Clear();
                //src.IntersectsObjectsCount = 0;
                foreach (GraphicObject dest in Objects)
                {

                    if (src != dest)
                        if (src.Visible && dest.Visible)
                        {
                            Collision C = Intersects(src, dest);
                            if (C != null)
                            {
                                //IntersectsEvents.Add(new IntersectionClass(C, dest, src.Intersection));
                                src.AddCollision(new IntersectionClass(C, dest, src.Intersection));
                                //Logger.Instance.WriteLn("Object Created");
                                src.Intersection(C, dest);
                                cnt++;
                                //total++;
                            }
                        }
                }


                if (cnt == 0)
                    src.Intersection_None();
            }

            //if (IntersectsEvents.Count > 0)
            //    for (int i = 0; i < IntersectsEvents.Count; i++)
            //         IntersectsEvents[i].E(IntersectsEvents[i].C, IntersectsEvents[i].G);


        }
        public Boolean Contains(Point Src, Rectangle Dest)
        {
            if ((Src.X >= Dest.X && Src.X <= Dest.X + Dest.Width)
                && (Src.Y >= Dest.Y && Src.Y <= Dest.Y + Dest.Height))
                return true;
            else
                return false;

        }
        public Collision Intersects(GraphicObject SrcObject, GraphicObject DestObject)
        {

            Rectangle Src = SrcObject.GetObjectRect();
            Rectangle Dest = DestObject.GetObjectRect();


            if (Src.X + Src.Width < Dest.X) return null;
            if (Src.Y + Src.Height < Dest.Y) return null;

            if (Src.X > Dest.X + Dest.Width) return null;
            if (Src.Y > Dest.Y + Dest.Height) return null;

            CollisionDirection Dir = CollisionDirection.CD_Down;

            int H, W;
            //Point ButtomRight = new Point(Src.X + Src.Width, Src.Y + Src.Height);
            //Point ButtomLeft = new Point(Src.X, Src.Y + Src.Height);
            //Point TopRight = new Point(Src.X + Src.Width, Src.Y);
            //Point TopLeft = new Point(Src.X, Src.Y);
            ButtomRight.X = Src.X + Src.Width;
            ButtomRight.Y = Src.Y + Src.Height;
            ButtomLeft.X = Src.X;
            ButtomLeft.Y = Src.Y + Src.Height;
            TopRight.X = Src.X + Src.Width;
            TopRight.Y = Src.Y;
            TopLeft.X = Src.X;
            TopLeft.Y = Src.Y;



            Boolean Found = false;
            if (Contains(ButtomRight, Dest))
            //if (Dest.Contains(ButtomRight))
            {
                Found = true;
                W = ButtomRight.X - Dest.X;
                H = ButtomRight.Y - Dest.Y;
                if (W > H)
                    Dir = CollisionDirection.CD_Up;
                else if (H > W)
                    Dir = CollisionDirection.CD_Left;
                else
                    Dir = CollisionDirection.CD_TopLeft;
            }
            if (Contains(ButtomLeft, Dest))
            //                if (Dest.Contains(ButtomLeft))
            {
                Found = true;
                W = Dest.X + Dest.Width - ButtomLeft.X;
                H = ButtomLeft.Y - Dest.Y;
                if (W > H)
                    Dir = CollisionDirection.CD_Up;
                else if (H > W)
                    Dir = CollisionDirection.CD_Right;
                else
                    Dir = CollisionDirection.CD_TopRight;
            }
            if (Contains(TopRight, Dest))
            //                if (Dest.Contains(TopRight))
            {
                Found = true;
                W = TopRight.X - Dest.X;
                H = Dest.Y + Dest.Height - TopRight.Y;
                if (W > H)
                    Dir = CollisionDirection.CD_Down;
                else
                    Dir = CollisionDirection.CD_Left;
            }

            if (Contains(TopLeft, Dest))
            //                if (Dest.Contains(TopLeft))
            {
                Found = true;
                W = Dest.X + Dest.Width - TopLeft.X;
                H = Dest.Y + Dest.Height - TopLeft.Y;// -5; //Bug
                if (W > H)
                    Dir = CollisionDirection.CD_Down;
                else
                    Dir = CollisionDirection.CD_Right;
            }

            if (Found == false)
                return null;
            else
            {
                // For Better Performance.....
                MainColision.Src = Src;
                MainColision.Dest = Dest;
                MainColision.Dir = Dir;
                MainColision.Type = CollisionType.CT_Moveable;
                return MainColision;
                // Old One
                //return new Collision(Src, Dest, CollisionType.CT_Moveable, Dir);
            }

        }
        public void AcceptVisitor(VisitorObject V)
        {
            foreach (GraphicObject g in Objects)
                g.AcceptVisitor(V);

        }

        public void UpdateX(int value)
        {
            MarioObject.SetX(value);
            Update_ScreensX();
        }
        public void UpdateY(int value)
        {
            MarioObject.y += value;
            Update_ScreensY();
        }

        public void Update_ScreensX()
        {
            if (MarioObject.x >= Screen.BackgroundScreen.width / 2)
                Screen.BackgroundScreen.x = MarioObject.x - Screen.BackgroundScreen.width / 2;
            else
                Screen.BackgroundScreen.x = 0;

            if (MarioObject.x >= Screen.OutputScreen.width / 2)
                Screen.OutputScreen.x = MarioObject.x - Screen.OutputScreen.width / 2;
            else
                Screen.OutputScreen.x = 0;

            if (MarioObject.x + Screen.BackgroundScreen.width / 2 >= width)
                Screen.BackgroundScreen.x = width - Screen.BackgroundScreen.width;

            if (MarioObject.x + Screen.OutputScreen.width / 2 >= width)
                Screen.OutputScreen.x = width - Screen.OutputScreen.width;
        }

        public void Update_ScreensY()
        {
            if (height - MarioObject.y >= Screen.BackgroundScreen.height / 2)
                Screen.BackgroundScreen.y = height - MarioObject.y - Screen.BackgroundScreen.height / 2;
            else
                Screen.BackgroundScreen.y = 0;

            if (height - MarioObject.y >= Screen.OutputScreen.height / 2)
                Screen.OutputScreen.y = height - MarioObject.y - Screen.OutputScreen.height / 2;
            else
                Screen.OutputScreen.y = 0;

            if (height - MarioObject.y + Screen.BackgroundScreen.height / 2 >= height)
                Screen.BackgroundScreen.y = height - Screen.BackgroundScreen.height;

            if (height - MarioObject.y + Screen.OutputScreen.height / 2 >= height)
                Screen.OutputScreen.y = height - Screen.OutputScreen.height;
        }

        public Level()
        {
            LevelGenerator.CurrentLevel = this;

            width = 1024;
            height = 464;//464
            Objects = new List<GraphicObject>();
            LevelBitmap = ImageGenerator.GetImage(ObjectType.OT_BG_Block);
            Visitor_Check_Object_Enabled = new VisitorCheckObjectEnabled();

            MainColision = new Collision(new Rectangle(0, 0, 0, 0), new Rectangle(0, 0, 0, 0), CollisionType.CT_Moveable, CollisionDirection.CD_ButtomLeft);
            AvailableRect = new Rectangle(0, 0, 0, 0);
            ButtomLeft = new Point(0, 0);
            ButtomRight = new Point(0, 0);
            TopRight = new Point(0, 0);
            TopLeft = new Point(0, 0);

            SRC = new Rectangle(0, 0, 0, 0);
            DEST = new Rectangle(0, 0, 0, 0);



            //MarioObject = new Mario();
            //Objects.Add(MarioObject);

            IntersectsEvents = new List<IntersectionClass>();
        }
        public void AddObject(int x, int y, GraphicObject Object)
        {


        }
        public void DrawBackground(Rectangle Rect)
        {
            Graphics xGraph;
            //xGraph = Graphics.FromImage(Screen.GetScreen);
            xGraph = Screen.Instance.Background.xGraph;
            //Rectangle dest = new Rectangle(0, 0, Screen.Width, Screen.Height);
            //Rectangle src = new Rectangle(Screen.OutputScreen.x / 3, (LevelBitmap.Height - Screen.Height) - Screen.OutputScreen.y / 3, Screen.Width, Screen.Height);
            //Rectangle dest = new Rectangle(x - Screen.BackgroundScreen.x, y - (LevelGenerator.LevelHeight - Screen.BackgroundScreen.height) + Screen.BackgroundScreen.y, width, height);




            int Y = (LevelGenerator.CurrentLevel.LevelBitmap.Height - Screen.OutputScreen.y / 3);
            Y = Y - (Y - (Rect.Y));
            int X = (Screen.OutputScreen.x / 3) + (Rect.X - Screen.BackgroundScreen.x);

            DEST.X = Rect.X - Screen.BackgroundScreen.x;
            DEST.Y = Rect.Y - (LevelGenerator.LevelHeight - Screen.BackgroundScreen.height) + Screen.BackgroundScreen.y;
            DEST.Width = Rect.Width;
            DEST.Height = Rect.Height;

            SRC.X = X;
            SRC.Y = Y;
            SRC.Width = Rect.Width;
            SRC.Height = Rect.Height;
            //xGraph.DrawImage(LevelBitmap, dest, src, GraphicsUnit.Pixel);
            xGraph.DrawImage(LevelBitmap, DEST, SRC, GraphicsUnit.Pixel);

            //xGraph.Dispose();


        }
        public void DrawBackground()
        {
            Graphics xGraph;
            //xGraph = Graphics.FromImage(Screen.GetScreen);
            xGraph = Screen.Instance.Background.xGraph;

            //Rectangle dest = new Rectangle(0, 0, Screen.Width, Screen.Height);
            //Rectangle src = new Rectangle(Screen.OutputScreen.x / 3, (LevelBitmap.Height - Screen.Height) - Screen.OutputScreen.y / 3, Screen.Width, Screen.Height);
            DEST.X = 0;
            DEST.Y = 0;
            DEST.Width = Screen.Width;
            DEST.Height = Screen.Height;

            SRC.X = Screen.OutputScreen.x / 3;
            SRC.Y = (LevelBitmap.Height - Screen.Height) - Screen.OutputScreen.y / 3;
            SRC.Width = Screen.Width;
            SRC.Height = Screen.Height;

            //xGraph.DrawImage(LevelBitmap, dest, src, GraphicsUnit.Pixel);
            xGraph.DrawImage(LevelBitmap, DEST, SRC, GraphicsUnit.Pixel);

            //xGraph.Dispose();

        }
        public Rectangle GetAvailableObjectRec()
        {
            int AX, AY;

            if (MarioObject.x < Screen.BackgroundScreen.width / 2)
                AX = 0;
            else if (MarioObject.x >= Screen.BackgroundScreen.width / 2 && MarioObject.x < LevelGenerator.CurrentLevel.width - Screen.BackgroundScreen.width / 2)
                AX = MarioObject.x - Screen.BackgroundScreen.width / 2;
            else
                AX = LevelGenerator.CurrentLevel.width - Screen.BackgroundScreen.width;

            if (MarioObject.y < Screen.BackgroundScreen.height / 2)
                AY = 0;
            else if (MarioObject.y >= Screen.BackgroundScreen.height / 2 && MarioObject.y < LevelGenerator.CurrentLevel.height - Screen.BackgroundScreen.height / 2)
                AY = MarioObject.y - Screen.BackgroundScreen.height / 2;
            else
                AY = LevelGenerator.CurrentLevel.height - Screen.BackgroundScreen.height;

            // Performance Issue

            AvailableRect.X = AX;
            AvailableRect.Y = AY;
            AvailableRect.Width = Screen.BackgroundScreen.width;
            AvailableRect.Height = Screen.BackgroundScreen.height;
            return AvailableRect;

            //return new Rectangle(AX,AY, Screen.BackgroundScreen.width, Screen.BackgroundScreen.height);
        }


        public void Draw()
        {
            Rectangle AvailableRec = GetAvailableObjectRec();
            int cnt = 0;
            if (ChangeFlagDrawBackground)
            {
                DrawBackground();
                //foreach (GraphicObject g in Objects)
                //    if (AvailableRec.Contains(g.GetObjectRect()))
                //        g.Draw();

                //ChangeFlagDrawBackground = false;
            }
            DrawCountPerCycle = 0;
            foreach (GraphicObject g in Objects)
            {
                // Should Improve Performance. Draw only objects in Range...
                // Rectangle r = g.GetObjectRect();
                if (AvailableRec.Contains(g.GetObjectRect()))
                {
                    g.Draw();
                    //cnt++;
                    //Logger.Instance.WriteLn(g.GetType().ToString());
                }

            }
            //Logger.Instance.WriteLn("Objects:" + cnt.ToString());
            //Logger.Instance.WriteLn("Drown:" + DrawCountPerCycle.ToString());


        }

    }
}

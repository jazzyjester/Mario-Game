using System;
using System.Collections.Generic;
using System.Text;
using System.Drawing;
using Helper;
using MarioObjects.Objects.Utils;
using MarioObjects.Objects.Patterns;

namespace MarioObjects.Objects.BaseObjects
{
    public class GraphicObject
    {
        public List<IntersectionClass> IntersectsObjects;
        public List<GraphicObject> Objects = null;

        public Rectangle ObjectRect;
        public Rectangle SRC, DEST;

        public Boolean Enabled;
        public Boolean Visible;
        public Boolean ObjectChangedDrawFlag = true;
        // public int offx,offy;
        public int newx, newy;
        public int x, y;
        public int width, height;
        public ObjectType OT;

        public void SetObjectChangeFlag(Boolean F)
        {
            ObjectChangedDrawFlag = F;
            LevelGenerator.CurrentLevel.ChangeFlagDrawBackground = true;
        }
        public virtual void Get_LevelEditor()
        {

        }
        public void LogMe(Collision c, GraphicObject g)
        {
            Logger.Instance.Log_Method(c.Dir.ToString());
            Logger.Instance.Step_In();

            Logger.Instance.WriteLn("Src Object:" + this.GetType().Name);
            Logger.Instance.WriteLn("Dest Object:" + g.GetType().Name);

            Logger.Instance.WriteLn("Src Rectangle:" + c.Src.ToString());
            Logger.Instance.WriteLn("Dest Rectangle:" + c.Dest.ToString());

            Logger.Instance.Step_Out();

        }
        public virtual void Draw() { }
        public virtual void Intersection(Collision c, GraphicObject g)
        {
            //if (this.GetType().Name == "Mario")
            //    if (g.GetType().Name == "BlockSolid")
            //        LogMe(c, g);

            // if (this.GetType().Name == "Mario")
            //     if (g.GetType().Name == "BlockGrass")
            //         LogMe(c, g);
        }
        public virtual void Intersection_None() { }
        public void AddObject(GraphicObject g)
        {
            if (Objects == null)
                Objects = new List<GraphicObject>();

            Objects.Add(g);
        }
        public void AddCollision(IntersectionClass IC)
        {
            IntersectsObjects.Add(IC);
        }

        public GraphicObject()
        {
            IntersectsObjects = new List<IntersectionClass>(10);
            for (int i = 0; i < 10; i++)
                IntersectsObjects.Add(new IntersectionClass(null, null, null));

            ObjectRect = new Rectangle(0, 0, 0, 0);
            SRC = new Rectangle(0, 0, 0, 0);
            DEST = new Rectangle(0, 0, 0, 0);

            Visible = true;

        }
        public void SetWidthHeight()
        {
            Bitmap b = ImageGenerator.GetImage(OT);
            width = b.Height;
            height = b.Height;

            newx = x * 16;
            newy = LevelGenerator.LevelHeight - (y + 1) * 16;
            if (height == 32)
                newy -= 16;
        }
        public virtual Rectangle GetObjectRect()
        {
            //Bitmap b = ImageGenerator.GetImage(OT);
            //int bw = b.Width;
            //int bh = b.Height;        

            // Performance Issue
            ObjectRect.X = newx;
            ObjectRect.Y = newy;
            ObjectRect.Width = width;
            ObjectRect.Height = height;

            return ObjectRect;

            //return new Rectangle(newx, newy, width, height);
        }
        public void AcceptVisitor(VisitorObject V)
        {
            V.Action(this);
        }
        public void CheckObjectEnabled()
        {
            int x = newx;
            int y = newy;
            if ((x >= Screen.BackgroundScreen.x) &&
               (x + width <= Screen.BackgroundScreen.x + Screen.BackgroundScreen.width) &&
               (y >= LevelGenerator.LevelHeight - (Screen.BackgroundScreen.y + Screen.BackgroundScreen.height)) &&
               (y <= LevelGenerator.LevelHeight - Screen.BackgroundScreen.y))
                Enabled = true;
            else
                Enabled = false;

        }

    }
}

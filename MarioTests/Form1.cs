using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;
using MarioObjects.Objects.Utils;

namespace MarioObjects
{
    public partial class Form1 : Form
    {
        public List<MyObject> list;
        public Bitmap MainImage;
        public Graphics MainGraphic;
        public Form1()
        {
            InitializeComponent();
            
        }

        public void AddLine(ObjectType OT, int y)
        { 
            for(int x = 0;x<40;x++)
                list.Add(new MyObject(OT, MainGraphic, x*16, y));

        }

        private void Form1_Load(object sender, EventArgs e)
        {
            list = new List<MyObject>();
            MainImage = new Bitmap(this.Width,this.Height);
            MainGraphic = Graphics.FromImage(MainImage);

            AddLine(ObjectType.OT_MarioBig,0);
            AddLine(ObjectType.OT_MarioFire,16);
            AddLine(ObjectType.OT_MarioSmall,32);
            AddLine(ObjectType.OT_Brick,48);
            AddLine(ObjectType.OT_BlockQuestion,64);
            AddLine(ObjectType.OT_Goomba,80);
            AddLine(ObjectType.OT_Koopa,96);
            AddLine(ObjectType.OT_Pirana, 112);

            

        }

        private void timer_Tick(object sender, EventArgs e)
        {
            Invalidate();
        }

        public void DrawAll(Graphics g)
        {
            
            //MainGraphic.DrawImage(ImageGenerator.GetImage(ObjectType.OT_BG_Block), new Rectangle(0, 0, this.Width
            //    , this.Height), new Rectangle(0, 0, 1024, 400), GraphicsUnit.Pixel);

            

           // MainGraphic.DrawImage(pMain.Image, new Rectangle(0, 0, this.Width
           //     , this.Height), new Rectangle(0, 0, 1024, 400), GraphicsUnit.Pixel);

            foreach (MyObject o in list)
            {
                if (o.xGraph != g)
                    o.xGraph=g;
                o.Draw();
            }
        }
        private void Form1_Paint(object sender,PaintEventArgs e)
        {
            Graphics xGraph = e.Graphics;

            //xGraph.DrawImage(ImageGenerator.GetImage(ObjectType.OT_BG_Block), new Rectangle(0, 0, this.Width
            //    , this.Height), new Rectangle(0, 0, 1024, 400), GraphicsUnit.Pixel);
            xGraph.DrawImage(ImageGenerator.GetImage(ObjectType.OT_BG_Block),0,0);

            DrawAll(xGraph);
            
            //xGraph.DrawImage(MainImage,new Rectangle(0,0,this.Width,this.Height),new Rectangle(0,0,this.Width,this.Height),GraphicsUnit.Pixel);




        }

    }

    public class MyObject
    { 
        public int x,y;
        public int ox, oy;
        public Graphics xGraph;
        public int index = 0;
        public ObjectType OT;
        public MyObject(ObjectType T,Graphics g,int x, int y)
        {
            this.x = x;
            this.y = y;
            OT = T;
            xGraph = g;
            ox = oy = 0;

            TimerGenerator.AddTimerEventHandler(TimerType.TT_50, OnChange);
        }
        public void OnChange(Object sender, EventArgs e)
        {
            index++;
            if (index > 3)
                index = 0;

            x++;
            ox++;
            if (ox > 20)
            {
                ox = 0;
                x -= 20;
                oy++;
                y++;
            }

            if(oy > 20)
            {
                y -= 20;
                x -= 20;
                oy = 0;
                ox = 0;
            }

            
            
        }
        public void Draw()
        { 
            Rectangle SRC = new Rectangle(index*16,0,16,16);
            Rectangle DEST = new Rectangle(x,y,16,16);
            xGraph.DrawImage(ImageGenerator.GetImage(OT), DEST, SRC, GraphicsUnit.Pixel);
        }

    }
}
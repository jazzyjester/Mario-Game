using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;
using System.Runtime.InteropServices;

using Helper;
using MarioObjects.Objects.BaseObjects;
using MarioObjects.Objects.GameObjects;
using MarioObjects.Objects.Utils;

namespace MarioObjects
{

    
    public partial class frmMain : Form
    {
        public const int WM_NCLBUTTONDOWN = 0xA1;
        public const int HT_CAPTION = 0x2;
        private const int WM_PAINT = 0x000F;


        [DllImportAttribute("user32.dll")]
        public static extern int SendMessage(IntPtr hWnd,
                         int Msg, int wParam, int lParam);
        [DllImportAttribute("user32.dll")]
        public static extern bool ReleaseCapture();

        [DllImport("User32.dll")]
        private static extern short GetAsyncKeyState(System.Windows.Forms.Keys vKey); 

        public Level lev;
        public int BackPaint = 0;
        Rectangle SRC ;
        Rectangle DEST;

        DateTime MyTime;


        public frmMain()
        {
            InitializeComponent();
        }


        public void InitLevel()
        {
            for (int i = 0; i < 25; i++)
            {
                lev.AddObject(new BlockSolid(0, i));
                lev.AddObject(new BlockSolid(49, i));
            }
    
            for (int i = 0; i < 50; i++)
                lev.AddObject(new BlockSolid(i, 25));

            for (int i = 0; i < 5; i++)
                lev.AddObject(new BlockSolid(48-i, 22));


            for (int i = 0; i < 5; i++)
                {
                    lev.AddObject(new CoinBlock(47 - i, 5 + 5, false));
                    lev.AddObject(new CoinBlock(47, 1+i + 5, false));

                    lev.AddObject(new CoinBlock(41, 1 + i + 5, false));

                    lev.AddObject(new CoinBlock(39, 1 + i + 5, false));
                    lev.AddObject(new CoinBlock(39 - i, 1 + 5, false));
                }
            for (int i = 0; i < 3; i++)
                lev.AddObject(new CoinBlock(33 , 5-i + 5, false));

            lev.AddObject(new ExitBlock(48, 24));

        
        }

        public void Init_Properties()
        {

            Width = 320;
            Height = 240  + 25;

            Cursor.Hide();


            //pBack.Left = 0;
            //pBack.Top = 0;
            //pBack.Width = pBack.Image.Width;
            //pBack.Height = pBack.Image.Height;

            pMain.Image = new Bitmap(320,240);
            pMain.Left = 0;
            pMain.Top = 0;
            pMain.Width = pMain.Image.Width;
            pMain.Height = pMain.Image.Height;


            Left = SystemInformation.PrimaryMonitorSize.Width / 2 - this.Width / 2;
            Top = SystemInformation.PrimaryMonitorSize.Height / 2 - this.Height / 2;

            Media.PlaySound(Media.SoundType.ST_level2);
        }
        public void OnTest(object sender, EventArgs e)
        { 
        
        }
        private void MainForm_Load(object sender, EventArgs e)
        {
            MyTime = DateTime.Now;

            SRC = new Rectangle(0, 0, 320, 240);
            DEST = new Rectangle(0, 0, 320, 240);

            Init_Properties();

            lev = new Level();

            Load_Level_XML();


//            InitLevel();

/*
//            for (int i = 0; i < 7; i++)
//                for (int j = 7-i; j < 7; j++)
//                    lev.AddObject(new BlockBrick (4 + i, 8-(1 + j)));

//            for (int i = 0; i < 15; i++)
//                lev.AddObject(new BlockBrick(7+i, 5));

//            for (int i = 0; i < 10; i++)
//                    lev.AddObject(new BlockBrick(6,i+1));

            for (int i = 0; i < 32; i++)
                lev.AddObject(new BlockGrass(i, 0));
            
            for (int i = 34; i < 50; i++)
                lev.AddObject(new BlockGrass(i, 0));

            //lev.AddObject(new MonsterGoomba(3, 5));
            //lev.AddObject(new MonsterKoopa(5, 5));

            for (int i = 0; i < 7; i++)
            {
                if (i%2==0)
                    lev.AddObject(new BlockBrick(3 + i, 4));
                else
                    lev.AddObject(new BlockQuestion(3 + i, 4, ObjectType.OT_Coin));
            }

            lev.AddObject(new BlockQuestion(5, 8, ObjectType.OT_Mush));
            lev.AddObject(new BlockQuestion(6, 8, ObjectType.OT_Coin));
            lev.AddObject(new BlockQuestion(7, 8, ObjectType.OT_Flower));

            lev.AddObject(new BlockQuestion(6, 12, ObjectType.OT_Coin));

            lev.AddObject(new CoinBlock(6, 15, false));


            lev.AddObject(new MonsterGoomba(18, 1));
            lev.AddObject(new MonsterGoomba(21, 1));

            lev.AddObject(new BlockPipeUp(25, 2,MonsterPiranah.PiranahType.PT_Fish));

            lev.AddObject(new BlockPipeUp(14, 2,MonsterPiranah.PiranahType.PT_Fire));

            lev.AddObject(new BlockMoving(15, 15, 100, BlockMoving.MovingType.MT_RightLeft,true));
            lev.AddObject(new BlockMoving(22, 12, 100, BlockMoving.MovingType.MT_RightLeft,false));
            lev.AddObject(new BlockMoving(30, 9, 100, BlockMoving.MovingType.MT_RightLeft,true));

            lev.AddObject(new BlockMoving(40, 15, 50, BlockMoving.MovingType.MT_UpDown, true));


            lev.AddObject(lev.MarioObject);

          */




                //lev.Update_ScreensX();
                //lev.Update_ScreensY();
            
           // MyTest t1 = new MyTest(this, "1");
           // MyTest t2 = new MyTest(this, "2");

        }

        private void MainForm_Paint(object sender, PaintEventArgs e)
        {
            //Graphics xGraph;
            //xGraph = e.Graphics;
            //lev.Draw();
           

            //xGraph.DrawImage(ImageGenerator.GetImage(ObjectType.OT_Frame),0,0,640+120,480 + 120);
            //xGraph.DrawImage(ImageGenerator.GetImage(ObjectType.OT_Frame), 0, 0);
           // xGraph.DrawImage(Screen.GetSubScreen,DEST,SRC,GraphicsUnit.Pixel);
            //xGraph.DrawImage(Screen.GetSubScreen,0,0,320,240);
            //if (BackPaint == 50)
           // {
           //     BackPaint = 0;
           // xGraph.DrawImage(ImageGenerator.GetImage(ObjectType.OT_Frame), 0, 0, 640 + 120, 480 + 120);
           // }

            
            
        }

        protected override void OnPaint(PaintEventArgs e)
        {

             //Graphics xGraph;
             //xGraph = e.Graphics ;
             //lev.Draw();


             //xGraph.DrawImage(Screen.GetSubScreen,DEST,SRC,GraphicsUnit.Pixel);
             //xGraph.DrawImage(ImageGenerator.GetImage(ObjectType.OT_Frame), 0, 0, 640 + 120, 480 + 120);

             //base.OnPaint(e);

         }
        private void timerPaint_Tick(object sender, EventArgs e)
        {

            pMain.Invalidate();
            //Invalidate();
            //SendMessage(this.Handle, WM_PAINT, 0, 0);
            //OnPaint(null);
            
            //this.Text = "Mario By Jazzy," + lev.MarioObject.x.ToString() + "," + Screen.BackgroundScreen.x.ToString() + "," + Screen.OutputScreen.x.ToString();
            //this.Text += " | ";
            //this.Text += lev.MarioObject.y.ToString() + "," + Screen.BackgroundScreen.y.ToString() + "," + Screen.OutputScreen.y.ToString();
            //this.Text = lev.MarioObject.XAdd.ToString() + " , "+ lev.MarioObject.IsBrickExistOnSidesLeft().ToString();

            DateTime TimeClose = DateTime.Now;

            TimeSpan Diff = TimeClose.Subtract(MyTime);

            this.Text = string.Format("{0:00}:{1:00}:{2:00}", Diff.Hours, Diff.Minutes, Diff.Seconds);

        }

        private void MainForm_KeyDown(object sender, KeyEventArgs e)
        {
            Boolean KeyRight = false;
            Boolean KeyLeft = false;

            int state = Convert.ToInt32(GetAsyncKeyState(Keys.Right).ToString());
            KeyRight = state == -32767;
            state = Convert.ToInt32(GetAsyncKeyState(Keys.Left).ToString());
            KeyLeft = state == -32767;


            if ((e.Modifiers & Keys.Control) == Keys.Control)
                lev.MarioObject.StartJump(false,0);

            if (e.KeyValue == (int)Keys.Right || KeyRight)
                lev.MarioObject.MarioMove(Mario.MarioMoveState.J_Right);

            if (e.KeyValue == (int)Keys.Left || KeyLeft)
                lev.MarioObject.MarioMove(Mario.MarioMoveState.J_Left);

            if (e.KeyValue == (int)Keys.Space)
                lev.MarioObject.MarioFireBall();


            if (e.KeyValue == (int)Keys.Up)
                lev.MarioObject.UpPressed = true;

            if (e.KeyValue == (int)Keys.Escape)
                this.Close();


            //if (e.KeyValue == (int)Keys.Down)
            //    BM.newy += 2;

           
        }

        private void frmMain_KeyUp(object sender, KeyEventArgs e)
        {

            if (e.KeyValue == (int)Keys.ControlKey)
                lev.MarioObject.StopJump();

            if (e.KeyValue == (int)Keys.Right)
                lev.MarioObject.StopMove();


            if (e.KeyValue == (int)Keys.Left)
                lev.MarioObject.StopMove();

            if (e.KeyValue == (int)Keys.Up)
                lev.MarioObject.UpPressed = false;


        }


        public void Load_Level_XML()
        {
            List<LevelEditorObject> list =  MarioEditorXML.Load_From_XML("lev1.xml");
            Mario MTemp = null;
            foreach(LevelEditorObject le in list)
            {

                GraphicObject g = ObjectGenerator.SetEditorObject(le);
                if (g != null && g.OT != ObjectType.OT_Mario)
                    lev.AddObject(g);
                else if (g.OT == ObjectType.OT_Mario)
                    MTemp = (Mario)g;

            }

            lev.AddObject(MTemp);

           for(int i=0;i<lev.Objects.Count;i++)
               if (lev.Objects[i].OT == ObjectType.OT_Mario)
                {
                    lev.MarioObject = (Mario)lev.Objects[i];
                    break;
                }

        }

        private void frmMain_MouseDown(object sender, MouseEventArgs e)
        {

            if (e.Button == MouseButtons.Left)
            {
                ReleaseCapture();
                SendMessage(Handle, WM_NCLBUTTONDOWN, HT_CAPTION, 0);
            }


        }

        private void pMain_MouseDown(object sender, MouseEventArgs e)
        {
            frmMain_MouseDown(sender, e);
        }

        private void pMain_Paint(object sender, PaintEventArgs e)
        {
            Graphics xGraph = e.Graphics;//Graphics.FromImage(pMain.Image) ; 


            lev.Draw();


            MarioObjects.Objects.Utils.Screen.Instance.DrawOnGraphic(xGraph);

            //Rectangle SRC = new Rectangle(0, 0, 320, 240);
            //Rectangle DEST = new Rectangle(0, 0, pMain.Image.Width, pMain.Image.Height);

           //xGraph.DrawImage(ImageGenerator.GetImage(ObjectType.OT_Frame),0,0,640+120,480 + 120);
            //xGraph.DrawImage(ImageGenerator.GetImage(ObjectType.OT_Frame), 0, 0);
            //xGraph.DrawImage(Screen.GetSubScreen,DEST,SRC,GraphicsUnit.Pixel);
            //xGraph.DrawImage(Screen.GetSubScreen, 0, 0);

            //xGraph.Dispose();
            

        }

        private void timerBack_Tick(object sender, EventArgs e)
        {
            Invalidate();

        }

        private void frmMain_FormClosed(object sender, FormClosedEventArgs e)
        {
            DateTime TimeClose = DateTime.Now;

            TimeSpan Diff = TimeClose.Subtract(MyTime);

            Logger.Instance.Log_Method(Diff.ToString());


        }

    }

}
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
        public static extern int SendMessage(IntPtr hWnd, int Msg, int wParam, int lParam);
        [DllImportAttribute("user32.dll")]
        public static extern bool ReleaseCapture();

        [DllImport("User32.dll")]
        private static extern short GetAsyncKeyState(System.Windows.Forms.Keys vKey); 

        public Level lev;
        public int BackPaint = 0;

        DateTime LevelBeginTime;
        

        public frmMain()
        {
            InitializeComponent();
        }

        public void Init_Properties()
        {
            Width = 320;
            Height = 240  + 40 + flowPanel_gameInfo.Height;

            //Cursor.Hide();

            pMain.Image = new Bitmap(320,240);
            /*pMain.Left = 0;
            pMain.Top = 0;
            pMain.Width = pMain.Image.Width;
            pMain.Height = pMain.Image.Height;*/
            
            Left = SystemInformation.PrimaryMonitorSize.Width / 2 - this.Width / 2;
            Top = SystemInformation.PrimaryMonitorSize.Height / 2 - this.Height / 2;
            
            Media.PlaySound(Media.SoundType.ST_level2);
        }

        private void MainForm_Load(object sender, EventArgs e)
        {
            LevelManager.Instance.InitLevelManager("LevelManager.xml");
            Load_Level(LevelManagerLoadTypes.STARTUP);
        }

        private void timerPaint_Tick(object sender, EventArgs e)
        {
            pMain.Invalidate();
            DateTime TimeClose = DateTime.Now;
            TimeSpan Diff = TimeClose.Subtract(LevelBeginTime);
            this.Text = string.Format("{0:00}:{1:00}:{2:00}", Diff.Hours, Diff.Minutes, Diff.Seconds);
            lbl_Level.Text = "Level " + (LevelManager.Instance.CurrentLevelIndex + 1).ToString() + " (" + LevelManager.Instance.CurrentLevelName + ")";
            lbl_numCoins.Text = lev?.MarioObject?.NumberOfCollectedCoins.ToString();
            lbl_numLives.Text = LevelManager.Instance.MarioLives.ToString();
        }

        private void MainForm_KeyDown(object sender, KeyEventArgs e)
        {
            Boolean KeyRight = false;
            Boolean KeyLeft = false;

            int state = Convert.ToInt32(GetAsyncKeyState(Keys.Right).ToString());
            KeyRight = (state == -32767);
            state = Convert.ToInt32(GetAsyncKeyState(Keys.Left).ToString());
            KeyLeft = (state == -32767);

            if (e.KeyValue == (int)Keys.Up)
                lev.MarioObject.StartJump(false,0);

            if (e.KeyValue == (int)Keys.Right || KeyRight)
                lev.MarioObject.MarioMove(Mario.MarioMoveState.J_Right);

            if (e.KeyValue == (int)Keys.Left || KeyLeft)
                lev.MarioObject.MarioMove(Mario.MarioMoveState.J_Left);

            if (e.KeyValue == (int)Keys.Space)
                lev.MarioObject.MarioFireBall();

            
            if(e.KeyValue == (int)Keys.Enter)
                lev.MarioObject.EnterPressed = true;

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


        public void Load_Level(LevelManagerLoadTypes levelLoadType)
        {
            TimerGenerator.RemoveAllTimerEvents();

            Init_Properties();

            lev = LevelManager.Instance.LoadLevel(levelLoadType);

            lev.MarioObject.OnLevelCompleted += (() => Load_Level(LevelManagerLoadTypes.NEXT));
            lev.MarioObject.OnMarioDied += (() => Load_Level(LevelManagerLoadTypes.RELOAD));

            lev.MarioObject.x = 20;
            lev.MarioObject.y = LevelGenerator.LevelHeight - 16 * 1 - lev.MarioObject.height;
            LevelGenerator.CurrentLevel.Update_ScreensX();
            LevelGenerator.CurrentLevel.Update_ScreensY();

            LevelBeginTime = DateTime.Now;

            Invalidate();
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
            Graphics xGraph = e.Graphics; 
            lev.Draw();
            MarioObjects.Objects.Utils.Screen.Instance.DrawOnGraphic(xGraph);      
        }

        private void timerBack_Tick(object sender, EventArgs e)
        {
            Invalidate();
        }

        private void frmMain_FormClosed(object sender, FormClosedEventArgs e)
        {
            LevelManager.Instance.SaveLevelManager("LevelManager.xml");

            DateTime TimeClose = DateTime.Now;
            TimeSpan Diff = TimeClose.Subtract(LevelBeginTime);
            Logger.Instance.Log_Method(Diff.ToString());
        }

    }
}
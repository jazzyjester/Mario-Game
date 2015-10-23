using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;

namespace MarioRectangle
{
    public partial class MainForm : Form
    {
        public Bitmap MainImage;

        public MainForm()
        {
            InitializeComponent();
        }

        private void MainForm_Load(object sender, EventArgs e)
        {
            MainImage = new Bitmap(Width, Height);


        }

        private void bDraw_Click(object sender, EventArgs e)
        {
            int iTop, iLeft, iWidth, iHeight;
            iTop = Convert.ToInt32(tTop.Text);
            iLeft = Convert.ToInt32(tLeft.Text);
            iWidth = Convert.ToInt32(tWidth.Text);
            iHeight = Convert.ToInt32(tHeight.Text);


            Rectangle rec = new Rectangle(iLeft, iTop, iWidth, iHeight);
            Graphics xGraph = Graphics.FromImage(MainImage);
            Pen p = new Pen(Color.Red);
            
            xGraph.DrawRectangle(p, rec);
            p.Dispose();
            xGraph.Dispose();

            Invalidate();

            

        }

        private void MainForm_Paint(object sender, PaintEventArgs e)
        {
            Graphics xGraph = e.Graphics;
            xGraph.DrawImage(MainImage, 0, 0);
            xGraph.Dispose();


        }

        private void bClear_Click(object sender, EventArgs e)
        {
            Graphics xGraph = Graphics.FromImage(MainImage);

            SolidBrush b = new SolidBrush(Color.Silver);
            xGraph.FillRectangle(b, new Rectangle(0, 0, Width, Height));

            b.Dispose();
            xGraph.Dispose();

            Invalidate();


        }
    }
}
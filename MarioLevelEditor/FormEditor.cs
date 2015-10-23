using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;
using System.Runtime.InteropServices;
using System.IO;
using System.Resources;
using System.Reflection;
using System.Collections; 


using MarioObjects;
using MarioObjects.Objects.Utils;

namespace MarioLevelEditor
{
    public partial class MainForm : Form
    {
        public Bitmap MainImage = null;
        public int CurrentImageIndex;
        public List<LevelEditorObject> Objects;
        public int Seconds = 0;

        string FileName;

        public int LX,LY;

        public int OX, OY;

        public MainForm()
        {
            InitializeComponent();
        }

        public void DrawAllObjects()
        {
            //IDictionaryEnumerator ide = Objects.GetEnumerator();
	
            foreach (LevelEditorObject obj in Objects)
            {
                Point p = new Point(obj.x, obj.y);
                PutBox(p.X*16, MainImage.Height -  (p.Y+1)*16, obj.ListIndex,obj.Checked);
            }
        }

        public void PutBox(int x, int y,int ind,Boolean Check)
        {


            Graphics xGraph = Graphics.FromImage(pictureLevel.Image);
            LevelEditorObject le = (LevelEditorObject)list.Items[ind].Tag;
            int hOff = (le.height - 16);
            xGraph.DrawImage(images.Images[ind], new Rectangle(x, y - hOff, le.width, le.height),new Rectangle(0,0,32,32),GraphicsUnit.Pixel);

            if (Check)
            {
                xGraph.DrawImage(pSelected.Image, new Rectangle(x, y - hOff, le.width, le.height), new Rectangle(0, 0, 12, 12), GraphicsUnit.Pixel);
            }
           
        
        }

        public Bitmap ObjectTypeToImage(LevelEditorObject obj)
        {
            Bitmap tmp = new Bitmap(obj.width, obj.height);
            Graphics xGraph = Graphics.FromImage(tmp);
            Rectangle Src, Dest;
            Dest = new Rectangle(0, 0, obj.width, obj.height);
            Src = new Rectangle(obj.width * obj.ImageIndex, 0, obj.width, obj.height);
            xGraph.DrawImage(ImageGenerator.GetImage(obj.OT), Dest,Src,GraphicsUnit.Pixel);
            xGraph.Dispose();
            return tmp;
        }

        public void LoadEditorObjects()
        {
            list.SmallImageList = images;
            int cnt = 0;

            foreach (LevelEditorObject obj in ObjectGenerator.GetEditorObjects())
            {
                images.Images.Add(ObjectTypeToImage(obj));
                ListViewItem item = new ListViewItem(obj.name);
                item.Name = obj.name;
                item.ImageIndex = cnt;
                obj.ListIndex = cnt++;
                item.Tag = (LevelEditorObject)obj;
                list.Items.Add(item);
            }

            if (list.Items.Count > 0)
            {
                list.Items[0].Focused = true;
                CurrentImageIndex = 0;
            }

        
        }
        

        private void MainForm_Load(object sender, EventArgs e)
        {
            Objects = new List<LevelEditorObject>();

            MainImage = ImageGenerator.GetImage(ObjectType.OT_BG_Block);
            Invalidate();
            LoadEditorObjects();
    
        }

        private void MainForm_Paint(object sender, PaintEventArgs e)
        {


        }

        private void pictureLevel_Paint(object sender, PaintEventArgs e)
        {


            Graphics xGraph;
            xGraph = Graphics.FromImage(pictureLevel.Image);
            xGraph.DrawImage(MainImage, 0, 0, MainImage.Width, MainImage.Height);


            DrawAllObjects();
            
            PutBox(LX, LY, CurrentImageIndex,false);

            xGraph.Dispose();

            


        }

        private void pictureLevel_MouseMove(object sender, MouseEventArgs e)
        {
            int Divx,Divy,Divyi;

            Divx = (e.X / 16);
            Divy = (e.Y / 16);

            LX = Divx*16;
            LY = Divy*16;
            PutBox(LX,LY,CurrentImageIndex,false);

            Divyi = (MainImage.Height / 16) - (Divy+1);

            OX = Divx;
            OY = Divyi;

            pictureLevel.Invalidate();


            labelx.Text = "X = " + Divx.ToString();
            labely.Text = "Y = " + Divyi.ToString();

            timerobject.Enabled = true;
            Seconds = 0;
            objectnamelabel.Text = "";

        }

        private void pictureLevel_MouseEnter(object sender, EventArgs e)
        {
          
            Cursor.Hide();
        }

        private void pictureLevel_MouseLeave(object sender, EventArgs e)
        {
            Cursor.Show();
         
            pictureLevel.Invalidate();
        
        }

        private void list_ItemActivate(object sender, EventArgs e)
        {
            int ind = list.FocusedItem.Index;
            CurrentImageIndex = ind;

           

        }

        private void pictureLevel_MouseDown(object sender, MouseEventArgs e)
        {

            int Divx, Divy, Divyi;

            Divx = (e.X / 16);
            Divy = (e.Y / 16);

            LX = Divx * 16;
            LY = Divy * 16;
            //PutBox(LX, LY, CurrentImageIndex);

            Divyi = (MainImage.Height / 16) - (Divy + 1);

            if (e.Button == MouseButtons.Left)
            {
                LevelEditorObject le = CheckPosition(Divx, Divyi);
                if (le == null)
                {
                    le = new LevelEditorObject((LevelEditorObject)list.Items[CurrentImageIndex].Tag);
                    le.x = Divx;
                    le.y = Divyi;
                    Objects.Add(le);
                }
                else
                {
                    if (le.ParamTypes != null)
                    {
                        FormParams PR = new FormParams(le);
                        PR.ShowDialog();
                        if (PR.Update)
                            le = PR.MainObject;
                        PR.Dispose();
                    }


                }
            }
            if (e.Button == MouseButtons.Right)
            {
                LevelEditorObject le = CheckPosition(Divx, Divyi);
                if (le != null)
                {
                    Objects.Remove(le);
                    pictureLevel.Invalidate();
                }
            
            }


        }

        private void mSave_Click(object sender, EventArgs e)
        {


            MarioEditorXML.Save_To_XML(FileName,Objects);

        }

        private void mOpen_Click(object sender, EventArgs e)
        {
            dOpen.ShowDialog();

            if (dOpen.FileName.Length == 0)
                return;

            FileName = dOpen.FileName;
            Objects = MarioEditorXML.Load_From_XML(dOpen.FileName);
            SetListIndexToObjects();

        }

        public void SetListIndexToObjects()
        {
            foreach (LevelEditorObject le in Objects)
            {
                LevelEditorObject tmp =
                    (LevelEditorObject)(list.Items.Find(le.name, false)[0].Tag);

                le.ListIndex = tmp.ListIndex;
            }
        }

        public LevelEditorObject CheckPosition(int x, int y)
        { 
            LevelEditorObject Res = null;
            for (int i = 0; i < Objects.Count; i++)
                if (x == Objects[i].x && y == Objects[i].y)
                    return Objects[i];

            return Res;
        }

        private void list_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.KeyValue == (int)Keys.Space)
            {
                LevelEditorObject le = CheckPosition(OX,OY);
                if (le != null)
                {
                    le.Checked = !le.Checked;
                }
            }

        }

        private void offsetXSelectedToolStripMenuItem_Click(object sender, EventArgs e)
        {

            string X = Microsoft.VisualBasic.Interaction.InputBox("Enter X Offset", "X Offset", "1",Width/2,Height/2);
            try
            {
                int xVal = System.Convert.ToInt16(X);

                foreach (LevelEditorObject le in Objects)
                    if (le.Checked)
                    {
                        le.x = le.x + xVal;
                        le.Checked = false;
                    }
                pictureLevel.Invalidate();
            }
            catch
            {
                MessageBox.Show("Wrong Parameters...");
            }


        }

        private void offsetYSelectedToolStripMenuItem_Click(object sender, EventArgs e)
        {
            string Y = Microsoft.VisualBasic.Interaction.InputBox("Enter Y Offset", "Y Offset", "1",Width/2,Height/2);
            try
            {
                int yVal = System.Convert.ToInt16(Y);

                foreach (LevelEditorObject le in Objects)
                    if (le.Checked)
                    {
                        le.y = le.y - yVal;
                        le.Checked = false;
                    }
                pictureLevel.Invalidate();
            }
            catch
            {
                MessageBox.Show("Wrong Parameters...");
            }


        
    


        }

        private void mSaveAs_Click(object sender, EventArgs e)
        {

            dSave.ShowDialog();

            if (dSave.FileName.Length == 0)
                return;

            MarioEditorXML.Save_To_XML(dSave.FileName, Objects);

        }

        private void timerobject_Tick(object sender, EventArgs e)
        {
            Seconds++;

            if (Seconds >= 10)
            {
                LevelEditorObject le = CheckPosition(OX, OY);
                if (le != null)
                {
                    objectnamelabel.Text = le.name;
                    timerobject.Enabled = false;
                }
            }
        }


    }



}
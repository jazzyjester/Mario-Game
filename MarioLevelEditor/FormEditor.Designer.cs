namespace MarioLevelEditor
{
    partial class MainForm
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.components = new System.ComponentModel.Container();
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(MainForm));
            this.pictureLevel = new System.Windows.Forms.PictureBox();
            this.pRight = new System.Windows.Forms.Panel();
            this.pLeft = new System.Windows.Forms.Panel();
            this.pSelected = new System.Windows.Forms.PictureBox();
            this.list = new System.Windows.Forms.ListView();
            this.menu = new System.Windows.Forms.MenuStrip();
            this.fileToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.mOpen = new System.Windows.Forms.ToolStripMenuItem();
            this.mSave = new System.Windows.Forms.ToolStripMenuItem();
            this.mSaveAs = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripMenuItem1 = new System.Windows.Forms.ToolStripSeparator();
            this.mExit = new System.Windows.Forms.ToolStripMenuItem();
            this.actiondToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.offsetXSelectedToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.offsetYSelectedToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.aboutToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.images = new System.Windows.Forms.ImageList(this.components);
            this.PTop = new System.Windows.Forms.Panel();
            this.PRest = new System.Windows.Forms.Panel();
            this.dOpen = new System.Windows.Forms.OpenFileDialog();
            this.dSave = new System.Windows.Forms.SaveFileDialog();
            this.pButtom = new System.Windows.Forms.Panel();
            this.status = new System.Windows.Forms.StatusStrip();
            this.labelx = new System.Windows.Forms.ToolStripStatusLabel();
            this.labely = new System.Windows.Forms.ToolStripStatusLabel();
            this.objectnamelabel = new System.Windows.Forms.ToolStripStatusLabel();
            this.timerobject = new System.Windows.Forms.Timer(this.components);
            ((System.ComponentModel.ISupportInitialize)(this.pictureLevel)).BeginInit();
            this.pRight.SuspendLayout();
            this.pLeft.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.pSelected)).BeginInit();
            this.menu.SuspendLayout();
            this.PTop.SuspendLayout();
            this.PRest.SuspendLayout();
            this.pButtom.SuspendLayout();
            this.status.SuspendLayout();
            this.SuspendLayout();
            // 
            // pictureLevel
            // 
            this.pictureLevel.Cursor = System.Windows.Forms.Cursors.Default;
            this.pictureLevel.Image = ((System.Drawing.Image)(resources.GetObject("pictureLevel.Image")));
            this.pictureLevel.Location = new System.Drawing.Point(6, 6);
            this.pictureLevel.Name = "pictureLevel";
            this.pictureLevel.Size = new System.Drawing.Size(1024, 464);
            this.pictureLevel.SizeMode = System.Windows.Forms.PictureBoxSizeMode.AutoSize;
            this.pictureLevel.TabIndex = 0;
            this.pictureLevel.TabStop = false;
            this.pictureLevel.MouseLeave += new System.EventHandler(this.pictureLevel_MouseLeave);
            this.pictureLevel.MouseMove += new System.Windows.Forms.MouseEventHandler(this.pictureLevel_MouseMove);
            this.pictureLevel.MouseDown += new System.Windows.Forms.MouseEventHandler(this.pictureLevel_MouseDown);
            this.pictureLevel.Paint += new System.Windows.Forms.PaintEventHandler(this.pictureLevel_Paint);
            this.pictureLevel.MouseEnter += new System.EventHandler(this.pictureLevel_MouseEnter);
            // 
            // pRight
            // 
            this.pRight.AutoScroll = true;
            this.pRight.BackColor = System.Drawing.Color.Gold;
            this.pRight.Controls.Add(this.pictureLevel);
            this.pRight.Dock = System.Windows.Forms.DockStyle.Fill;
            this.pRight.Location = new System.Drawing.Point(141, 0);
            this.pRight.Name = "pRight";
            this.pRight.Size = new System.Drawing.Size(631, 490);
            this.pRight.TabIndex = 1;
            // 
            // pLeft
            // 
            this.pLeft.BackColor = System.Drawing.SystemColors.ControlDarkDark;
            this.pLeft.Controls.Add(this.pSelected);
            this.pLeft.Controls.Add(this.list);
            this.pLeft.Dock = System.Windows.Forms.DockStyle.Left;
            this.pLeft.Location = new System.Drawing.Point(0, 0);
            this.pLeft.Name = "pLeft";
            this.pLeft.Size = new System.Drawing.Size(141, 490);
            this.pLeft.TabIndex = 2;
            // 
            // pSelected
            // 
            this.pSelected.Image = global::MarioLevelEditor.Properties.Resources.Selected;
            this.pSelected.Location = new System.Drawing.Point(3, 448);
            this.pSelected.Name = "pSelected";
            this.pSelected.Size = new System.Drawing.Size(45, 40);
            this.pSelected.TabIndex = 2;
            this.pSelected.TabStop = false;
            this.pSelected.Visible = false;
            // 
            // list
            // 
            this.list.Dock = System.Windows.Forms.DockStyle.Left;
            this.list.FullRowSelect = true;
            this.list.HeaderStyle = System.Windows.Forms.ColumnHeaderStyle.Nonclickable;
            this.list.Location = new System.Drawing.Point(0, 0);
            this.list.Name = "list";
            this.list.Size = new System.Drawing.Size(138, 490);
            this.list.TabIndex = 1;
            this.list.UseCompatibleStateImageBehavior = false;
            this.list.View = System.Windows.Forms.View.SmallIcon;
            this.list.ItemActivate += new System.EventHandler(this.list_ItemActivate);
            this.list.KeyDown += new System.Windows.Forms.KeyEventHandler(this.list_KeyDown);
            // 
            // menu
            // 
            this.menu.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.fileToolStripMenuItem,
            this.actiondToolStripMenuItem,
            this.aboutToolStripMenuItem});
            this.menu.Location = new System.Drawing.Point(0, 0);
            this.menu.Name = "menu";
            this.menu.RenderMode = System.Windows.Forms.ToolStripRenderMode.Professional;
            this.menu.Size = new System.Drawing.Size(772, 24);
            this.menu.TabIndex = 2;
            this.menu.Text = "menuStrip1";
            // 
            // fileToolStripMenuItem
            // 
            this.fileToolStripMenuItem.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.mOpen,
            this.mSave,
            this.mSaveAs,
            this.toolStripMenuItem1,
            this.mExit});
            this.fileToolStripMenuItem.Name = "fileToolStripMenuItem";
            this.fileToolStripMenuItem.Size = new System.Drawing.Size(35, 20);
            this.fileToolStripMenuItem.Text = "File";
            // 
            // mOpen
            // 
            this.mOpen.Name = "mOpen";
            this.mOpen.Size = new System.Drawing.Size(124, 22);
            this.mOpen.Text = "Open...";
            this.mOpen.Click += new System.EventHandler(this.mOpen_Click);
            // 
            // mSave
            // 
            this.mSave.Name = "mSave";
            this.mSave.Size = new System.Drawing.Size(124, 22);
            this.mSave.Text = "Save";
            this.mSave.Click += new System.EventHandler(this.mSave_Click);
            // 
            // mSaveAs
            // 
            this.mSaveAs.Name = "mSaveAs";
            this.mSaveAs.Size = new System.Drawing.Size(124, 22);
            this.mSaveAs.Text = "Save as...";
            this.mSaveAs.Click += new System.EventHandler(this.mSaveAs_Click);
            // 
            // toolStripMenuItem1
            // 
            this.toolStripMenuItem1.Name = "toolStripMenuItem1";
            this.toolStripMenuItem1.Size = new System.Drawing.Size(121, 6);
            // 
            // mExit
            // 
            this.mExit.Name = "mExit";
            this.mExit.Size = new System.Drawing.Size(124, 22);
            this.mExit.Text = "Exit";
            // 
            // actiondToolStripMenuItem
            // 
            this.actiondToolStripMenuItem.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.offsetXSelectedToolStripMenuItem,
            this.offsetYSelectedToolStripMenuItem});
            this.actiondToolStripMenuItem.Name = "actiondToolStripMenuItem";
            this.actiondToolStripMenuItem.Size = new System.Drawing.Size(54, 20);
            this.actiondToolStripMenuItem.Text = "Actions";
            // 
            // offsetXSelectedToolStripMenuItem
            // 
            this.offsetXSelectedToolStripMenuItem.Name = "offsetXSelectedToolStripMenuItem";
            this.offsetXSelectedToolStripMenuItem.Size = new System.Drawing.Size(155, 22);
            this.offsetXSelectedToolStripMenuItem.Text = "OffsetX Selected";
            this.offsetXSelectedToolStripMenuItem.Click += new System.EventHandler(this.offsetXSelectedToolStripMenuItem_Click);
            // 
            // offsetYSelectedToolStripMenuItem
            // 
            this.offsetYSelectedToolStripMenuItem.Name = "offsetYSelectedToolStripMenuItem";
            this.offsetYSelectedToolStripMenuItem.Size = new System.Drawing.Size(155, 22);
            this.offsetYSelectedToolStripMenuItem.Text = "OffsetY Selected";
            this.offsetYSelectedToolStripMenuItem.Click += new System.EventHandler(this.offsetYSelectedToolStripMenuItem_Click);
            // 
            // aboutToolStripMenuItem
            // 
            this.aboutToolStripMenuItem.Name = "aboutToolStripMenuItem";
            this.aboutToolStripMenuItem.Size = new System.Drawing.Size(48, 20);
            this.aboutToolStripMenuItem.Text = "About";
            // 
            // images
            // 
            this.images.ColorDepth = System.Windows.Forms.ColorDepth.Depth24Bit;
            this.images.ImageSize = new System.Drawing.Size(32, 32);
            this.images.TransparentColor = System.Drawing.Color.Transparent;
            // 
            // PTop
            // 
            this.PTop.BackColor = System.Drawing.Color.Red;
            this.PTop.Controls.Add(this.menu);
            this.PTop.Dock = System.Windows.Forms.DockStyle.Top;
            this.PTop.Location = new System.Drawing.Point(0, 0);
            this.PTop.Name = "PTop";
            this.PTop.Size = new System.Drawing.Size(772, 24);
            this.PTop.TabIndex = 2;
            // 
            // PRest
            // 
            this.PRest.BackColor = System.Drawing.Color.Olive;
            this.PRest.Controls.Add(this.pRight);
            this.PRest.Controls.Add(this.pLeft);
            this.PRest.Dock = System.Windows.Forms.DockStyle.Fill;
            this.PRest.Location = new System.Drawing.Point(0, 24);
            this.PRest.Name = "PRest";
            this.PRest.Size = new System.Drawing.Size(772, 490);
            this.PRest.TabIndex = 3;
            // 
            // dOpen
            // 
            this.dOpen.Filter = "Mario Levels | *.xml";
            // 
            // dSave
            // 
            this.dSave.Filter = "Mario Levels | *.xml";
            // 
            // pButtom
            // 
            this.pButtom.BackColor = System.Drawing.Color.Thistle;
            this.pButtom.Controls.Add(this.status);
            this.pButtom.Dock = System.Windows.Forms.DockStyle.Bottom;
            this.pButtom.Location = new System.Drawing.Point(0, 514);
            this.pButtom.Name = "pButtom";
            this.pButtom.Size = new System.Drawing.Size(772, 25);
            this.pButtom.TabIndex = 1;
            // 
            // status
            // 
            this.status.Dock = System.Windows.Forms.DockStyle.Fill;
            this.status.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.labelx,
            this.labely,
            this.objectnamelabel});
            this.status.Location = new System.Drawing.Point(0, 0);
            this.status.Name = "status";
            this.status.Size = new System.Drawing.Size(772, 25);
            this.status.TabIndex = 0;
            this.status.Text = "statusStrip1";
            // 
            // labelx
            // 
            this.labelx.AutoSize = false;
            this.labelx.BackColor = System.Drawing.SystemColors.ButtonFace;
            this.labelx.Name = "labelx";
            this.labelx.Size = new System.Drawing.Size(50, 20);
            this.labelx.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // labely
            // 
            this.labely.AutoSize = false;
            this.labely.BackColor = System.Drawing.SystemColors.ButtonFace;
            this.labely.Name = "labely";
            this.labely.Size = new System.Drawing.Size(50, 20);
            this.labely.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // objectnamelabel
            // 
            this.objectnamelabel.AutoSize = false;
            this.objectnamelabel.BackColor = System.Drawing.SystemColors.ButtonFace;
            this.objectnamelabel.Font = new System.Drawing.Font("Tahoma", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.objectnamelabel.Name = "objectnamelabel";
            this.objectnamelabel.Size = new System.Drawing.Size(100, 20);
            this.objectnamelabel.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // timerobject
            // 
            this.timerobject.Enabled = true;
            this.timerobject.Tick += new System.EventHandler(this.timerobject_Tick);
            // 
            // MainForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(772, 539);
            this.Controls.Add(this.PRest);
            this.Controls.Add(this.PTop);
            this.Controls.Add(this.pButtom);
            this.DoubleBuffered = true;
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.Name = "MainForm";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "Level Editor";
            this.Load += new System.EventHandler(this.MainForm_Load);
            this.Paint += new System.Windows.Forms.PaintEventHandler(this.MainForm_Paint);
            ((System.ComponentModel.ISupportInitialize)(this.pictureLevel)).EndInit();
            this.pRight.ResumeLayout(false);
            this.pRight.PerformLayout();
            this.pLeft.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.pSelected)).EndInit();
            this.menu.ResumeLayout(false);
            this.menu.PerformLayout();
            this.PTop.ResumeLayout(false);
            this.PTop.PerformLayout();
            this.PRest.ResumeLayout(false);
            this.pButtom.ResumeLayout(false);
            this.pButtom.PerformLayout();
            this.status.ResumeLayout(false);
            this.status.PerformLayout();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.PictureBox pictureLevel;
        private System.Windows.Forms.Panel pRight;
        private System.Windows.Forms.Panel pLeft;
        private System.Windows.Forms.ImageList images;
        private System.Windows.Forms.ListView list;
        private System.Windows.Forms.MenuStrip menu;
        private System.Windows.Forms.ToolStripMenuItem fileToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem mOpen;
        private System.Windows.Forms.ToolStripMenuItem mSave;
        private System.Windows.Forms.ToolStripSeparator toolStripMenuItem1;
        private System.Windows.Forms.ToolStripMenuItem mExit;
        private System.Windows.Forms.ToolStripMenuItem aboutToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem actiondToolStripMenuItem;
        private System.Windows.Forms.Panel PTop;
        private System.Windows.Forms.Panel PRest;
        private System.Windows.Forms.PictureBox pSelected;
        private System.Windows.Forms.ToolStripMenuItem offsetXSelectedToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem offsetYSelectedToolStripMenuItem;
        private System.Windows.Forms.OpenFileDialog dOpen;
        private System.Windows.Forms.SaveFileDialog dSave;
        private System.Windows.Forms.ToolStripMenuItem mSaveAs;
        private System.Windows.Forms.Panel pButtom;
        private System.Windows.Forms.StatusStrip status;
        private System.Windows.Forms.ToolStripStatusLabel labelx;
        private System.Windows.Forms.ToolStripStatusLabel objectnamelabel;
        private System.Windows.Forms.ToolStripStatusLabel labely;
        private System.Windows.Forms.Timer timerobject;
    }
}


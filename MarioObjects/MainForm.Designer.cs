namespace MarioObjects
{
    partial class frmMain
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

                if (Media.SOUND_ENABLE)
                    Media.Instance.Destroy();

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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(frmMain));
            this.timerPaint = new System.Windows.Forms.Timer(this.components);
            this.timerBack = new System.Windows.Forms.Timer(this.components);
            this.pMain = new System.Windows.Forms.PictureBox();
            this.pic_Coin = new System.Windows.Forms.PictureBox();
            this.lbl_numCoins = new System.Windows.Forms.Label();
            this.flowPanel_gameInfo = new System.Windows.Forms.FlowLayoutPanel();
            this.pic_Life = new System.Windows.Forms.PictureBox();
            this.lbl_numLives = new System.Windows.Forms.Label();
            this.pic_Level = new System.Windows.Forms.PictureBox();
            this.lbl_Level = new System.Windows.Forms.Label();
            ((System.ComponentModel.ISupportInitialize)(this.pMain)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.pic_Coin)).BeginInit();
            this.flowPanel_gameInfo.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.pic_Life)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.pic_Level)).BeginInit();
            this.SuspendLayout();
            // 
            // timerPaint
            // 
            this.timerPaint.Enabled = true;
            this.timerPaint.Interval = 30;
            this.timerPaint.Tick += new System.EventHandler(this.timerPaint_Tick);
            // 
            // timerBack
            // 
            this.timerBack.Interval = 500;
            this.timerBack.Tick += new System.EventHandler(this.timerBack_Tick);
            // 
            // pMain
            // 
            this.pMain.Dock = System.Windows.Forms.DockStyle.Fill;
            this.pMain.Location = new System.Drawing.Point(0, 25);
            this.pMain.Name = "pMain";
            this.pMain.Size = new System.Drawing.Size(486, 310);
            this.pMain.TabIndex = 0;
            this.pMain.TabStop = false;
            this.pMain.Paint += new System.Windows.Forms.PaintEventHandler(this.pMain_Paint);
            // 
            // pic_Coin
            // 
            this.pic_Coin.Anchor = System.Windows.Forms.AnchorStyles.Left;
            this.pic_Coin.Image = ((System.Drawing.Image)(resources.GetObject("pic_Coin.Image")));
            this.pic_Coin.Location = new System.Drawing.Point(48, 3);
            this.pic_Coin.Name = "pic_Coin";
            this.pic_Coin.Size = new System.Drawing.Size(17, 21);
            this.pic_Coin.TabIndex = 0;
            this.pic_Coin.TabStop = false;
            // 
            // lbl_numCoins
            // 
            this.lbl_numCoins.Anchor = System.Windows.Forms.AnchorStyles.Left;
            this.lbl_numCoins.AutoSize = true;
            this.lbl_numCoins.Location = new System.Drawing.Point(71, 7);
            this.lbl_numCoins.Name = "lbl_numCoins";
            this.lbl_numCoins.Size = new System.Drawing.Size(13, 13);
            this.lbl_numCoins.TabIndex = 1;
            this.lbl_numCoins.Text = "0";
            // 
            // flowPanel_gameInfo
            // 
            this.flowPanel_gameInfo.Controls.Add(this.pic_Level);
            this.flowPanel_gameInfo.Controls.Add(this.lbl_Level);
            this.flowPanel_gameInfo.Controls.Add(this.pic_Coin);
            this.flowPanel_gameInfo.Controls.Add(this.lbl_numCoins);
            this.flowPanel_gameInfo.Controls.Add(this.pic_Life);
            this.flowPanel_gameInfo.Controls.Add(this.lbl_numLives);
            this.flowPanel_gameInfo.Dock = System.Windows.Forms.DockStyle.Top;
            this.flowPanel_gameInfo.Location = new System.Drawing.Point(0, 0);
            this.flowPanel_gameInfo.Name = "flowPanel_gameInfo";
            this.flowPanel_gameInfo.Size = new System.Drawing.Size(486, 25);
            this.flowPanel_gameInfo.TabIndex = 2;
            // 
            // pic_Life
            // 
            this.pic_Life.Anchor = System.Windows.Forms.AnchorStyles.Left;
            this.pic_Life.Image = ((System.Drawing.Image)(resources.GetObject("pic_Life.Image")));
            this.pic_Life.Location = new System.Drawing.Point(90, 3);
            this.pic_Life.Name = "pic_Life";
            this.pic_Life.Size = new System.Drawing.Size(17, 21);
            this.pic_Life.TabIndex = 2;
            this.pic_Life.TabStop = false;
            // 
            // lbl_numLives
            // 
            this.lbl_numLives.Anchor = System.Windows.Forms.AnchorStyles.Left;
            this.lbl_numLives.AutoSize = true;
            this.lbl_numLives.Location = new System.Drawing.Point(113, 7);
            this.lbl_numLives.Name = "lbl_numLives";
            this.lbl_numLives.Size = new System.Drawing.Size(13, 13);
            this.lbl_numLives.TabIndex = 3;
            this.lbl_numLives.Text = "0";
            // 
            // pic_Level
            // 
            this.pic_Level.Anchor = System.Windows.Forms.AnchorStyles.Left;
            this.pic_Level.Image = ((System.Drawing.Image)(resources.GetObject("pic_Level.Image")));
            this.pic_Level.Location = new System.Drawing.Point(3, 3);
            this.pic_Level.Name = "pic_Level";
            this.pic_Level.Size = new System.Drawing.Size(17, 21);
            this.pic_Level.TabIndex = 4;
            this.pic_Level.TabStop = false;
            // 
            // lbl_Level
            // 
            this.lbl_Level.Anchor = System.Windows.Forms.AnchorStyles.Left;
            this.lbl_Level.AutoSize = true;
            this.lbl_Level.Location = new System.Drawing.Point(26, 7);
            this.lbl_Level.Name = "lbl_Level";
            this.lbl_Level.Size = new System.Drawing.Size(16, 13);
            this.lbl_Level.TabIndex = 5;
            this.lbl_Level.Text = "---";
            // 
            // frmMain
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(486, 335);
            this.Controls.Add(this.pMain);
            this.Controls.Add(this.flowPanel_gameInfo);
            this.DoubleBuffered = true;
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.Name = "frmMain";
            this.StartPosition = System.Windows.Forms.FormStartPosition.Manual;
            this.Text = "Mario By Jazzy";
            this.FormClosed += new System.Windows.Forms.FormClosedEventHandler(this.frmMain_FormClosed);
            this.Load += new System.EventHandler(this.MainForm_Load);
            this.KeyDown += new System.Windows.Forms.KeyEventHandler(this.MainForm_KeyDown);
            this.KeyUp += new System.Windows.Forms.KeyEventHandler(this.frmMain_KeyUp);
            this.MouseDown += new System.Windows.Forms.MouseEventHandler(this.frmMain_MouseDown);
            ((System.ComponentModel.ISupportInitialize)(this.pMain)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.pic_Coin)).EndInit();
            this.flowPanel_gameInfo.ResumeLayout(false);
            this.flowPanel_gameInfo.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.pic_Life)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.pic_Level)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Timer timerBack;
        private System.Windows.Forms.Timer timerPaint;
        private System.Windows.Forms.PictureBox pMain;
        private System.Windows.Forms.PictureBox pic_Coin;
        private System.Windows.Forms.Label lbl_numCoins;
        private System.Windows.Forms.FlowLayoutPanel flowPanel_gameInfo;
        private System.Windows.Forms.PictureBox pic_Life;
        private System.Windows.Forms.Label lbl_numLives;
        private System.Windows.Forms.PictureBox pic_Level;
        private System.Windows.Forms.Label lbl_Level;
    }
}


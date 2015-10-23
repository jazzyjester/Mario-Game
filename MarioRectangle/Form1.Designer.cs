namespace MarioRectangle
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
            this.tLeft = new System.Windows.Forms.TextBox();
            this.tTop = new System.Windows.Forms.TextBox();
            this.tWidth = new System.Windows.Forms.TextBox();
            this.tHeight = new System.Windows.Forms.TextBox();
            this.bDraw = new System.Windows.Forms.Button();
            this.bClear = new System.Windows.Forms.Button();
            this.SuspendLayout();
            // 
            // tLeft
            // 
            this.tLeft.Location = new System.Drawing.Point(26, 12);
            this.tLeft.Name = "tLeft";
            this.tLeft.Size = new System.Drawing.Size(100, 20);
            this.tLeft.TabIndex = 0;
            // 
            // tTop
            // 
            this.tTop.Location = new System.Drawing.Point(132, 12);
            this.tTop.Name = "tTop";
            this.tTop.Size = new System.Drawing.Size(100, 20);
            this.tTop.TabIndex = 1;
            // 
            // tWidth
            // 
            this.tWidth.Location = new System.Drawing.Point(238, 12);
            this.tWidth.Name = "tWidth";
            this.tWidth.Size = new System.Drawing.Size(100, 20);
            this.tWidth.TabIndex = 2;
            // 
            // tHeight
            // 
            this.tHeight.Location = new System.Drawing.Point(344, 12);
            this.tHeight.Name = "tHeight";
            this.tHeight.Size = new System.Drawing.Size(100, 20);
            this.tHeight.TabIndex = 3;
            // 
            // bDraw
            // 
            this.bDraw.Location = new System.Drawing.Point(474, 12);
            this.bDraw.Name = "bDraw";
            this.bDraw.Size = new System.Drawing.Size(81, 64);
            this.bDraw.TabIndex = 4;
            this.bDraw.Text = "Draw";
            this.bDraw.UseVisualStyleBackColor = true;
            this.bDraw.Click += new System.EventHandler(this.bDraw_Click);
            // 
            // bClear
            // 
            this.bClear.Location = new System.Drawing.Point(561, 12);
            this.bClear.Name = "bClear";
            this.bClear.Size = new System.Drawing.Size(81, 64);
            this.bClear.TabIndex = 5;
            this.bClear.Text = "Clear";
            this.bClear.UseVisualStyleBackColor = true;
            this.bClear.Click += new System.EventHandler(this.bClear_Click);
            // 
            // MainForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(692, 466);
            this.Controls.Add(this.bClear);
            this.Controls.Add(this.bDraw);
            this.Controls.Add(this.tHeight);
            this.Controls.Add(this.tWidth);
            this.Controls.Add(this.tTop);
            this.Controls.Add(this.tLeft);
            this.Name = "MainForm";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "Form1";
            this.Load += new System.EventHandler(this.MainForm_Load);
            this.Paint += new System.Windows.Forms.PaintEventHandler(this.MainForm_Paint);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.TextBox tLeft;
        private System.Windows.Forms.TextBox tTop;
        private System.Windows.Forms.TextBox tWidth;
        private System.Windows.Forms.TextBox tHeight;
        private System.Windows.Forms.Button bDraw;
        private System.Windows.Forms.Button bClear;
    }
}


namespace MarioLevelEditor
{
    partial class FormParams
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
            this.lName = new System.Windows.Forms.Label();
            this.cInt1 = new System.Windows.Forms.ComboBox();
            this.cInt2 = new System.Windows.Forms.ComboBox();
            this.cInt3 = new System.Windows.Forms.ComboBox();
            this.cBool1 = new System.Windows.Forms.ComboBox();
            this.cBool2 = new System.Windows.Forms.ComboBox();
            this.cBool3 = new System.Windows.Forms.ComboBox();
            this.bClose = new System.Windows.Forms.Button();
            this.bSave = new System.Windows.Forms.Button();
            this.SuspendLayout();
            // 
            // lName
            // 
            this.lName.Dock = System.Windows.Forms.DockStyle.Top;
            this.lName.Font = new System.Drawing.Font("Arial", 9.75F, ((System.Drawing.FontStyle)((System.Drawing.FontStyle.Bold | System.Drawing.FontStyle.Underline))), System.Drawing.GraphicsUnit.Point, ((byte)(177)));
            this.lName.Location = new System.Drawing.Point(0, 0);
            this.lName.Name = "lName";
            this.lName.Size = new System.Drawing.Size(350, 21);
            this.lName.TabIndex = 0;
            this.lName.Text = "label1";
            this.lName.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // cInt1
            // 
            this.cInt1.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.cInt1.FormattingEnabled = true;
            this.cInt1.Location = new System.Drawing.Point(12, 35);
            this.cInt1.Name = "cInt1";
            this.cInt1.Size = new System.Drawing.Size(139, 21);
            this.cInt1.TabIndex = 1;
            this.cInt1.Visible = false;
            // 
            // cInt2
            // 
            this.cInt2.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.cInt2.FormattingEnabled = true;
            this.cInt2.Location = new System.Drawing.Point(12, 73);
            this.cInt2.Name = "cInt2";
            this.cInt2.Size = new System.Drawing.Size(139, 21);
            this.cInt2.TabIndex = 2;
            this.cInt2.Visible = false;
            // 
            // cInt3
            // 
            this.cInt3.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.cInt3.FormattingEnabled = true;
            this.cInt3.Location = new System.Drawing.Point(12, 110);
            this.cInt3.Name = "cInt3";
            this.cInt3.Size = new System.Drawing.Size(139, 21);
            this.cInt3.TabIndex = 3;
            this.cInt3.Visible = false;
            // 
            // cBool1
            // 
            this.cBool1.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.cBool1.FormattingEnabled = true;
            this.cBool1.Location = new System.Drawing.Point(184, 35);
            this.cBool1.Name = "cBool1";
            this.cBool1.Size = new System.Drawing.Size(139, 21);
            this.cBool1.TabIndex = 4;
            this.cBool1.Visible = false;
            // 
            // cBool2
            // 
            this.cBool2.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.cBool2.FormattingEnabled = true;
            this.cBool2.Location = new System.Drawing.Point(184, 73);
            this.cBool2.Name = "cBool2";
            this.cBool2.Size = new System.Drawing.Size(139, 21);
            this.cBool2.TabIndex = 5;
            this.cBool2.Visible = false;
            // 
            // cBool3
            // 
            this.cBool3.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.cBool3.FormattingEnabled = true;
            this.cBool3.Location = new System.Drawing.Point(184, 110);
            this.cBool3.Name = "cBool3";
            this.cBool3.Size = new System.Drawing.Size(139, 21);
            this.cBool3.TabIndex = 6;
            this.cBool3.Visible = false;
            // 
            // bClose
            // 
            this.bClose.Location = new System.Drawing.Point(167, 148);
            this.bClose.Name = "bClose";
            this.bClose.Size = new System.Drawing.Size(86, 30);
            this.bClose.TabIndex = 7;
            this.bClose.Text = "Close";
            this.bClose.UseVisualStyleBackColor = true;
            this.bClose.Click += new System.EventHandler(this.bClose_Click);
            // 
            // bSave
            // 
            this.bSave.Location = new System.Drawing.Point(75, 148);
            this.bSave.Name = "bSave";
            this.bSave.Size = new System.Drawing.Size(86, 30);
            this.bSave.TabIndex = 8;
            this.bSave.Text = "Save";
            this.bSave.UseVisualStyleBackColor = true;
            this.bSave.Click += new System.EventHandler(this.bSave_Click);
            // 
            // FormParams
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(350, 178);
            this.Controls.Add(this.bSave);
            this.Controls.Add(this.bClose);
            this.Controls.Add(this.cBool3);
            this.Controls.Add(this.cBool2);
            this.Controls.Add(this.cBool1);
            this.Controls.Add(this.cInt3);
            this.Controls.Add(this.cInt2);
            this.Controls.Add(this.cInt1);
            this.Controls.Add(this.lName);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedSingle;
            this.MaximizeBox = false;
            this.Name = "FormParams";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "Object Properties";
            this.Load += new System.EventHandler(this.FormParams_Load);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Label lName;
        private System.Windows.Forms.ComboBox cInt1;
        private System.Windows.Forms.ComboBox cInt2;
        private System.Windows.Forms.ComboBox cInt3;
        private System.Windows.Forms.ComboBox cBool1;
        private System.Windows.Forms.ComboBox cBool2;
        private System.Windows.Forms.ComboBox cBool3;
        private System.Windows.Forms.Button bClose;
        private System.Windows.Forms.Button bSave;
    }
}
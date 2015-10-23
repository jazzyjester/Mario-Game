using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;

using MarioObjects;
namespace MarioLevelEditor
{
    public partial class FormParams : Form
    {
        public LevelEditorObject MainObject = null;
        int[][] intValues = null;
        public Boolean Update = false;

        public FormParams(LevelEditorObject le)
        {
            InitializeComponent();

            MainObject = le;

        }

        private void FormParams_Load(object sender, EventArgs e)
        {
            LoadParams();
        }

        public void LoadParams()
        {
            object[] intS = (object[])MainObject.ParamTypes[0];
            int boolS = (int)MainObject.ParamTypes[1];

            intValues = new int [intS.Length][];
            for (int i = 0; i < intS.Length; i++)
            { 
                ComboBox C = (ComboBox)Controls.Find("cInt" +(i+1),false)[0];
                C.Visible = true;
                object[] values = (object[])intS[i];
                intValues[i] = new int[values.Length/2];
                for (int j = 0; j < values.Length/2; j++)
                {
                    C.Items.Add(values[j*2]);
                    intValues[i][j] = (int)values[j * 2 + 1];

                }

            }

            for (int i = 0; i < boolS; i++)
            {
                ComboBox C = (ComboBox)Controls.Find("cBool" + (i + 1), false)[0];
                C.Visible = true;
                C.Items.Add("True");
                C.Items.Add("False");
            }
            //--------------------------------------------------------

            for (int i = 0; i < 3; i++)
            {
                ComboBox C = (ComboBox)Controls.Find("cInt" + (i + 1), false)[0];
                if (C.Visible)
                    UpdateControlComboInt(C, MainObject.ParamInt[i], i);
                
                C = (ComboBox)Controls.Find("cBool" + (i + 1), false)[0];
                if (C.Visible)
                    UpdateControlComboBool(C, MainObject.Parambool[i]);
                    

            }

            lName.Text = MainObject.name + ": X = " + MainObject.x + " , Y = " + MainObject.y + ".";

        }

        public void UpdateControlComboBool(ComboBox C, bool value)
        {
            if (value)
                C.SelectedIndex = 0;
            else
                C.SelectedIndex = 1;
        }
        public void UpdateControlComboInt(ComboBox C, int value,int paramnum)
        {
            for(int i=0;i<intValues[paramnum].Length;i++)
                if (intValues[paramnum][i] == value)
                {
                    C.SelectedIndex = i;
                    return;
                }
            C.SelectedIndex = 0;
        }
        private void bClose_Click(object sender, EventArgs e)
        {
            Close();
        }

        private void bSave_Click(object sender, EventArgs e)
        {

            for (int i = 0; i < 3; i++)
            {
                ComboBox C = (ComboBox)Controls.Find("cInt" + (i + 1), false)[0];
                if (C.Visible)
                    MainObject.ParamInt[i] = intValues[i][C.SelectedIndex];

                C = (ComboBox)Controls.Find("cBool" + (i + 1), false)[0];
                if (C.Visible)
                {
                    if (C.SelectedIndex == 0)
                        MainObject.Parambool[i] = true;
                    else
                        MainObject.Parambool[i] = false;

                }

            }
            
            Update = true;
            Close();
        }
    }
}
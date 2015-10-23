using System;
using System.Collections.Generic;
using System.Text;
using MarioObjects.Objects.BaseObjects;

namespace MarioObjects.Objects.Utils
{
    public class LevelGenerator
    {
        public enum LevelEvent { LE_Check_Collision, LE_PaintForm };
        public int Width;
        public int Height;
        public Level level = null;
        public frmMain MyForm = null;

        private static LevelGenerator instance;

        public static LevelGenerator Instance
        {
            get
            {
                if (instance == null)
                    instance = new LevelGenerator();
                return instance;
            }
        }

        public void SetMainForm(frmMain tmp)
        {
            MyForm = tmp;
        }

        public static void Raise_Event(LevelEvent le)
        {
            switch (le)
            {
                case LevelEvent.LE_Check_Collision:
                    {
                        CurrentLevel.CheckLevelCollisions(null, null);
                    } break;
                case LevelEvent.LE_PaintForm:
                    {
                        if (instance.MyForm != null)
                            instance.MyForm.Invalidate();
                    } break;
            }
        }

        public static Level CurrentLevel
        {
            get
            {
                return Instance.level;
            }
            set
            {
                Instance.level = value;
            }
        }

        public LevelGenerator()
        {
            Width = 800;
            Height = 464;

        }
        public static int LevelWidth
        {
            get
            {
                return Instance.Width;
            }
        }
        public static int LevelHeight
        {
            get
            {
                return Instance.Height;
            }
        }

    }

}

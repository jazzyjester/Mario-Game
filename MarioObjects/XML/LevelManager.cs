using System;
using System.Collections.Generic;
using System.Text;
using System.Windows.Forms;
using System.IO;
using System.Xml.Serialization;

using MarioObjects.Objects.BaseObjects;

namespace MarioObjects
{
    public enum LevelManagerLoadTypes
    {
        STARTUP,    // Load the first level on startup
        FIRST,      // Load the first level when you are out of lives 
        NEXT,       // Load the next level. If you reached the highest level the level is reloaded.
        RELOAD      // Load the current level again. This is done when mario dies, so the life count is decremented.
    };

    public class LevelManager
    {
        #region Singleton

        private static LevelManager instance;
        public static LevelManager Instance
        {
            get
            {
                if(instance == null) { instance = new LevelManager(); }
                return instance;
            }
        }

        #endregion
        
        public int CurrentLevelIndex { get; set; }
        public int MarioLives { get; set; }
        public List<string> LevelFilePaths { get; set; }

        public string CurrentLevelName
        {
            get { return LevelFilePaths[CurrentLevelIndex]; }
        }

        public LevelManager()
        {
            CurrentLevelIndex = 0;
            MarioLives = 5;
            LevelFilePaths = new List<string>();
        }

        public void InitLevelManager(string filepath)
        {
            StreamReader streamReader = new StreamReader(filepath);
            XmlSerializer xmlSerializer = new XmlSerializer(typeof(LevelManager));
            LevelManager tmpManager = (LevelManager)xmlSerializer.Deserialize(streamReader);
            this.CurrentLevelIndex = tmpManager.CurrentLevelIndex;
            this.MarioLives = tmpManager.MarioLives;
            this.LevelFilePaths = tmpManager.LevelFilePaths;
            streamReader.Close();
        }

        public void SaveLevelManager(string filepath)
        {
            StreamWriter streamWriter = new StreamWriter(filepath);
            XmlSerializer xmlSerializer = new XmlSerializer(typeof(LevelManager));
            xmlSerializer.Serialize(streamWriter, this);
            streamWriter.Close();
        }

        public Level LoadLevel(LevelManagerLoadTypes levelLoadType)
        {
            if (LevelFilePaths.Count == 0)
            {
                MessageBox.Show("No levels are configured in the levels file.", "No levels configured.", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return null;
            }

            switch(levelLoadType)
            {
                case LevelManagerLoadTypes.FIRST:
                {
                    CurrentLevelIndex = 0;
                    break;
                }
                case LevelManagerLoadTypes.NEXT:
                {
                    CurrentLevelIndex++;
                    if (CurrentLevelIndex < 0) { CurrentLevelIndex = 0; }
                    if (CurrentLevelIndex >= LevelFilePaths.Count)
                    {
                        CurrentLevelIndex = LevelFilePaths.Count - 1;
                        MessageBox.Show("The highest level was reached.", "Highest level reached.", MessageBoxButtons.OK, MessageBoxIcon.Information);
                    }
                    break;
                }
                case LevelManagerLoadTypes.STARTUP:
                case LevelManagerLoadTypes.RELOAD:
                {
                    if (CurrentLevelIndex < 0) { CurrentLevelIndex = 0; }
                    if (CurrentLevelIndex >= LevelFilePaths.Count) { CurrentLevelIndex = LevelFilePaths.Count - 1; }
                    break;
                }
            }

            if(levelLoadType == LevelManagerLoadTypes.RELOAD)
            {
                MarioLives--;
                if(MarioLives == 0)
                {
                    MessageBox.Show("Mario is out of lives. You start from the first level again.", "Out of lives.", MessageBoxButtons.OK, MessageBoxIcon.Information);
                    CurrentLevelIndex = 0;
                    MarioLives = 5;
                }
            }

            return MarioEditorXML.Load_Level_From_XML(LevelFilePaths[CurrentLevelIndex]);
        }

    }
}

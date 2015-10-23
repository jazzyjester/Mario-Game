using System;
using System.Collections.Generic;
using System.Text;
using System.Windows.Forms;
using System.IO;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Runtime.InteropServices;
using System.Resources;


namespace MarioObjects
{
    class Media
    {
        public static Boolean SOUND_ENABLE = false;
        public enum SoundType { ST_level1, ST_level2, ST_Brick, ST_Coin, ST_Jump, ST_Block, ST_Stomp, ST_Mush, ST_FireBall };

        private FMOD.System soundsystem = null;
        
        private FMOD.Sound s_level1 = null;
        private FMOD.Sound s_level2 = null;
        private FMOD.Sound s_brick = null;
        private FMOD.Sound s_coin = null;
        private FMOD.Sound s_jump = null;
        private FMOD.Sound s_block = null;
        private FMOD.Sound s_stomp = null;
        private FMOD.Sound s_mush = null;
        private FMOD.Sound s_fireball = null;
        
        private FMOD.Channel channel = null;

        public static Media instance=null;

        public void Destroy()
        {

            FMOD.RESULT result;

            result = s_level1.release();
            ERRCHECK(result);
            result = s_level2.release();
            ERRCHECK(result);
            result = s_jump.release();
            ERRCHECK(result);
            result = s_coin.release();
            ERRCHECK(result);
            result = s_brick.release();
            ERRCHECK(result);
            result = s_block.release();
            ERRCHECK(result);
            result = s_stomp.release();
            ERRCHECK(result);
            result = s_mush.release();
            ERRCHECK(result);
            result = s_fireball.release();
            ERRCHECK(result);

            result = soundsystem.close();
            ERRCHECK(result);
            result = soundsystem.release();
            ERRCHECK(result);


        

        }
        public static Media Instance 
        {
            get 
            {
                if (instance == null)
                    instance = new Media();
                return instance;
            }
        }

        
        public void UpdateSound(string name,ref FMOD.Sound s,Boolean Loop)
        {
            FMOD.RESULT result;
            string strNameSpace =
            System.Reflection.Assembly.GetExecutingAssembly().GetName().Name.ToString();

            Stream str = System.Reflection.Assembly.GetExecutingAssembly().GetManifestResourceStream(strNameSpace + ".Sounds." + name);

            //Block = new Bitmap(str);
            byte[] Arr = new byte[str.Length];
            str.Read(Arr, 0, (int)str.Length);
            FMOD.CREATESOUNDEXINFO inf = new FMOD.CREATESOUNDEXINFO();
            inf.cbsize = Marshal.SizeOf(inf);
            inf.length = (uint)str.Length;

            result = soundsystem.createSound(Arr, FMOD.MODE.SOFTWARE | FMOD.MODE.OPENMEMORY | FMOD.MODE._3D, ref inf, ref s);
            ERRCHECK(result);

            if (!Loop)
                s.setMode(FMOD.MODE.LOOP_OFF);
            else
                s.setMode(FMOD.MODE.LOOP_NORMAL);

            ERRCHECK(result);


        }

        public void LoadFromResource()
        {
            UpdateSound("level1.mp3", ref s_level1,true);
            UpdateSound("level2.mp3", ref s_level2, true);
            UpdateSound("brick.wav", ref s_brick, false);
            UpdateSound("coin.wav", ref s_coin, false);
            UpdateSound("jump.wav", ref s_jump, false);
            UpdateSound("block.wav", ref s_block, false);
            UpdateSound("stomp.wav", ref s_stomp, false);
            UpdateSound("mush.wav", ref s_mush, false);
            UpdateSound("fireball.wav", ref s_fireball, false);
        
        }

        public FMOD.Sound GetSound(SoundType type)
        {
            switch (type)
            {
                case SoundType.ST_level1:
                    { return s_level1; }
                case SoundType.ST_level2:
                    { return s_level2; }
                case SoundType.ST_Brick:
                    { return s_brick; } 
                case SoundType.ST_Coin:
                    { return s_coin; } 
                case SoundType.ST_Jump:
                    { return s_jump; } 
                case SoundType.ST_Block:
                    { return s_block; } 
                case SoundType.ST_Stomp:
                    { return s_stomp; } 
                case SoundType.ST_Mush:
                    { return s_mush; } 
                case SoundType.ST_FireBall:
                    { return s_fireball; } 
                    
            }
            return null;
        }
        public void PlayInnerSound(SoundType type)
        {
            FMOD.RESULT result;
            FMOD.Sound sound = GetSound(type);
            if (sound != null)
            {
                result = soundsystem.playSound(FMOD.CHANNELINDEX.FREE, sound, false, ref channel);
                ERRCHECK(result);

                if (type == SoundType.ST_level1 || type == SoundType.ST_level2)
                    channel.setVolume(1f);
                else
                    channel.setVolume(0.15f);

            }
        
        }

        public static void PlaySound(SoundType type)
        {
            if (!SOUND_ENABLE)
                return;
            Instance.PlayInnerSound(type);
        }

        public Media()
        {
            uint version = 0;
            FMOD.RESULT result;

            /*
                Create a System object and initialize.
            */
            result = FMOD.Factory.System_Create(ref soundsystem);
            ERRCHECK(result);

            result = soundsystem.getVersion(ref version);
            ERRCHECK(result);


            if (version < FMOD.VERSION.number)
            {
                MessageBox.Show("Error!  You are using an old version of FMOD " + version.ToString("X") + ".  This program requires " + FMOD.VERSION.number.ToString("X") + ".");
                Application.Exit();
            }

            result = soundsystem.init(32, FMOD.INITFLAGS.NORMAL, (IntPtr)null);
            ERRCHECK(result);

            LoadFromResource();

        }

        private void ERRCHECK(FMOD.RESULT result)
        {
            if (result != FMOD.RESULT.OK)
            {
                //timer.Stop();
                //MessageBox.Show("FMOD error! " + result + " - " + FMOD.Error.String(result));
                //Environment.Exit(-1);
            }
        }

    }
}

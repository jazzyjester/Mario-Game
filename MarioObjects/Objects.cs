using System;
using System.Collections.Generic;
using System.Text;
using System.Drawing;
using System.ComponentModel;
using System.Data;
using System.Windows.Forms;
using System.Runtime.InteropServices;
using System.Resources;
using System.IO;
using System.Reflection;

using Helper;
using MarioObjects.Objects.BaseObjects;
using MarioObjects.Objects.GameObjects;
using MarioObjects.Objects.Utils;

namespace MarioObjects
{
    public enum ObjectType { OT_Coin, OT_BlockQuestion, OT_Ground1, OT_Ground2, OT_BG_LowSky, OT_BG_Block, OT_Grass, OT_Goomba, OT_PipeUp, OT_Mario, OT_MarioSmall, OT_MarioBig, OT_MarioFire, OT_Mush, OT_Brick, OT_BrickPiece, OT_Koopa, OT_FireBall, OT_Flower, OT_Pirana, OT_MovingBlock, OT_SolidBlock, OT_Exit, OT_MushLife,OT_BlockQuestionHidden,OT_Frame};
    public enum TimerType  { TT_50=50, TT_100 = 100, TT_200 = 200,TT_500 = 500 };
    public enum CollisionType { CT_Static, CT_Moveable };
    public enum CollisionDirection { CD_Right, CD_Left, CD_Up, CD_Down, CD_TopLeft,CD_TopRight,CD_ButtomLeft,CD_ButtomRight }

    public class TimerGenerator
    {
        private SortedList<TimerType, Timer> Timers;
        public SortedList<TimerType, List<EventHandler>> Events;

        private static TimerGenerator instance = null;

        public static TimerGenerator Instance 
        {
            get 
            {
                if (instance == null)
                    instance = new TimerGenerator();

                return instance;
            }
        }

        public static void AddTimerEventHandler(TimerType Type, EventHandler Event)
        {
            Timer temp = GetTimer(Type);
            if (!Instance.Events.ContainsKey(Type))
                Instance.Events.Add(Type, new List<EventHandler>());

            if (Instance.Events[Type].IndexOf(Event) != -1)
                return;

           Instance.Events[Type].Add(Event);
        }

        public static void RemoveAllTimerEvents()
        {
            Instance.Events.Clear();
        }

        public Boolean EventInRange(EventHandler myevent)
        {
            Rectangle ARec = LevelGenerator.CurrentLevel.GetAvailableObjectRec();
            GraphicObject g = (GraphicObject)myevent.Target;
            return (ARec.Contains(g.GetObjectRect()));

        }
        public void TT_50_Tick(Object Sender, EventArgs E)
        {
            List<EventHandler> EventsList = Events[TimerType.TT_50];
            foreach(EventHandler Event in EventsList)
                    Event(Sender,E);
        }
        public void TT_100_Tick(Object Sender, EventArgs E)
        {
            List<EventHandler> EventsList = Events[TimerType.TT_100];
            foreach (EventHandler Event in EventsList)
                    Event(Sender, E);
        }

        public void TT_200_Tick(Object Sender, EventArgs E)
        {
            List<EventHandler> EventsList = Events[TimerType.TT_200];
            foreach (EventHandler Event in EventsList)
                    Event(Sender, E);
        }
        public void TT_500_Tick(Object Sender, EventArgs E)
        {
            List<EventHandler> EventsList = Events[TimerType.TT_500];
            foreach (EventHandler Event in EventsList)
                    Event(Sender, E);
        }

        public static Timer GetTimer(TimerType value)
        {
                  
                    if (!Instance.Timers.ContainsKey(value))
                    {
                        Instance.Timers[value] = new Timer();
                        Instance.Timers[value].Interval = (int)value;
                        switch (value)
                        {
                            case TimerType.TT_50:
                                Instance.Timers[value].Tick += new EventHandler(instance.TT_50_Tick); break;
                            case TimerType.TT_100:
                                Instance.Timers[value].Tick += new EventHandler(instance.TT_100_Tick); break;
                            case TimerType.TT_200:
                                Instance.Timers[value].Tick += new EventHandler(instance.TT_200_Tick); break;
                            case TimerType.TT_500:
                                Instance.Timers[value].Tick += new EventHandler(instance.TT_500_Tick); break;
                        }
                        Instance.Timers[value].Enabled = true;
                    }

                    return instance.Timers[value];
        }

        TimerGenerator()
        {
            Timers = new SortedList<TimerType, Timer>();
            Events = new SortedList<TimerType, List<EventHandler>>();
        }
    }


    public class Collision
    {
        public Rectangle Src;
        public Rectangle Dest;
        public CollisionType Type;
        public CollisionDirection Dir;
        public Collision(Rectangle S,Rectangle D,CollisionType T,CollisionDirection Di)
        {
            Src = S;
            Dest = D;
            Type = T;
            Dir = Di;
        }
    }

    public delegate void Intersects_Event(Collision c, GraphicObject g);

   
    public class IntersectionClass
    {
        public Collision C;
        public GraphicObject G;
        public Intersects_Event E;
        public IntersectionClass(Collision _C, GraphicObject _G, Intersects_Event _E)
        {
            C = _C;
            G = _G;
            E = _E;
        }
    };


    public class LevelEditorObject
    {
        public int width, height;
        public int ImageIndex;
        public int ImageCount;
        public string name;
        public ObjectType OT;

        public int ListIndex; // external
        public int x, y; //external
        public int[] ParamInt; //external
        public bool[] Parambool; //external
        public object[] ParamTypes; //external
        public Boolean Checked = false; //external
        public LevelEditorObject()
        {
            ParamInt = new int[3];
            Parambool = new bool[3];

        }

        public LevelEditorObject(int w, int h, int cnt, int ind, ObjectType o, object[] pt)
        {
            width = w;
            height = h;
            ImageCount = cnt;
            ImageIndex = ind;
            OT = o;

            ParamInt = new int[3];
            Parambool = new bool[3];
            ParamTypes = pt;

        }
        public LevelEditorObject(LevelEditorObject tmp)
        {
            this.width = tmp.width;
            this.height = tmp.height;
            this.ImageIndex = tmp.ImageIndex;
            this.ImageCount = tmp.ImageCount;
            this.OT = tmp.OT;
            this.x = tmp.x;
            this.y = tmp.y;
            this.name = tmp.name;
            this.ListIndex = tmp.ListIndex;
            this.ParamTypes = tmp.ParamTypes;

            ParamInt = new int[3];
            Parambool = new bool[3];

        }
    }

}

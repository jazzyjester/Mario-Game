using System;
using System.Collections.Generic;
using System.Text;
using MarioObjects.Objects.BaseObjects;
using MarioObjects.Objects.Utils;

namespace MarioObjects.Objects.GameObjects
{
    public class MonsterGoomba : MoveableAnimatedObject
    {
        public Boolean FallDie;

        public static LevelEditorObject GetLEObject()
        {
            return new LevelEditorObject(16, 16, 4, 1, ObjectType.OT_Goomba, null);
        }

        public static MonsterGoomba SetLEObject(LevelEditorObject le)
        {
            return new MonsterGoomba(le.x, le.y);
        }

        public override void Intersection(Collision c, GraphicObject g)
        {
            base.Intersection(c, g);

            switch (g.OT)
            {
                case ObjectType.OT_BlockQuestion:
                    {
                        int a = 1;
                    } break;
                case ObjectType.OT_Goomba:
                    {
                        DirX *= -1;
                        OnWalk(null, null);
                        ((MonsterGoomba)g).DirX *= -1;
                        ((MonsterGoomba)g).OnWalk(null, null);
                    } break;
                case ObjectType.OT_Mario:
                    {
                        Mario m = (Mario)g;
                        if (c.Dir != CollisionDirection.CD_Down)
                        {
                            if (!m.Blinking)
                            {
                                m.MarioHandleCollision();
                            }
                        }

                    } break;
            }
        }

        public void GoombaFallDie()
        {
            if (FallDie == false)
            {
                FallDie = true;

            }
        }
        public void GoombaDie()
        {
            Animated = false;
            Live = false;
        }
        public override void OnWalk(object sender, EventArgs e)
        {
            if (!FallDie)
                base.OnWalk(sender, e);
            else
            {
                Animated = false;
                ImageIndex = 3;
                newy += 3;

                if (newy >= LevelGenerator.CurrentLevel.height)
                {
                    Visible = false;
                }

            }


        }
        public MonsterGoomba(int x, int y)
            : base(ObjectType.OT_Goomba)
        {
            AnimatedCount = 2;
            this.x = x;
            this.y = y;
            SetWidthHeight();
            FallDie = false;

            TimerGenerator.AddTimerEventHandler(TimerType.TT_50, this.OnWalk);
            TimerGenerator.AddTimerEventHandler(TimerType.TT_100, this.OnAnimate);
        }
        public override void Draw()
        {
            base.Draw();
        }
        public override void OnAnimate(object sender, EventArgs e)
        {
            if (Visible)
            {
                if (Live)
                    base.OnAnimate(sender, e);
                else
                {
                    if (ImageIndex != 2)
                        ImageIndex = 2; //Die Picture
                    else
                    {
                        Visible = false; //Next Time,Visible False
                    }
                }
            }
        }
    }

}

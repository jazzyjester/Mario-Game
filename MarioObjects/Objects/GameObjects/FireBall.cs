using System;
using System.Collections.Generic;
using System.Text;
using MarioObjects.Objects.BaseObjects;
using MarioObjects.Objects.Utils;

namespace MarioObjects.Objects.GameObjects
{
    public class FireBall : AnimatedGraphicObject
    {
        public enum FireBallType { FT_Mario, FT_Piranah };
        public enum FireBallDir { FB_Right, FB_Left };
        public double StartVelocity;
        public double StartPosition;
        public double TimeCount;
        public FireBallDir Direction;
        public int Dirx;
        public Boolean Started;
        public FireBallType Type;

        public Boolean Fire;
        public double OffX, OffY;
        public double CntX, CntY;

        public override void Intersection(Collision c, GraphicObject g)
        {
            base.Intersection(c, g);
            switch (g.OT)
            {
                case ObjectType.OT_SolidBlock:
                    goto case ObjectType.OT_PipeUp;
                case ObjectType.OT_BlockQuestion:
                    goto case ObjectType.OT_Grass;
                case ObjectType.OT_Brick:
                    goto case ObjectType.OT_Grass;

                case ObjectType.OT_Grass:
                    {
                        StartFireBall();

                    } break;

                case ObjectType.OT_PipeUp:
                    {
                        Started = false;
                        Visible = false;
                    } break;
                case ObjectType.OT_Goomba:
                    {
                        if (Type == FireBallType.FT_Mario)
                        {
                            ((MonsterGoomba)g).GoombaFallDie();

                            Started = false;
                            Visible = false;
                        }

                    } break;
                case ObjectType.OT_Koopa:
                    {
                        if (Type == FireBallType.FT_Mario)
                        {
                            ((MonsterKoopa)g).SetKoopaState(MonsterKoopa.KoopaState.KS_Shield);

                            Started = false;
                            Visible = false;
                        }
                    } break;
                case ObjectType.OT_Pirana:
                    {
                        if (Type == FireBallType.FT_Mario)
                        {
                            ((MonsterPiranah)g).Visible = false;
                            ((MonsterPiranah)g).Live = false;

                        }

                    } break;
            }

        }

        public void RunFireBall(int x, int y, FireBallType T, FireBallDir D)
        {
            Type = T;
            Direction = D;
            if (Type == FireBallType.FT_Mario)
            {
                if (D == FireBallDir.FB_Right)
                    Dirx = 1;
                else
                    Dirx = -1;
            }
            if (Type == FireBallType.FT_Piranah)
            {

            }

            SetFireProperties();
            newx = x;
            newy = y;

            StartFireBall();
        }
        public void StartFireBall()
        {
            Fire = true;
            Visible = true;
            StartPosition = newy;
            if (Started == false)
                StartVelocity = 0;
            else
                StartVelocity = -15;

            Started = true;
            TimeCount = 0;
        }
        public double CalcFireBallPosition()
        {
            return StartPosition + StartVelocity * TimeCount + 4.9 * TimeCount * TimeCount;
        }

        public override void Draw()
        {
            base.Draw();
        }
        public override void OnAnimate(object sender, EventArgs e)
        {
            base.OnAnimate(sender, e);
        }
        public void SetOffXY(double x, double y)
        {
            OffX = x;
            OffY = y;

            CntX = 0;
            CntY = 0;


        }
        public void OnFire(object sender, EventArgs e)
        {
            if (Started)
            {
                if (Fire)
                {
                    if (Type == FireBallType.FT_Mario)
                    {
                        TimeCount += (250.0 / 1000.0);
                        newy = (int)CalcFireBallPosition();

                        newx += 5 * Dirx;
                    }
                    if (Type == FireBallType.FT_Piranah)
                    {
                        //CntX += OffX;
                        //CntY += OffY;

                        newx += (int)OffX;
                        newy += (int)OffY;
                    }

                    if (newy < 0)
                        Started = false;

                    if (newx >= LevelGenerator.CurrentLevel.MarioObject.x + 320)
                    {
                        Started = false;
                        Visible = false;
                    }
                    if (newx < LevelGenerator.CurrentLevel.MarioObject.x - 320)
                    {
                        Started = false;
                        Visible = false;
                    }
                }
            }

        }

        public void SetFireProperties()
        {
            this.x = x;
            this.y = y;
            SetWidthHeight();
            width = 8;
            height = 9;

        }
        public FireBall(int x, int y)
            : base(ObjectType.OT_FireBall)
        {

            Fire = false;
            Visible = false;
            AnimatedCount = 4;

            TimerGenerator.AddTimerEventHandler(TimerType.TT_100, OnAnimate);
            TimerGenerator.AddTimerEventHandler(TimerType.TT_50, OnFire);
        }
    }

}

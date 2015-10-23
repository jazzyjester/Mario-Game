using System;
using System.Collections.Generic;
using System.Text;
using MarioObjects.Objects.BaseObjects;
using MarioObjects.Objects.Utils;

namespace MarioObjects.Objects.GameObjects
{
    public class MonsterPiranah : AnimatedGraphicObject
    {
        public enum PiranahType { PT_None, PT_Fish, PT_Fire }
        public enum PiranahDirection { PD_Right, PD_Left };
        public enum PiranaMove { PM_None, PM_Up, PN_Middle, PM_Down };
        public PiranahType Type;
        public PiranahDirection Direction;
        public PiranaMove Move;

        public int OffY;
        public Boolean Live;
        public FireBall Ball;
        public Boolean FireOnce = false;

        public void SetDirection()
        {
            if (newx >= LevelGenerator.CurrentLevel.MarioObject.x)
                Direction = PiranahDirection.PD_Left;
            else
                Direction = PiranahDirection.PD_Right;

            SetPiranahProperties();

        }
        public override void OnAnimate(object sender, EventArgs e)
        {
            base.OnAnimate(sender, e);
        }
        public void OnMove(object sender, EventArgs e)
        {
            if (Live == false)
                return;

            if (Move == PiranaMove.PM_Up)
            {
                if (Type == PiranahType.PT_Fire)
                    Animated = false;
                else
                    Animated = true;

                OffY += 1;
                newy -= 1;

                if (OffY >= height)
                {
                    Move = PiranaMove.PN_Middle;
                    OffY = 0;
                }

            }
            else
                if (Move == PiranaMove.PM_Down)
                {
                    if (Type == PiranahType.PT_Fire)
                    {
                        Animated = false;
                        if (!Ball.Started)
                        {
                            UpdateOffsetsFireBall();
                            if (FireOnce)
                            {
                                Ball.RunFireBall(newx, newy, FireBall.FireBallType.FT_Piranah, FireBall.FireBallDir.FB_Left);
                                FireOnce = false;
                            }
                        }
                    }
                    else
                        Animated = true;


                    OffY += 1;
                    newy += 1;

                    if (OffY >= height)
                    {
                        Move = PiranaMove.PM_None;
                        OffY = 0;
                    }

                }
                else if (Move == PiranaMove.PN_Middle)
                {
                    Animated = true;


                    OffY += 1;

                    if (OffY >= height)
                    {
                        Move = PiranaMove.PM_Down;
                        FireOnce = true;
                        OffY = 0;
                    }

                }
                else
                {
                    OffY += 1;

                    if (OffY >= height * 2)
                    {
                        Move = PiranaMove.PM_Up;
                        OffY = 0;
                        SetDirection();
                    }
                }
        }
        public void UpdateOffsetsFireBall()
        {
            double srcy, desty;
            double dx = 5;
            double dy;
            int absx = Math.Abs(newx - LevelGenerator.CurrentLevel.MarioObject.x) / (int)dx;
            srcy = LevelGenerator.CurrentLevel.MarioObject.y;
            desty = newy - height;

            dy = (srcy - desty) / absx;

            if (newx > LevelGenerator.CurrentLevel.MarioObject.x)
                dx *= -1;

            Ball.SetOffXY(dx, dy);



        }
        public override void Draw()
        {
            base.Draw();
        }

        public void SetPiranahProperties()
        {
            switch (Type)
            {
                case PiranahType.PT_Fish:
                    {
                        AnimatedCount = 2;
                        OffsetIndex = 8;
                    } break;
                case PiranahType.PT_Fire:
                    {

                        if (Direction == PiranahDirection.PD_Left)
                        {
                            AnimatedCount = 4;
                            OffsetIndex = 0;
                        }
                        if (Direction == PiranahDirection.PD_Right)
                        {
                            AnimatedCount = 4;
                            OffsetIndex = 4;
                        }

                    } break;
            }
        }
        public MonsterPiranah(int x, int y, PiranahType T)
            : base(ObjectType.OT_Pirana)
        {
            ImageCount = 10;

            Type = T;
            SetPiranahProperties();
            Move = PiranaMove.PM_None;

            this.x = x;
            this.y = y;
            SetWidthHeight();
            newx += 8;
            width = 16;
            OffY = 0;
            Live = true;

            Ball = new FireBall(0, 0);
            AddObject(Ball);

            TimerGenerator.AddTimerEventHandler(TimerType.TT_500, OnAnimate);
            TimerGenerator.AddTimerEventHandler(TimerType.TT_50, OnMove);

        }
    }

}

using System;
using System.Collections.Generic;
using System.Text;
using MarioObjects.Objects.BaseObjects;
using MarioObjects.Objects.Utils;

namespace MarioObjects.Objects.GameObjects
{
    public class BlockMoving : StaticGraphicObject
    {
        public enum MovingType { MT_UpDown, MT_RightLeft };
        public MovingType Type;
        public int MaxDistance;
        public int StartPosition;
        public double Dir;
        public Boolean MarioOn;

        public static LevelEditorObject GetLEObject()
        {
            return new LevelEditorObject(50, 16, 1, 0, ObjectType.OT_MovingBlock, new object[] { new object[] { new object[] { "Small", 25, "Medium", 50, "Big", 75, "Huge", 100 }, new object[] { "Up Down", 0, "Right Left", 1 } }, 1 });
        }
        public static BlockMoving SetLEObject(LevelEditorObject le)
        {
            return new BlockMoving(le.x, le.y, le.ParamInt[0], (MovingType)le.ParamInt[1], le.Parambool[0]);
        }


        public override void Intersection_None()
        {
            base.Intersection_None();
            MarioOn = false;
        }
        public void OnMove(Object sender, EventArgs e)
        {

            if (Type == MovingType.MT_UpDown)
                newy += (int)Dir;
            else
                newx += (int)Dir;


            if (MarioOn)
            {
                if (Type == MovingType.MT_UpDown)
                {
                    LevelGenerator.CurrentLevel.MarioObject.y = newy - LevelGenerator.CurrentLevel.MarioObject.height;
                    LevelGenerator.CurrentLevel.Update_ScreensY();
                }
                else
                {
                    LevelGenerator.CurrentLevel.MarioObject.x += (int)Dir;
                    LevelGenerator.CurrentLevel.Update_ScreensX();

                }
            }
            if (Dir > 0)
            {
                if (Type == MovingType.MT_UpDown)
                {
                    if (newy >= StartPosition + MaxDistance - 5)
                        Dir = 1;


                    if (newy >= StartPosition + MaxDistance)
                    {
                        Dir = -2;
                    }
                }
                else
                {
                    if (newx >= StartPosition + MaxDistance - 5)
                        Dir = 1;


                    if (newx >= StartPosition + MaxDistance)
                    {
                        Dir = -2;
                    }

                }
            }
            else
            {
                if (Type == MovingType.MT_UpDown)
                {
                    if (newy <= StartPosition - MaxDistance + 5)
                        Dir = -1;


                    if (newy <= StartPosition - MaxDistance)
                    {
                        Dir = 2;
                    }
                }
                else
                {
                    if (newx <= StartPosition - MaxDistance + 5)
                        Dir = -1;


                    if (newx <= StartPosition - MaxDistance)
                    {
                        Dir = 2;
                    }
                }

            }

        }
        public override void Draw()
        {
            base.Draw();
        }
        public BlockMoving(int x, int y, int Distance, MovingType T, Boolean Start)
        {
            //ImageCount = 4;
            MaxDistance = Distance;
            Type = T;
            this.x = x;
            this.y = y;
            OT = ObjectType.OT_MovingBlock;
            SetWidthHeight();
            width = 50;
            Dir = 2.0;
            if (Start)
                Dir *= -1;

            if (Type == MovingType.MT_UpDown)
                StartPosition = newy;
            else
                StartPosition = newx;

            MarioOn = false;

            TimerGenerator.AddTimerEventHandler(TimerType.TT_50, OnMove);
        }


    }

}

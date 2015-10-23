using System;
using System.Collections.Generic;
using System.Text;

namespace MarioObjects.Objects.BaseObjects
{
    public class MoveableAnimatedObject : AnimatedGraphicObject
    {
        public int DirX;
        public int DirY;
        public Boolean Live;
        public int WalkStep;


        public Boolean Fall;

        public override void Intersection(Collision c, GraphicObject g)
        {
            base.Intersection(c, g);

            switch (g.OT)
            {
                case ObjectType.OT_BlockQuestion:
                    goto case ObjectType.OT_Grass;
                case ObjectType.OT_Grass:
                    {
                        if (c.Dir == CollisionDirection.CD_Up)
                        {
                            Fall = false;
                        }

                    } break;
                case ObjectType.OT_Brick:
                    goto case ObjectType.OT_PipeUp;
                case ObjectType.OT_Pirana:
                    goto case ObjectType.OT_PipeUp;
                case ObjectType.OT_SolidBlock:
                    goto case ObjectType.OT_PipeUp;
                case ObjectType.OT_PipeUp:
                    {
                        if (c.Dir == CollisionDirection.CD_Left || c.Dir == CollisionDirection.CD_Right)
                        {
                            Fall = false;
                            DirX *= -1;
                            OnWalk(null, null);
                        }

                    } break;

            }

        }

        public override void Intersection_None()
        {
            base.Intersection_None();

            if (Fall == false)
            {
                Fall = true;
            }
        }

        public MoveableAnimatedObject(ObjectType OT)
            : base(OT)
        {
            DirX = 1;
            DirY = 0;
            Fall = false;
            Live = true;
            WalkStep = 1;
        }

        public override void Draw()
        {
            base.Draw();
        }
        public override void OnAnimate(object sender, EventArgs e)
        {
            base.OnAnimate(sender, e);

        }
        public virtual void OnWalk(object sender, EventArgs e)
        {

            newx += DirX * WalkStep;

            if (Fall == true)
                newy += 2;



            //LevelGenerator.Raise_Event(LevelGenerator.LevelEvent.LE_Check_Collision);
        }

    }

}

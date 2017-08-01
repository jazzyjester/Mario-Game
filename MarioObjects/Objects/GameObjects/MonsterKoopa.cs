using System;
using System.Collections.Generic;
using System.Text;
using MarioObjects.Objects.BaseObjects;
using MarioObjects.Objects.Utils;

namespace MarioObjects.Objects.GameObjects
{
    public class MonsterKoopa : MoveableAnimatedObject
    {
        public enum KoopaState { KS_Walking, KS_Shield, KS_Returning, KS_ShieldMoving };
        public enum KoopaDir { KD_Right, KD_Left };
        public KoopaState State;
        public KoopaDir Dir;
        public int ReturningTime;
        public static LevelEditorObject GetLEObject()
        {
            return new LevelEditorObject(16, 27, 10, 2, ObjectType.OT_Koopa, null);
        }

        public static MonsterKoopa SetLEObject(LevelEditorObject le)
        {
            return new MonsterKoopa(le.x, le.y);
        }

        public override void Draw()
        {
            base.Draw();
        }
        public override void OnWalk(object sender, EventArgs e)
        {
            if (State == KoopaState.KS_Shield && IntersectsObjects.Count == 0)
                base.OnWalk(sender, e);

            if (State == KoopaState.KS_Walking || State == KoopaState.KS_ShieldMoving)
            {
                if (newx <= LevelGenerator.CurrentLevel.MarioObject.x - 160)
                {
                    if (Live)
                    {
                        Animated = false;
                        Live = false;
                        Visible = false;
                    }
                }

                base.OnWalk(sender, e);

                if (DirX > 0)
                    Dir = KoopaDir.KD_Right;
                else
                    Dir = KoopaDir.KD_Left;

                if (State != KoopaState.KS_ShieldMoving)
                {
                    switch (Dir)
                    {
                        case KoopaDir.KD_Left:
                            {
                                OffsetIndex = 0;
                            } break;
                        case KoopaDir.KD_Right:
                            {
                                OffsetIndex = 2;
                            } break;
                    }
                }
            }
        }
        public override void Intersection(Collision c, GraphicObject g)
        {
            base.Intersection(c, g);

            switch (g.OT)
            {
                case ObjectType.OT_Brick:
                    {
                        if (State == KoopaState.KS_ShieldMoving)
                        {
                            if (c.Dir == CollisionDirection.CD_Left || c.Dir == CollisionDirection.CD_Right)
                                ((BlockBrick)g).BreakBrick();
                        }
                    } break;
                case ObjectType.OT_Goomba:
                    {
                        if (State == KoopaState.KS_ShieldMoving)
                        {
                            ((MonsterGoomba)g).GoombaFallDie();
                        }
                        if (State == KoopaState.KS_Walking)
                        {
                            ((MonsterGoomba)g).DirX *= -1;
                            ((MonsterGoomba)g).newx += 5 * ((MonsterGoomba)g).DirX;

                            ((MonsterGoomba)g).OnWalk(null, null);
                            DirX *= -1;
                            OnWalk(null, null);
                        }
                        if (State == KoopaState.KS_Shield)
                        {
                            ((MonsterGoomba)g).DirX *= -1;
                            ((MonsterGoomba)g).newx += 5 * ((MonsterGoomba)g).DirX;
                            ((MonsterGoomba)g).OnWalk(null, null);
                        }
                    } break;
                case ObjectType.OT_Mario:
                    {

                        if (State == KoopaState.KS_Shield && ReturningTime >= 3)
                        {
                            if (c.Dir == CollisionDirection.CD_Left)
                                DirX = -1;

                            if (c.Dir == CollisionDirection.CD_Right)
                                DirX = 1;

                            SetKoopaState(KoopaState.KS_ShieldMoving);
                        }

                        // Size-down mario when colliding with a koopa
                        if (State != KoopaState.KS_Shield) // but not in shield state
                        {
                          if (!(State == KoopaState.KS_ShieldMoving // Or that he's just set in motion
                              && (DirX == -1 && c.Dir == CollisionDirection.CD_Left) || (DirX == 1 && c.Dir == CollisionDirection.CD_Right)))
                          {
                            Mario m = (Mario)g;
                            if (c.Dir != CollisionDirection.CD_Down)
                            {
                              if (!m.Blinking)
                                if (m.Type == Mario.MarioType.MT_Big || m.Type == Mario.MarioType.MT_Fire)
                                {
                                  m.Type = Mario.MarioType.MT_Small;
                                  m.StartBlinking();
                                  m.SetMarioProperties();
                                }
                            }
                          }
                    } break;
            }
          } 
        }
        public override void OnAnimate(object sender, EventArgs e)
        {
            base.OnAnimate(sender, e);

            if (State == KoopaState.KS_Shield)
            {
                ReturningTime++;

                if (ReturningTime > 20)
                {
                    SetKoopaState(KoopaState.KS_Returning);
                }
            }

            if (State == KoopaState.KS_Returning)
            {
                ReturningTime++;
                ImageIndex = (ReturningTime % 2) * 4 + 4; //4 or 9;

                if (ReturningTime > 40)
                {
                    SetKoopaState(KoopaState.KS_Walking);
                    ReturningTime = 0;
                }
            }
        }
        public void SetKoopaState(KoopaState S)
        {
            State = S;
            switch (State)
            {
                case KoopaState.KS_Walking:
                    {
                        width = 16;
                        height = 27;
                        AnimatedCount = 2;
                        newy -= 11;
                        WalkStep = 1;


                        Animated = true;
                    } break;
                case KoopaState.KS_Shield:
                    {
                        width = 16;
                        height = 27;
                        ReturningTime = 0;
                        OffsetIndex = 0;

                        ImageIndex = 4;
                        //newy -= 11;
                        Animated = false;
                    } break;
                case KoopaState.KS_Returning:
                    {
                        OffsetIndex = 0;
                        //Animated = false;
                    } break;
                case KoopaState.KS_ShieldMoving:
                    {
                        width = 16;
                        height = 27;
                        //newy -= 11;

                        WalkStep = 4;
                        AnimatedCount = 4;
                        OffsetIndex = 4;
                        Animated = true;

                    } break;
            }
        }
        public MonsterKoopa(int x, int y)
            : base(ObjectType.OT_Koopa)
        {
            this.x = x;
            this.y = y;
            ImageCount = 10;

            SetWidthHeight();

            SetKoopaState(KoopaState.KS_Walking);
            Dir = KoopaDir.KD_Right;

            TimerGenerator.AddTimerEventHandler(TimerType.TT_50, this.OnWalk);
            TimerGenerator.AddTimerEventHandler(TimerType.TT_100, this.OnAnimate);

        }
    }

}

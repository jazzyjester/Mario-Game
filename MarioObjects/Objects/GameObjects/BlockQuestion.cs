using System;
using System.Collections.Generic;
using System.Text;
using MarioObjects.Objects.BaseObjects;
using MarioObjects.Objects.Utils;

namespace MarioObjects.Objects.GameObjects
{
    public class BlockQuestion : AnimatedGraphicObject
    {
        public Boolean Hit;
        public Boolean Open;
        public double OffY;
        public int DirY;

        public GraphicObject HiddenObject = null;

        public static LevelEditorObject GetLEObject()
        {
            return new LevelEditorObject(16, 16, 5, 0, ObjectType.OT_BlockQuestion, new object[] { new object[] { new object[] { "Mush Life", (int)ObjectType.OT_MushLife, "Mush Big", (int)ObjectType.OT_Mush, "Coin", (int)ObjectType.OT_Coin, "Flower", (int)ObjectType.OT_Flower } }, 0 });
        }

        public static BlockQuestion SetLEObject(LevelEditorObject le)
        {
            return new BlockQuestion(le.x, le.y, (ObjectType)le.ParamInt[0]);
        }


        private static bool Predicate_Monster(IntersectionClass IC)
        {
            if ((IC.G.GetType() == typeof(MonsterGoomba) ||
                IC.G.GetType() == typeof(MonsterKoopa)))
                return true;
            else
                return false;
        }

        public void isMonsterExist()
        {
            if (Open == true)
                return;

            IntersectionClass IC;
            IC = IntersectsObjects.Find(Predicate_Monster);

            if (IC != null)
            {
                switch (IC.G.OT)
                {
                    case ObjectType.OT_Goomba:
                        {
                            ((MonsterGoomba)IC.G).GoombaFallDie();
                        } break;
                    case ObjectType.OT_Koopa:
                        {
                            ((MonsterKoopa)IC.G).SetKoopaState(MonsterKoopa.KoopaState.KS_Shield);
                        } break;

                }
            }

        }

        public void StartMove()
        {
            if (Hit == false && Open == false)
            {
                Open = true;
                DirY = -1;
                Hit = true;
                OffY = 0;

                switch (HiddenObject.OT)
                {
                    case ObjectType.OT_Flower:
                        {
                            ((Flower)HiddenObject).Visible = true;

                        } break;
                    case ObjectType.OT_MushLife:
                        {
                            ((MushLife)HiddenObject).Visible = true;
                            ((MushLife)HiddenObject).Live = true;

                        } break;

                    case ObjectType.OT_Mush:
                        {
                            ((MushRed)HiddenObject).Visible = true;
                            ((MushRed)HiddenObject).Live = true;

                        } break;
                    case ObjectType.OT_Coin:
                        {
                            Media.PlaySound(Media.SoundType.ST_Coin);
                            ((CoinBlock)HiddenObject).MoveCoinUp();

                        } break;

                }
            }
        }
        public override void Intersection(Collision c, GraphicObject g)
        {
            base.Intersection(c, g);
            switch (g.OT)
            {
                case ObjectType.OT_Goomba:
                    {
                        int a = 2;
                    } break;
                case ObjectType.OT_Mario:
                    {

                    } break;
            }

        }

        public override void Draw()
        {
            base.Draw();
        }

        public virtual void OnBlockHit(object sender, EventArgs e)
        {
            if (Hit)
            {
                if (DirY == -1)
                {
                    OffY += 1;
                    newy += (int)(DirY * OffY);

                    if (OffY == 2)
                    {
                        DirY = 1;
                        OffY = 0;
                    }
                }
                else
                {
                    OffY += 1;
                    newy += (int)OffY;
                    if (OffY == 2)
                    {
                        DirY = -1;
                        OffY = 0;
                        Hit = false;
                    }
                }
            }

        }

        public override void OnAnimate(object sender, EventArgs e)
        {
            if (Open)
            {
                Animated = false;
                ImageIndex = 4;
            }
            else
                base.OnAnimate(sender, e);
        }

        public void CreateHidden(ObjectType hidden)
        {
            switch (hidden)
            {
                case ObjectType.OT_Coin:
                    HiddenObject = new CoinBlock(x, y, true); break;
                case ObjectType.OT_Mush:
                    HiddenObject = new MushRed(x, y + 1); break;
                case ObjectType.OT_MushLife:
                    HiddenObject = new MushLife(x, y + 1); break;
                case ObjectType.OT_Flower:
                    HiddenObject = new Flower(x, y + 1); break;
            }

            AddObject(HiddenObject);
        }

        public BlockQuestion(int x, int y, ObjectType hidden)
            : base(ObjectType.OT_BlockQuestion)
        {
            AnimatedCount = 4;
            Hit = false;
            Open = false;
            this.x = x;
            this.y = y;
            SetWidthHeight();
            CreateHidden(hidden);

            TimerGenerator.AddTimerEventHandler(TimerType.TT_100, OnAnimate);
            TimerGenerator.AddTimerEventHandler(TimerType.TT_50, OnBlockHit);
        }
    }


}

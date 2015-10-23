using System;
using System.Collections.Generic;
using System.Text;
using MarioObjects.Objects.Utils;

namespace MarioObjects.Objects.GameObjects
{
    public class BlockQuestionHidden : BlockQuestion
    {
        public static new LevelEditorObject GetLEObject()
        {
            return new LevelEditorObject(16, 16, 6, 5, ObjectType.OT_BlockQuestionHidden, new object[] { new object[] { new object[] { "Mush Life", (int)ObjectType.OT_MushLife, "Mush Big", (int)ObjectType.OT_Mush, "Coin", (int)ObjectType.OT_Coin, "Flower", (int)ObjectType.OT_Flower } }, 0 });
        }

        public static new BlockQuestionHidden SetLEObject(LevelEditorObject le)
        {
            return new BlockQuestionHidden(le.x, le.y, (ObjectType)le.ParamInt[0]);
        }

        public override void OnBlockHit(object sender, EventArgs e)
        {
            base.OnBlockHit(sender, e);

            Collision C = LevelGenerator.CurrentLevel.Intersects(LevelGenerator.CurrentLevel.MarioObject, this);
            if (C != null)
                if (C.Dir == CollisionDirection.CD_Down)
                {
                    if (LevelGenerator.CurrentLevel.MarioObject.State == Mario.MarioJumpState.J_Up)
                    {
                        Visible = true;
                        isMonsterExist();
                        StartMove();
                        LevelGenerator.CurrentLevel.MarioObject.State = Mario.MarioJumpState.JDown;
                        LevelGenerator.CurrentLevel.MarioObject.StartPosition = y;
                        LevelGenerator.CurrentLevel.MarioObject.TimeCount = 0;
                        LevelGenerator.CurrentLevel.MarioObject.StartVelocity = 0;

                        if (HiddenObject.OT != ObjectType.OT_Coin)
                            Media.PlaySound(Media.SoundType.ST_Block);
                    }

                }

        }
        public override void Draw()
        {
            if (Open)
                base.Draw();
        }
        BlockQuestionHidden(int x, int y, ObjectType hidden)
            :
            base(x, y, hidden)
        {
            Animated = false;
            Visible = false;
            OT = ObjectType.OT_BlockQuestionHidden;
        }
    }


}

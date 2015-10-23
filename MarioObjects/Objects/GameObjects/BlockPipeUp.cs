using System;
using System.Collections.Generic;
using System.Text;
using MarioObjects.Objects.BaseObjects;
using MarioObjects.Objects.Utils;

namespace MarioObjects.Objects.GameObjects
{
    public class BlockPipeUp : StaticGraphicObject
    {
        public MonsterPiranah Monster;

        public static LevelEditorObject GetLEObject()
        {
            return new LevelEditorObject(32, 32, 1, 0, ObjectType.OT_PipeUp, new object[] { new object[] { new object[] { "Pirana Fish", (int)(MonsterPiranah.PiranahType.PT_Fish), "Pirana Fire", (int)(MonsterPiranah.PiranahType.PT_Fire), "None", (int)(MonsterPiranah.PiranahType.PT_None) } }, 0 });
        }

        public static BlockPipeUp SetLEObject(LevelEditorObject le)
        {
            return new BlockPipeUp(le.x, le.y, (MonsterPiranah.PiranahType)le.ParamInt[0]);
        }

        public override void Draw()
        {
            base.Draw();
        }
        public BlockPipeUp(int x, int y, MonsterPiranah.PiranahType T)
        {
            if (T != MonsterPiranah.PiranahType.PT_None)
            {
                Monster = new MonsterPiranah(x, y, T);
                AddObject(Monster);
            }

            this.x = x;
            this.y = y;
            OT = ObjectType.OT_PipeUp;
            SetWidthHeight();
        }
    }

}

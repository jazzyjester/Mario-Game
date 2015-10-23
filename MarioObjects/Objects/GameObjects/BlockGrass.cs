using System;
using System.Collections.Generic;
using System.Text;
using MarioObjects.Objects.BaseObjects;
using MarioObjects.Objects.Utils;

namespace MarioObjects.Objects.GameObjects
{
    public class BlockGrass : StaticGraphicObject
    {
        public static LevelEditorObject GetLEObject()
        {
            return new LevelEditorObject(16, 16, 2, 1, ObjectType.OT_Grass, null);
        }
        public static BlockGrass SetLEObject(LevelEditorObject le)
        {
            return new BlockGrass(le.x, le.y);
        }

        public override void Draw()
        {
            base.Draw();
        }
        public BlockGrass(int x, int y)
        {
            ImageIndex = 1;
            this.x = x;
            this.y = y;
            OT = ObjectType.OT_Grass;
            SetWidthHeight();

        }
    }


}

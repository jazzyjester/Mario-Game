using System;
using System.Collections.Generic;
using System.Text;
using MarioObjects.Objects.BaseObjects;
using MarioObjects.Objects.Utils;

namespace MarioObjects.Objects.GameObjects
{
    public class BlockSolid : StaticGraphicObject
    {
        public static LevelEditorObject GetLEObject()
        {
            return new LevelEditorObject(16, 16, 1, 0, ObjectType.OT_SolidBlock, null);
        }
        public static BlockSolid SetLEObject(LevelEditorObject le)
        {
            return new BlockSolid(le.x, le.y);
        }
        public BlockSolid(int x, int y)
        {
            this.x = x;
            this.y = y;
            SetWidthHeight();
            OT = ObjectType.OT_SolidBlock;

        }
    }

}

using System;
using System.Collections.Generic;
using System.Text;
using System.Reflection;
using MarioObjects.Objects.BaseObjects;

namespace MarioObjects.Objects.Utils
{
    public class ObjectGenerator
    {
        private static ObjectGenerator instance = null;
        public static ObjectGenerator Instance
        {
            get
            {
                if (instance == null)
                    instance = new ObjectGenerator();
                return instance;
            }
        }
        public ObjectGenerator()
        {


        }
        public static GraphicObject SetEditorObject(LevelEditorObject le)
        {
            Assembly asm = System.Reflection.Assembly.GetExecutingAssembly();

            Type objType = Type.GetType("MarioObjects.Objects.GameObjects." + le.name);
            MethodInfo i = objType.GetMethod("SetLEObject");
            GraphicObject g = null;

            if (i != null)
            {
                g = (GraphicObject)i.Invoke(null, new object[] { le });
            }

            return g;
        }

        public static LevelEditorObject GetEditorObject(string name)
        {
            Assembly asm = System.Reflection.Assembly.GetExecutingAssembly();

            Type objType = Type.GetType("MarioObjects.Objects.GameObjects." + name);
            MethodInfo i = objType.GetMethod("GetLEObject");
            if (i != null)
            {
                LevelEditorObject LE = (LevelEditorObject)(i.Invoke(null, null));
                LE.name = name;
                return LE;
            }
            else
                return null;
        }
        public static List<LevelEditorObject> GetEditorObjects()
        {
            /*
            Creates Object... don't need it, use static instead
            Assembly asm = System.Reflection.Assembly.GetExecutingAssembly();
            GraphicObject g = (GraphicObject)asm.CreateInstance(objType.ToString(), false, BindingFlags.CreateInstance, null, new object[] { x , y },null,null);
            */
            List<LevelEditorObject> Res = new List<LevelEditorObject>();
            Assembly asm = System.Reflection.Assembly.GetExecutingAssembly();
            foreach (Type t in asm.GetTypes())
            {
                Type objType = Type.GetType(t.FullName);
                MethodInfo i = objType.GetMethod("GetLEObject");
                if (i != null)
                {
                    LevelEditorObject LE = (LevelEditorObject)(i.Invoke(null, null));
                    LE.name = t.Name;
                    Res.Add(LE);
                }

            }

            //Type objType = Type.GetType("MarioObjects.");
            //MethodInfo i = objType.GetMethod("GetLEObject");
            //return (LevelEditorObject)(i.Invoke(null, null));
            return Res;
        }
    }


}

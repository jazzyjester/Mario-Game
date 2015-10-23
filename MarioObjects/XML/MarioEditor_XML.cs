using System;
using System.Collections.Generic;
using System.Text;
using System.Xml.Serialization;
using System.Xml;
using System.IO;

using MarioObjects;
using MarioObjects.Objects.Utils;

namespace MarioObjects
{
    public class MarioEditorXML
    {

        public MarioEditorXML()
        { 
          
        }

        public static void Save_To_XML(string filename,List<LevelEditorObject> list)
        {
            root MainObject = null;
            rootObject[] Objects = null;

            int cnt = 0;
            MainObject = new root();
            Objects = new rootObject[list.Count];

            foreach (LevelEditorObject le in list)
            {
                rootObject tmp = new rootObject();
                tmp.X = le.x;
                tmp.Y = le.y;
                tmp.OName = le.name;
                tmp.Int1 =  le.ParamInt[0];
                tmp.Int2 =  le.ParamInt[1];
                tmp.Int3 =  le.ParamInt[2];
                tmp.Bool1 = le.Parambool[0];
                tmp.Bool2 = le.Parambool[1];
                tmp.Bool3 = le.Parambool[2];

                Objects[cnt++] = tmp;

            }
            MainObject.Object = Objects;

            StreamWriter SW = new StreamWriter(filename);
            XmlSerializer xSer = new XmlSerializer(typeof(root));
            xSer.Serialize(SW, MainObject);
            SW.Close();
        }

        public static List<LevelEditorObject> Load_From_XML(string filename)
        {
            List<LevelEditorObject> Res = new List<LevelEditorObject>();
            root MainObject = null;

            MainObject = new root();

            StreamReader SR = new StreamReader(filename);
            XmlSerializer xSer = new XmlSerializer(typeof(root));
            MainObject = (root)xSer.Deserialize(SR);
            SR.Close();

            foreach (rootObject obj in MainObject.Object)
            {
                LevelEditorObject le = ObjectGenerator.GetEditorObject(obj.OName);
                if (le != null)
                {
                    le.name = obj.OName;
                    le.x = obj.X;
                    le.y = obj.Y;
                    le.ParamInt[0] = obj.Int1;
                    le.ParamInt[1] = obj.Int2;
                    le.ParamInt[2] = obj.Int3;
                    le.Parambool[0] = obj.Bool1;
                    le.Parambool[1] = obj.Bool2;
                    le.Parambool[2] = obj.Bool3;

                    Res.Add(le);
                }
            }



            return Res;
        }
    }
}

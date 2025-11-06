using Godot;
using System;

namespace Spine
{
    public partial class ZipManager : GodotObject
    {
        #nullable enable
        public static String? zippath;

        public static void SetZipPath(String zippath)
        {
            ZipManager.zippath = zippath;
        }
        public static void ClearZipPath()
        {
            ZipManager.zippath = null;
        }

    }
}
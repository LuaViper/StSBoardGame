using Godot;
using System;
using System.ComponentModel.Design;
using System.IO;
using System.IO.Compression;
using System.Net.NetworkInformation;

namespace Spine { 
    public partial class GodotSpineTextureLoader : GodotObject, TextureLoader
    {
        public static TextureLoader textureLoader = new GodotSpineTextureLoader();
        public void Load(AtlasPage page, String path)
        {
            Texture texture;
            if (ZipManager.zippath == null)
            {
                texture = (Texture)ResourceLoader.Load(path);
                if (texture == null)
                {
                    GD.PrintErr($"Failed to load texture from path: {path}");
                }
            }
            else
            {
                //GD.Print("1 Open " + ZipManager.zippath + " filestream...");
                // Open the JAR file as a zip archive
                using (FileStream jarStream = new FileStream(ZipManager.zippath, FileMode.Open, System.IO.FileAccess.Read, FileShare.ReadWrite))
                {
                    //GD.Print("2 Open " + ZipManager.zippath + " ziparchive...");
                    using (ZipArchive archive = new ZipArchive(jarStream, ZipArchiveMode.Read))
                    {                        
                        //GD.Print("3 Locate " + path + " entry...");
                        // Locate the image entry inside the JAR
                        path = path.Replace("\\", "/");
                        ZipArchiveEntry entry = archive.GetEntry(path);
                        if (entry == null)
                        {
                            GD.PrintErr($"Image '{path}' not found in JAR '{ZipManager.zippath}'");
                            return;
                        }
                        //GD.Print("4 Found it, now read to array...");

                        // Read the image data into a byte array
                        using (Stream entryStream = entry.Open())
                        using (MemoryStream memoryStream = new MemoryStream())
                        {
                            entryStream.CopyTo(memoryStream);
                            byte[] imageData = memoryStream.ToArray();

                            // Load the image into a Godot Image
                            Image image = new Image();
                            Error err = image.LoadPngFromBuffer(imageData); // Use LoadPngFromBuffer if it's a PNG
                            if (err != Error.Ok)
                            {
                                GD.PrintErr("Failed to load image from buffer");
                                return;
                            }

                            // Create a texture from the image
                            texture = ImageTexture.CreateFromImage(image);
                        }
                    }
                }
            }
        

            page.rendererObject = texture;
        }
        public void Unload(Object texture)
        {
            if(texture is Texture){
                ((Texture)texture).Dispose();
            }
        }
    }
}

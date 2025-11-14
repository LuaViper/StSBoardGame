/******************************************************************************
 * Spine Runtimes Software License v2.5
 * 
 * Copyright (c) 2013-2016, Esoteric Software
 * All rights reserved.
 * 
 * You are granted a perpetual, non-exclusive, non-sublicensable, and
 * non-transferable license to use, install, execute, and perform the Spine
 * Runtimes software and derivative works solely for personal or internal
 * use. Without the written permission of Esoteric Software (see Section 2 of
 * the Spine Software License Agreement), you may not (a) modify, translate,
 * adapt, or develop new applications using the Spine Runtimes or otherwise
 * create derivative works or improvements of the Spine Runtimes or (b) remove,
 * delete, alter, or obscure any trademarks or any copyright, trademark, patent,
 * or other intellectual property or proprietary rights notices on or in the
 * Software, including any copy thereof. Redistributions in binary or source
 * form must include this license and terms.
 * 
 * THIS SOFTWARE IS PROVIDED BY ESOTERIC SOFTWARE "AS IS" AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
 * EVENT SHALL ESOTERIC SOFTWARE BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES, BUSINESS INTERRUPTION, OR LOSS OF
 * USE, DATA, OR PROFITS) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
 * IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 *****************************************************************************/

using Godot;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;

namespace Spine
{
    public struct VertexPositionColorTexture
    {
        public VertexPositionColorTexture() { }
        public Vector3 position;
        public Godot.Color color;
        public Vector2 textureCoordinate;
    }


    /// <summary>Draws region and mesh attachments.</summary>
    public partial class SkeletonMeshRenderer : GodotObject
    {
        private const int TL = 0;
        private const int TR = 1;
        private const int BL = 2;
        private const int BR = 3;

        //GraphicsDevice device;
        //MeshBatcher batcher;
        //RasterizerState rasterizerState;
        float[] vertices = new float[8];
        int[] quadTriangles = { 0, 1, 2, 1, 3, 2 };
        //BlendState defaultBlendState;

        //BasicEffect effect;
        //public BasicEffect Effect { get { return effect; } set { effect = value; } }

        private bool premultipliedAlpha;
        public bool PremultipliedAlpha { get { return premultipliedAlpha; } set { premultipliedAlpha = value; } }

        //public SkeletonMeshRenderer(GraphicsDevice device)
        //{
        //    this.device = device;

        //    batcher = new MeshBatcher();

        //    effect = new BasicEffect(device);
        //    effect.World = Matrix.Identity;
        //    effect.View = Matrix.CreateLookAt(new Vector3(0.0f, 0.0f, 1.0f), Vector3.Zero, Vector3.Up);
        //    effect.TextureEnabled = true;
        //    effect.VertexColorEnabled = true;

        //    rasterizerState = new RasterizerState();
        //    rasterizerState.CullMode = CullMode.None;

        //    Bone.yDown = true;
        //}

        //public void Begin()
        //{
        //    defaultBlendState = premultipliedAlpha ? BlendState.AlphaBlend : BlendState.NonPremultiplied;

        //    device.RasterizerState = rasterizerState;
        //    device.BlendState = defaultBlendState;

        //    effect.Projection = Matrix.CreateOrthographicOffCenter(0, device.Viewport.Width, device.Viewport.Height, 0, 1, 0);
        //}

        //public void End()
        //{
        //    foreach (EffectPass pass in effect.CurrentTechnique.Passes)
        //    {
        //        pass.Apply();
        //        batcher.Draw(device);
        //    }
        //}

        //Godot renderer requires these to be persistent non-static vars.
        //TODO: do we need to free these manually after use?
        private Godot.ArrayMesh arrayMesh;
        private Godot.Texture primaryTexture;
        public void DrawSkeletonToCanvas(Skeleton skeleton, CanvasItem canvasItem)
        {
            //GD.Print("---------------");
            arrayMesh = new Godot.ArrayMesh();
            primaryTexture = null;
            if (arrayMesh != null)
            {

                Godot.Collections.Array surfaceArray = [];
                surfaceArray.Resize((int)Mesh.ArrayType.Max);
                List<Vector3> verts = [];
                List<Vector2> uvs = [];
                List<Godot.Color> colors = [];
                List<int> indices = [];

                surfaceArray.Resize((int)Mesh.ArrayType.Max);



                float[] vertices = this.vertices;
                var drawOrder = skeleton.DrawOrder;
                var drawOrderItems = skeleton.DrawOrder.Items;
                float skeletonR = skeleton.R, skeletonG = skeleton.G, skeletonB = skeleton.B, skeletonA = skeleton.A;
                for (int i = 0, n = drawOrder.Count; i < n; i++)
                {
                    int firstNewVert = verts.Count;
                    Slot slot = drawOrderItems[i];
                    if (slot.data.name.ToLower().EndsWith("shadow") || slot.data.name.ToLower().EndsWith("shadowidle") || slot.data.name.ToLower().EndsWith("shadowdefensive"))
                    {
                        if(skeleton.IgnoreShadows) continue;
                    }
                    Attachment attachment = slot.Attachment;
                    if (attachment is RegionAttachment)
                    {
                        RegionAttachment regionAttachment = (RegionAttachment)attachment;

                        VertexPositionColorTexture[] itemVertices = new VertexPositionColorTexture[4];

                        AtlasRegion region = (AtlasRegion)regionAttachment.RendererObject;
                        Godot.Texture texture = (Godot.Texture)region.page.rendererObject;
                        if (primaryTexture==null) primaryTexture = texture;

                        Godot.Color color;
                        float a = skeletonA * slot.A * regionAttachment.A;
                        if (premultipliedAlpha)
                        {
                            color = new Color(
                                    skeletonR * slot.R * regionAttachment.R * a,
                                    skeletonG * slot.G * regionAttachment.G * a,
                                    skeletonB * slot.B * regionAttachment.B * a, a);
                        }
                        else
                        {
                            color = new Color(
                                    skeletonR * slot.R * regionAttachment.R,
                                    skeletonG * slot.G * regionAttachment.G,
                                    skeletonB * slot.B * regionAttachment.B, a);
                        }
                        itemVertices[TL].color = color;
                        itemVertices[BL].color = color;
                        itemVertices[BR].color = color;
                        itemVertices[TR].color = color;

                        regionAttachment.ComputeWorldVertices(slot.Bone, vertices);
                        itemVertices[TL].position.X = vertices[RegionAttachment.X1];
                        itemVertices[TL].position.Y = vertices[RegionAttachment.Y1];
                        itemVertices[TL].position.Z = 0;
                        itemVertices[BL].position.X = vertices[RegionAttachment.X2];
                        itemVertices[BL].position.Y = vertices[RegionAttachment.Y2];
                        itemVertices[BL].position.Z = 0;
                        itemVertices[BR].position.X = vertices[RegionAttachment.X3];
                        itemVertices[BR].position.Y = vertices[RegionAttachment.Y3];
                        itemVertices[BR].position.Z = 0;
                        itemVertices[TR].position.X = vertices[RegionAttachment.X4];
                        itemVertices[TR].position.Y = vertices[RegionAttachment.Y4];
                        itemVertices[TR].position.Z = 0;

                        float[] regionuvs = regionAttachment.UVs;
                        itemVertices[TL].textureCoordinate.X = regionuvs[RegionAttachment.X1];
                        itemVertices[TL].textureCoordinate.Y = regionuvs[RegionAttachment.Y1];
                        itemVertices[BL].textureCoordinate.X = regionuvs[RegionAttachment.X2];
                        itemVertices[BL].textureCoordinate.Y = regionuvs[RegionAttachment.Y2];
                        itemVertices[BR].textureCoordinate.X = regionuvs[RegionAttachment.X3];
                        itemVertices[BR].textureCoordinate.Y = regionuvs[RegionAttachment.Y3];
                        itemVertices[TR].textureCoordinate.X = regionuvs[RegionAttachment.X4];
                        itemVertices[TR].textureCoordinate.Y = regionuvs[RegionAttachment.Y4];
                        
                        //reminder: correct order is TL-TR-BL-BR, despite the previous code blocks
                        colors.Add(itemVertices[TL].color);
                        colors.Add(itemVertices[TR].color);
                        colors.Add(itemVertices[BL].color);
                        colors.Add(itemVertices[BR].color);
                        verts.Add(itemVertices[TL].position);
                        verts.Add(itemVertices[TR].position);
                        verts.Add(itemVertices[BL].position);
                        verts.Add(itemVertices[BR].position);
                        uvs.Add(itemVertices[TL].textureCoordinate);
                        uvs.Add(itemVertices[TR].textureCoordinate);
                        uvs.Add(itemVertices[BL].textureCoordinate);
                        uvs.Add(itemVertices[BR].textureCoordinate);
                        //GD.Print("Vert count: "+itemVertices.Length.ToString());
                        indices.Add(firstNewVert + quadTriangles[0]);
                        indices.Add(firstNewVert + quadTriangles[1]);
                        indices.Add(firstNewVert + quadTriangles[2]);
                        indices.Add(firstNewVert + quadTriangles[3]);
                        indices.Add(firstNewVert + quadTriangles[4]);
                        indices.Add(firstNewVert + quadTriangles[5]);
                        //GD.Print("New triangles: " + (firstNewVert + quadTriangles[0]).ToString()+"," + (firstNewVert + quadTriangles[1]).ToString() +"," + (firstNewVert + quadTriangles[2]).ToString() +"," + (firstNewVert + quadTriangles[3]).ToString() +"," + (firstNewVert + quadTriangles[4]).ToString() +"," + (firstNewVert + quadTriangles[5]).ToString() );

                        //canvasItem.Call("draw_mesh_item", item, slot.Data.name);                    
                    }
                    else if (attachment is MeshAttachment)
                    {
                        MeshAttachment mesh = (MeshAttachment)attachment;
                        int vertexCount = mesh.WorldVerticesLength;
                        if (vertices.Length < vertexCount) vertices = new float[vertexCount];
                        mesh.ComputeWorldVertices(slot, vertices);

                        int[] triangles = mesh.Triangles;

                        AtlasRegion region = (AtlasRegion)mesh.RendererObject;
                        Godot.Texture texture = (Texture2D)region.page.rendererObject;
                        if (primaryTexture == null) primaryTexture = texture;

                        Godot.Color color;
                        float a = skeletonA * slot.A * mesh.A;
                        if (premultipliedAlpha)
                        {
                            color = new Color(
                                    skeletonR * slot.R * mesh.R * a,
                                    skeletonG * slot.G * mesh.G * a,
                                    skeletonB * slot.B * mesh.B * a, a);
                        }
                        else
                        {
                            color = new Color(
                                    skeletonR * slot.R * mesh.R,
                                    skeletonG * slot.G * mesh.G,
                                    skeletonB * slot.B * mesh.B, a);
                        }

                        float[] meshuvs = mesh.UVs;
                        VertexPositionColorTexture[] itemVertices = new VertexPositionColorTexture[vertexCount];
                        for (int ii = 0, v = 0; v < vertexCount; ii++, v += 2)
                        {
                            itemVertices[ii].color = color;
                            itemVertices[ii].position.X = vertices[v];
                            itemVertices[ii].position.Y = vertices[v + 1];
                            itemVertices[ii].position.Z = 0;
                            itemVertices[ii].textureCoordinate.X = meshuvs[v];
                            itemVertices[ii].textureCoordinate.Y = meshuvs[v + 1];

                            colors.Add(itemVertices[ii].color);
                            verts.Add(itemVertices[ii].position);
                            uvs.Add(itemVertices[ii].textureCoordinate);
                        }
                        //GD.Print("Vert count: " + verts.Count.ToString());
                        for (int iii = 0; iii < triangles.Length; iii += 1)
                        {
                            indices.Add(firstNewVert + triangles[iii]);
                            //GD.Print("New triangles: " + (firstNewVert + triangles[iii]).ToString() + "...");
                        }
                        
                        //canvasItem.Call("draw_mesh_item", item, slot.Data.name);
                    }
                }
                surfaceArray[(int)Mesh.ArrayType.Vertex] = verts.ToArray();
                surfaceArray[(int)Mesh.ArrayType.TexUV] = uvs.ToArray();
                surfaceArray[(int)Mesh.ArrayType.Color] = colors.ToArray();
                surfaceArray[(int)Mesh.ArrayType.Index] = indices.ToArray();

                arrayMesh.AddSurfaceFromArrays(Mesh.PrimitiveType.Triangles, surfaceArray);
                canvasItem.DrawMesh(arrayMesh, (Godot.Texture2D)primaryTexture);
                //canvasItem.Call("debug_draw_callback", arrayMesh, (Godot.Texture2D)primaryTexture, colors.ToArray());
            }
            else
            {
                GD.PrintErr("Failed to initialize a new Godot.ArrayMesh");

            }
            

        }


    }
}

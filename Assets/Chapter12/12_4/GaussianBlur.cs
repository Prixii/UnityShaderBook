using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class GaussianBlur : PostEffectsBase
{

    public Shader gaussianShader;
    private Material gaussianMaterial = null;
    public Material material
    {
        get => CheckShaderAndCreateMaterial(gaussianShader, gaussianMaterial);
    }


    [Range(0, 4)]
    public int iterations = 3;

    [Range(0.2f, 3.0f)]
    public float blurSpread = 0.6f;

    [Range(1, 8)]
    public int downSample = 2;


    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (material == null)
        {
            Graphics.Blit(src, dest);
        }
        else
        {
            var rtW = src.width / downSample;
            var rtH = src.height / downSample;
            var buffer0 = RenderTexture.GetTemporary(rtW, rtH, 0);
            buffer0.filterMode = FilterMode.Bilinear;

            Graphics.Blit(src, buffer0);

            for (int i = 0; i < iterations; i++)
            {
                material.SetFloat("_BlurSize", 1.0f + i * blurSpread);
                var buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);
                Graphics.Blit(src, buffer1, material, 0);
                RenderTexture.ReleaseTemporary(buffer0);

                buffer0 = buffer1;
                buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);

                Graphics.Blit(buffer0, buffer1, material, 1);
                RenderTexture.ReleaseTemporary(buffer0);

                buffer0 = buffer1;
            }
            Graphics.Blit(buffer0, dest);

            RenderTexture.ReleaseTemporary(buffer0);
        }
    }
}

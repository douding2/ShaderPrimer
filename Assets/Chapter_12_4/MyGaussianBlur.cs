using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MyGaussianBlur : PostEffectsBase
{
    public Shader gaussianBlurShader;
    private Material _gaussianBlurMat;

    private Material _material
    {
        get
        {
            _gaussianBlurMat = CheckShaderAndCreateMaterial(gaussianBlurShader, _gaussianBlurMat);
            return _gaussianBlurMat;
        }
    }

    [Range(0, 4)]
    public int iterations = 3;

    [Range(0.2f, 3.0f)]
    public float blurSpread = 0.6f;
    
    [Range(1f, 8f)]
    public int downSample = 2;

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (_material)
        {
            int rtW = source.width / downSample;
            int rtH = source.height/ downSample;
            
            RenderTexture buffer = RenderTexture.GetTemporary(rtW, rtH, 0);
            buffer.filterMode = FilterMode.Bilinear;
            
            Graphics.Blit(source, buffer);
            
            for (int i = 0; i < iterations; i++)
            {
                _material.SetFloat("_BlurSize", 1 + i * blurSpread);
                
                RenderTexture buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);
                Graphics.Blit(buffer, buffer1, _material, 0);
                RenderTexture.ReleaseTemporary(buffer);
                buffer = buffer1;
                
                buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);
                Graphics.Blit(buffer, buffer1, _material, 1);
                RenderTexture.ReleaseTemporary(buffer);
                buffer = buffer1;
            }
            
            Graphics.Blit(buffer, destination, _material);
            RenderTexture.ReleaseTemporary(buffer);
        }
        else
            Graphics.Blit(source, destination);
    }
}

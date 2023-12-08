using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MyBloom : PostEffectsBase
{
    public Shader bloomShader;
    private Material _bloomMat;

    private Material _material
    {
        get
        {
            _bloomMat = CheckShaderAndCreateMaterial(bloomShader, _bloomMat);
            return _bloomMat;
        }
    }

    [Range(0, 4)] public float luminanceThreshold = 0.8f;

    [Range(0, 4)] public int iterations = 3;

    [Range(0.2f, 3.0f)] public float blurSpread = 0.6f;

    [Range(1f, 8f)] public int downSample = 2;

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (_material)
        {
            _material.SetFloat("_LuminanceThreshold", luminanceThreshold);

            int rtW = source.width / downSample;
            int rtH = source.height / downSample;

            RenderTexture buffer = RenderTexture.GetTemporary(rtW, rtH, 0);
            buffer.filterMode = FilterMode.Bilinear;

            Graphics.Blit(source, buffer, _material, 0);

            for (int i = 0; i < iterations; i++)
            {
                _material.SetFloat("_BlurSize", 1 + i * blurSpread);

                RenderTexture buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);
                Graphics.Blit(buffer, buffer1, _material, 1);
                RenderTexture.ReleaseTemporary(buffer);
                buffer = buffer1;

                buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);
                Graphics.Blit(buffer, buffer1, _material, 2);
                RenderTexture.ReleaseTemporary(buffer);
                buffer = buffer1;
            }

            _material.SetTexture("_Bloom", buffer);
            Graphics.Blit(source, destination, _material, 3);
            RenderTexture.ReleaseTemporary(buffer);
        }
        else
            Graphics.Blit(source, destination);
    }
}
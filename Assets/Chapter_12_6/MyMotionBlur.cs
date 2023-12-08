using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Serialization;

public class MyMotionBlur : PostEffectsBase
{
    public Shader motionBlurShader;
    private Material _motionBlurMat;

    private Material _material
    {
        get
        {
            _motionBlurMat = CheckShaderAndCreateMaterial(motionBlurShader, _motionBlurMat);
            return _motionBlurMat;
        }
    }

    [Range(0, 0.9f)] public float blurAmount = 0.5f;

    private RenderTexture cacheTexture;

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (_material)
        {
            if (!cacheTexture || cacheTexture.width != source.width || cacheTexture.height != source.height)
            {
                DestroyImmediate(cacheTexture);
                cacheTexture = new RenderTexture(source.width, source.height, 0)
                {
                    hideFlags = HideFlags.HideAndDontSave
                };
                Graphics.Blit(source, cacheTexture);
            }

            cacheTexture.MarkRestoreExpected();
            
            _material.SetFloat("_BlurAmount", 1 - blurAmount);
            Graphics.Blit(source, cacheTexture, _material);
            Graphics.Blit(cacheTexture, destination);
        }
        else
            Graphics.Blit(source, destination);
    }

    private void OnDisable()
    {
        DestroyImmediate(cacheTexture);
    }
}
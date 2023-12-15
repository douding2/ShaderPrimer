using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Serialization;

public class MyDepthTexture : PostEffectsBase
{
    public Shader shader;
    private Material _Mat;

    private Material _material
    {
        get
        {
            _Mat = CheckShaderAndCreateMaterial(shader, _Mat);
            return _Mat;
        }
    }

    private void Awake()
    {
        Camera.main.depthTextureMode |= DepthTextureMode.Depth;
        Camera.main.depthTextureMode |= DepthTextureMode.DepthNormals;
    }


    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (_material)
        {
            Graphics.Blit(source, destination, _material);
        }
        else
            Graphics.Blit(source, destination);
    }
}
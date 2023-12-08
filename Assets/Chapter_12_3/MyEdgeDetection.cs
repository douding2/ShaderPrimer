using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Serialization;

public class MyEdgeDetection : PostEffectsBase
{
    public Shader edgeDetectionShader;
    private Material _edgeDetectionMat;

    private Material _material
    {
        get
        {
            _edgeDetectionMat = CheckShaderAndCreateMaterial(edgeDetectionShader, _edgeDetectionMat);
            return _edgeDetectionMat;
        }
    }

    [Range(0, 1)] public float edgeOnly = 0f;

    public Color edgeColor = Color.black;

    public Color backgroundColor = Color.white;


    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (_material)
        {
            _material.SetFloat("_EdgeOnly", edgeOnly);
            _material.SetColor("_EdgeColor", edgeColor);
            _material.SetColor("_BackgroundColor", backgroundColor);
            Graphics.Blit(source, destination, _material);
        }
        else
            Graphics.Blit(source, destination);
    }
}
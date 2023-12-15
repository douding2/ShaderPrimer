using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Serialization;

public class MyMotionBluWithDepthTexturer : PostEffectsBase
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

    [Range(0, 1f)] public float blurSize = 0.5f;

    private Matrix4x4 previousViewProjectionMatrix;

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (_material)
        {
            _material.SetFloat("_BlurSize", blurSize);
            _material.SetMatrix("_PreviousViewProjectionMatrix", previousViewProjectionMatrix);
            Matrix4x4 currentViewProjectionMatrix =
                Camera.main.projectionMatrix * Camera.main.worldToCameraMatrix;
            Matrix4x4 currentViewProjectionInverseMatrix = currentViewProjectionMatrix.inverse;
            _material.SetMatrix("_CurrentViewProjectionInverseMatrix", currentViewProjectionInverseMatrix);
            previousViewProjectionMatrix = currentViewProjectionMatrix;
            Graphics.Blit(source, destination, _material);
        }
        else
            Graphics.Blit(source, destination);
    }

    private void OnEnable()
    {
        Camera.main.depthTextureMode |= DepthTextureMode.Depth;
    }
    
}
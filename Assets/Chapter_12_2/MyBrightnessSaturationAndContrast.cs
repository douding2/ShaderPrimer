using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MyBrightnessSaturationAndContrast : PostEffectsBase
{
    // Start is called before the first frame update
    public Shader briSatConShader;
    private Material _briSatConMaterial;

    public Material material
    {
        get
        {
            _briSatConMaterial = CheckShaderAndCreateMaterial(briSatConShader, _briSatConMaterial);
            return _briSatConMaterial;
        } 
    }

    [Range(0f, 3f)]
    public float brightness = 1f;
    
    [Range(0f, 3f)]
    public float saturation = 1f;
    
    [Range(0f, 3f)]
    public float contrast = 1f;

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (material)
        {
            material.SetFloat("_Brightness", brightness);
            material.SetFloat("_Saturation", saturation);
            material.SetFloat("_Contrast", contrast);
            
            Graphics.Blit(source, destination, material);
        }
        else
            Graphics.Blit(source, destination);
    }
    
    
}

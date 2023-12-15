using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Serialization;

public class MyFogWithDepthTexture : PostEffectsBase
{
    public Shader fogShader;
    private Material _fogMat;

    private Material _material
    {
        get
        {
            _fogMat = CheckShaderAndCreateMaterial(fogShader, _fogMat);
            return _fogMat;
        }
    }

    [Range(0, 3f)] public float fogDensity = 1f;
    public Color fogColor = Color.white;

    public float fogStart = 0f;
    public float fogEnd = 2f;

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (_material)
        {
            Camera camera = Camera.main;

            Matrix4x4 frustumCorners = Matrix4x4.identity;

            float fov = camera.fieldOfView;
            float near = camera.nearClipPlane;
            float far = camera.farClipPlane;
            float aspect = camera.aspect;

            float halfHeight = near * Mathf.Tan(fov * 0.5f * Mathf.Deg2Rad);
            Vector3 toRight = camera.transform.right * halfHeight * aspect;
            Vector3 toTop = camera.transform.up * halfHeight;

            Vector3 topLeft = camera.transform.forward * near + toTop - toRight;
            float scale = topLeft.magnitude / near;

            topLeft.Normalize();
            topLeft *= scale;

            Vector3 topRight = camera.transform.forward * near + toRight + toTop;
            topRight.Normalize();
            topRight *= scale;

            Vector3 bottomLeft = camera.transform.forward * near - toRight - toTop;
            bottomLeft.Normalize();
            bottomLeft *= scale;

            Vector3 bottomRight = camera.transform.forward * near + toRight - toTop;
            bottomRight.Normalize();
            bottomRight *= scale;
            
            frustumCorners.SetRow(0, bottomLeft);
            frustumCorners.SetRow(1, bottomRight);
            frustumCorners.SetRow(2, topRight);
            frustumCorners.SetRow(3, topLeft);
            
            _material.SetMatrix("_FrustumCornersRay", frustumCorners);
            _material.SetMatrix("_CurrentViewProjectionInverseMatrix", (camera.projectionMatrix * camera.worldToCameraMatrix).inverse);
            
            _material.SetFloat("_FogDensity", fogDensity);
            _material.SetColor("_FogColor", fogColor);
            _material.SetFloat("_FogStart", fogStart);
            _material.SetFloat("_FogEnd", fogEnd);

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
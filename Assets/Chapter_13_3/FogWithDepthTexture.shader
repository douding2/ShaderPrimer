Shader "Unity Shaders Book/Chapter 13/Fog With Depth Texture"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }

    SubShader
    {
        CGINCLUDE
        #include "UnityCG.cginc"

        struct v2f
        {
            float4 pos : SV_POSITION;
            half2 uv : TEXCOORD0;
            half2 uv_depth : TEXCOORD0;
            float4 interpolatedRay : TEXCOORD1;
        };

        sampler2D _MainTex;
        half4 _MainTex_TexelSize;
        sampler2D _CameraDepthTexture;
        float _FogDensity;
        fixed3 _FogColor;
        float _FogStart;
        float _FogEnd;
        float4x4 _FrustumCornersRay;
        float4x4 _CurrentViewProjectionInverseMatrix;

        v2f vert(appdata_img v)
        {
            v2f o;
            o.pos = UnityObjectToClipPos(v.vertex);
            o.uv = v.texcoord;
            o.uv_depth = v.texcoord;
            int index = 0;
            if (v.texcoord.x < 0.5 && v.texcoord.y < 0.5)
                index = 0;
            else if (v.texcoord.x > 0.5 && v.texcoord.y < 0.5)
                index = 1;
            else if (v.texcoord.x > 0.5 && v.texcoord.y > 0.5)
                index = 2;
            else
                index = 3;
            #if UNITY_UV_STARTS_AT_TOP
            if (_MainTex_TexelSize.y < 0)
            {
                index = 3 - index;
                o.uv_depth.y = 1 - o.uv_depth.y;
            }
            #endif
            
            o.interpolatedRay = _FrustumCornersRay[index];
            
            return o;
        }

        fixed4 frag(v2f i) : SV_Target
        {
            float linearDepth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv_depth));
            float3 worldPos = _WorldSpaceCameraPos + linearDepth * i.interpolatedRay.xyz;
            float fogDensity = (_FogStart + abs(worldPos.z - _WorldSpaceCameraPos.z)) / (_FogEnd - _FogStart); //自己算计了下基于深度的雾
            fogDensity = saturate(fogDensity * _FogDensity);

            fixed4 fColor = tex2D(_MainTex, i.uv);
            fColor.rgb = lerp(fColor.rgb, _FogColor.rgb, fogDensity);
            // return fixed4(linearDepth / 255, linearDepth / 255,linearDepth / 255, 1);
            return fColor;
        }
        ENDCG

        ZTest Always
        Cull Off
        ZWrite Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            ENDCG
        }

    }
}
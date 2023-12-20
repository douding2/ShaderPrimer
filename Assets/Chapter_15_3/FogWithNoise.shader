Shader "Unity Shaders Book/Chapter 15/Fog With Noise"
{
    Properties
    {
        _MainTex ("Main Tex", 2D) = "white" {}
        _FogDensity ("Fog Density", Float) = 0
        _FogColor ("Fog Color", Color) = (1, 1, 1, 1)
        _FogStart ("_FogStart", Float) = 0
        _FogEnd ("_FogEnd", Float) = 1
        _NoiseTex ("Noise Map", 2D) = "white" {}
        _FogXSpeed ("Fog X Speed", Float) = 0.1
        _FogYSpeed ("Fog Y Speed", Float) = 0.1
        _NoiseAmount ("Noise Amount", Float) = 1
    }

    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }

        Pass
        {
            Tags
            {
                "LightMode" = "ForwardBase"
            }

            Cull Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                half2 uv : TEXCOORD0;
                half2 uv_depth : TEXCOORD0;
                float4 interpolatedRay : TEXCOORD1;
            };

            float4x4 _FrustumCornersRay;
            sampler2D _MainTex;
            float4 _MainTex_TexelSize;
            sampler2D _CameraDepthTexture;
            float _FogDensity;
            fixed4 _FogColor;
            float _FogStart;
            float _FogEnd;
            float _FogXSpeed;
            float _FogYSpeed;
            float _NoiseAmount;
            sampler2D _NoiseTex;
            float4 _NoiseTex_ST;

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
                float linerDepth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv_depth));
                float3 worldPos = _WorldSpaceCameraPos + linerDepth * i.interpolatedRay.xyz;

                float2 speed = _Time.y * float2(_FogXSpeed, _FogYSpeed);
                float noise = (tex2D(_NoiseTex, i.uv + speed).r - 0.5) * _NoiseAmount;

                float fogDensity = (_FogEnd - worldPos.y) / (_FogEnd - _FogStart);
                fogDensity = saturate(fogDensity * _FogDensity * (1 + noise));

                fixed4 finalColor = tex2D(_MainTex, i.uv);
                finalColor.rgb = lerp(finalColor.rgb, _FogColor.rgb, fogDensity);

                return  finalColor;
            }
            ENDCG

        }
    }

}
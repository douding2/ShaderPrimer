Shader "Unity Shaders Book/Chapter 12/Bloom"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Bloom ("Bloom", 2D) = "white" {}
        _LuminanceThreshold ("Luminance Threshold", Float) = 0.6
        _BlurSize ("BlurSize", Float) = 1.0
    }

    SubShader
    {
        CGINCLUDE
        #include "UnityCG.cginc"

        struct v2fLuminance
        {
            float4 pos : SV_POSITION;
            half2 uv : TEXCOORD0;
        };

        struct v2fBloom
        {
            float4 pos : SV_POSITION;
            half4 uv : TEXCOORD0;
        };

        sampler2D _MainTex;
        half4 _MainTex_TexelSize;
        sampler2D _Bloom;
        fixed _LuminanceThreshold;
        fixed _BlurSize;

        fixed luminance(fixed4 color)
        {
            return 0.2125 * color.r + 0.7154 * color.g + 0.0721 * color.b;
        }

        v2fLuminance vertLuminance(appdata_img v)
        {
            v2fLuminance o;
            o.pos = UnityObjectToClipPos(v.vertex);
            o.uv = v.texcoord;

            return o;
        }

        fixed4 fragLuminance(v2fLuminance i) : SV_Target
        {
            fixed4 c = tex2D(_MainTex, i.uv);
            fixed4 val = clamp(luminance(c) - _LuminanceThreshold, 0, 1.0);
            return c * val;
        }

        v2fBloom vertBloom(appdata_img v)
        {
            v2fBloom o;
            o.pos = UnityObjectToClipPos(v.vertex);
            o.uv.xy = v.texcoord;
            o.uv.zw = v.texcoord;
            #if UNITY_UV_STARTS_AT_TOP
            if (_MainTex_TexelSize.y < 0)
            {
                o.uv.w = 1 - o.uv.w;
            }
            #endif

            return o;
        }

        fixed4 fragBloom(v2fBloom i) : SV_Target
        {
            return tex2D(_MainTex, i.uv.xy) + tex2D(_Bloom, i.uv.zw);
        }
        
        ENDCG

        ZTest Always
        Cull Off
        ZWrite Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vertLuminance
            #pragma fragment fragLuminance
            ENDCG
        }

        UsePass "Unity Shaders Book/Chapter 12/Gaussian Blur/GAUSSIAN_BLUR_VERTICAL"
        
        UsePass "Unity Shaders Book/Chapter 12/Gaussian Blur/GAUSSIAN_BLUR_HORIZONTAL"
        

        Pass
        {
            CGPROGRAM
            #pragma vertex vertBloom
            #pragma fragment fragBloom
            ENDCG
        }
    }
}
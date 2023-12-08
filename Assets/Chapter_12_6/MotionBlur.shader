Shader "Unity Shaders Book/Chapter 12/Motion Blur"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BlurAmount ("_BlurAmount", Float) = 0.6
    }

    SubShader
    {
        CGINCLUDE
        #include "UnityCG.cginc"

        struct v2f
        {
            float4 pos : SV_POSITION;
            half2 uv : TEXCOORD0;
        };

        sampler2D _MainTex;
        half4 _MainTex_TexelSize;
        fixed _BlurAmount;
        
        v2f vert(appdata_img v)
        {
            v2f o;
            o.pos = UnityObjectToClipPos(v.vertex);
            o.uv = v.texcoord;

            return o;
        }

        fixed4 fragRGB(v2f i) : SV_Target
        {
            return float4(tex2D(_MainTex, i.uv).rgb, _BlurAmount);
        }
        
        fixed4 fragA(v2f i) : SV_Target
        {
            return tex2D(_MainTex, i.uv);
        }
        
        ENDCG

        ZTest Always
        Cull Off
        ZWrite Off

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment fragRGB
            ENDCG
        }

        Pass
        {
            Blend One Zero
            ColorMask A
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment fragA
            ENDCG
        }
    }
}
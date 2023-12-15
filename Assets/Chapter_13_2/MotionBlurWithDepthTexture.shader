Shader "Unity Shaders Book/Chapter 13/Motion Blur With Depth Texture"
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
        };

        sampler2D _MainTex;
        half4 _MainTex_TexelSize;
        sampler2D _CameraDepthTexture;
        fixed _BlurSize;
        float4x4 _PreviousViewProjectionMatrix;
        float4x4 _CurrentViewProjectionInverseMatrix;

        v2f vert(appdata_img v)
        {
            v2f o;
            o.pos = UnityObjectToClipPos(v.vertex);
            o.uv = v.texcoord;
            o.uv_depth = v.texcoord;
            #if UNITY_UV_STARTS_AT_TOP
            if (_MainTex_TexelSize.y < 0)
            {
                o.uv_depth.y = 1 - o.uv_depth.y;
            }
            #endif

            return o;
        }

        fixed4 frag(v2f i) : SV_Target
        {
            float d = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv_depth);
            float4 h = float4(i.uv.x * 2 - 1, i.uv.y * 2 - 1, d * 2 - 1, 1);
            float4 D = mul(_CurrentViewProjectionInverseMatrix, h);
            float4 worldPos = D / D.w;
            float4 currentPos = h;
            float4 previousPos = mul(_PreviousViewProjectionMatrix, worldPos);
            previousPos /= previousPos.w;

            float2 velocity = (currentPos.xy - previousPos.xy) / 2.0f;
            float2 uv = i.uv;
            float4 c = tex2D(_MainTex, uv);
            uv += velocity * _BlurSize;
            for (int it = 0; it < 3; ++it, uv += velocity * _BlurSize)
            {
                float4 currentColor = tex2D(_MainTex, uv);
                c += currentColor;
            }
            c /= 3;

            return fixed4(c.rgb, 1);
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
Shader "Unity Shaders Book/Chapter 11/Image Sequence Animation"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _DetailTex ("Texture", 2D) = "white" {}
        _ScrollX ("Base Layer Speed", Float) = 1
        _Scroll2X ("2nd Layer Speed", Float) = 0.5
        _Multiplier ("Multiplier", Float) = 1
    }
    SubShader
    {
        Tags
        {
            "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType"="Opaque"
        }

        Pass
        {
            Tags
            {
                "LightMode" = "ForwardBase"
            }
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            fixed4 _MainTex_ST;
            sampler2D _DetailTex;
            fixed4 _DetailTex_ST;
            float _ScrollX;
            float _Scroll2X;
            float _Multiplier;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;
            };


            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex) + frac(float2(_ScrollX, 0) * _Time.y);
                o.uv.zw = TRANSFORM_TEX(v.texcoord, _DetailTex) + frac(float2(_Scroll2X, 0) * _Time.y);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 first = tex2D(_MainTex, i.uv.xy);
                fixed4 second = tex2D(_DetailTex, i.uv.zw);
                fixed4 c = lerp(first, second, second.a);
                c.rgb *= _Multiplier;
                return c; //fixed4(row / 255, row /255, row/255 ,1);
            }
            ENDCG
        }
    }
}
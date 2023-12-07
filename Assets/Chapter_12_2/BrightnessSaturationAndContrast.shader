Shader "Unity Shaders Book/Chapter 12/Brightness Saturation And Contrast"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Brightness ("_Brightness", Float) = 1
        _Saturation ("_Saturation", Float) = 1
        _Contrast ("_Contrast", Float) = 1
    }

    SubShader
    {
        Pass
        {
            ZTest Always
            Cull Off
            ZWrite Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            half _Brightness;
            half _Saturation;
            half _Contrast;

            v2f vert(appdata_img v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex); // v.texcoord;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 tex = tex2D(_MainTex, i.uv);

                fixed3 finalColor = tex.rgb * _Brightness;

                fixed luminance = 0.2125 * tex.r + 0.7154 * tex.g + 0.0721 * tex.b;
                fixed3 luminanceColor = fixed3(luminance, luminance, luminance);
                finalColor = lerp(luminanceColor, finalColor, _Saturation);

                fixed3 avgColor = fixed3(0.5, 0.5, 0.5);
                finalColor = lerp(avgColor, finalColor, _Contrast);

                return fixed4(finalColor, tex.a);
            }
            ENDCG
        }
    }
}
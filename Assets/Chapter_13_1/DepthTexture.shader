Shader "Unity Shaders Book/Chapter 13/DepthTexture"
{
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            sampler2D _MainTex;
            float4 _MainTex_TexelSize;
            sampler2D _CameraDepthTexture;
            sampler2D _CameraDepthNormalsTexture;

            v2f vert(appdata_img v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                if (_MainTex_TexelSize.y < 0) //像素的y小于则说明进行了反转
					o.uv.y = 1 - o.uv.y;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv);
                float linerDepth = Linear01Depth(depth);
                float3 color = tex2D(_MainTex, i.uv);
                return fixed4(float3(linerDepth, linerDepth, linerDepth), 1);
                // fixed3 normal = DecodeViewNormalStereo(tex2D(_CameraDepthNormalsTexture, i.uv));
                // return fixed4(normal * 0.5 + 0.5, 1);
            }
            ENDCG
        }
    }

    Fallback "Diffuse"
}

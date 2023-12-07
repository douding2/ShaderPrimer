Shader "Unity Shaders Book/Chapter 11/Billboard"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
        _VerticalBillboard ("Vertical Billboard", Range(0 , 1)) = 1
    }
    SubShader
    {
        Tags
        {
            "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType"="Transparent" "DisableBatching" = "True"
        }

        Pass
        {
            Tags
            {
                "LightMode" = "ForwardBase"
            }
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            fixed4 _MainTex_ST;
            fixed4 _Color;
            float _VerticalBillboard;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };


            v2f vert(appdata v)
            {
                v2f o;
                float3 center = float3(0, 0, 0);
                float3 viewer = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1));
                float3 normalDir = viewer - center;
                normalDir.y = normalDir.y * _VerticalBillboard;
                normalDir = normalize(normalDir);
                float3 upDir = abs(normalDir.y) > 0.999 ? float3(0, 0, 1) : float3(0, 1, 0);
                float3 rightDir = normalize(cross(upDir, normalDir));
                upDir = normalize(cross(normalDir, rightDir));

                float3 centerOffset = v.vertex.xyz - center;
                float3 localPos = center + rightDir * centerOffset.x + upDir * centerOffset.y + normalDir * centerOffset
                    .z;

                o.pos = UnityObjectToClipPos(float4(localPos, 1));
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 c = tex2D(_MainTex, i.uv);
                c.rgb *= _Color;
                return c;
            }
            ENDCG
        }
    }
}
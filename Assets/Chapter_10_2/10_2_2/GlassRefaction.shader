Shader "Unity Shaders Book/Chapter 10/Glass Refaction"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _BumpMap ("Normal Map", 2D) = "white" {}
        _CubeMap ("Cube Map", Cube) = "white" {}
        _Distortion ("Distortion", Range(0, 100)) = 10
        _RefractAmount ("_Refract Amount", Range(0, 1.0)) = 1.0
    }


    SubShader
    {
        Tags
        {
            "Queue"="Transparent" "RenderType"="Opaque"
        }

        GrabPass
        {
            "_RefractionTex"
        }

        Pass
        {
            Tags
            {
                "LightMode" = "ForwardBase"
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            samplerCUBE _CubeMap;
            float _Distortion;
            float _RefractAmount;
            sampler2D _RefractionTex;
            float4 _RefractionTex_TexelSize;

            struct a2v
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 scrPos : TEXCOORD0;
                float4 uv : TEXCOORD1;
                float4 TBN0 : TEXCOORD2;
                float4 TBN1 : TEXCOORD3;
                float4 TBN2 : TEXCOORD4;
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                ///获取屏幕图像的采样坐标
                o.scrPos = ComputeGrabScreenPos(o.pos);

                o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv.zw = TRANSFORM_TEX(v.uv, _BumpMap);

                float3 worldPos = mul(unity_ObjectToWorld, v.vertex);
                fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
                fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
                fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;

                //TBN的逆矩阵, 用来将切线空间转到世界空间
                o.TBN0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
                o.TBN1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
                o.TBN2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float3 worldPos = float3(i.TBN0.w, i.TBN1.w, i.TBN2.w);
                fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));

                //获取切线空间下的法线
                fixed3 bump = UnpackNormal(tex2D(_BumpMap, i.uv.zw));
                //计算切线空间下的偏移
                float2 offset = bump.xy * _Distortion * _RefractionTex_TexelSize.xy;
                i.scrPos.xy = offset + i.scrPos.xy;
                fixed3 refrCol = tex2D(_RefractionTex, i.scrPos.xy / i.scrPos.w).rgb;
                //将法线从切线转到世界空间
                bump = normalize(half3(dot(i.TBN0.xyz, bump), dot(i.TBN1.xyz, bump), dot(i.TBN2.xyz, bump)));

                fixed3 reflDir = reflect(-worldViewDir, bump);
                fixed3 texColor = tex2D(_MainTex, i.uv.xy);
                fixed3 reflCol = texCUBE(_CubeMap, reflDir).rgb * texColor.rgb;

                fixed3 finalColor = reflCol * (1 - _RefractAmount) + refrCol * _RefractAmount;

                return float4(finalColor, 1);
            }
            ENDCG
        }
    }
}
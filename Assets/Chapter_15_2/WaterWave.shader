Shader "Unity Shaders Book/Chapter 15/Water Wave"
{
    Properties
    {
        _Color ("Color", Color) = (0, 0.15, 0.15, 1)
        _MainTex ("Main Tex", 2D) = "white" {}
        _WaveMap ("Wave Map", 2D) = "bump" {}
        _CubeMap ("Cube Map", Cube) = "_skybox" {}
        _WaveXSpeed ("Line Horizontal Speed", Range(-0.1, 0.1)) = 0.01
        _WaveYSpeed ("Line Vertical Speed", Range(-0.1, 0.1)) = 0.01
        _Distortion ("Distortion", Range(0, 100)) = 10
    }

    SubShader
    {
        Tags
        {
            "Queue" = "Transparent"
            "RenderType"="Opaque"
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
                float4 scrPos : TEXCOORD0;
                float4 uv : TEXCOORD1;
                float4 T2W0 : TEXCOORD2;
                float4 T2W1 : TEXCOORD3;
                float4 T2W2 : TEXCOORD4;
            };

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _WaveMap;
            float4 _WaveMap_ST;
            samplerCUBE _CubeMap;
            float _WaveXSpeed;
            float _WaveYSpeed;
            float _Distortion;
            sampler2D _RefractionTex;
            float4 _RefractionTex_TexelSize;

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                
                o.scrPos = ComputeGrabScreenPos(o.pos);
                
                o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.uv.zw = TRANSFORM_TEX(v.texcoord, _WaveMap);

                float3 worldPos = mul(unity_ObjectToWorld, v.vertex);
                fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
                fixed3 worldTangent = UnityObjectToWorldDir(v.tangent);
                fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;

                o.T2W0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
                o.T2W1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
                o.T2W2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);

                TRANSFER_SHADOW(o);

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float3 worldPos = float3(i.T2W0.w, i.T2W1.w, i.T2W2.w);
                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));
                float2 speed = _Time.y * float2(_WaveXSpeed, _WaveYSpeed);

                fixed3 wave1 = UnpackNormal(tex2D(_WaveMap, i.uv.zw + speed));
                fixed3 wave2 =UnpackNormal(tex2D(_WaveMap, i.uv.zw - speed));
                fixed3 bump = normalize(wave1 + wave2);

                float2 offset = bump.xy * _Distortion * _RefractionTex_TexelSize.xy;
                i.scrPos.xy = offset + i.scrPos.xy;
                fixed3 refrCol = tex2D(_RefractionTex, i.scrPos.xy / i.scrPos.w).rgb;

                bump = normalize(half3(dot(i.T2W0.xyz, bump), dot(i.T2W1.xyz, bump), dot(i.T2W2.xyz, bump)));

                fixed4 texColor = tex2D(_MainTex, i.uv.xy + speed);
                fixed3 reflDir = reflect(-viewDir, bump);
                fixed3 reflCol = texCUBE(_CubeMap, reflDir).rgb * texColor.rgb * _Color.rgb;

                fixed fresnel = pow(1 - saturate(dot(viewDir, bump)), 4);
                fixed3 finalColor = reflCol * fresnel + refrCol * (1 - fresnel);

                return fixed4(finalColor, 1);
            }
            ENDCG

        }
    }

}
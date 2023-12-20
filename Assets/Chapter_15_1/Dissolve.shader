Shader "Unity Shaders Book/Chapter 15/Dissolve"
{
    Properties
    {
        _BurnAmount ("Burn Amount", Range(0, 1)) = 0
        _LineWidth ("Line Width", Range(0, 0.2)) = 0.1
        _MainTex ("Main Tex", 2D) = "white" {}
        _Normal ("Normal Map", 2D) = "bump" {}
        _BurnMap ("Burn Map", 2D) = "white" {}
        _BurnFirstColor ("Burn First Color", Color) = (1, 0, 0, 1)
        _BurnSecondColor ("Burn Second Color", Color) = (1, 0, 0, 1)
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
                "LightMode" = "ShadowCaster"
            }
            
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_shadowcaster

            #include "UnityCG.cginc"

            float _BurnAmount;
            sampler2D _BurnMap;
            float4 _BurnMap_ST;
            
            struct v2f
            {
                V2F_SHADOW_CASTER;
                float2 uvBurn : TEXCOORD1;
            };

            v2f vert(appdata_base v)
            {
                v2f o;
                
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
                
                o.uvBurn = TRANSFORM_TEX(v.texcoord, _BurnMap);
                
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed3 burn = tex2D(_BurnMap, i.uvBurn);
                clip(burn.r - _BurnAmount);
                SHADOW_CASTER_FRAGMENT(i)
            }
            
            ENDCG
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
                float4 uv : TEXCOORD0;
                float2 uvBurn : TEXCOORD1;
                float3 lightDir : TEXCOORD2;
                float3 worldPos : TEXCOORD3;
                SHADOW_COORDS(4)
            };

            float _BurnAmount;
            float _LineWidth;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _Normal;
            float4 _Normal_ST;
            sampler2D _BurnMap;
            float4 _BurnMap_ST;
            fixed4 _BurnFirstColor;
            fixed4 _BurnSecondColor;

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.uv.zw = TRANSFORM_TEX(v.texcoord, _Normal);
                o.uvBurn = TRANSFORM_TEX(v.texcoord, _BurnMap);

                TANGENT_SPACE_ROTATION; //直接计算tbn
                o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex));

                TRANSFER_SHADOW(o);

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed3 burn = tex2D(_BurnMap, i.uvBurn);
                clip(burn.r - _BurnAmount);

                fixed4 normal = tex2D(_Normal, i.uv.zw);
                fixed3 tangentNormal = UnpackNormal(normal);
                fixed3 albode = tex2D(_MainTex, i.uv.xy);
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albode;
                fixed3 diff = _LightColor0.rgb * albode.rgb * max(0, dot(tangentNormal, normalize(i.lightDir)));

                fixed t = 1 - smoothstep(0, _LineWidth, burn.r - _BurnAmount);
                fixed3 burnColor = lerp(_BurnFirstColor, _BurnSecondColor, t);
                burnColor = pow(burnColor, 5);

                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos)

                fixed3 finalColor = lerp(ambient + diff * atten, burnColor, t * step(0.0001, _BurnAmount));

                return fixed4(finalColor, 1);
            }
            ENDCG

        }
    }

}
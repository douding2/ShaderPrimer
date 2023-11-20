Shader "Unity Shaders Book/Chapter 7/MaskTexture"
{
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
        _MainTex ("Main Texture", 2D) = "white" {}
        _BumpTex ("Normal Texture", 2D) = "bump" {}
        _BumpScale ("Normal Scale", float) = 1.0
        _SpecularMask ("_SpecularMask", 2D) = "white" {}
        _SpecularScale ("SpecularMask Scale", float) = 1.0
        _Specular ("Specular", Color) = (1,1,1,1)
        _Gloss ("Gloss", Range(8.0, 256)) = 20
    }
    SubShader
    {
        Pass
        {
            Tags {"LightModel" = "FowardBase"}
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpTex;
            float4 _BumpTex_ST;
            float _BumpScale;
            sampler2D _SpecularMask;
            float4 _SpecularMask_ST;
            float _SpecularScale;
            fixed4 _Specular;
            float _Gloss;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 lightDir : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
            };


            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                float3 binormal = cross(v.tangent.xyz, v.normal.xyz) * v.tangent.w;
                //这个是模型空间到切线空间的逆矩阵
                float3x3 rotate = float3x3(v.tangent.xyz, binormal.xyz, v.normal.xyz);
                o.lightDir = mul(rotate, ObjSpaceLightDir(v.vertex)).xyz;
                o.viewDir = mul(rotate, ObjSpaceViewDir(v.vertex)).xyz;
                // o.uv = v.texcoord * _RampTex_ST.xy + _RampTex_ST.zw;
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 tangentNormal = UnpackNormal(tex2D(_BumpTex, i.uv));
                tangentNormal.xy *= _BumpScale;
                tangentNormal.z = sqrt(1.0- saturate(dot(tangentNormal.xy, tangentNormal.xy)));

                fixed3 abledo = tex2D(_MainTex, i.uv) * _Color;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * abledo;

                float3 tangentLight = normalize(i.lightDir);
                float3 tangentView = normalize(i.viewDir);

                //兰伯特公式计算的漫反射
                fixed3 diffuse = _LightColor0.rgb * abledo * max(0, dot(tangentNormal, tangentLight));

                //计算高光
                fixed3 halfDir = normalize(tangentLight + tangentView);
                fixed SpecularMask = tex2D(_SpecularMask, i.uv).r * _SpecularScale;
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(tangentNormal, halfDir)), _Gloss) * SpecularMask;

                return fixed4(ambient + diffuse + specular, 1.0); 
            }

            ENDCG
        }
    }
}
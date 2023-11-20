// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unity Shaders Book/Chapter 6/BllinnPhong"
{
   Properties
    {
        _Diffuse ("Diffuse", Color) = (1,1,1,1)
        _Specular ("Specular", Color) = (1,1,1,1)
        _Gloss ("Gloss", Range(8.0, 256)) = 20
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Tags {"LightModel" = "FowardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;

            struct appdata
            {
                float4 vertex : POSITION;
                fixed3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                fixed3 worldNormal : TEXCOORD0;
                fixed3 worldPos : TEXCOORD1;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                //将法线从模型空间转成世界空间
                o.worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                  //获得Unity环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                //获得归一化的光照方向
                fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
                //兰伯特公式计算的漫反射
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(i.worldNormal, worldLight));
                //获得视野方向
                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos);
                //获得矢量h
                fixed3 halfDir = normalize(worldLight + viewDir);
                //计算高光
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(i.worldNormal, halfDir)), _Gloss);
                //将漫反射, 高光和环境光混合输出到颜色
                fixed3 color = ambient + diffuse + specular;
                return fixed4(color, 1.0);
            }

            ENDCG
        }
    }

    FallBack "Diffuse"
}

Shader "Unity Shaders Book/Chapter 7/NormalMapTangentSpace"
{
   Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
        _MainTex ("Main Texture", 2D) = "white" {}
        _BumpMap ("Normal Map", 2D) = "bump" {}
        _BumpScale ("Normal Scale", float) = 1.0
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

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            float _BumpScale;
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
                float4 uv : TEXCOORD0;
                fixed3 lightDir : TEXCOORD1;
                fixed3 viewDir : TEXCOORD2;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                //计算纹理缩放和偏移
                o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;

                //计算下副法线 从法线和切线的叉积的来, w分量确定朝向
                float3 binormal = cross(normalize(v.normal), normalize(v.tangent.xyz)) * v.tangent.w;
                //计算下从模型空间到切线空间的转换矩阵
                float3x3 rotate = float3x3(v.tangent.xyz, binormal, v.normal);

                //将光照方向和观察方向从模型空间转换到切线空间
                o.lightDir = mul(rotate, ObjSpaceLightDir(v.vertex)).xyz;
                o.viewDir = mul(rotate, ObjSpaceViewDir(v.vertex)).xyz;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                ///单位话切线空间关照方向和观察方向
                fixed3 tangentLightDir = normalize(i.lightDir);
                fixed3 tangentViewDir = normalize(i.viewDir);
                //获得贴图和基础颜色混合的颜色
                fixed3 abledo = tex2D(_MainTex, i.uv.xy).rgb * _Color.rgb;
                //获得法线贴图偏移后的数据
                fixed4 packedNormal = tex2D(_BumpMap, i.uv.zw);
                //从法线贴图获得法线向量 因为法线贴图的向量范围是[0, 1], 而法线的范围是[-1,1] 所以需要转换一下
                fixed3 tangentNormal;
                // tangentNormal.xy = (packedNormal.xy * 2 - 1) * _BumpScale;
                // tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));
                //因为Unity存储缘故, 上面的计算方式会失效, 采用Unity提供的函数来计算
                tangentNormal = UnpackNormal(packedNormal);
                tangentNormal.xy *= _BumpScale;
                tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));

                //获得Unity环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * abledo;
                //兰伯特公式计算的漫反射
                fixed3 diffuse = _LightColor0.rgb * abledo.rgb * max(0, dot(tangentNormal, tangentLightDir)); //为何改成max而不是saturate?
                //获得单位矢量h
                fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);
                //计算高光
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(tangentNormal, halfDir)), _Gloss);
                //将漫反射, 高光和环境光混合输出到颜色
                return fixed4(ambient + diffuse + specular, 1.0);
            }

            ENDCG
        }
    }

    FallBack "Specular"
}

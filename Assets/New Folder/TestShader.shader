Shader "Unlit/TestShader"
{
   Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
        _MainTex ("Texture", 2D) ="white" {}
        _MainTex2 ("Texture2", 2D) ="white" {}
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
            sampler2D _MainTex2;
            float4 _MainTex2_ST;
            fixed4 _Specular;
            float _Gloss;

            struct appdata
            {
                float4 vertex : POSITION;
                fixed3 normal : NORMAL;
                fixed3 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                fixed3 worldNormal : TEXCOORD0;
                fixed3 worldPos : TEXCOORD1;
                float2 uv : TEXCOORD2;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                //使用内置函数将法线从模型空间转成世界空间
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                //计算纹理缩放和偏移
                o.uv = v.texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 worldNormal = normalize(i.worldNormal);
                //获得贴图和基础颜色混合的颜色
                fixed3 abledo = abledo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
                if (i.uv.y < 0.5) {
                    abledo = tex2D(_MainTex2, i.uv).rgb * _Color.rgb;
                }
                //获得Unity环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * abledo;
                //通过内置函数获得单位光照方向
                fixed3 worldLight = normalize(UnityWorldSpaceLightDir(i.worldPos));
                //兰伯特公式计算的漫反射
                fixed3 diffuse = _LightColor0.rgb * abledo.rgb * max(0, dot(worldNormal, worldLight)); //为何改成max而不是saturate?
                //通过内置函数获得视野方向
                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                //获得单位矢量h
                fixed3 halfDir = normalize(worldLight + viewDir);
                //计算高光
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);
                //将漫反射, 高光和环境光混合输出到颜色
                fixed3 color = ambient + diffuse + specular;
                return fixed4(color, 1.0);
            }

            ENDCG
        }
    }
}

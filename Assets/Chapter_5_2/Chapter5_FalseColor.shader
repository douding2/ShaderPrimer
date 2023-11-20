// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shaders Book/Chapter 5/False Color" {
    SubShader {
        Pass {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct v2f {
                float4 pos : SV_POSITION; //裁剪空间坐标
                fixed4 color : COLOR0; //存储颜色信息
            };

            // float4 vert(a2v v) : SV_POSITION {
            //     return UnityObjectToClipPos(v.vertex);
            // }


            v2f vert(appdata_full v){
                v2f o; //声明下结构体
                o.pos = UnityObjectToClipPos(v.vertex);
                //可视化法线方向
                o.color = fixed4(v.normal * 0.5 + fixed3(0.5,0.5,0.5), 1.0); //可视化法线方向
                // // 可视化切线方向
                // o.color = fixed4(v.tangent.xyz * 0.5 + fixed3(0.5,0.5,0.5), 1.0); //可视化切线方向
                // // 可视化副切线方向
                // fixed3 binormal = cross(v.normal, v.tangent.xyz) * v.tangent.w;
                // o.color = fixed4(binormal * 0.5 + fixed3(0.5,0.5,0.5), 1.0);
                //可视化第一组纹理坐标
                o.color = fixed4(v.texcoord.xy, 0.0, 1.0);
                //可视化第二组纹理坐标
                o.color = fixed4(v.texcoord1.xy, 0.0, 1.0);
                //可视化第一组纹理坐标的小数部分
                o.color = frac(v.texcoord);
                if(any(saturate(v.texcoord) - v.texcoord)) {
                    o.color.b = 0.5; 
                }
                o.color.a = 1.0;
                //可视化第二组纹理坐标的小数部分
                o.color = frac(v.texcoord1);
                if(any(saturate(v.texcoord1) - v.texcoord1)) {
                    o.color.b = 0.5; 
                }
                o.color.a = 1.0;
                //可视化顶点颜色
                o.color = v.color;
                return o;
            }

            // fixed4 frag() : SV_TARGET {
            //     return fixed4(1.0, 1.0, 1.0, 1.0);
            // }


            // fixed4 frag(v2f i) : SV_TARGET {
            //     return fixed4(i.color, 1.0); //将插值后的颜色显示出来
            // }

            fixed4 frag(v2f i) : SV_TARGET {
                return i.color;
            }

            ENDCG
        }
    }
}

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shaders Book/Chapter 5/Simple Shader" {
    Properties {
        _Color ("Color Tint", Color) = (1.0, 1.0, 1.0, 1.0) //定义一个颜色的变量
    }
    SubShader {
        Pass {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            fixed4 _Color; //在CG代码中, 我们需要定义一个与属性名称和类型都匹配的变量

            struct a2v {
                float4 vertex : POSITION; //模型顶点坐标
                float4 normal : NORMAL; //模型的法线方向
                float4 texcoord : TEXCOORD; //模型的第一个纹理
            };

            struct v2f {
                float4 pos : SV_POSITION; //裁剪空间坐标
                fixed3 color : COLOR0; //存储颜色信息
            };

            // float4 vert(a2v v) : SV_POSITION {
            //     return UnityObjectToClipPos(v.vertex);
            // }


            v2f vert(a2v v){
                v2f o; //声明下结构体
                o.pos = UnityObjectToClipPos(v.vertex);
                o.color = v.normal * 0.5 + fixed3(0.5,0.5,0.5); //normal的范围为[-1,1], 这个操作将分量范围控制在[0, 1]之间
                return o;
            }

            // fixed4 frag() : SV_TARGET {
            //     return fixed4(1.0, 1.0, 1.0, 1.0);
            // }


            // fixed4 frag(v2f i) : SV_TARGET {
            //     return fixed4(i.color, 1.0); //将插值后的颜色显示出来
            // }

            fixed4 frag(v2f i) : SV_TARGET {
                fixed3 c = i.color;
                c *= _Color.rgb; //控制颜色输出
                return fixed4(c, 1.0); //将插值后的颜色显示出来
            }

            ENDCG
        }
    }
}

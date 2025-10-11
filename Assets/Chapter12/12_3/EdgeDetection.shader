Shader "Custom/EdgeDetection"{
    Properties {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _EdgesOnly("Edges Only", Range(0, 1)) = 0
        _EdgeColor("Edge Color", Color) = (0, 0, 0, 1)
        _BackgroundColor("Background Color", Color) = (1, 1, 1, 1)
    }
    SubShader {
        Tags { "RenderType" = "Opaque" }
        Pass {
            Tags {"RenderType" = "Opaque"}

            ZTest Always
            Cull Off
            ZWrite Off

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float _EdgesOnly;
            float4 _EdgeColor;
            float4 _BackgroundColor;
            half4 _MainTex_TexelSize;
            struct a2v {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float2 uv[9] : TEXCOORD0;
            };

            v2f vert(a2v v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                half2 uv = v.texcoord;
                half2 size = _MainTex_TexelSize.xy;

                o.uv[0] = uv + size * half2(- 1, - 1);
                o.uv[1] = uv + size * half2(0, - 1);
                o.uv[2] = uv + size * half2(1, - 1);
                o.uv[3] = uv + size * half2(- 1, 0);
                o.uv[4] = uv;
                o.uv[5] = uv + size * half2(1, 0);
                o.uv[6] = uv + size * half2(- 1, 1);
                o.uv[7] = uv + size * half2(0, 1);
                o.uv[8] = uv + size * half2(1, 1);

                return o;
            }

            fixed luminance(fixed4 color) {
                return 0.2125 * color.r + 0.7154 * color.g + 0.0721 * color.b;
            }

            half Sobel(v2f i) {
                const half Gx[9] = {
                    - 1, - 2, - 1,
                    0, 0, 0,
                    1, 2, 1
                };

                const half Gy[9] = {
                    - 1, 0, 1,
                    - 2, 0, 2,
                    - 1, 0, 1
                };

                half texColor;
                half edgeX = 0;
                half edgeY = 0;

                for (int it = 0; it < 9; it ++) {
                    texColor = luminance(tex2D(_MainTex, i.uv[it]));
                    edgeX += Gx[it] * texColor;
                    edgeY += Gy[it] * texColor;
                }
                return 1 - abs(edgeX) - abs(edgeY);
            }

            half4 frag(v2f i) : SV_Target {
                half edge = Sobel(i);

                fixed4 withEdgeColor = lerp(_EdgeColor, tex2D(_MainTex, i.uv[4]), edge);

                fixed4 onlyEdgeColor = lerp(_EdgeColor, _BackgroundColor, edge);

                return lerp(withEdgeColor, onlyEdgeColor, _EdgesOnly);
            }
            ENDCG
        }
    }
    FallBack Off
}

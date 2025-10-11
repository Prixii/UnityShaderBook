Shader "Custom/BrightnessSaturationAndContrast"{
    Properties {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Brightness("Brightness", Float) = 1.0
        _Saturation("Saturation", Float) = 1.0
        _Contrast("Contrast", Float) = 1.0
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
            float4 _MainTex_ST;
            half _Brightness;
            half _Saturation;
            half _Contrast;

            struct a2v {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;

            };

            struct v2f {
                float4 pos : SV_POSITION;
                half2 uv : TEXCOORD0;
            };


            v2f vert(a2v v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                return o;
            }

            half4 frag(v2f i) : SV_Target {
                fixed4 renderTex = tex2D(_MainTex, i.uv);

                fixed3 finalColor = renderTex.rgb * _Brightness;

                fixed luminance = 0.2125 * renderTex.r + 0.7154 * renderTex.g + 0.0721 * renderTex.b;
                fixed3 luminanceColor = fixed3(luminance, luminance, luminance);
                finalColor = lerp(luminanceColor, finalColor, _Saturation);

                fixed3 avgColor = fixed3(0.5, 0.5, 0.5);
                finalColor = lerp(avgColor, finalColor, _Contrast);

                return fixed4(finalColor, renderTex.a);
            }
            ENDCG
        }
    }
    FallBack Off
}

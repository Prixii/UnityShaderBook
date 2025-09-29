Shader "Custom/MotionBlur"{
    Properties {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _BlurAmount("Blur Amount", Float) = 1.0
    }
    SubShader {
        Tags { "RenderType" = "Opaque" }
        CGINCLUDE
        #include "UnityCG.cginc"

        sampler2D _MainTex;
        float _BlurAmount;

        struct v2f {
            float4 pos : SV_POSITION;
            float2 uv : TEXCOORD0;
        };

        v2f vert(appdata_img v) {
            v2f o;
            o.pos = UnityObjectToClipPos(v.vertex);
            o.uv = v.texcoord;
            return o;
        }

        fixed4 fragRGB(v2f i) : SV_Target {
            return fixed4(tex2D(_MainTex, i.uv).rgb, _BlurAmount);
        }

        half4 fragA(v2f i) : SV_Target {
            return tex2D(_MainTex, i.uv);
        }

        ENDCG

        ZTest Always
        ZWrite Off
        Cull Off

        Pass {
            Blend SrcAlpha OneMinusSrcAlpha
            ColorMask RGB
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment fragRGB

            ENDCG
        }

        Pass {
            Blend SrcAlpha OneMinusSrcAlpha
            ColorMask A
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment fragA

            ENDCG
        }
    }
    FallBack Off
}

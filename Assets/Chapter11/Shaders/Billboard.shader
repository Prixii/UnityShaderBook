
Shader "Custom/Billboard"
{
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _VerticalBillboarding("Vertical Restraints", Range(0, 1)) = 1
    }
    SubShader{
        Tags { "RenderType" = "Transparent" "Queue" = "Transparent" "IgnoreProjector" = "True" "DisableBatching" = "True" }
        Cull Off
        ZWrite Off

        Pass {
            Tags { "LightMode" = "ForwardBase" }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;
            float _VerticalBillboarding;

            struct a2v {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            v2f vert(a2v v) {
                v2f o;

                float3 center = float3(0, 0, 0);
                float3 viewer = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1));

                float3 normalDir = viewer - center;
                normalDir.y = normalDir.y * _VerticalBillboarding;
                normalDir = normalize(normalDir);

                float3 upDir = abs(normalDir.y) > 0.99 ? float3(0, 1, 0) : float3(0, 0, 1);
                float3 rightDir = normalize(cross(normalDir, upDir));
                upDir = normalize(cross(rightDir, normalDir));

                float3 centerOffset = v.vertex.xyz - center;
                float3 localPos = center + rightDir * centerOffset.x + upDir * centerOffset.y + normalDir.z * centerOffset.z;

                o.pos = UnityObjectToClipPos(float4(localPos, 1));
                o.uv = v.texcoord;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target {
                fixed4 c = tex2D(_MainTex, i.uv);
                c.rgb *= _Color.rgb;
                return c;
            }

            ENDCG
        }

    }
    FallBack "Transparent/VertexLit"
}

Shader "Custom/HalfLambertMat"
{
    Properties
    {
        _Diffuse("Diffuse", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Pass {
            Tags { "LightMode" = "ForwardBase" }
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"

            fixed4 _Diffuse;

            struct a2v {
                float3 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float3 color : COLOR;
            };

            v2f vert(a2v v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                // calc color
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                fixed3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
                fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
                fixed3 halfLambert = (0.5 * dot(worldNormal, worldLight) + 0.5);
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * halfLambert;

                o.color = diffuse + ambient;

                return o;
            }

            half4 frag(v2f i) : SV_Target {
                return half4(i.color, 1.0);
            }

        ENDCG
        }
    }
}

Shader "Custom/Chapter9-ForwardRendering"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _Diffuse("Diffuse", Color) = (1, 1, 1, 1)
        _Specular("Specular", Color) = (1, 1, 1, 1)
        _Gloss("Gloss", Range(8.0, 256)) = 20
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
    }
    SubShader
    {
        Pass {
            Tags { "LightMode" = "ForwardBase" }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"

            fixed4 _Color;
            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;

            struct a2v {
                float3 normal: NORMAL;
                float3 vertex: POSITION;
                float3 worldNormal: TEXCOORD0;
                float3 worldPos: TEXCOORD1;
            };

            struct v2f {
                float4 pos: SV_POSITION;
                float3 worldNormal: TEXCOORD0;
                float3 worldPos: TEXCOORD1;
                float3 color: COLOR;
            };

            v2f vert(a2v v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(v.vertex, (float3x3)unity_WorldToObject);
                o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
                return o;
            }

            half4 frag(v2f i): SV_Target {
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
                fixed3 lambert = saturate(dot(worldNormal, worldLight));
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * lambert;

                fixed3 reflectDir = normalize(reflect(-worldLight, worldNormal));
                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - (normalize(i.worldPos)).xyz);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(reflectDir, viewDir)), _Gloss);

                return half4(diffuse + ambient + specular, 1.0);
            }

            ENDCG
        }
    }
    FallBack "Diffuse"
}

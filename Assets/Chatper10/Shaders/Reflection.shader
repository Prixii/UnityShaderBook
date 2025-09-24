Shader "Custom/Chapter10-Reflection"
{
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
        _ReflectColor("Reflection Color", Color) = (1, 1, 1, 1)
        _ReflectAmount ("Reflection Amount", Range(0, 1)) = 1
        _CubeMap ("Reflection Cube Map", Cube) = "white"
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        Pass {
            Tags { "RenderType" = "ForwardBase" }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            float4 _Color;
            float4 _ReflectColor;
            float _ReflectAmount;
            samplerCUBE _CubeMap;

            struct a2v {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float3 worldRefl : TEXCOORD2;
                SHADOW_COORDS(3)
            };


            v2f vert(a2v v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                o.worldNormal = UnityObjectToWorldNormal(v.normal);

                float3 worldViewDir = UnityWorldSpaceViewDir(o.worldPos);

                o.worldRefl = reflect(- worldViewDir, o.worldNormal);
                return o;
            }


            half4 frag(v2f i) : SV_Target {

                fixed3 worldNormal = normalize(i.worldNormal);

                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                fixed lambert = max(0, dot(worldNormal, worldLightDir));
                fixed3 diffuse = _LightColor0.rgb * _Color.rgb * lambert;

                fixed3 reflection = texCUBE(_CubeMap, i.worldRefl).rgb * _ReflectColor.rgb;

                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

                fixed3 color = ambient + lerp(diffuse, reflection, _ReflectAmount) * atten;

                return half4(color, 1.0);
            }

            ENDCG
        }
    }
    FallBack "Reflection"
}

Shader "Custom/Refraction" {
    Properties {
        _Color ("Color", Color) = (1, 1, 1, 1)
        _RefractionColor("Refraction Color", Color) = (1, 1, 1, 1)
        _RefractionAmount ("Refraction Amount", Range(0, 1)) = 1
        _RefractionRatio("Refraction Radio", Range(0.1, 1)) = 0.5
        _CubeMap ("Refraction Cube Map", Cube) = "_Skybox" {}
    }
    SubShader {
        Tags { "RenderType" = "Opaque" }
        Pass {
            Tags {"RenderType" = "ForwardBase"}

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            fixed4 _Color;
            fixed4 _RefractionColor;
            fixed _RefractionAmount;
            fixed _RefractionRatio;
            samplerCUBE _CubeMap;


            struct a2v {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float3 worldRefract : TEXCOORD2;
                SHADOW_COORDS(3)
            };

            v2f vert(a2v v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                fixed3 worldViewDir = UnityWorldSpaceViewDir(o.worldPos);
                o.worldRefract = refract(- worldViewDir, o.worldNormal, _RefractionRatio);
                TRANSFER_SHADOW(o);
                return o;
            }

            half4 frag(v2f i) : SV_Target {
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                fixed lambert = max(0, dot(worldNormal, worldLightDir));
                fixed3 diffuse = _Color.rgb * lambert * _LightColor0.rgb;

                fixed3 refraction = texCUBE(_CubeMap, i.worldRefract).rgb * _RefractionColor.rgb;

                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

                fixed3 color = ambient + lerp(diffuse, refraction, _RefractionAmount) * atten;

                return half4(color, 1);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}

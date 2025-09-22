Shader "Custom/BumpedDiffuse"{
    Properties {
        _Color ("Color Tint", Color) = (1, 1, 1, 1)
        _MainTex ("Main Tex", 2D) = "white" {}
        _BumpMap ("Normal Map", 2D) = "bump" {}
    }
    SubShader {
        Tags { "RenderType" = "Opaque" "Queue" = "Geometry" }
        Pass {
            Tags {"RenderType" = "ForwardBase"}

            CGPROGRAM
            #pragma multi_compile_fwdbase

            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;

            struct a2v {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;
                float4 TBN0 : TEXCOORD1;
                float4 TBN1 : TEXCOORD2;
                float4 TBN2 : TEXCOORD3;
                SHADOW_COORDS(4)
            };

            v2f vert(a2v v) {
                v2f o;

                o.pos = UnityObjectToClipPos(v.vertex);
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
                fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
                fixed3 worldBinormal = cross(worldNormal, worldTangent);

                o.TBN0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, 0);
                o.TBN1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, 0);
                o.TBN2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, 0);

                o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpMap);

                TRANSFER_SHADOW(o);
                return o;
            }

            half4 frag(v2f i) : SV_Target {
                fixed3 worldPos = float3(i.TBN0.w, i.TBN1.w, i.TBN2.w);
                fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));

                fixed3 bump = UnpackNormal(tex2D(_BumpMap, i.uv.zw));
                bump = normalize(half3(dot(i.TBN0.xyz, bump), dot(i.TBN1.xyz, bump), dot(i.TBN2.xyz, bump)));

                fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _Color.rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

                fixed lambert = max(0, dot(bump, lightDir));
                fixed3 diffuse = _LightColor0.rgb * albedo * lambert;

                UNITY_LIGHT_ATTENUATION(atten, i, worldPos);

                return half4(ambient + diffuse * atten, 1.0);
            }
            ENDCG
        }
        Pass {
            Tags {"RenderType" = "ForwardAdd"}

            CGPROGRAM
            #pragma multi_compile_fwdadd

            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;

            struct a2v {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;
                float4 TBN0 : TEXCOORD1;
                float4 TBN1 : TEXCOORD2;
                float4 TBN2 : TEXCOORD3;
                SHADOW_COORDS(4)
            };

            v2f vert(a2v v) {
                v2f o;

                o.pos = UnityObjectToClipPos(v.vertex);
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
                fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
                fixed3 worldBinormal = cross(worldNormal, worldTangent);

                o.TBN0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, 0);
                o.TBN1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, 0);
                o.TBN2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, 0);

                o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpMap);

                TRANSFER_SHADOW(o);
                return o;
            }

            half4 frag(v2f i) : SV_Target {
                fixed3 worldPos = float3(i.TBN0.w, i.TBN1.w, i.TBN2.w);
                fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));

                fixed3 bump = UnpackNormal(tex2D(_BumpMap, i.uv.zw));
                bump = normalize(half3(dot(i.TBN0.xyz, bump), dot(i.TBN1.xyz, bump), dot(i.TBN2.xyz, bump)));

                fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _Color.rgb;

                fixed lambert = max(0, dot(bump, lightDir));
                fixed3 diffuse = _LightColor0.rgb * albedo * lambert;

                UNITY_LIGHT_ATTENUATION(atten, i, worldPos);

                return half4(diffuse * atten, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}

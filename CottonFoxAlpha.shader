Shader "Custom/CottonFoxAlpha" {
    Properties {
        [Header(Color)]
        [Space(10)]
        _Hue_Primary ("Hue", Range(0.0, 360.0)) = 0.0
        _Sat_Primary ("Saturation", Range(0.0, 2.0)) = 1.0
        _Bright_Primary("Brightness", Range(-1,1)) = 0
        _Invert_Primary ("Invert", Range(0.0, 1.0)) = 0
        _Emission_Primary ("Emission", Range(0.0, 4.0)) = 0

        [Space(20)]
        [HDR][Header(Texture (UV1))]
        [Space(10)]
        _Color_Primary ("Color", Color) = (1, 1, 1, 1)
        _MainTex_Primary ("Texture", 2D) = "white" { }

        [Space(20)]
        [HDR][Header(Texture (Alpha))]
        [Space(10)]
        _AlphaMask("Alpha Mask (UV2)", 2D) = "white" { }
    }

    Category {
        Tags {
            "Queue" = "Transparent"
            "RenderType" = "Transparent"
        }
        Blend SrcAlpha OneMinusSrcAlpha
        Zwrite Off
        Cull Off

        SubShader {
            Pass {
                CGPROGRAM
                #pragma vertex vert_surface
                #pragma fragment frag_surface
                #pragma target 3.0
                #include "Lighting.cginc"
                #include "UnityCG.cginc"
                float4 _Color_Primary;
                float _Hue_Primary;
                float _Sat_Primary;
                float _Bright_Primary;
                float _Invert_Primary;
                float _Emission_Primary;
                sampler2D _MainTex_Primary, _AlphaMask;
                float4 _MainTex_Primary_ST, _AlphaMask_ST;

                struct appdata {
                    float4 vertex : POSITION;
                    float3 normal : NORMAL;
                    float4 pos: POSITION;
                    float2 uv: TEXCOORD0;
                    float2 uv2: TEXCOORD1;
                };

                struct v2f {
                    float4 pos: SV_POSITION;
                    float2 uv: TEXCOORD0;
                    float2 uv2: TEXCOORD1;
                    float3 worldNormal: NORMAL;
                    float3 worldPos: TEXCOORD4;
                };

                v2f vert_surface(appdata v) {
                    v2f o;
                    o.pos = UnityObjectToClipPos(v.vertex);
                    o.uv = TRANSFORM_TEX(v.uv, _MainTex_Primary);
                    o.uv2 = v.uv2; // Use UV2 directly for the alpha mask
                    o.worldNormal = UnityObjectToWorldNormal(v.normal);
                    o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                    return o;
                }

                // Color Controls
                float3 Hue(float3 aColor, float aHue) {
                    float angle = radians(aHue);
                    float3 k = float3(0.57735, 0.57735, 0.57735);
                    float cosAngle = cos(angle);
                    return aColor * cosAngle + cross(k, aColor) * sin(angle) + k * dot(k, aColor) * (1 - cosAngle);
                }
                float4 HSB(float4 rgb) {
                    float4 output = rgb;
                    output.rgb = Hue(output.rgb, _Hue_Primary);
                    output.rgb = (output.rgb + _Bright_Primary);
                    float3 intensity = dot(output.rgb, float3(0.299, 0.587, 0.114));
                    output.rgb = lerp(intensity, output.rgb, _Sat_Primary);
                    return output;
                }
                float4 INV(float4 rgb) {
                    return abs(rgb - _Invert_Primary);
                }

                // Color & Texture
                float3 surface(float3 UVworldNormal, float3 UVworldPos, float3 UVpos, float2 UVc, float2 UVg) {
                    float3 worldNormal = normalize(UVworldNormal);
                    float3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
                    float3 worldView = normalize(_WorldSpaceCameraPos.xyz - UVworldPos.xyz);
                    float3 worldHalf = normalize(worldView + worldLight);
                    float3 color = HSB(INV(tex2D(_MainTex_Primary, UVc))) * _Color_Primary;

                    // Use the alpha values from the mask as the final alpha values
                    float alpha = tex2D(_AlphaMask, UVg).r;

                    float3 emission = color * (_Emission_Primary * 10);

                    // Apply alpha to the color
                    return ((color + emission)) + emission * alpha;
                }

                // Mesh Surface
                float4 frag_surface(v2f i): SV_Target {
                    float3 color = surface(i.worldNormal, i.worldPos, i.pos, i.uv, i.uv2);

                    // Use the alpha values from the mask as the final alpha values
                    float alpha = tex2D(_AlphaMask, i.uv2).r;

                    // Apply alpha to the final color
                    return float4(color, alpha);
                }
                ENDCG
            }
        }
    }
    FallBack "Standard"
}

// Custom shader made by Juice...
Shader "Custom/CottonFoxBase" {
    Properties {
        [Header(Color)]
        _Hue_Primary ("Hue", Range(0.0, 360.0)) = 0.0
        _Sat_Primary ("Saturation", Range(0.0, 2.0)) = 1.0
        _Bright_Primary("Brightness", Range(-1,1)) = 0
        [MaterialToggle]_Invert_Primary ("Invert", Range(0.0, 1.0)) = 0
        _Emission_Primary ("Emission", Range(0.0, 4.0)) = 0
        _Rim_Primary ("Rim Lighting", Range(-0.5, 1.0)) = 0
        _Opacity("Opacity", Range(0, 1.0)) = 1

        [Header(Environment)]
        _SpecularPower_Primary ("Specular Power", Range(0, 1)) = 0.2
        _SpecularShine_Primary("Specular Shine", Range(0,1)) = 0.2
        _Ambient_Primary("Ambient Influence", Range(0,1)) = 1
        _Directional_Primary("Directional Influence", Range(0,1)) = 1
        _Probes_Primary("Probe Influence", Range(0,1)) = 1
        _Gloss_Primary("Reflection Influence", Range(0,1)) = 0.5

        [HDR][Header(Texture (UV1))]
        _Color_Primary ("Color", Color) = (1, 1, 1, 1)
        _MainTex_Primary ("Texture", 2D) = "white" { }
        
        [HDR][Header(Texture (UV2))]
        _GlossMap_Primary("Gloss Map", 2D) = "white" {}


        [HDR][Header(Fallback)]
        _Color ("Color", Color) = (1, 1, 1, 1)
        _MainTex ("Fallback Texture", 2D) = "white" { }
    }


    Category {
        Tags {
            "RenderType" = "Opaque"
            "Queue" = "Geometry"
            "LightMode" = "ForwardBase"
        }
        Zwrite On
        Cull Back
        
        SubShader
        {
            Pass {
                CGPROGRAM
                #pragma vertex vert_surface
                #pragma fragment frag_surface
                #pragma target 3.0
                #include "Lighting.cginc"
                #include "UnityCG.cginc"
                #include "Packages/red.sim.lightvolumes/Shaders/LightVolumes.cginc"
                float4 _Color_Primary;
                float _Hue_Primary;
                float _Sat_Primary;
                float _Bright_Primary;
                float _Invert_Primary;
                float _Emission_Primary;
                float _Rim_Primary;
                float _SpecularPower_Primary;
                float _SpecularShine_Primary;
                float _Ambient_Primary;
                float _Directional_Primary;
                float _Probes_Primary;
                float _Gloss_Primary;
                sampler2D _MainTex_Primary, _GlossMap_Primary;
                float4 _MainTex_Primary_ST, _GlossMap_Primary_ST;
                float _VRChatMirrorMode;
                float _Opacity;

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
                    o.uv2 = TRANSFORM_TEX(v.uv2, _GlossMap_Primary);
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
                    if (_Invert_Primary) {
                        return float4(1.0 - rgb.r, 1.0 - rgb.g, 1.0 - rgb.b, rgb.a);
                        } else {
                        return rgb;
                    }
                }

                // Reflectivity
                float3 reflection(float3 UVworldNormal, float3 UVworldPos, float Gloss) {
                    float3 worldNormal = normalize(UVworldNormal);
                    float3 worldViewDir = normalize(UnityWorldSpaceViewDir(UVworldPos));
                    float3 worldRefl = reflect(-worldViewDir, UVworldNormal);
                    float4 reflectionData = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, worldRefl);
                    float3 reflectionColor = DecodeHDR (reflectionData, unity_SpecCube0_HDR);
                    return reflectionColor * Gloss;
                }

                // Rim Lighting
                float3 addRim(float3 UVworldView, float3 UVworldNormal, float3 input) {
                    half rim = 1.0 - saturate(dot(UVworldView, UVworldNormal));
                    float3 output = input + (float4(input * pow(rim, 2), 1.0) * (_Rim_Primary * 2));
                    return output;
                }

                // Color & Texture
                float3 surface(float3 UVworldNormal, float3 UVworldPos, float3 UVpos, float2 UVc, float2 UVg) {
                    float3 worldNormal = normalize(UVworldNormal);
                    float3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
                    float3 worldView = normalize(_WorldSpaceCameraPos.xyz - UVworldPos.xyz);
                    float3 worldHalf = normalize(worldView + worldLight);
                    float3 color = HSB(INV(tex2D(_MainTex_Primary, UVc))) * _Color_Primary;
                    float3 emission = color * (_Emission_Primary * 10);
                    float3 ambient = unity_AmbientEquator.xyz * _Ambient_Primary;
                    float3 diffuse = _LightColor0 * (saturate(dot(worldNormal, worldLight)) * (_Directional_Primary));

                    float3 probes = ShadeSH9(float4(worldNormal,1)) * _Probes_Primary * 2;

                    #ifdef VRC_LIGHT_VOLUMES_INCLUDED
                        float3 L0, L1r, L1g, L1b;
                        LightVolumeSH(UVworldPos, L0, L1r, L1g, L1b);
                        probes = LightVolumeEvaluate(worldNormal, L0, L1r, L1g, L1b) * _Probes_Primary * 2;
                    #endif

                    float3 glossmap = tex2D(_GlossMap_Primary, UVg);
                    float3 reflectivity = reflection(worldNormal, UVworldPos, _Gloss_Primary);
                    float3 specular = _LightColor0 * pow(saturate(dot(worldNormal, worldHalf)), clamp( (_SpecularShine_Primary * 99), .001, 99) ) * _SpecularPower_Primary;
                    float3 gloss = lerp(color, (reflectivity + specular), glossmap);
                    float3 rim = addRim(worldView, worldNormal, ambient + diffuse + probes);


                    float3 finalColor = lerp(color, gloss, _Gloss_Primary);


                    return ((finalColor + (emission)) * rim) + (emission);
                }

                // Mesh Surface
                float4 frag_surface(v2f i): SV_Target {
                    float3 color = surface(i.worldNormal, i.worldPos, i.pos, i.uv, i.uv2);
                    float4x4 thresholdMatrix = {
                        1.0 / 17.0,  9.0 / 17.0,  3.0 / 17.0, 11.0 / 17.0,
                        13.0 / 17.0,  5.0 / 17.0, 15.0 / 17.0,  7.0 / 17.0,
                        4.0 / 17.0, 12.0 / 17.0,  2.0 / 17.0, 10.0 / 17.0,
                        16.0 / 17.0,  8.0 / 17.0, 14.0 / 17.0,  6.0 / 17.0
                    };
                    float4x4 _RowAccess = { 1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1 };
                    if (_VRChatMirrorMode == 0) {
                        clip(_Opacity - thresholdMatrix[fmod(i.pos.x, 4)] * _RowAccess[fmod(i.pos.y, 4)]);
                    }
                    return float4(color, 1);
                }
                ENDCG
            }
        }
    }
    FallBack "Standard"
}
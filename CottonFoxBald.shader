// Custom shader made by Juice...
Shader "Custom/CottonFoxBald" {
    Properties {
        [Space(20)]
        [Header(Color)]
        [Space(10)]
        _Hue_FurPrimary ("Hue", Range(0.0, 360.0)) = 0.0
        _Saturation_FurPrimary ("Saturation", Range(0.0, 2.0)) = 1.0
        _Bright_FurPrimary("Brightness", Range(-1,1)) = 0
        [MaterialToggle]_Invert_FurPrimary ("Invert", Range(0, 1)) = 0
        _Emission_FurPrimary ("Emission", Range(0.0, 4.0)) = .5
        _Rim_FurPrimary ("Rim Lighting", Range(-0.5, 1.0)) = 0

        [Space(20)]
        [Header(Environment)]
        [Space(10)]
        _SpecularPower_FurPrimary ("Specular Power", Range(0, 1)) = 0.2
        _SpecularShine_FurPrimary("Specular Shine", Range(0,1)) = 0.2
        _Ambient_FurPrimary("Ambient Influence", Range(0,1)) = 1
        _Directional_FurPrimary("Directional Influence", Range(0,1)) = 1
        _Probes_FurPrimary("Probe Influence", Range(0,1)) = 1
        _Gloss_FurPrimary("Reflection Influence", Range(0,1)) = 0.5

        [Space(20)]
        [HDR][Header(Texture (UV1))]
        [Space(10)]
        _Color ("Color", Color) = (1, 1, 1, 1)
        _MainTex ("Texture", 2D) = "white" { }

        [Space(20)]
        [Header(Bald (UV2))]
        [Space(10)]
        [NoScaleOffset] _Texture_FurPrimary ("Fur Texture", 2D) = "white" { }

        [Space(20)]
        [Header(Mask (UV3))]
        [Space(10)]
        _EmissionMask_FurPrimary ("Texture", 2D) = "white" { }
        _MaskInfluence_FurPrimary ("Influence", Range(0, 1)) = 0

        [Space(20)]
        [Header(AudioLink (UV4))]
        [Space(10)]
        _AL_Trebel("Trebel", Range(0.0, 1.0)) = 1
        _AL_MidHigh("MidHigh", Range(0.0, 1.0)) = 1
        _AL_MidLow("MidLow", Range(0.0, 1.0)) = 1
        _AL_Bass("Bass", Range(0.0, 1.0)) = 1

        [Space(10)]
        _AL_Waves("Wave Effect", Range(0.0, 1.0)) = 1
        _AL_WaveLength("Length", Range(0.0, 1.0)) = 1
        _AL_Rotation("Rotation (π)", Range(-1.57075,  4.71225)) = 1.57075
        _AL_Distortion("Distortion", Range(0,  1)) = 0.0
        _AL_FurLength("Fur Influence", Range(0.0, 1.0)) = 1

        [Space(10)]
        _AL_Rim("Rim Effect", Range(0, 1.0)) = 0
        _AL_RimLength("Length", Range(0.0, 1.0)) = 1


        [Space(20)]
        [Header(Video Texture (UV4))]
        [Space(10)]
        _VideoMix("Mix", Range(0.0, 1.0)) = 0
        _VideoScale("Size", Range(.01, 50.0)) = 1
        _VideoDistortion("Distortion", Range(0, 2)) = 0
        _VideoBlur("Blur", Range(0.0, 1.0)) = 0
    }


    Category {
        Tags {
            "RenderType" = "Opaque"
            "Queue" = "Geometry"
            "LightMode" = "ForwardBase"
        }
        Zwrite On
        Cull Back
        Blend SrcAlpha OneMinusSrcAlpha
        
        SubShader {
            Pass {
                Tags {
                    "LightMode" = "ShadowCaster"
                }
            }
            Pass {
                CGPROGRAM
                #pragma vertex vert_surface
                #pragma fragment frag_surface

                #pragma target 3.0
                #include "Lighting.cginc"
                #include "UnityCG.cginc"
                #include "Packages/com.llealloo.audiolink/Runtime/Shaders/AudioLink.cginc"
                #include "Packages/red.sim.lightvolumes/Shaders/LightVolumes.cginc"

                float4 _Color;
                float _Emission_FurPrimary;
                float _MaskInfluence_FurPrimary;
                half _Rim_FurPrimary;
                float _Hue_FurPrimary;
                float _Saturation_FurPrimary;
                float _Bright_FurPrimary;
                float _Invert_FurPrimary;
                float _SpecularPower_FurPrimary;
                float _SpecularShine_FurPrimary;
                float _Ambient_FurPrimary;
                float _Directional_FurPrimary;
                float _Probes_FurPrimary;
                float _Gloss_FurPrimary;
                sampler2D _MainTex, _EmissionMask_FurPrimary, _Mask_FurPrimary, _Texture_FurPrimary;
                uniform sampler2D _Udon_VideoTex;
                float4 _MainTex_ST, _EmissionMask_FurPrimary_ST, _Mask_FurPrimary_ST, _Texture_FurPrimary_ST, _Udon_VideoTex_ST;
                float4 _Udon_VideoTex_TexelSize;
                float _VideoMix;
                float _VideoScale;
                float _VideoDistortion;
                float _VideoBlur;
                float _VertexMask_FurPrimary;
                float _Clip_FurPrimary;
                float _Density_FurPrimary;
                float _FurLength_FurPrimary;
                float _Shading_FurPrimary;

                float _AL_Trebel;
                float _AL_MidHigh;
                float _AL_MidLow;
                float _AL_Bass;
                
                float _AL_FurLength;
                
                float _AL_Waves;
                float _AL_WaveLength;
                float _AL_Rotation;
                float _AL_Distortion;
                
                float _AL_Rim;
                float _AL_RimLength;

                float _VRChatMirrorMode;

                // Color Controls
                float4 HSBI(float4 rgb) {
                    float3 originalColor = rgb.rgb;
                    float angle = radians(_Hue_FurPrimary);
                    float3 k = float3(0.57735, 0.57735, 0.57735);
                    float cosAngle = cos(angle);
                    rgb.rgb = originalColor * cosAngle + cross(k, originalColor) * sin(angle) + k * dot(k, originalColor) * (1 - cosAngle);
                    rgb.rgb += _Bright_FurPrimary;
                    float3 intensity = dot(rgb.rgb, float3(0.299, 0.587, 0.114));
                    rgb.rgb = lerp(intensity, rgb.rgb, _Saturation_FurPrimary);
                    if (_Invert_FurPrimary) {
                        rgb.rgb = float3(1.0, 1.0, 1.0) - rgb.rgb;
                    }
                    return rgb;
                }

                // Utility
                float2 RotateUV(float2 uv, float angle) {
                    float2 pivot = float2(0.5, 0.5);
                    float cosAngle = cos(angle);
                    float sinAngle = sin(angle);
                    float2x2 rot = float2x2(cosAngle, -sinAngle, sinAngle, cosAngle);
                    float2 rotatedUV = uv - pivot;
                    return mul(rot, rotatedUV) + pivot;
                }

                float2 DistortUV(float2 uv, float distortion, float time) {
                    float2 scrollOffset = float2(0, time * .25);
                    return (uv + (distortion / 5) * sin(uv.yx * 10 + scrollOffset)) + (time * .25);
                }

                // Audiolink
                float lfrac(float Input, float MaxValue) {
                    return frac(Input / MaxValue) * MaxValue;
                }

                // Function to retrieve audio link data with specific UV and y-coordinate
                float GetAudioLinkData(float2 uv, float y, float length) {
                    float pos = (frac(uv.y * length * 10) * 0.5 - 0.5);
                    float pos2 = (frac(uv.y * length * 10) * 0.5);
                    float start_fade = saturate(abs(frac((uv.y) * (length * 10)) - 1));
                    float AL = AudioLinkIsAvailable() ? AudioLinkData(ALPASS_AUDIOLINK + int2(lfrac(pos * 128, 128), y)).g : 0;
                    float AL2 = AudioLinkIsAvailable() ? AudioLinkData(ALPASS_AUDIOLINK + int2(lfrac(pos2 * 128 + 1, 128), y)).g : 0;
                    return lerp(AL2, AL, start_fade);
                }

                // Main audiolink function
                float audiolink(float2 uv, float3 worldNormal, float3 worldViewDir, float4 mask) {

                    float activeAL = _AL_Bass + _AL_MidLow + _AL_MidHigh + _AL_Trebel;
                    activeAL = max(activeAL, 0.0001); // Prevent division by zero

                    float2 rotatedUV = RotateUV(uv, _AL_Rotation);
                    float2 distortedUV = DistortUV(rotatedUV, _AL_Distortion, 1);
                    float ALWave1 = GetAudioLinkData(distortedUV, 0, _AL_WaveLength);
                    float ALWave2 = GetAudioLinkData(distortedUV, 1, _AL_WaveLength);
                    float ALWave3 = GetAudioLinkData(distortedUV, 2, _AL_WaveLength);
                    float ALWave4 = GetAudioLinkData(distortedUV, 3, _AL_WaveLength);

                    float ALWave = AudioLinkIsAvailable() ? 
                    (((ALWave1 * _AL_Bass) + (ALWave2 * _AL_MidLow) + (ALWave3 * _AL_MidHigh) + (ALWave4 * _AL_Trebel))) / activeAL : 0;

                    float waveEffect = lerp(0, ALWave, _AL_Waves);

                    half rim = saturate(dot(worldViewDir, worldNormal));
                    float ALRim1 = GetAudioLinkData(1 - rim, 0, _AL_RimLength);
                    float ALRim2 = GetAudioLinkData(1 - rim, 1, _AL_RimLength);
                    float ALRim3 = GetAudioLinkData(1 - rim, 2, _AL_RimLength);
                    float ALRim4 = GetAudioLinkData(1 - rim, 3, _AL_RimLength);

                    float ALRim = AudioLinkIsAvailable() ? 
                    (((ALRim1 * _AL_Bass) + (ALRim2 * _AL_MidLow) + (ALRim3 * _AL_MidHigh) + (ALRim4 * _AL_Trebel))) / activeAL : 0;

                    float rimEffect = lerp(0, ALRim, _AL_Rim);
                    return (saturate(rimEffect + waveEffect) * mask.b * 3) * rim;
                }

                // Blur Texture
                float4 Blur(sampler2D tex, float2 uv, float blurAmount) {
                    float mipLevel = log2(blurAmount * 256);
                    float3 blurColor = tex2Dlod(tex, float4(uv, 0, mipLevel)).rgb;
                    return float4(blurColor, 1.0); // Return float4
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
                    float3 output = input + (float4(input * pow(rim, 2), 1.0) * (_Rim_FurPrimary * 2));
                    return output;
                }


                struct appdata {
                    float4 vertex : POSITION;
                    float4 tangent : TANGENT;
                    float3 normal : NORMAL;
                    float4 pos: POSITION;
                    float2 texcoord: TEXCOORD0;
                    float2 texcoord1: TEXCOORD1;
                    float2 texcoord2: TEXCOORD2;
                    float2 texcoord3: TEXCOORD3; // Media
                    float4 color : COLOR;   // Vertex color
                };
                
                struct v2f {
                    float4 pos: SV_POSITION;
                    float3 worldNormal: NORMAL;
                    float3 worldPos: TEXCOORD4;
                    float2 texcoord: TEXCOORD0;
                    float2 texcoord1: TEXCOORD1;
                    float2 texcoord2: TEXCOORD2;
                    float2 texcoord3: TEXCOORD3; // Media
                    float4 color : COLOR;   // Vertex color
                };
                
                v2f vert (appdata v) {
                    v2f o;
                    o.pos = UnityObjectToClipPos(v.pos);
                    o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
                    o.texcoord1 = TRANSFORM_TEX(v.texcoord1, _Mask_FurPrimary);
                    o.texcoord2 = TRANSFORM_TEX(v.texcoord2, _EmissionMask_FurPrimary);
                    o.texcoord3 = v.texcoord3; // Media
                    return o;
                }
                
                v2f vert_surface(appdata v) {
                    v2f o;
                    o.pos = UnityObjectToClipPos(v.vertex);
                    o.color = v.color;
                    o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
                    o.texcoord1 = TRANSFORM_TEX(v.texcoord1, _Mask_FurPrimary);
                    o.texcoord2 = TRANSFORM_TEX(v.texcoord2, _EmissionMask_FurPrimary);
                    o.texcoord3 = v.texcoord3; // Media
                    o.worldNormal = UnityObjectToWorldNormal(v.normal);
                    o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                    return o;
                }




// Color & Texture
float3 surface(float3 UVworldNormal, float3 UVworldPos, float3 UVpos, float2 UVcolor, float2 UVemission, float4 vertexColor, float2 UVMedia) {
    float3 worldNormal = normalize(UVworldNormal);
    float3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
    float3 worldView = normalize(_WorldSpaceCameraPos.xyz - UVworldPos.xyz);
    float3 worldHalf = normalize(worldView + worldLight);
    float4 AL = AudioLinkIsAvailable() ? audiolink(UVMedia, worldNormal, worldView, vertexColor) : 0;
    float3 mainColor = HSBI(tex2D(_MainTex, UVcolor)).rgb * _Color;
    float3 color = mainColor.rgb;
    
    float3 mask = tex2D(_EmissionMask_FurPrimary, UVemission).rgb;
    float3 flippedMask = float3(1.0, 1.0, 1.0) - mask * 1.05;
    mask = lerp(mask, float3(1.0, 1.0, 1.0), smoothstep(0.0, 0.5, _MaskInfluence_FurPrimary));
    mask = lerp(mask, flippedMask, smoothstep(0.5, 1.0, _MaskInfluence_FurPrimary));

    if (_Udon_VideoTex_TexelSize.z <= 16) {
        // no video texture
    } else {
        float2 videotexcoord = DistortUV(UVMedia, _VideoDistortion, _VideoDistortion);
        float3 videoColor = HSBI( Blur(_Udon_VideoTex, frac((videotexcoord - 0.5) * _VideoScale + 0.5), _VideoBlur) ).rgb * _Color;
        float3 videoBlendedColor = lerp(mainColor, videoColor, _VideoMix * mask);
        color = videoBlendedColor;
    }

    float3 eColor = color * mask;

    float3 emission = eColor.rgb * _Emission_FurPrimary;
    float3 emissionAL = eColor.rgb * mask * AL;
    float3 reflectivity = reflection(worldNormal, UVworldPos, _Gloss_FurPrimary);
    float3 ambient = unity_AmbientEquator.xyz * _Ambient_FurPrimary;
    float3 diffuse = _LightColor0.rgb * (saturate(dot(worldNormal, worldLight)) * (_Directional_FurPrimary));
    float3 specular = (_LightColor0.rgb * pow(saturate(dot(worldNormal, worldHalf)), clamp( (_SpecularShine_FurPrimary * 90), .001, 90) ) * _SpecularPower_FurPrimary);

    float3 probes = ShadeSH9(float4(worldNormal,1)) * _Probes_FurPrimary * 2;

    #ifdef VRC_LIGHT_VOLUMES_INCLUDED
        float3 L0, L1r, L1g, L1b;
        LightVolumeSH(UVworldPos, L0, L1r, L1g, L1b);
        probes = LightVolumeEvaluate(worldNormal, L0, L1r, L1g, L1b) * _Probes_FurPrimary * 2;
    #endif


    float3 rim = addRim(worldView, worldNormal, ambient + diffuse + specular + probes);
    float mix1 = saturate(_Gloss_FurPrimary * 2);
    float3 mixedColor = lerp(color, (reflectivity * color * 2) + color / 1.5, mix1);
    float mix2 = saturate((_Gloss_FurPrimary * 2) - 1);
    float3 finalColor = lerp(mixedColor, reflectivity, mix2);
    return ((finalColor + (emission + emissionAL)) * rim) + (emission + emissionAL);
}

// Mesh Surface
float4 frag_surface(v2f i): SV_Target {
    float3 color = surface(i.worldNormal, i.worldPos, i.pos, i.texcoord, i.texcoord2, i.color, i.texcoord3);
    return float4(color, 1 );
}


                ENDCG
            }
        }
    }
    FallBack "Standard"
}
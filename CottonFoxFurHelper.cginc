// Custom shader made by Juice...
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
float _Gravity_FurPrimary;
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
float _Opacity;

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
float2 RotateUV(float2 texcoord, float angle) {
    float2 pivot = float2(0.5, 0.5);
    float cosAngle = cos(angle);
    float sinAngle = sin(angle);
    float2x2 rot = float2x2(cosAngle, -sinAngle, sinAngle, cosAngle);
    float2 rotatedtexcoord = texcoord - pivot;
    return mul(rot, rotatedtexcoord) + pivot;
}

float2 DistortUV(float2 texcoord, float distortion, float time) {
    float2 scrollOffset = float2(0, time * .25);
    return (texcoord + (distortion / 5) * sin(texcoord.yx * 10 + scrollOffset)) + (time * .25);
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

// Vertex audiolink function
float audiolinkfur(float2 uv, float4 mask) {
    float activeAL = _AL_Bass + _AL_MidLow + _AL_MidHigh + _AL_Trebel;
    activeAL = max(activeAL, 0.0001); // Prevent division by zero
    float2 rotatedUV = RotateUV(uv, _AL_Rotation);
    float2 distortedUV = DistortUV(rotatedUV, _AL_Distortion, 1);
    float ALFur1 = GetAudioLinkData(distortedUV, 0, .5);
    float ALFur2 = GetAudioLinkData(distortedUV, 1, .5);
    float ALFur3 = GetAudioLinkData(distortedUV, 2, .5);
    float ALFur4 = GetAudioLinkData(distortedUV, 3, .5);
    float ALFur = AudioLinkIsAvailable() ? 
    (((ALFur1 * _AL_Bass) + (ALFur2 * _AL_MidLow) + (ALFur3 * _AL_MidHigh) + (ALFur4 * _AL_Trebel))) / activeAL : 0;
    float furEffect = lerp(0, ALFur, _AL_FurLength);
    return (furEffect * mask.b);
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
float3 addRim(float3 texcoordworldView, float3 UVworldNormal, float3 input) {
    half rim = 1.0 - saturate(dot(texcoordworldView, UVworldNormal));
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

v2f vert_base(appdata v) {
    v2f o;
    o.color = v.color;   // Vertex color
    o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex );
    o.texcoord1 = TRANSFORM_TEX(v.texcoord1, _Mask_FurPrimary);
    o.texcoord2 = TRANSFORM_TEX(v.texcoord2, _EmissionMask_FurPrimary);
    o.texcoord3 = v.texcoord3; // Media
    o.worldNormal = UnityObjectToWorldNormal(v.normal);
    o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

    float4 AL = AudioLinkIsAvailable() ? audiolinkfur(v.texcoord3, v.color) : 0;
    
    float gravityEffect = (_Gravity_FurPrimary / 5) * _FurLength_FurPrimary;
    
    float angle = max(0, dot(o.worldNormal, float3(0, 1, 0)));
    
    float reducedGravityEffect = gravityEffect * (1.0 - angle); // Reduce effect for top surfaces
    
    // Apply gravity offset
    float3 gravityOffset = float3(0, -reducedGravityEffect, 0);
    float3 P = (v.vertex.xyz + v.normal * ((_FurLength_FurPrimary + AL) / 10) * STEP) + gravityOffset * STEP;
    o.pos = UnityObjectToClipPos(float4(P, 1.0));
    
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
    color -= ((pow(1 - STEP, 3)) * _Shading_FurPrimary / 4) * vertexColor;
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
    if (_VRChatMirrorMode == 0) {
        return float4(color, _Opacity);
    } else {
        return float4(color, 1 );
    }
}

// Shell Layers
float4 frag_base(v2f i): SV_Target {
    float3 color = surface(i.worldNormal, i.worldPos, i.pos, i.texcoord, i.texcoord2, i.color, i.texcoord3);
    float3 vertexMask = tex2D(_Mask_FurPrimary, i.texcoord1).rgb;
    if (_VertexMask_FurPrimary > .01) {
        vertexMask *= i.color.rgb * _VertexMask_FurPrimary;
    }
    float noisetexcoordx = (i.texcoord1.x - 0.5) * _Density_FurPrimary + 0.5;
    float noisetexcoordy = (i.texcoord1.y - 0.5) * _Density_FurPrimary + 0.5;
    float2 noisetexcoord = float2(noisetexcoordx, noisetexcoordy);
    float3 noise = tex2D(_Texture_FurPrimary, noisetexcoord).rgb;
    float alpha = clamp((noise * vertexMask) - (STEP * STEP) * _Clip_FurPrimary, 0, 1);
    if (_VRChatMirrorMode == 0) {
        return float4(color, alpha * _Opacity);
    } else {
        return float4(color, alpha);
    }
}

// Custom shader made by Juice...
#pragma target 3.0
#include "Lighting.cginc"
#include "UnityCG.cginc"

float4 _Color;
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
sampler2D _MainTex, _Mask_FurPrimary, _Texture_FurPrimary;
float4 _MainTex_ST, _Mask_FurPrimary_ST, _Texture_FurPrimary_ST;
float _VertexMask_FurPrimary;
float _Clip_FurPrimary;
float _Density_FurPrimary;
float _FurLength_FurPrimary;
float _Shading_FurPrimary;

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
    float4 color : COLOR;   // Vertex color
};

struct v2f {
    float4 pos: SV_POSITION;
    float3 worldNormal: NORMAL;
    float3 worldPos: TEXCOORD4;
    float2 texcoord: TEXCOORD0;
    float2 texcoord1: TEXCOORD1;
    float4 color : COLOR;   // Vertex color
};

v2f vert (appdata v) {
    v2f o;
    o.pos = UnityObjectToClipPos(v.pos);
    o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
    o.texcoord1 = TRANSFORM_TEX(v.texcoord1, _Mask_FurPrimary);
    return o;
}

v2f vert_surface(appdata v) {
    v2f o;
    o.pos = UnityObjectToClipPos(v.vertex);
    o.color = v.color;
    o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
    o.texcoord1 = TRANSFORM_TEX(v.texcoord1, _Mask_FurPrimary);
    o.worldNormal = UnityObjectToWorldNormal(v.normal);
    o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
    return o;
}

v2f vert_base(appdata v) {
    v2f o;

    float3 P = v.vertex.xyz + v.normal * ((_FurLength_FurPrimary) / 10) * STEP;
    o.pos = UnityObjectToClipPos(float4(P, 1.0));
    o.color = v.color;   // Vertex color
    o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex );
    o.texcoord1 = TRANSFORM_TEX(v.texcoord1, _Mask_FurPrimary);
    o.worldNormal = UnityObjectToWorldNormal(v.normal);
    o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
    return o;
}

// Color & Texture
float3 surface(float3 UVworldNormal, float3 UVworldPos, float3 UVpos, float2 UVcolor, float4 vertexColor) {
    float3 worldNormal = normalize(UVworldNormal);
    float3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
    float3 worldView = normalize(_WorldSpaceCameraPos.xyz - UVworldPos.xyz);
    float3 worldHalf = normalize(worldView + worldLight);
    float3 mainColor = HSBI(tex2D(_MainTex, UVcolor)).rgb * _Color;
    float3 color = mainColor.rgb;
    
    color -= ((pow(1 - STEP, 3)) * _Shading_FurPrimary / 4) * vertexColor;


    float3 reflectivity = reflection(worldNormal, UVworldPos, _Gloss_FurPrimary);
    float3 ambient = unity_AmbientEquator.xyz * _Ambient_FurPrimary;
    float3 diffuse = _LightColor0.rgb * (saturate(dot(worldNormal, worldLight)) * (_Directional_FurPrimary));
    float3 specular = (_LightColor0.rgb * pow(saturate(dot(worldNormal, worldHalf)), clamp( (_SpecularShine_FurPrimary * 90), .001, 90) ) * _SpecularPower_FurPrimary);
    float3 probes = ShadeSH9(float4(worldNormal,1)) * _Probes_FurPrimary * 2;
    float3 rim = addRim(worldView, worldNormal, ambient + diffuse + specular + probes);
    float mix1 = saturate(_Gloss_FurPrimary * 2);
    float3 mixedColor = lerp(color, (reflectivity * color * 2) + color / 1.5, mix1);
    float mix2 = saturate((_Gloss_FurPrimary * 2) - 1);
    float3 finalColor = lerp(mixedColor, reflectivity, mix2);
    return finalColor * rim;
}

// Mesh Surface
float4 frag_surface(v2f i): SV_Target {
    float3 color = surface(i.worldNormal, i.worldPos, i.pos, i.texcoord, i.color);
    return float4(color, 1 );
}

// Shell Layers
float4 frag_base(v2f i): SV_Target {
    float3 color = surface(i.worldNormal, i.worldPos, i.pos, i.texcoord, i.color);
    float3 vertexMask = tex2D(_Mask_FurPrimary, i.texcoord1).rgb;
    if (_VertexMask_FurPrimary > .01) {
        vertexMask *= i.color.rgb * _VertexMask_FurPrimary;
    }
    float noisetexcoordx = (i.texcoord1.x - 0.5) * _Density_FurPrimary + 0.5;
    float noisetexcoordy = (i.texcoord1.y - 0.5) * _Density_FurPrimary + 0.5;
    float2 noisetexcoord = float2(noisetexcoordx, noisetexcoordy);
    float3 noise = tex2D(_Texture_FurPrimary, noisetexcoord).rgb;
    float alpha = clamp((noise * vertexMask) - (STEP * STEP) * _Clip_FurPrimary, 0, 1);
    return float4(color, alpha);
}

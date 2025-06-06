// Custom shader made by Juice...
Shader "Custom/CottonFoxFur" {
    Properties {
        [Header(Color)]
        [Space(10)]
        _Hue_FurPrimary ("Hue", Range(0.0, 360.0)) = 0.0
        _Saturation_FurPrimary ("Saturation", Range(0.0, 2.0)) = 1.0
        _Bright_FurPrimary("Brightness", Range(-1,1)) = 0
        [MaterialToggle]_Invert_FurPrimary ("Invert", Range(0, 1)) = 0
        _Emission_FurPrimary ("Emission", Range(0.0, 4.0)) = .5
        _Rim_FurPrimary ("Rim Lighting", Range(-0.5, 1.0)) = 0
        _Opacity("Alpha", Range(0.0, 512.0)) = 0

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
        [Header(Fur (UV2))]
        [Space(10)]
        _Mask_FurPrimary ("Height Mask", 2D) = "white" { }
        _VertexMask_FurPrimary("Vertex Color Influence", Range(0, 1)) = 0
        [NoScaleOffset] _Texture_FurPrimary ("Texture", 2D) = "white" { }
        _Density_FurPrimary ("Density", Range(1,20)) = 8
        _Clip_FurPrimary ("Clip", Range(0.0, 1)) = 0.5
        _FurLength_FurPrimary ("Length", Range(0.0, 1)) = 0.5
        _Gravity_FurPrimary ("Gravity", Range(0.0, 1)) = 0.5
        _Shading_FurPrimary ("Shading", Range(0.0, 1)) = 0.25

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
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
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
                #define STEP 0.00
                #include "CottonFoxFurHelper.cginc"
                ENDCG
            }
            Pass {
                CGPROGRAM
                #pragma vertex vert_base
                #pragma fragment frag_base
                #define STEP 0.05
                #include "CottonFoxFurHelper.cginc"
                ENDCG
            }
            Pass {
                CGPROGRAM
                #pragma vertex vert_base
                #pragma fragment frag_base
                #define STEP 0.10
                #include "CottonFoxFurHelper.cginc"
                ENDCG
            }
            Pass {
                CGPROGRAM
                #pragma vertex vert_base
                #pragma fragment frag_base
                #define STEP 0.15
                #include "CottonFoxFurHelper.cginc"
                ENDCG
            }
            Pass {
                CGPROGRAM
                #pragma vertex vert_base
                #pragma fragment frag_base
                #define STEP 0.20
                #include "CottonFoxFurHelper.cginc"
                ENDCG
            }
            Pass {
                CGPROGRAM
                #pragma vertex vert_base
                #pragma fragment frag_base
                #define STEP 0.25
                #include "CottonFoxFurHelper.cginc"
                ENDCG
            }
            Pass {
                CGPROGRAM
                #pragma vertex vert_base
                #pragma fragment frag_base
                #define STEP 0.30
                #include "CottonFoxFurHelper.cginc"
                ENDCG
            }
            Pass {
                CGPROGRAM
                #pragma vertex vert_base
                #pragma fragment frag_base
                #define STEP 0.35
                #include "CottonFoxFurHelper.cginc"
                ENDCG
            }
            Pass {
                CGPROGRAM
                #pragma vertex vert_base
                #pragma fragment frag_base
                #define STEP 0.40
                #include "CottonFoxFurHelper.cginc"
                ENDCG
            }
            Pass {
                CGPROGRAM
                #pragma vertex vert_base
                #pragma fragment frag_base
                #define STEP 0.45
                #include "CottonFoxFurHelper.cginc"
                ENDCG
            }
            Pass {
                CGPROGRAM
                #pragma vertex vert_base
                #pragma fragment frag_base
                #define STEP 0.50
                #include "CottonFoxFurHelper.cginc"
                ENDCG
            }
            Pass {
                CGPROGRAM
                #pragma vertex vert_base
                #pragma fragment frag_base
                #define STEP 0.55
                #include "CottonFoxFurHelper.cginc"
                ENDCG
            }
            Pass {
                CGPROGRAM
                #pragma vertex vert_base
                #pragma fragment frag_base
                #define STEP 0.60
                #include "CottonFoxFurHelper.cginc"
                ENDCG
            }
            Pass {
                CGPROGRAM
                #pragma vertex vert_base
                #pragma fragment frag_base
                #define STEP 0.65
                #include "CottonFoxFurHelper.cginc"
                ENDCG
            }
            Pass {
                CGPROGRAM
                #pragma vertex vert_base
                #pragma fragment frag_base
                #define STEP 0.70
                #include "CottonFoxFurHelper.cginc"
                ENDCG
            }
            Pass {
                CGPROGRAM
                #pragma vertex vert_base
                #pragma fragment frag_base
                #define STEP 0.75
                #include "CottonFoxFurHelper.cginc"
                ENDCG
            }
            Pass {
                CGPROGRAM
                #pragma vertex vert_base
                #pragma fragment frag_base
                #define STEP 0.80
                #include "CottonFoxFurHelper.cginc"
                ENDCG
            }
            Pass {
                CGPROGRAM
                #pragma vertex vert_base
                #pragma fragment frag_base
                #define STEP 0.85
                #include "CottonFoxFurHelper.cginc"
                ENDCG
            }
            Pass {
                CGPROGRAM
                #pragma vertex vert_base
                #pragma fragment frag_base
                #define STEP 0.90
                #include "CottonFoxFurHelper.cginc"
                ENDCG
            }
            Pass {
                CGPROGRAM
                #pragma vertex vert_base
                #pragma fragment frag_base
                #define STEP 0.95
                #include "CottonFoxFurHelper.cginc"
                ENDCG
            }
            Pass {
                CGPROGRAM
                #pragma vertex vert_base
                #pragma fragment frag_base
                #define STEP 1.00
                #include "CottonFoxFurHelper.cginc"
                ENDCG
            }
        }
    }
    FallBack "Standard"
}
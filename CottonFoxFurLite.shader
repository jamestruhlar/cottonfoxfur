// Custom shader made by Juice...
Shader "Custom/CottonFoxFur (Lite)" {
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
        [Header(Fur (UV2))]
        [Space(10)]
        _Mask_FurPrimary ("Fur Height Mask", 2D) = "white" { }
        _VertexMask_FurPrimary("Vertex Color Influence", Range(0, 1)) = 0
        [NoScaleOffset] _Texture_FurPrimary ("Fur Texture", 2D) = "white" { }
        _Density_FurPrimary ("Fur Density", Range(1,20)) = 8
        _Clip_FurPrimary ("Fur Clip", Range(0.0, 1)) = 0.5
        _FurLength_FurPrimary ("Fur Length", Range(0.0, 1)) = 0.5
        _Shading_FurPrimary ("Fur Shading", Range(0.0, 1)) = 0.25
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
                #include "CottonFoxFurLiteHelper.cginc"
                ENDCG
            }
            Pass {
                CGPROGRAM
                #pragma vertex vert_base
                #pragma fragment frag_base
                #define STEP 0.05
                #include "CottonFoxFurLiteHelper.cginc"
                ENDCG
            }
            Pass {
                CGPROGRAM
                #pragma vertex vert_base
                #pragma fragment frag_base
                #define STEP 0.10
                #include "CottonFoxFurLiteHelper.cginc"
                ENDCG
            }
            Pass {
                CGPROGRAM
                #pragma vertex vert_base
                #pragma fragment frag_base
                #define STEP 0.15
                #include "CottonFoxFurLiteHelper.cginc"
                ENDCG
            }
            Pass {
                CGPROGRAM
                #pragma vertex vert_base
                #pragma fragment frag_base
                #define STEP 0.20
                #include "CottonFoxFurLiteHelper.cginc"
                ENDCG
            }
            Pass {
                CGPROGRAM
                #pragma vertex vert_base
                #pragma fragment frag_base
                #define STEP 0.25
                #include "CottonFoxFurLiteHelper.cginc"
                ENDCG
            }
            Pass {
                CGPROGRAM
                #pragma vertex vert_base
                #pragma fragment frag_base
                #define STEP 0.30
                #include "CottonFoxFurLiteHelper.cginc"
                ENDCG
            }
            Pass {
                CGPROGRAM
                #pragma vertex vert_base
                #pragma fragment frag_base
                #define STEP 0.35
                #include "CottonFoxFurLiteHelper.cginc"
                ENDCG
            }
            Pass {
                CGPROGRAM
                #pragma vertex vert_base
                #pragma fragment frag_base
                #define STEP 0.40
                #include "CottonFoxFurLiteHelper.cginc"
                ENDCG
            }
            Pass {
                CGPROGRAM
                #pragma vertex vert_base
                #pragma fragment frag_base
                #define STEP 0.45
                #include "CottonFoxFurLiteHelper.cginc"
                ENDCG
            }
            Pass {
                CGPROGRAM
                #pragma vertex vert_base
                #pragma fragment frag_base
                #define STEP 0.50
                #include "CottonFoxFurLiteHelper.cginc"
                ENDCG
            }
            Pass {
                CGPROGRAM
                #pragma vertex vert_base
                #pragma fragment frag_base
                #define STEP 0.55
                #include "CottonFoxFurLiteHelper.cginc"
                ENDCG
            }
            Pass {
                CGPROGRAM
                #pragma vertex vert_base
                #pragma fragment frag_base
                #define STEP 0.60
                #include "CottonFoxFurLiteHelper.cginc"
                ENDCG
            }
            Pass {
                CGPROGRAM
                #pragma vertex vert_base
                #pragma fragment frag_base
                #define STEP 0.65
                #include "CottonFoxFurLiteHelper.cginc"
                ENDCG
            }
            Pass {
                CGPROGRAM
                #pragma vertex vert_base
                #pragma fragment frag_base
                #define STEP 0.70
                #include "CottonFoxFurLiteHelper.cginc"
                ENDCG
            }
            Pass {
                CGPROGRAM
                #pragma vertex vert_base
                #pragma fragment frag_base
                #define STEP 0.75
                #include "CottonFoxFurLiteHelper.cginc"
                ENDCG
            }
            Pass {
                CGPROGRAM
                #pragma vertex vert_base
                #pragma fragment frag_base
                #define STEP 0.80
                #include "CottonFoxFurLiteHelper.cginc"
                ENDCG
            }
            Pass {
                CGPROGRAM
                #pragma vertex vert_base
                #pragma fragment frag_base
                #define STEP 0.85
                #include "CottonFoxFurLiteHelper.cginc"
                ENDCG
            }
            Pass {
                CGPROGRAM
                #pragma vertex vert_base
                #pragma fragment frag_base
                #define STEP 0.90
                #include "CottonFoxFurLiteHelper.cginc"
                ENDCG
            }
            Pass {
                CGPROGRAM
                #pragma vertex vert_base
                #pragma fragment frag_base
                #define STEP 0.95
                #include "CottonFoxFurLiteHelper.cginc"
                ENDCG
            }
            Pass {
                CGPROGRAM
                #pragma vertex vert_base
                #pragma fragment frag_base
                #define STEP 1.00
                #include "CottonFoxFurLiteHelper.cginc"
                ENDCG
            }
        }
    }
    FallBack "Standard"
}
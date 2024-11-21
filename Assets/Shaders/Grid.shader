Shader "Custom/Grid"
{
    Properties
    {
        _StencilRef ("Stencil Ref", range(0, 255)) = 1
        _Color ("Color", Color) = (1,1,1,1)
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        
        [Header(Grid)]
        _GridColor ("Grid Color", Color) = (0,0.61,0.7,1)
        _EmissionStrength ("Emission Strength", Range(0, 5)) = 0
        _GridScale ("Grid Scale", float) = 10
        _GridThickness ("Grid Thickness", Range(0, 1)) = 0.1
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Geometry-3" }
        LOD 200
        

        stencil
        {
            ref [_StencilRef]
            comp equal
        }
        
        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows vertex:vert alpha:fade

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0
        #define PI 3.1415926535

        struct Input
        {
            float3 vertex;
            INTERNAL_DATA
        };
        
        void vert (inout appdata_full v, out Input o) {
            UNITY_INITIALIZE_OUTPUT(Input,o);
            o.vertex = v.vertex;
        }

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

        fixed4 _GridColor;
        float _EmissionStrength;
        float _GridScale;
        float _GridThickness;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)
        
        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            float2 grid = saturate((cos(IN.vertex.xz * 2 * PI * _GridScale) * 0.5 + 0.5 - (1 - _GridThickness)) / _GridThickness);
            float gridMask = max(grid.x, grid.y);
            fixed4 c = lerp(_Color, _GridColor, gridMask);
            o.Albedo = c.rgb;
            o.Emission = _GridColor * gridMask * _EmissionStrength;
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}

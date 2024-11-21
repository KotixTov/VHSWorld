Shader "Custom/Ground"
{
    Properties
    {
        _StencilRef ("Stencil Ref", range(0, 255)) = 1
        _Color ("Color", Color) = (1,1,1,1)
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        
        [Header(Noise)]
        _Amplitude ("Amplitude", Range(0,10)) = 1
        _NoiseScale ("Noise Scale", Range(0, 2)) = 1
        _Dimensions ("Dimension", vector) = (10, 10, 0, 0)
        _Offset ("Offset", float) = 0
        
        [Header(Grid)]
        _GridColor ("Grid Color", Color) = (0,0.61,0.7,1)
        _EmissionStrength ("Emission Strength", Range(0, 5)) = 0
        _GridScale ("Grid Scale", float) = 10
        _GridThickness ("Grid Thickness", Range(0, 1)) = 0.1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry-4" }
        LOD 200

        stencil
        {
            ref [_StencilRef]
            comp equal
        }
        
        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows vertex:vert addshadow

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0
        #define PI 3.1415926535

        struct Input
        {
            float3 vertex;
            float3 worldPos;
            float3 worldNormal;
            INTERNAL_DATA
        };

        #include "Noise.hlsl"

        float _Amplitude;
        float _NoiseScale;
        float2 _Dimensions;
        float _Offset;
        
        void vert (inout appdata_full v, out Input o) {
            UNITY_INITIALIZE_OUTPUT(Input,o);
            o.worldPos = mul(unity_ObjectToWorld, v.vertex);
            float noiseMask = saturate(abs(v.vertex.x / 3) - 1 + abs(o.worldPos.z / 10));
            v.vertex.y += Noise2D(v.vertex.xz + float2(0, _Offset), _NoiseScale) * _Amplitude * noiseMask;
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

        
        float3 WorldToTangentNormalVector(Input IN, float3 normal) {
            float3 t2w0 = WorldNormalVector(IN, float3(1,0,0));
            float3 t2w1 = WorldNormalVector(IN, float3(0,1,0));
            float3 t2w2 = WorldNormalVector(IN, float3(0,0,1));
            float3x3 t2w = float3x3(t2w0, t2w1, t2w2);
            return normalize(mul(t2w, normal));
        }
        
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
            
            float3 x = ddx(IN.worldPos);
            float3 y = ddy(IN.worldPos);
            float3 n =  WorldToTangentNormalVector(IN, -normalize(cross(x, y)));
            o.Normal = n;
        }
        ENDCG
    }
    FallBack "Diffuse"
}

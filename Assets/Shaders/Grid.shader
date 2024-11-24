Shader "Custom/Grid"
{
    Properties
    {
        _StencilRef ("Stencil Ref", range(0, 255)) = 1
        _Color ("Color", Color) = (1,1,1,1)
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        
        [Header(Grid)]
        _GridScale ("Grid Scale", float) = 10
        _GridThickness ("Grid Thickness", Range(0, 1)) = 0.1
        _GridSpeed ("Grid Speed", Vector) = (0,0,0,0)
        _GridColor ("Grid Color", Color) = (0,0.61,0.7,1)
        _EmissionStrength ("Emission Strength", Range(0, 5)) = 0
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
            float4 screenPos;
            float3 viewDir;
        };
        
        void vert (inout appdata_full v, out Input o) {
            UNITY_INITIALIZE_OUTPUT(Input,o);
            o.vertex = v.vertex;
        }

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

        float _GridScale;
        float _GridThickness;
        float3 _GridSpeed;
        fixed4 _GridColor;
        float _EmissionStrength;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)
        
        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            _GridThickness *= IN.screenPos.w;
            float2 grid = saturate((cos(IN.vertex.xz * 2 * PI * _GridScale + _GridSpeed.xz * _Time.y) * 0.5 + 0.5 - (1 - _GridThickness)) / _GridThickness);
            float gridMask = max(grid.x, grid.y);
            fixed4 c = lerp(_Color, _GridColor, gridMask);
            float fresnel = 1 - abs(dot(normalize(IN.viewDir), float3(0,1,0)));
            c = lerp(c, _GridColor, pow(fresnel, 4));
            o.Albedo = c.rgb;
            fixed3 e = _GridColor * gridMask * _EmissionStrength;
            o.Emission = lerp(e, _GridColor,  pow(fresnel, 4));
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}

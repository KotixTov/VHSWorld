Shader "Custom/CRTScreen"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        
        [Header(CRT)]
        _MaxDistance ("Max Distance", float) = 3
        _CRTScale ("CRT Scale", float) = 100
        _CRTStrength ("CRT Lines Strength", Range(0,1)) = 0.3
        _ChromaticAberration ("Chromatic Aberration", Vector) = (0,0,0,0)
        _NoiseStrength ("Noise Strength", Range(0,1)) = 0.1
        _Distortion ("Distortion", Range(0,1)) = 0.1
        
        [Header(Brightness)]
        _Brightness ("Brightness", Range(0,1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        LOD 200
        
        Cull Off
        Blend SrcAlpha OneMinusSrcAlpha

        GrabPass { }
        
        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0
        #define PI 3.1415926535

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
            float4 screenPos;
        };
        
        sampler2D _GrabTexture;
        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        float _MaxDistance;
        float _CRTScale;
        float _CRTStrength;
        float2 _ChromaticAberration;
        float _NoiseStrength;
        float _Distortion;
        float _Brightness;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        #include "Noise.hlsl"
        
        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            float relativeDistance = IN.screenPos.w / _MaxDistance;
            float CRTMask = 1 - (sin(IN.uv_MainTex.y * _CRTScale * 2 * PI) * 0.5 + 0.5) * _CRTStrength * saturate(1 - relativeDistance);
            float2 uv = IN.screenPos.xy/IN.screenPos.w;
            float noise = Noise2D(IN.uv_MainTex.xy + random(_Time) * 1000, _CRTScale) * _NoiseStrength;
            float2 distortion = float2(Noise2D(IN.uv_MainTex.xy + random(_Time) * 1000, _CRTScale), Noise2D(-IN.uv_MainTex.xy - random(_Time) * 1000, _CRTScale));
            uv += distortion * _Distortion / _CRTScale * saturate(1 - relativeDistance);
            fixed4 c = fixed4(0,0,0,1);
            _ChromaticAberration /= _CRTScale;
            c.r = tex2D (_GrabTexture, uv + _ChromaticAberration / IN.screenPos.w).r;
            c.g = tex2D (_GrabTexture, uv).g;
            c.b = tex2D (_GrabTexture, uv - _ChromaticAberration / IN.screenPos.w).b;
            c *= _Color * CRTMask;
            c += noise;

            
            
            o.Albedo = c.rgb;
            o.Emission = c.rgb * _Brightness;
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            
            o.Alpha = 1;
        }
        ENDCG
    }

    FallBack "Diffuse"
}

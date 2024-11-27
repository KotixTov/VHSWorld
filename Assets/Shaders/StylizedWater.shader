Shader "Custom/StylizedWater"
{
    Properties
    {
        _StencilRef ("Stencil Ref", range(0, 255)) = 1
        _Speed ("Speed", vector) = (0,0,0,0)
        _NoiseScale ("Noise Scale", float) = 1
        _Amplitude ("Amplitude", float) = 1
        _Color1 ("Color", Color) = (0,0,0,1)
        _Color2 ("Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Geometry-4" }
        LOD 100
        
        Blend SrcAlpha OneMinusSrcAlpha

        stencil
        {
            ref [_StencilRef]
            comp equal
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Noise.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 objPos : TEXCOORD1;
            };

            float4 _Speed;
            float _NoiseScale;
            float _Amplitude;
            float4 _Color1;
            float4 _Color2;
            
            v2f vert (appdata v)
            {
                v2f o;
                float4 position = v.vertex;
                position.y += Noise4D(float4(position.xyz, 0) + _Time.y * _Speed, _NoiseScale) * _Amplitude;
                o.vertex = UnityObjectToClipPos(position);
                o.objPos = position;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = lerp(_Color1, _Color2, i.objPos.y / _Amplitude);
                return col;
            }
            ENDCG
        }
    }
}

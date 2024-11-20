Shader "Custom/FakeSkybox"
{
    Properties
    {
        _StencilRef ("Stencil Ref", range(0, 255)) = 1
        _TopColor ("Color", Color) = (0.5, 0.7, 1, 1)
        _BottomColor ("Color", Color) = (0.1, 0.3, 0.6, 1)
        _Offset ("Offset", Range(-10, 10)) = 0
        _Multiplier ("Multiplier", Range(0, 10)) = 1
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" "Queue" = "Geometry-4" }
        Cull Off
        ZWrite Off
        LOD 100

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

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 worldPosition : TEXCOORD1;
            };
            
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldPosition = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }
            
            fixed4 _TopColor;
            fixed4 _BottomColor;
            float _Offset;
            float _Multiplier;
            
            fixed4 frag (v2f i) : SV_Target
            {
                float maskHorizon = saturate((dot(normalize(i.worldPosition), float3(0, 1, 0)) * 0.5 + 0.5) * _Multiplier + _Offset);
                fixed4 col = lerp(_BottomColor, _TopColor, maskHorizon);
                return col;
            }
            ENDCG
        }
    }
}

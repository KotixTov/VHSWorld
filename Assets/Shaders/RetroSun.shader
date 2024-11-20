Shader "Unlit/RetroSun"
{
    Properties
    {
        _StencilRef ("Stencil Ref", range(0, 255)) = 1
        _TopColor ("Top Color", Color) = (1,1,1,1)
        _BottomColor ("Bottom & Rim Color", Color) = (0,0,0,1)
        _RimStrength ("Rim Strength", Range(0, 2)) = 1
        _Speed ("Speed", Range(0, 10)) = 1
        _LinesFrequency ("Lines Frequency", Range(0, 200)) = 100
        _TresholdOffset ("Treshold Offset", Range(-2, 2)) = 1
        _LinesThickness ("Lines Thickness", Range(0, 10)) = 2
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Geometry-3" }
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

            #define PI 3.1415926535
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 objPos : TEXCOORD1;
                float3 normal : TEXCOORD2;
                float3 viewDir : TEXCOORD3;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.objPos = v.vertex;
                o.normal = v.normal;
                o.viewDir = normalize(ObjSpaceViewDir(o.objPos));
                return o;
            }

            fixed4 _TopColor;
            fixed4 _BottomColor;
            float _RimStrength;
            float _Speed;
            float _LinesFrequency;
            float _TresholdOffset;
            float _LinesThickness;
            
            fixed4 frag (v2f i) : SV_Target
            {
                float gradientMask = saturate(i.objPos.y + 0.5) * saturate(dot(i.normal, i.viewDir) + (1 - _RimStrength));
                fixed4 col = lerp(_BottomColor, _TopColor, gradientMask);
                col.a = saturate(sign(sin(i.objPos.y * _LinesFrequency - _Time.y * _Speed) + i.objPos.y * _LinesThickness * PI + _TresholdOffset));
                return col;
            }
            ENDCG
        }
    }
}

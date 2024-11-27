Shader "Custom/MaskableUnlit"
{
    Properties
    {
        _StencilRef("Stencil Ref", Float) = 0
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
        [HDR] _Emission ("Emission", Color) = (0,0,0,0)
    }
    SubShader
    {
        Tags { "RenderType"="Transparent"  "Queue"="Geometry-3" }
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

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                fixed4 color : COLOR;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                fixed4 color : COLOR;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.color = v.color;
                return o;
            }

            fixed4 _Color;
            fixed4 _Emission;
            
            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv) * _Color;
                col.rgb = lerp(col.rgb, _Emission.rgb * _Emission.a, saturate(_Emission.a)) * i.color.rgb * i.color.a;
                return col;
            }
            ENDCG
        }
    }
}

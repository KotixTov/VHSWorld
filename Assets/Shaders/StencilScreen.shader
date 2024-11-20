Shader "Custom/StencilScreen"
{
    Properties
    {
        _Stencil ("Stencil Layer", range(0, 255)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry-5" }
        LOD 200
        
        ColorMask 0
        ZWrite Off
        
        stencil
        {
            ref [_Stencil]
            pass replace
            comp notequal
        }
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            struct v2f
            {
                float4 pos : SV_POSITION;
            };

            v2f vert(appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            half4 frag(v2f i) : COLOR
            {
                return 0;
            }
            ENDCG
        }
    }

    FallBack "Diffuse"
}

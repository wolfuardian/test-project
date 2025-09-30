Shader "NADIVisual/Blink"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("HDR Color", Color) = (1,1,1,1)
        _MinIntensity ("Min Intensity", Range(0, 1)) = 0.0
        _MaxIntensity ("Max Intensity", Range(0, 1)) = 1.0
        _IntensityMultiplier ("Intensity Multiplier", Float) = 1.0
        _BlinkInterval ("Blink Interval (Seconds)", Float) = 1.0

        // --- UI Mask / Stencil 需要的隱藏屬性 ---
        [HideInInspector] _StencilComp ("Stencil Comparison", Float) = 8
        [HideInInspector] _Stencil ("Stencil ID", Float) = 0
        [HideInInspector] _StencilOp ("Stencil Operation", Float) = 0
        [HideInInspector] _StencilWriteMask ("Stencil Write Mask", Float) = 255
        [HideInInspector] _StencilReadMask ("Stencil Read Mask", Float) = 255
        [HideInInspector] _ColorMask ("Color Mask", Float) = 15
    }
    SubShader
    {
        Tags
        {
            "Queue"="Transparent"
            "IgnoreProjector"="True"
            "RenderType"="Transparent"
            "PreviewType"="Sprite"
            "CanUseSpriteAtlas"="True"
        }
        LOD 100

        Pass
        {
            Name "Blink"

            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off
            Lighting Off
            ZWrite Off

            // --- 關鍵：Stencil 支援 ---
            Stencil
            {
                Ref [_Stencil]
                Comp [_StencilComp]
                Pass [_StencilOp]
                ReadMask [_StencilReadMask]
                WriteMask [_StencilWriteMask]
            }
            ColorMask [_ColorMask]

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                half4 color : COLOR;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                half4 color : COLOR;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;
            float _MinIntensity;
            float _MaxIntensity;
            float _IntensityMultiplier;
            float _BlinkInterval;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.color = v.color;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 color = tex2D(_MainTex, i.uv) * _Color;

                float t = fmod(_Time.y, _BlinkInterval) / _BlinkInterval;
                float lerp_t = lerp(_MinIntensity, _MaxIntensity, abs(1 - 2 * t));
                float intensity = lerp_t * _IntensityMultiplier;

                fixed4 final_color = color * intensity * i.color;
                final_color.a = saturate(final_color.a);
                return final_color;
            }
            ENDCG
        }
    }
}
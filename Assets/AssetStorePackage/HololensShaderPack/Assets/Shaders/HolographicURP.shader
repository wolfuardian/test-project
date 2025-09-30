Shader "Hololens Shader Pack/HolographicHDR"
{
    Properties
    {
        _Color("Color", Color) = (0.26,0.19,0.16,0.0)
        _Offset("Offset", Range(0.0,1.0)) = 0.0
        _Scale("Scale", Range(0.0,10.0)) = 1.0
        _RimPower("Rim Power", Range(0.1,8.0)) = 3.0
        _EmissionMultiplier("Emission Multiplier", Range(0.0,10.0)) = 2.0
    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent" "Queue" = "Transparent"
        }

        Pass
        {
            Cull Back
            Blend One One

            CGPROGRAM
            #include "HoloCP.cginc"

            #pragma vertex vert
            #pragma fragment frag

            fixed4 _Color;
            fixed _Offset;
            fixed _Scale;
            fixed _RimPower;
            fixed _EmissionMultiplier;

            struct v2f
            {
                fixed4 viewPos : SV_POSITION;
                fixed3 normal: NORMAL;
                fixed3 worldSpaceViewDir: TEXCOORD0;
                fixed4 world : TEXCOORD1;
                fixed2 offset: TEXCOORD2;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            v2f vert(appdata_base v)
            {
                UNITY_SETUP_INSTANCE_ID(v);
                v2f o;
                o.viewPos = UnityObjectToClipPos(v.vertex);
                o.worldSpaceViewDir = WorldSpaceViewDir(v.vertex);
                o.normal = mul(unity_ObjectToWorld, fixed4(v.normal, 0.0)).xyz;
                o.world = mul(unity_ObjectToWorld, v.vertex);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                return o;
            }

            fixed4 frag(v2f i) : COLOR
            {
                fixed4 o = 0;
                half rim = 1.0 - saturate(dot(normalize(i.worldSpaceViewDir), normalize(i.normal)));
                // 將計算結果乘上發光乘數，輸出 HDR 色值
                o.rgb = _Color.rgb * (_Offset + _Scale * pow(rim, _RimPower)) * _EmissionMultiplier;
                return o;
            }
            ENDCG
        }

    }
    FallBack "Diffuse"
}
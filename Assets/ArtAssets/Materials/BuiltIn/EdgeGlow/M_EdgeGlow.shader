Shader "NADIVisual/EdgeGlow"
{
    Properties
    {
        _BaseColor("Base Color", Color) = (0.0, 0.8, 1.0, 0.3)
        _EdgeColor("Edge Glow Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _RimPower("Rim Power", Range(0.1, 8.0)) = 3.0
        _GlowIntensity("Glow Intensity", Range(0.0, 5.0)) = 1.0
    }

    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            fixed4 _BaseColor;
            fixed4 _EdgeColor;
            float _RimPower;
            float _GlowIntensity;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 normalDir : TEXCOORD0;
                float3 viewDir : TEXCOORD1;
            };

            v2f vert(appdata v)
            {
                v2f o;
                float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.pos = UnityObjectToClipPos(v.vertex);
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.viewDir = normalize(_WorldSpaceCameraPos - worldPos.xyz);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float rim = 1.0 - saturate(abs(dot(normalize(i.normalDir), normalize(i.viewDir))));
                rim = pow(rim, _RimPower);

                fixed4 col = _BaseColor;
                col.rgb += _EdgeColor.rgb * rim * _GlowIntensity;

                return col;
            }
            ENDCG
        }
    }

    Fallback Off
}

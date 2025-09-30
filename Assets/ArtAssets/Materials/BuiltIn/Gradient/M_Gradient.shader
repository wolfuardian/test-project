Shader "NADIVisual/Gradient"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ColorA ("Color A", Color) = (1,1,1,1)
        _ColorB ("Color B", Color) = (1,1,1,1)
        _GradientDirection ("Gradient Direction", Range(0, 1)) = 0
        _Speed ("Speed", Float) = 0
        _EmissionMultiplier("Emission Multiplier", Range(0.0,10.0)) = 2.0
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
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _ColorA;
            float4 _ColorB;
			fixed _EmissionMultiplier;

            float _GradientDirection;

            float _Speed;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o, o.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float actualSpeed = _Speed * 20;
                float deltaTime = _Time * actualSpeed;

                deltaTime = frac(deltaTime);
                i.uv.x += deltaTime;
                i.uv.y += deltaTime;

                i.uv.x = frac(i.uv.x);
                i.uv.y = frac(i.uv.y);

                float gradientValue = lerp(i.uv.x, i.uv.y, _GradientDirection);

                if (_Speed < 0)
                {
                    gradientValue = 1 - gradientValue;
                }
                fixed4 col = lerp(_ColorA, _ColorB, gradientValue) * _EmissionMultiplier;
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
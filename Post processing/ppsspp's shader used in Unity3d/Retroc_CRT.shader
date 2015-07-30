/*
*Hi, I'm Lin Dong,
*this shader's algorithm is from ppsspp
*this is a shader about CRT
*maybe something wrong, welcome to contect me
*if you want to get more detail please enter my blog http://blog.csdn.net/wolf96
*/
Shader "Custom/Retroc_CRT" {
		Properties{
		_MainTex("Main", 2D) = "white" {}
		_Size("Size", range(0.00005, 0.0008)) = 0.0001
		_Inten("Inten", range(0.5, 4)) = 2
	}
		SubShader{
			pass{
			Tags{ "LightMode" = "ForwardBase" }
			Cull off
				CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#include "UnityCG.cginc"
#include "MyFunc.cginc"

				float _Size;
			float _Inten;

				float4 _LightColor0;
			sampler2D _MainTex;
			float4 _MainTex_TexelSize;
			float4 _MainTex_ST;
			struct v2f {
				float4 pos : SV_POSITION;
				float2 uv_MainTex : TEXCOORD0;

			};

			v2f vert(appdata_full v) {
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv_MainTex = TRANSFORM_TEX(v.texcoord, _MainTex);
				return o;
			}

			float4 frag(v2f i) :COLOR
			{

				// scanlines
				float vPos = float((i.uv_MainTex.y + _Time.z * 0.5) * 272.0);
				float j = 2;
				float line_intensity = modf(float(vPos), j);

				// color shift
				float off = line_intensity *0.00001;
				float2 shift = float2(off, 0);

				// shift R and G channels to simulate NTSC color bleed
				float2 colorShift = float2(0.001, 0);
				float r = tex2D(_MainTex, i.uv_MainTex + colorShift + shift).x;
				float g = tex2D(_MainTex, i.uv_MainTex - colorShift + shift).y;
				float b = tex2D(_MainTex, i.uv_MainTex).z;

				float4 c = float4(r, g * 0.99, b, 1) * clamp(line_intensity, 0.85, 1);

				float rollbar = sin((i.uv_MainTex.y + _Time.z) * 30);

				return c + (rollbar * 0.02);
			}
			ENDCG
		}//

		}
	}
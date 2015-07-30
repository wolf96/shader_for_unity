/*
*Hi, I'm Lin Dong,
*this shader's algorithm is from ppsspp
*this is a shader about scanlines
*maybe something wrong, welcome to contect me
*if you want to get more detail please enter my blog http://blog.csdn.net/wolf96
*/
Shader "Custom/scanlines" {
		Properties{
		_MainTex("Main", 2D) = "white" {}
		_Amount("Amount", range(0.3, 2)) = 1//越大线个数越少，线越宽
		_Inten("Inten", range(0.2, 1)) = 0.5//越大，背景色越深
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

				float _Amount;
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

				float pos0 = ((i.uv_MainTex.y + 1.0) * 170.0*_Amount);
				float pos1 = cos((frac(pos0) - 0.5)*3.1415926*_Inten)*1.5;
				float4 rgb = tex2D(_MainTex, i.uv_MainTex);

				// slight contrast curve
				float4 color = rgb*0.5 + 0.5*rgb*rgb*1.2;

				// color tint
				color *= float4(0.9, 1.0, 0.7, 0.0);

				// vignette
				color *= 1.1 - 0.6 * (dot(i.uv_MainTex - 0.5, i.uv_MainTex - 0.5) * 2.0);

				return mix(float4(0, 0, 0, 0), color, pos1);
			}
			ENDCG
		}//

		}
	}
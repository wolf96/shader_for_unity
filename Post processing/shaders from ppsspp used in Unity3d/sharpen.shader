/*
*Hi, I'm Lin Dong,
*this shader's algorithm is from ppsspp
*this is a shader about sharpen
*maybe something wrong, welcome to contect me
*if you want to get more detail please enter my blog http://blog.csdn.net/wolf96
*/
Shader "Custom/sharpen" {
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
				float4 c = tex2D(_MainTex, i.uv_MainTex);
				c -= tex2D(_MainTex, i.uv_MainTex + _Size)*7.0*_Inten;
				c += tex2D(_MainTex, i.uv_MainTex - _Size)*7.0*_Inten;
				//采样点之间的颜色差越大(边缘，色差大等处)，sharp越明显
				return c;
			}
			ENDCG
		}//

		}
	}
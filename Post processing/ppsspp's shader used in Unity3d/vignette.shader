/*
*Hi, I'm Lin Dong,
*this shader's algorithm is from ppsspp
*this is a shader about vignette
*maybe something wrong, welcome to contect me
*if you want to get more detail please enter my blog http://blog.csdn.net/wolf96
*/
Shader "Custom/vignette" {
		Properties{
		_MainTex("Main", 2D) = "white" {}
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

				float vignette = 1.1 - 0.6 * (dot(i.uv_MainTex - 0.5, i.uv_MainTex - 0.5) * 2.0);
				float3 rgb = tex2D(_MainTex, i.uv_MainTex).rgb;
				return float4(vignette * rgb, 1);

			}
			ENDCG
		}//

		}
	}
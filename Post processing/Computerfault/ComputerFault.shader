/*
*Hi, I'm Lin Dong,
*this shader is about when the computer is fault , the screen's effect rendering shader in unity3d
*if you want to get more detail please enter my blog http://blog.csdn.net/wolf96
*/
Shader "Custom/ComputerFault" {
	Properties{
	_MainTex("MainTex", 2D) = "white" {}
	_Step("Step", range(10, 100)) = 50
		_Speed("Speed", range(1, 10)) = 10
		_Black("Black", range(0, 1)) = 0
}
	SubShader{
		pass{
		Tags{ "LightMode" = "ForwardBase" }
		Cull off
			CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#pragma target 3.0
#include "UnityCG.cginc"
			int _Step;
		int _Speed;
		int _Black;
		sampler2D _MainTex;
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
#define PIE 3.1415926535
		float4 frag(v2f i) :COLOR
		{
			/*
			*this part is compute the black noise
			*/
			float2 uv_steps = float2(_Step, _Step - _Step * i.uv_MainTex.y* _SinTime.x);
			float2 newUV = (floor(i.uv_MainTex * uv_steps) / uv_steps);
			float k = newUV.x*_Step + newUV.y*_Step;
			k = floor(k);
			k = k - floor(k / 2) * 2;

			/*
			*this part is compute the uv's warp
			*/
			float2 finUV = i.uv_MainTex + float2(sin(i.uv_MainTex.y*PIE / 2)* sin(_Time.z*_Speed * 2) / 10, 0);
			finUV *= 0.9;

			/*
			*this part is compute color shift
			*/
			float4 tex1 = tex2D(_MainTex, finUV);
			float4 tex2 = tex2D(_MainTex, finUV + float2(sin(_Time.z * _Speed) / 180, 0));

			if (_Black == 1)
				return  float4(tex1.r, tex2.g, tex1.b, 1)*k;
			else
				return  float4(tex1.r, tex2.g, tex1.b, 1);

		}
		ENDCG
	}//

	}
}

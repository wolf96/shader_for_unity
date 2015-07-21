/*
*Hi, I'm Lin Dong,
*this shader is about Fisheye distortion in unity3d
*if you want to get more detail please enter my blog http://blog.csdn.net/wolf96
*/
Shader "Custom/fasheye" {
	Properties{
	_MainTex("MainTex", 2D) = "white" {}
		_Intensity_x("Intensity x", range(0, 3)) = 0.12
			_Intensity_y("Intensity y", range(0, 3)) =0.12
			_P_x("offset x", range(-1, 1)) = 0
			_P_y("offset y", range(-1, 1)) = 0
			_scale("scale", range(0, 3)) = 1.07
}
	SubShader{
		pass{
		Tags{ "LightMode" = "ForwardBase" }
		Cull off
			CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#pragma target 4.0 
#include "UnityCG.cginc"
		float 	_Intensity_x;
		float 	_Intensity_y;
		float _P_x;
		float _P_y;
		float _scale;
		sampler2D _MainTex;
		fixed4 _MainTex_ST;
		struct v2f {
			fixed4 pos : SV_POSITION;
			fixed2 uv_MainTex : TEXCOORD0;

		};

		v2f vert(appdata_full v) {
			v2f o;
			o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
			o.uv_MainTex = TRANSFORM_TEX(v.texcoord, _MainTex);
			return o;
		}

float2 fisheye(float2 uv)
{
float2	n_uv = (uv - 0.5) * 2.0;

	float2 r_uv;
	r_uv.x = (1 - n_uv.y * n_uv.y) * _Intensity_y * (n_uv.x);
	r_uv.y = (1 - n_uv.x * n_uv.x) * _Intensity_x * (n_uv.y);
	return(uv* _scale - r_uv);
}
		fixed4 frag(v2f i) :COLOR
		{

			return tex2D(_MainTex, fisheye(i.uv_MainTex));
		}
		ENDCG
	}//

	}
}

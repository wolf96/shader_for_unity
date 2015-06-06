/*
*Hi, I'm Lin Dong,
*this shader is about denoise technique in Square Enix's paper
*maybe something wrong, welcome to contect me
*if you want to get more detail please enter my blog http://blog.csdn.net/wolf96
*/
Shader "Custom/Conventional geometry-aware ﬁltering" {
	Properties{
	_MainTex("Base (RGB)", 2D) = "white" {}
	_Color("color", Color) = (1, 1, 1, 1)
		_inten("intensity", range(4, 1024)) = 512
		//		Gaussian
		_A("A", Range(0.001, 5)) = 1//amplitude
		_Sigma_x("SigmaX", Range(0.001, 5)) = 1// x spreads of the blob
		_Sigma_y("SigmaY", Range(0.001, 5)) = 1// y spreads of the blob
		_X0("X0", Range(-3, 3)) = 0
		_Y0("Y0", Range(-3, 3)) = 0
		//W
		_Sigma_z("SigmaZ", Range(0.001, 5)) = 1
		_Sigma_n("SigmaN", Range(0.001, 5)) = 1
}
	SubShader{
		pass{
		Tags{ "RenderType" = "Opaque" }
		CGPROGRAM
#pragma vertex vert
#pragma fragment frag

#include "UnityCG.cginc"
#include "MyFunc.cginc"
			sampler2D _CameraNormalsTexture;
		sampler2D _CameraDepthNormalsTexture;
		float4 _CameraDepthNormalsTexture_ST;

		sampler2D _CameraDepthTexture;
		float4 _CameraDepthTexture_ST;
		float4 _Color;


		float _inten;
		float _A;
		float _Sigma_x;
		float _Sigma_y;
		float _X0;
		float _Y0;
		float _Sigma_z;
		float _Sigma_n;

		uniform sampler2D _MainTex;
		float4 _MainTex_ST;

		struct v2f {
			float4 pos : SV_POSITION;
			float2 uv_MainTex : TEXCOORD0;
			float2 uv_CN : TEXCOORD1;
			float4 screen : TEXCOORD4;
		};
		v2f vert(appdata_full v) {
			v2f o;
			o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
			o.uv_CN = TRANSFORM_TEX(v.texcoord, _CameraDepthNormalsTexture);
			o.screen = ComputeScreenPos(o.pos);
			COMPUTE_EYEDEPTH(o.screen.z);
			o.uv_MainTex = TRANSFORM_TEX(v.texcoord, _MainTex);
			return o;
		}
		inline	float Gaussian(float x, float y)
		{
			return _A * exp(-(((pow((x - _X0), 2)) / (2 * _Sigma_x *_Sigma_x)) +
				((pow((y - _Y0), 2)) / (2 * _Sigma_y *_Sigma_y))));

		}
		inline float  GetDepth(float2 depth_uv)
		{
			float d = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, depth_uv)*0.8;
			return d;

		}
		inline float4  GetNormal(float2 depth_uv)
		{
			return tex2D(_CameraNormalsTexture, depth_uv);

		}
		float4 frag(v2f i) :COLOR
		{

			float2 i_ = i.uv_MainTex;

			float2 j1 = i.uv_MainTex + fixed2(1, -1) / _inten;
			float2 j2 = i.uv_MainTex + fixed2(1, 1) / _inten;

			float wz = Gaussian(GetDepth(i_) - GetDepth(i_), _Sigma_z);
			float wn = Gaussian(GetNormal(i_) - GetNormal(i_), _Sigma_z);

			float w = wz * wn;


			float wz1 = Gaussian(GetDepth(i_) - GetDepth(j1), _Sigma_z);
			float wn1 = Gaussian(GetNormal(i_) - GetNormal(j1), _Sigma_z);

			float w1 = wz1 * wn1;


			float wz2 = Gaussian(GetDepth(i_) - GetDepth(j2), _Sigma_z);
			float wn2 = Gaussian(GetNormal(i_) - GetNormal(j2), _Sigma_z);

			float w2 = wz2 * wn2;

			float4 c = tex2D(_MainTex, i_);
			float4 c1 = tex2D(_MainTex, j1);
			float4 c2 = tex2D(_MainTex, j2);

			float lum = Luminance(c);
			float lum1 = Luminance(c1);
			float lum2 = Luminance(c2);


			if (abs(lum - lum2)>0.1&&abs(lum - lum1)>0.1&& (abs(w - w2)  < 0.2))
				return c2;
			return c;

		}
		ENDCG
	}
	}
}

/*
*Hi, I'm Lin Dong,
*this shader is about terrain rendering
*if you want to get more detail please enter my blog http://blog.csdn.net/wolf96
*my email: wolf_crixus@sina.cn 
*/
Shader "Custom/terrain" {
	Properties{
	_MainTex("Base (RGB)", 2D) = "white" {}
	_NormalTex("Normal (RGB)", 2D) = "white" {}
	_LowTex("Low Tex", 2D) = "white" {}
	_LowNormalTex("Low Normal Tex", 2D) = "white" {}

	_OtherLowTex("Other Low Tex", 2D) = "white" {}
	_OtherLowNormalTex("Other Low Normal Tex", 2D) = "white" {}

	_UpTex("Up Tex", 2D) = "white" {}
	_UpNormalTex("Up Normal Tex", 2D) = "white" {}

	_OtherUpTex("Other Up Tex", 2D) = "white" {}
	_OtherUpNormalTex("Other Up Normal Tex", 2D) = "white" {}

	_NoiseTex("Noise Tex", 2D) = "white" {}

	_UpDownWeight("Up Down Weight", Range(-1, 1)) = 0.3
		_NoiseOtherWeight("Noise Other Weight", Range(-1, 1)) = 0.3
		//		_DamagePos("DamagePos", Vector) = (1, 1, 1, 1)

		_IsSnow("is Snow ", Range(0, 1)) = 1//0-no,1-yes
		_SnowNormalTex("Snow Normal Tex", 2D) = "white" {}
	_SnowDir("Snow Dir", Vector) = (0, 1, 0, 0)
		_SnowColor("Snow Color", Color) = (0.8, 0.9, 1, 1)
		_SnowInten("Snow Intensity", Range(-1, 1)) = 0.3

}
	SubShader{
		pass{//平行光的的pass渲染
		Tags{ "LightMode" = "ForwardBase" }
		Cull Back
			CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#include "UnityCG.cginc"
#pragma target 5.0


			sampler2D _NoiseTex;
		sampler2D _LowTex;
		sampler2D _LowNormalTex;
		sampler2D _UpTex;
		sampler2D _UpNormalTex;

		sampler2D _OtherLowTex;
		sampler2D _OtherLowNormalTex;
		sampler2D _OtherUpTex;
		sampler2D _OtherUpNormalTex;
		float	_UpDownWeight;
		float _NoiseOtherWeight;


		sampler2D _SnowNormalTex;
		float3 _SnowDir;
		float4	_SnowColor;
		float	_SnowInten;
		int _IsSnow;


		uniform sampler2D _MainTex;
		uniform sampler2D _NormalTex;

		float4 _NoiseTex_ST;
		float4 _LowTex_ST;
		float4 _UpTex_ST;
		float4 _MainTex_ST;
		float4 _OtherLowTex_ST;
		float4 _OtherUpTex_ST;
		float4 _SnowNormalTex_ST;

		struct v2f {
			float4 pos : SV_POSITION;
			float2 uv_MainTex : TEXCOORD0;
			float3 lightDir : TEXCOORD1;
			float3 viewDir : TEXCOORD2;
			float3 normal : TEXCOORD3;
			float2 uv_LowTex : TEXCOORD4;
			float2 uv_UpTex : TEXCOORD5;
			float2 uv_NoiseTex : TEXCOORD6;
			float2 uv_OtherLowTex : TEXCOORD7;
			float2 uv_OtherUpTex : TEXCOORD8;
			float2 uv_SnowNormalTex : TEXCOORD9;
			float4 pos_w : TEXCOORD10;
		};

		v2f vert(appdata_full v) {
			v2f o;
			o.pos = mul(UNITY_MATRIX_MVP, v.vertex);//切换到世界坐标
			o.normal = v.normal;
			o.lightDir = ObjSpaceLightDir(v.vertex);
			o.viewDir = ObjSpaceViewDir(v.vertex);
			o.uv_MainTex = TRANSFORM_TEX(v.texcoord, _MainTex);
			o.uv_LowTex = TRANSFORM_TEX(v.texcoord, _LowTex);
			o.uv_UpTex = TRANSFORM_TEX(v.texcoord, _UpTex);
			o.uv_OtherLowTex = TRANSFORM_TEX(v.texcoord, _OtherLowTex);
			o.uv_OtherUpTex = TRANSFORM_TEX(v.texcoord, _OtherUpTex);
			o.uv_NoiseTex = TRANSFORM_TEX(v.texcoord, _NoiseTex);
			o.uv_SnowNormalTex = TRANSFORM_TEX(v.texcoord, _SnowNormalTex);
			o.pos_w = v.vertex;


			return o;
		}
#define PIE 3.1415926535	


		float4 frag(v2f i) :COLOR
		{
			float3 lightDir = normalize(i.lightDir);
			float3 viewDir = normalize(i.viewDir);
			float3 N = normalize(i.normal);
			//	N = normalize((N + UnpackNormal(tex2D(_DamageNormalTex, i.uv_DamageNormalTex))) / 2);
			float4 up = tex2D(_UpTex, i.uv_UpTex);
			float4 low = tex2D(_LowTex, i.uv_LowTex);

			float3 n_up = UnpackNormal(tex2D(_UpNormalTex, i.uv_UpTex));
			float3 n_low = UnpackNormal(tex2D(_LowNormalTex, i.uv_LowTex));


			float4 up_o = tex2D(_OtherUpTex, i.uv_OtherUpTex);
			float4 low_o = tex2D(_OtherLowTex, i.uv_OtherLowTex);

			float3 n_up_o = UnpackNormal(tex2D(_OtherUpNormalTex, i.uv_OtherUpTex));
			float3 n_low_o = UnpackNormal(tex2D(_OtherLowNormalTex, i.uv_OtherLowTex));

			float noise = tex2D(_NoiseTex, i.uv_NoiseTex).x;

			up = lerp(up, up_o, noise + _NoiseOtherWeight);
			low = lerp(low, low_o, noise + _NoiseOtherWeight);

			n_up = lerp(n_up, n_up_o, noise + _NoiseOtherWeight);
			n_low = lerp(n_low, n_low_o, noise + _NoiseOtherWeight);


			float4 c = 0;

			c = lerp(low, up*1.3, i.pos_w.y*0.1 + _UpDownWeight);

			float3 n_fin = lerp(n_low, n_up, i.pos_w.y*0.1 + _UpDownWeight);
			n_fin = normalize(n_fin);

			N = normalize((N + n_fin) / 2);


			if (_IsSnow > 0)
			{
				_SnowDir = normalize(_SnowDir);

				if (dot(N, _SnowDir) > _SnowInten) {
					c = _SnowColor;
					N = normalize((normalize(i.normal) + normalize(UnpackNormal(tex2D(_SnowNormalTex, i.uv_SnowNormalTex)))) / 2);
				}
			}

			float diffuse = dot(lightDir, N);
			return  c*diffuse*1.2;
		}
		ENDCG
	}
	}
}


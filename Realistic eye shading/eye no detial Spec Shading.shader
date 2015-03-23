/*
*Hi, I'm Lin Dong,
*this shader is about realistic eye rendering without Sclera's detial specular in unity3d
*if you feel the Sclera's Specular unnatural, please look this one
*if you want to get more detail please enter my blog http://blog.csdn.net/wolf96
*/
Shader "Custom/eye no detial Spec Shading" {
	Properties{
	//cornea角膜
	//Iris虹膜
	//sclera巩膜
	_Lum("Luminance", Range(0, 10)) = 4
	_MainTex("Base (RGB)", 2D) = "white" {}
	_IrisColor("cornea Color", Color) = (1, 1, 1, 1)
		_SCCornea("Specular Color", Color) = (1, 1, 1, 1)
		_SpecularTex("SpecularTex (RGB)", 2D) = "white" {}
	_NormalIrisTex("NormalIrisTex (RGB)", 2D) = "white" {}
	_MaskTex("MaskTex (RGB)", 2D) = "white" {}
	_NormalIrisDetialTex("Iris Detial Tex (RGB)", 2D) = "white" {}
	_GLCornea("gloss", Range(0, 2)) = 0.5
		_GLIris("Iris Gloss", Range(0, 2)) = 0.5
		_SPIris("Iris Specular Power", Range(1, 100)) = 20

		_ReflAmount("ReflAmount", Range(0, 2)) = 1
		_Cubemap("CubeMap", CUBE) = ""{}
}
	SubShader{
		pass{
		Tags{ "LightMode" = "ForwardBase" }
		Cull Back
			CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#include "UnityCG.cginc"
		float _SPIris;
		float _Lum;
		float  _ReflAmount;
		samplerCUBE _Cubemap;
		float4 _LightColor0;
		float4 _SCCornea;
		float4 _IrisColor;
		float _GLCornea;
		float _GLIris;
		sampler2D _MaskTex;
		sampler2D _MainTex;
		sampler2D _SpecularTex;
		sampler2D _NormalIrisTex;
		sampler2D _NormalIrisDetialTex;
		float4 _MainTex_ST;
		float4 _MaskTex_ST;
		struct v2f {
			float4 pos : SV_POSITION;
			float2 uv_MainTex : TEXCOORD0;
			float3 lightDir : TEXCOORD1;
			float3 viewDir : TEXCOORD2;
			float3 normal : TEXCOORD3;
			float2 uv_MaskTex : TEXCOORD4;
		};

		v2f vert(appdata_full v) {
			v2f o;
			o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
			o.normal = v.normal;
			o.lightDir = ObjSpaceLightDir(v.vertex);
			o.viewDir = ObjSpaceViewDir(v.vertex);
			o.uv_MainTex = TRANSFORM_TEX(v.texcoord, _MainTex);
			o.uv_MaskTex = TRANSFORM_TEX(v.texcoord, _MaskTex);
			return o;
		}
#define PIE 3.1415926535	


		float4 frag(v2f i) :COLOR
		{
			float3 viewDir = normalize(i.viewDir);
			float3 lightDir = normalize(i.lightDir);
			float3 H = normalize(lightDir + viewDir);
			float3 N = normalize(i.normal);
			float3 c = tex2D(_MainTex, i.uv_MainTex);
			/*
			*this part is about Iris's diffuse Color,just Color
			*/
			if (tex2D(_MaskTex, i.uv_MaskTex).a > 0)
				c = lerp(c, c*_IrisColor, tex2D(_MaskTex, i.uv_MainTex).a + 0.2);

			/*
			*this part is compute Cornea's PBR specular
			*/
			float _SP;

			_SP = lerp(pow(8192, lerp(0, 0.5, _GLCornea - 0.4)),pow(8192, _GLCornea), tex2D(_MaskTex, i.uv_MainTex).a +0.005);


			float d = (_SP + 2) / (8 * PIE) * pow(dot(N, H), _SP);
			float f = _SCCornea + (1 - _SCCornea)*pow(2, -10 * dot(H, lightDir));
			float k = min(1, _GLCornea + 0.545);
			float v = 1 / (k* dot(viewDir, H)*dot(viewDir, H) + (1 - k));

			float SpecIns = d*f*v;

			SpecIns = lerp(0, SpecIns, clamp(tex2D(_MaskTex, i.uv_MainTex).a - 0.3,0, 1));

			/*
			*this part is compute Iris and Sclera's PBR specular
			*/
			float3 n2;

				n2 = UnpackNormal(tex2D(_NormalIrisTex, i.uv_MainTex));


			if (tex2D(_MaskTex, i.uv_MaskTex).a > 0.005)
				_SP = pow(8192, _GLIris);
	

			d = (_SP + 2) / (8 * PIE) * pow(dot(n2, H), _SP);
			f = _SCCornea + (1 - _SCCornea)*pow(2, -10 * dot(H, lightDir));
			k = min(1, _GLIris + 0.545);
			v = 1 / (k* dot(viewDir, H)*dot(viewDir, H) + (1 - k));

			float3 refDir = reflect(-viewDir, N);
			float3 ref = texCUBElod(_Cubemap, float4(refDir, 0.5 - _GLCornea*0.5)).rgb;


			float3 diff;
			float roughSpecIns = d*f*v;
			diff = dot(lightDir, UnpackNormal(tex2D(_NormalIrisDetialTex, i.uv_MainTex)));

			float3 roughSpec = roughSpecIns*tex2D(_SpecularTex, i.uv_MainTex);



			return float4(c *(diff)* _Lum + roughSpec * _SPIris + SpecIns + Luminance(ref)* _ReflAmount, 1) * _LightColor0;

		}
		ENDCG
	}
	}
}

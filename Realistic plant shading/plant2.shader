/*
*Hi, I'm Lin Dong,
*this shader is about plants real time rendering in unity3d
*if you want to get more detail please enter my blog http://blog.csdn.net/wolf96
*/
Shader "Custom/plant2" {
	Properties{
	_MainTex("Base (RGB)", 2D) = "white" {}
	_Color(" Color", Color) = (1, 1, 1, 1)
		_NormalTex("Normal Tex", 2D) = "white" {}
	_SpecTex("Specular Tex", 2D) = "white" {}
	_TransTex("Transport Tex", 2D) = "white" {}
	_TL("Transport Level", Range(-0.5, 0.5)) = 0
		_Lum("Lum", Range(0, 6)) = 1
		_SC("Specular Color", Color) = (1, 1, 1, 1)
		_SCP("Specular Power", Range(0, 4)) = 1
		_GL("gloss", Range(0, 2)) = 0.5
		_RimPower("RimPower", Range(0.1, 0.8)) = 0.5
		_RimColor("Rim Color", Color) = (1, 1, 1, 1)
		_RimTex("Rim (RGB)", 2D) = "white" {}

	_moveDirect("move Direct", Vector) = (0, 0, 0, 0)
}
	SubShader{
		pass{
		Tags{ "LightMode" = "ForwardBase" 		"Queue" = "AlphaTest" "IgnoreProjector" = "True" "RenderType" = "TransparentCutout" }
		Cull Back
			ZWrite on
			Blend SrcAlpha OneMinusSrcAlpha
			CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#include "UnityCG.cginc"
			float _TL;
		float _SCP;
		float _Lum;
		float4 _LightColor0;
		float4 _SC;
		float4 _Color;
		float _GL;
		uniform sampler2D _MainTex;
		uniform sampler2D _NormalTex;
		uniform sampler2D _SpecTex;

		float _RimPower;
		float4 _RimColor;
		uniform sampler2D _RimTex;
		uniform sampler2D _TransTex;
		float4 _MainTex_ST;

		float4 _moveDirect;
		struct v2f {
			float4 pos : SV_POSITION;
			float2 uv_MainTex : TEXCOORD0;
			float3 lightDir : TEXCOORD1;
			float3 viewDir : TEXCOORD2;
			float3 normal : TEXCOORD3;

		};

		v2f vert(appdata_full v) {
			v2f o;
			o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
			o.uv_MainTex = TRANSFORM_TEX(v.texcoord, _MainTex);
			o.normal = v.normal;
			o.lightDir = ObjSpaceLightDir(v.vertex);
			o.viewDir = ObjSpaceViewDir(v.vertex);

			return o;
		}
#define PIE 3.1415926535	


		float4 frag(v2f i) :COLOR
		{
			float4 c = tex2D(_MainTex, i.uv_MainTex);




			if (c.a < 0.5)
				discard;
			float3 viewDir = normalize(i.viewDir);
			float3 lightDir = normalize(i.lightDir);
			float3 H = normalize(lightDir + viewDir);
			float3 N = normalize(i.normal);

			float3 n1 = UnpackNormal(tex2D(_NormalTex, i.uv_MainTex));
			float3 n2 = N;

			N = (n1 + N) / 2;
			N = normalize(N);
			/*
			*this part is compute Physically-Based Rendering
			*the method is in the ppt about "ops2"
			*/

			float _SP = pow(8192, _GL);
			float d = (_SP + 2) / (8 * PIE) * pow(dot(N, H), _SP);
			float f = _SC + (1 - _SC)*pow(2, -10 * dot(H, lightDir));
			float k = min(1, _GL + 0.545);
			float v = 1 / (k* dot(viewDir, H)*dot(viewDir, H) + (1 - k));

			float all = d*f*v;
			all = saturate(all);


			float3 SpecC = tex2D(_SpecTex, i.uv_MainTex);
			float3 TransC = tex2D(_TransTex, i.uv_MainTex);
			float3 diff = dot(lightDir, N);

			float3 rim = (1 - dot(viewDir, N))*_RimPower * _RimColor *tex2D(_RimTex, i.uv_MainTex);


			diff = (1 - all)*diff;
			diff = saturate(diff);
			float3 cc = (c.rgb *(diff + 0.2)*_Color*_Lum + (all + 0.1)*(saturate(Luminance(SpecC)) + 0.1)*_SC*_SCP);
			return float4(cc * 2 + rim, c.a * (1 - Luminance(TransC) + _TL));
		}
		ENDCG
	}
	}
}


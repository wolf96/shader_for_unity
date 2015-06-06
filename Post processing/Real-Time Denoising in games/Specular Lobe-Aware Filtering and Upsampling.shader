/*
*Hi, I'm Lin Dong,
*this shader is about denoise technique in Square Enix's paper
*maybe something wrong, welcome to contect me
*if you want to get more detail please enter my blog http://blog.csdn.net/wolf96
*/

Shader "Custom/Specular Lobe-Aware Filtering and Upsampling" {
	Properties{
	_MainTex("Base (RGB)", 2D) = "white" {}
	_Color("color", Color) = (1, 1, 1, 1)
		_inten("intensity", range(4, 1024)) = 512

		_Tau("Tau", Range(0.001, 5)) = 1
		_Beta("Beta", Range(-5, 5)) = 1

		_SC("Specular Color", Color) = (1, 1, 1, 1)
		_GL("gloss", Range(0, 2)) = 0.5
}
	SubShader{
		pass{
		CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#include "UnityCG.cginc"
#include "MyFunc.cginc"
		sampler2D _CameraNormalsTexture;
		sampler2D _CameraDepthNormalsTexture;
		fixed4 _CameraDepthNormalsTexture_ST;

		sampler2D _CameraDepthTexture;
		fixed4 _CameraDepthTexture_ST;
		fixed4 _Color;
		float4x4 _ViewProjectInverse;
		fixed _inten;
		fixed _Tau;
		fixed _Beta;
		float4 _SC;
		float _GL;


		uniform sampler2D _MainTex;
		fixed4 _MainTex_ST;
#define PIE 3.1415926535	
#define	E 2.718281828459
		struct v2f {
			fixed4 pos : SV_POSITION;
			fixed2 uv_MainTex : TEXCOORD0;
			fixed2 uv_CN : TEXCOORD1;
			float3 lightDir : TEXCOORD2;
			float3 viewDir : TEXCOORD3;
			fixed4 screen : TEXCOORD4;
		};
		v2f vert(appdata_full v) {
			v2f o;
			o.lightDir = ObjSpaceLightDir(v.vertex);
			o.viewDir = WorldSpaceViewDir(v.vertex);
			fixed3 worldUp = fixed3(0, 1, 0);
			o.viewDir = o.viewDir - worldUp * dot(o.viewDir, worldUp);

			o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
			o.uv_CN = TRANSFORM_TEX(v.texcoord, _CameraDepthNormalsTexture);
			o.screen = ComputeScreenPos(o.pos);
			COMPUTE_EYEDEPTH(o.screen.z);
			o.uv_MainTex = TRANSFORM_TEX(v.texcoord, _MainTex);

			return o;
		}


		fixed Ci(float ai, fixed Y, fixed x, fixed uv_now, fixed uv_tar)
		{
			fixed ci = 0;

			++x;
			for (int i = 0 * x; i < 10 * x; i++)
			{
				x = i;
				ci += ai;
			}
			return ci;
		}
		fixed Pi(float ai, fixed Y, fixed x, fixed uv_now, fixed uv_tar)
		{
			return  Ci(ai, Y, 1, uv_now, uv_tar);
			fixed pi = 0;

			++x;
			fixed ci = Ci(ai, Y, x, uv_now, uv_tar);
			fixed ci_i = 0;
			for (int i = 0 * x; i < 10 * x; i++)
			{
				x = i;
				ci_i = Ci(ai, Y, x * 2, uv_now, uv_tar);
				pi += ci_i*ci_i;
			}
			pi = ci / (sqrt(pi) + 1);
			return pi;
		}
		fixed Qij(float ai, fixed Y, fixed uv_now_i, fixed uv_tar_i, fixed uv_now_j, fixed uv_tar_j)
		{
			return  Pi(ai, Y, 1, uv_now_i, uv_tar_i)* Pi(ai, Y, 1, uv_now_j, uv_tar_j);
			fixed Qi = 0;
			fixed Qj = 0;
			fixed Qall = 0;
			for (int i = 1; i < 10; i++)
			{
				Qi += Pi(ai, Y, i, uv_now_i, uv_tar_i);
				Qj += Pi(ai, Y, i, uv_now_j, uv_tar_j);
				Qall += Qi* Qj;
			}
			return Qall;
		}
		fixed  Delta_2(fixed x_a)
		{
			fixed del = 0;
			for (int i = -40; i < 40; i += 2)
			{
				del += pow(E, i*x_a);
			}
			del *= 2;
			del /= (2 * PIE);

			return del;

		}
		inline float4  GetNormal(float2 uv)
		{
			return tex2D(_CameraNormalsTexture, uv);

		}
		inline float  GetDepth(float2 depth_uv)
		{
			float d = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, depth_uv)*0.8;
			return d;

		}
		float4 SamplePositionMap(float2 uvCoord) {
			float depth = GetDepth(uvCoord);
			float4 H = float4((uvCoord.x) * 2 - 1, (uvCoord.y) * 2 - 1, depth, 1.0);
			float4 D = mul(_ViewProjectInverse, H);
			return D / D.w;
		}
		fixed4 frag(v2f i) :COLOR
		{
			float3 viewDir = _WorldSpaceCameraPos - SamplePositionMap(i.uv_MainTex).xyz;

			float3 lightDir = normalize(i.lightDir);
			float3 H = normalize(lightDir + viewDir);
			float3 N = normalize(GetNormal(i.uv_MainTex));
			float _SP = pow(8192, _GL);
			float d = (_SP + 2) / (8 * PIE) * pow(dot(N, H), _SP);
			float f = _SC + (1 - _SC)*pow(2, -10 * dot(H, lightDir));
			float k = min(1, _GL + 0.545);
			float v = 1 / (k* dot(viewDir, H)*dot(viewDir, H) + (1 - k));
			float all = d*f*v;

			float ai = v * max(dot(N, lightDir), 0);

			fixed2 j2 = i.uv_MainTex + fixed2(1, 1) / _inten;
			fixed2 j3 = i.uv_MainTex + fixed2(1, -1) / _inten;
			fixed2 j4 = i.uv_MainTex + fixed2(-1, 1) / _inten;
			fixed2 j5 = i.uv_MainTex + fixed2(-1, -1) / _inten;


			viewDir = _WorldSpaceCameraPos - SamplePositionMap(j2).xyz;

			H = normalize(lightDir + viewDir);
			N = normalize(GetNormal(j2));
			d = (_SP + 2) / (8 * PIE) * pow(dot(N, H), _SP);
			f = _SC + (1 - _SC)*pow(2, -10 * dot(H, lightDir));
			v = 1 / (k* dot(viewDir, H)*dot(viewDir, H) + (1 - k));

			float ai2 = v * max(dot(N, lightDir), 0);




			viewDir = _WorldSpaceCameraPos - SamplePositionMap(j3).xyz;

			H = normalize(lightDir + viewDir);
			N = normalize(GetNormal(j3));
			d = (_SP + 2) / (8 * PIE) * pow(dot(N, H), _SP);
			f = _SC + (1 - _SC)*pow(2, -10 * dot(H, lightDir));
			v = 1 / (k* dot(viewDir, H)*dot(viewDir, H) + (1 - k));

			float ai3 = v * max(dot(N, lightDir), 0);




			viewDir = _WorldSpaceCameraPos - SamplePositionMap(j4).xyz;

			H = normalize(lightDir + viewDir);
			N = normalize(GetNormal(j4));
			d = (_SP + 2) / (8 * PIE) * pow(dot(N, H), _SP);
			f = _SC + (1 - _SC)*pow(2, -10 * dot(H, lightDir));
			v = 1 / (k* dot(viewDir, H)*dot(viewDir, H) + (1 - k));

			float ai4 = v * max(dot(N, lightDir), 0);





			viewDir = _WorldSpaceCameraPos - SamplePositionMap(j5).xyz;

			H = normalize(lightDir + viewDir);
			N = normalize(GetNormal(j5));
			d = (_SP + 2) / (8 * PIE) * pow(dot(N, H), _SP);
			f = _SC + (1 - _SC)*pow(2, -10 * dot(H, lightDir));
			v = 1 / (k* dot(viewDir, H)*dot(viewDir, H) + (1 - k));

			float ai5 = v * max(dot(N, lightDir), 0);



			float4 c = tex2D(_MainTex, i.uv_MainTex);
			float4 c2 = tex2D(_MainTex, j2);
			float4 c3 = tex2D(_MainTex, j3);
			float4 c4 = tex2D(_MainTex, j4);
			float4 c5 = tex2D(_MainTex, j5);


			float lum = Luminance(c);
			float lum2 = Luminance(c2);
			float lum3 = Luminance(c3);
			float lum4 = Luminance(c4);
			float lum5 = Luminance(c5);

			float Lr = 0;

			Lr = (lum)*ai* Delta_2(-1 / _inten) * 2;
			Lr += (lum)*ai;

			float		I = Lr;
			Lr = (lum2)*ai* Delta_2(-1 / _inten) * 2;
			Lr += (lum2)*ai;


			float I3 = 0;
			I3 = (lum3)*ai* Delta_2(-1 / _inten) * 2;
			I3 += (lum3)*ai;



			float I4 = 0;
			I4 = (lum4)*ai* Delta_2(-1 / _inten) * 2;
			I4 += (lum4)*ai;

			float I5 = 0;
			I5 = (lum5)*ai* Delta_2(-1 / _inten) * 2;
			I5 += (lum5)*ai;

			fixed w = pow(Qij(ai, I, i.uv_MainTex.x, i.uv_MainTex.x, i.uv_MainTex.y, i.uv_MainTex.y), _Beta);
			fixed w2 = pow(Qij(ai2, I, i.uv_MainTex.x, j2.x, i.uv_MainTex.y, j2.y), _Beta);
			//	fixed w3 = pow(Qij(ai3, I, i.uv_MainTex.x, j3.x, i.uv_MainTex.y, j3.y), _Beta);

			//	fixed w4 = pow(Qij(ai4, I, i.uv_MainTex.x, j4.x, i.uv_MainTex.y, j4.y), _Beta);
			//	fixed w5 = pow(Qij(ai5, I, i.uv_MainTex.x, j5.x, i.uv_MainTex.y, j5.y), _Beta);


			if (GetDepth(i.uv_MainTex) > 0.74)
			{
				if (abs(lum - lum2) > 0.05&& abs(lum - lum3) > 0.05&& abs(lum - lum4) > 0.04  && abs(lum - lum5) > 0.04)// && (abs(w - w2)< 0.5))
					return c2;
				return c;

			}


			if (abs(lum - lum2) > 0.06&& abs(lum - lum3) > 0.06&& abs(lum - lum4) > 0.06  && abs(lum - lum5) > 0.06 && (abs(w - w2)< 0.5))
				return c2;
			return c;

			if ((I - Lr > 0.1 &&I - I3 > 0.1&&I - I4 > 0.1&&I - I5 > 0.1) || (I5 - I > 0.1&&I4 - I > 0.1&&I3 - I > 0.1&& Lr - I > 0.1) && (abs(w - w2) * 100 < 0.5))
				return c2;// (c2 + c3 + c4 + c5)*0.25;
			else
				return c;

		}
		ENDCG
	}
	}
}

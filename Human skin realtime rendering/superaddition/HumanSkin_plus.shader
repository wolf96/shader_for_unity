/*
*Hi, I'm Lin Dong,
*this shader is about human skin's real time rendering's superaddition in unity3d
*add the Oren–Nayar reflectance model and Subsurface Scattering
*delete rim light and the fake BRDF
*if you want to get more detail please enter my blog http://blog.csdn.net/wolf96
*/
Shader "Custom/HumanSkin_plus" {
	Properties{
	_MainTex("Base (RGB)", 2D) = "white" {}
	_SpecularTex("Specular (RGB)", 2D) = "white" {}
	_SpecularPower("Specular Power", Range(0.04, 1)) = 1

		_AlbedoTex("Albedo (RGB)", 2D) = "white" {}
	_AlbedoPower("Albedo Power", Range(0, 20)) = 1
		_AlbedoDistance("Albedo Distance", Range(0.1, 2)) = 1

		_BlurTex1("Blur Tex 1 (RGB)", 2D) = "white" {}
	_BlurTex2("Blur Tex 2 (RGB)", 2D) = "white" {}
	_BlurTex3("Blur Tex 3 (RGB)", 2D) = "white" {}
	_BlurTex4("Blur Tex 4 (RGB)", 2D) = "white" {}
	_BlurTex5("Blur Tex 5 (RGB)", 2D) = "white" {}
	_BlurTex6("Blur Tex 6 (RGB)", 2D) = "white" {}

	_DetailTex("Detail (RGB)", 2D) = "white" {}
	_BumpBias("Normal Map Blur", Range(0, 5)) = 2.0
		_Maintint("Main Color", Color) = (1, 1, 1, 1)
	_SC("Specular Color", Color) = (1, 1, 1, 1)
		_GL("gloss", Range(0, 1)) = 0.05
		_nMips("nMipsF", Range(0, 5)) = 0.5


	_LumPow("Lum Power", Range(0, 30)) = 1
		_LumPow_D("Lum Power D", Range(0, 200)) = 1
		_G("G", Range(-1, 1)) = 0.5
		_Sigma_A("Sigma_A", Vector) = (1, 1, 1, 1)
		_Sigma_S("Sigma_S", Vector) = (1, 1, 1, 1)
		_DaoSanJiao("Nabla", Color) = (1, 1, 1, 1)
		_Eta("Eta", Range(0.5, 2)) = 1.3

}
	SubShader{
		pass{
		Tags{ "LightMode" = "ForwardBase" }
		ZWrite on
			Cull Back

			CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#pragma target 5.0
#include "UnityCG.cginc"
#include "MyFunc.cginc"
			float _Albedo;
		float _LumPow;
		float _LumPow_D;
		float _Rough;
		float _G;
		float3 _Sigma_A;
		float3 _Sigma_S;
		float _Eta;
		float4 _SC;
		float _GL;
		float3 _DaoSanJiao;

			float4x4  _World2Light;
		float4 _LightColor0;
		float _SpecularPower;
		float4 _Maintint;
		float _nMips;

		uniform sampler2D _AlbedoTex;
		float _AlbedoPower;
		float _AlbedoDistance;

		uniform sampler2D _BlurTex1;
		uniform sampler2D _BlurTex2;
		uniform sampler2D _BlurTex3;
		uniform sampler2D _BlurTex4;
		uniform sampler2D _BlurTex5;
		uniform sampler2D _BlurTex6;

		uniform sampler2D _SpecularTex;
		uniform sampler2D _MainTex;
		uniform sampler2D _DetailTex;
		float4 _MainTex_ST;
		float4 _DetailTex_ST;
		float _BumpBias;
		struct v2f {
			float4 pos : SV_POSITION;
			float2 uv_MainTex : TEXCOORD0;
			float3 lightDir : TEXCOORD1;
			float3 viewDir : TEXCOORD2;
			float3 normal : TEXCOORD3;
			float4 worldPos : TEXCOORD4;
			float2 uv_DetailTex : TEXCOORD5;
		};
		struct appdata {
			float4 vertex : POSITION;
			float4 tangent : TANGENT;
			float3 normal : NORMAL;
			float2 texcoord : TEXCOORD0;
			fixed4 color : COLOR;
		};
		v2f vert(appdata_full v) {
			v2f o;
			o.uv_MainTex = TRANSFORM_TEX(v.texcoord, _MainTex);
			o.uv_DetailTex = TRANSFORM_TEX(v.texcoord, _DetailTex);

			o.worldPos = mul(_Object2World, v.vertex);
			o.pos = mul(UNITY_MATRIX_MVP, v.vertex);

		
			o.normal = v.normal;
			o.lightDir = ObjSpaceLightDir(v.vertex);
			o.viewDir = ObjSpaceViewDir(v.vertex);

			return o;
		}

#define PIE 3.1415926535	
#define	E 2.718281828459
		float phase(float cos_t)
		{
			return	1 / (4 * PIE)*(1 - _G*_G) / pow(1 + _G*_G - 2 * _G *cos_t, 1.5);

		}
		float Lri(float3 w_P, float phi_x, float p_L_Dist, float D)
		{
			float _Sigma_t = _Sigma_A + _Sigma_S;
			float L = 1 / (4 * PIE) * phi_x + 3 / (4 * PIE) * dot(w_P, -D*_DaoSanJiao * phi_x);

			float Lri = L * pow(E, -_Sigma_t* p_L_Dist);
			return Lri;
		}
		half OrenNayarDiffuse(half3 light, half3 view, half3 norm, half roughness)
		{
			half VdotN = dot(view, norm);
			half LdotN = dot(light, norm);
			half cos_theta_i = LdotN;
			half theta_r = acos(VdotN);
			half theta_i = acos(cos_theta_i);
			half cos_phi_diff = dot(normalize(view - norm * VdotN),
				normalize(light - norm * LdotN));
			half alpha = max(theta_i, theta_r);
			half beta = min(theta_i, theta_r);
			half sigma2 = roughness * roughness;
			half A = 1.0 - 0.5 * sigma2 / (sigma2 + 0.33);
			half B = 0.45 * sigma2 / (sigma2 + 0.09);
			return saturate(cos_theta_i) *(A + (B * saturate(cos_phi_diff) * sin(alpha) * tan(beta)));
		}
		float4 frag(v2f i) :COLOR
		{ 

		float dis = distance(_WorldSpaceLightPos0, i.worldPos);
			float3 c = tex2D(_MainTex, i.uv_MainTex) * 128;
			c += tex2D(_BlurTex1, i.uv_MainTex) * 64;
			c += tex2D(_BlurTex2, i.uv_MainTex) * 32;
			c += tex2D(_BlurTex3, i.uv_MainTex) * 16;
			c += tex2D(_BlurTex4, i.uv_MainTex) * 8;
			c += tex2D(_BlurTex5, i.uv_MainTex) * 4;
			c += tex2D(_BlurTex6, i.uv_MainTex) * 2;
			c /= 256;

			float3 viewDir = normalize(i.viewDir);
			float3 lightDir = normalize(i.lightDir);
			float3 H = normalize(lightDir + viewDir);
			/*
			*this part is about blend normal, normal map and detail map
			*and the nomal blur also in here
			*this blend method is from internet
			*/
			float3 n1 = tex2Dbias(_DetailTex, float4(i.uv_MainTex, 0.0, _BumpBias)) * 2 - 1;//normalBlur
			float3 n2 = normalize(i.normal) * 2 - 1;

			float a = 1 / (1 + n1.z);
			float b = -n1.x*n1.y*a;

			float3 b1 = float3(1 - n1.x*n1.x*a, b, -n1.x);
			float3 b2 = float3(b, 1 - n1.y*n1.y*a, -n1.y);
			float3 b3 = n1;

			if (n1.z < -0.9999999)
			{
				b1 = float3(0, -1, 0);
				b2 = float3(-1, 0, 0);
			}

			float3 r = n2.x*b1 + n2.y*b2 + n2.z*b3;

			n2 = r*0.5 + 0.5;

			n2 *= 3;
			n2 += n1;
			n2 /= 4;
			n2 = normalize(n2);

			float specBase = max(0, dot(n2, H));
			float spec = pow(specBase, 10) *(_GL + 0.2);
			spec = lerp(0, 1.2, spec);
			float3 spec3 = spec * (tex2D(_SpecularTex, i.uv_MainTex) - 0.1);


			/*
			*this part is compute the Subsurface Scattering
			*/

			float3 _Sigma_S_P = _Sigma_S *(1 - _G);
			float3	_Sigma_T_P = _Sigma_S_P + _Sigma_A;
			float3 _Sigma_TR = sqrt(3 * _Sigma_A * _Sigma_T_P);
			float3 _Sigma_t = _Sigma_A + _Sigma_S;
			float D = 1 / (3 * _Sigma_T_P);
			float p_L_Dist = 1;
			if (_WorldSpaceLightPos0.w != 0)
			{
				p_L_Dist = distance(_WorldSpaceLightPos0, i.worldPos);
			}
			float v_C_Dist = distance(_WorldSpaceCameraPos, i.worldPos)*0.04;
			v_C_Dist = v_C_Dist > 1.5 ? 1.5 : v_C_Dist;
			float3 phi_x = _LumPow_D / (4 * PIE*D)*pow(E, _Sigma_TR*p_L_Dist) / p_L_Dist;


			float Q = 0;
			float3 Q1 = 0;
			float3 w_P = 0;
			for (int i = 0; i < 30; i++)
			{
				w_P = normalize(float3(n2.x + rand(fixed2(i*0.05, i*0.05)), n2.y + rand(fixed2(-i*0.05, i*0.05)), n2.z + rand(fixed2(i*0.05, -i*0.05))));

				Q += phase(dot(-lightDir, w_P))*Lri(w_P, phi_x, p_L_Dist, D);
				Q *= _Sigma_S;
				Q1 += Q*w_P;

			}

			float3 diff = _Sigma_A - Q - 3 * D *dot(_DaoSanJiao, Q1);

			float fdr = -1.440 / (_Eta*_Eta) + 0.710 / _Eta + 0.668 + 0.0636*_Eta;

			float A = (1 + fdr) / (1 - fdr);


			phi_x = _LumPow_D / (4 * PIE*D)*(pow(E, -_Sigma_TR * p_L_Dist) / p_L_Dist - pow(E, -_Sigma_TR * v_C_Dist) / v_C_Dist);

			float phi_x_S = 2 * A * D * dot(n2, _DaoSanJiao) * phi_x;

			float3 ref = -D * (dot(n2, _DaoSanJiao*phi_x_S)) / (diff*_LumPow_D);

			/*
			*this part is compute Physically-Based Rendering
			*the method is in the ppt about "ops2"
			*/
			float _SP = pow(8192, _GL);
			float d = (_SP + 2) / (8 * PIE) * pow(dot(n2, H), _SP);
			float f = _SC + (1 - _SC)*pow(2, -10 * dot(H, lightDir));
			float k = min(1, _GL + 0.545);
			float v = 1 / (k* dot(viewDir, H)*dot(viewDir, H) + (1 - k));

			float all = d*f*v;

		
			all = saturate(all);
			diff = (1 - all)*diff;
			diff = saturate(diff);


			spec3 *= Luminance(diff);
			spec3 = saturate(spec3);
			spec3 *= _SpecularPower;
			/*
			*this part is used Oren–Nayar reflectance model
			*/
			float _Albedo = saturate( OrenNayarDiffuse(lightDir, viewDir, n2, _Rough));

			float4 c2 = float4(c *((diff *_Albedo + ref)*_Maintint + (all*_SC) / 2) + spec3 + (all*_SC) / 2 , 1);

			if (_WorldSpaceLightPos0.w != 0)
			{
				
				dis *= _AlbedoDistance;
				if (1 - dis > 0)
					c2 += tex2D(_AlbedoTex, float2(0.5, 1 - dis))*_AlbedoPower;
			}
		
			return c2;
		}
		ENDCG
	}
	}
}

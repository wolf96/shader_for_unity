/*
*Hi, I'm Lin Dong,
*this shader is about snow and sand rendering
*if you want to get more detail please enter my blog http://blog.csdn.net/wolf96
*my email: wolf_crixus@sina.cn
*/
Shader "Custom/snow" {
		Properties{
		_MainTex("Base (RGB)", 2D) = "white" {}
		_NormalTex("Normal (RGB)", 2D) = "white" {}


			_SnowNormalTex("Snow Normal Tex", 2D) = "white" {}
			_SnowColor("Snow Color", Color) = (0.8, 0.9, 1, 1)
			_SnowInten("Snow Intensity", Range(-1, 1)) = 0.3

			_SpecColor("Specular Color", Color) = (0.9, 0.95, 1, 1)


			_NoiseTex("Noise Tex", 2D) = "white" {}
			_NoiseWeight("Noise Weight", Range(0, 1)) = 0.3
				_SpecwInten("Specular Intensity", Range(0, 2)) = 0.3

				_Roughness("Roughness", Range(0, 1)) = 0.3
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


			sampler2D _SnowNormalTex;
			float4	_SnowColor;
			float	_SnowInten;
			float _NoiseWeight;
			float _SpecwInten;
			float _Roughness;

			float4 _SpecColor;

			uniform sampler2D _MainTex;
			uniform sampler2D _NormalTex;
			uniform sampler2D _NoiseTex;


			float4 _MainTex_ST;
			float4 _NoiseTex_ST;
			float4 _SnowNormalTex_ST;

			struct v2f {
				float4 pos : SV_POSITION;
				float2 uv_MainTex : TEXCOORD0;
				float3 lightDir : TEXCOORD1;
				float3 viewDir : TEXCOORD2;
				float3 normal : TEXCOORD3;
				float2 uv_NoiseTex : TEXCOORD4;
				float2 uv_SnowNormalTex : TEXCOORD5;
				float4 pos_w : TEXCOORD6;
			};

			v2f vert(appdata_full v) {
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.normal = v.normal;
				o.lightDir = ObjSpaceLightDir(v.vertex);
				o.viewDir = ObjSpaceViewDir(v.vertex);
				o.uv_MainTex = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.uv_NoiseTex = TRANSFORM_TEX(v.texcoord, _NoiseTex);
				o.uv_SnowNormalTex = TRANSFORM_TEX(v.texcoord, _SnowNormalTex);
				o.pos_w = v.vertex;


				return o;
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
				float3 lightDir = normalize(i.lightDir);
				float3 viewDir = normalize(i.viewDir);
				float3 N = normalize(i.normal);
				float3 H = normalize(lightDir + viewDir);


				float4 c = _SnowColor;
			//	N = N + normalize(UnpackNormal(tex2D(_SnowNormalTex, i.uv_SnowNormalTex))) ;
				N = (N + UnpackNormal(tex2D(_SnowNormalTex, i.uv_SnowNormalTex)))/2;
				N = normalize(N);
		//		float diffuse = saturate(dot(lightDir, N))+0.05;//1
		//		float diffuse = OrenNayarDiffuse(lightDir, viewDir, N, _Roughness);//2

				
				float3 N2 = N;
				N2.y *= 0.3;
				float diffuse = saturate(4 * dot(N2, lightDir));;//3

				 diffuse = saturate(diffuse) + 0.05;

				float4 spec = _SpecColor *saturate((dot(N, viewDir)));
				float noise = tex2D(_NoiseTex, i.uv_NoiseTex);


				if (noise > _NoiseWeight)
					noise *= 2;

				return  c*diffuse + spec*noise*_SpecwInten;
			}
			ENDCG
		}
		}
	}


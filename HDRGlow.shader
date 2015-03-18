Shader "Custom/HDR3" {
		Properties{
		_MainTex("Noise", 2D) = "white" {}
		_Exp("exposure", range(0, 4)) = 0.3//256
			_BM("bright Max", range(0, 4)) = 0.3//256
			_inten("intensity", range(4, 1024)) = 256//256
			_Lum("Luminance", range(0, 4)) = 1//256
	}
		SubShader{
			pass{
			Tags{ "LightMode" = "ForwardBase" }
			Cull off
				CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#include "UnityCG.cginc"

				float4 _LightColor0;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _Exp;
			float _BM;
			float _inten;
			float _Lum;
			struct v2f {
				float4 pos : SV_POSITION;
				float2 uv_MainTex : TEXCOORD0;
				float3 lightDir : TEXCOORD1;
				float3 viewDir : TEXCOORD2;
				float3 normal : TEXCOORD3;

			};
		//	const static float3x3 M = float3x3(
		//		0.2209, 0.3390, 0.4184,
		//		0.1138, 0.6780, 0.7319,
		//		0.0102, 0.1130, 0.2969);

			// Inverse M matrix, for decoding 
		//	const static float3x3 InverseM = float3x3(
		//		6.0013,    - 2.700,    - 1.7995,
		//		-1.332,    3.1029,    - 5.7720,
		//		.3007,    - 1.088,    5.6268);   

				float4 LogLuvEncode(float3 vRGB)
			{
					float3x3 M = float3x3(
						0.2209, 0.3390, 0.4184,
						0.1138, 0.6780, 0.7319,
						0.0102, 0.1130, 0.2969);
						float4 vResult;
					float3 Xp_Y_XYZp = mul(vRGB, M);
					Xp_Y_XYZp = max(Xp_Y_XYZp, float3(1e-6, 1e-6, 1e-6));
					vResult.xy = Xp_Y_XYZp.xy / Xp_Y_XYZp.z;
					float Le = 2 * log2(Xp_Y_XYZp.y) + 127;
					vResult.w = frac(Le);
					vResult.z = (Le - (floor(vResult.w*255.0f)) / 255.0f) / 255.0f;
					return vResult;
				}

			float3 LogLuvDecode(float4 vLogLuv)
			{
				float3x3 InverseM = float3x3(
					6.0013, -2.700, -1.7995,
					-1.332, 3.1029, -5.7720,
					.3007, -1.088, 5.6268);
				float Le = vLogLuv.z * 255 + vLogLuv.w;
				float3 Xp_Y_XYZp;
				Xp_Y_XYZp.y = exp2((Le - 127) / 2);
				Xp_Y_XYZp.z = Xp_Y_XYZp.y / vLogLuv.y;
				Xp_Y_XYZp.x = vLogLuv.x * Xp_Y_XYZp.z;
				float3 vRGB = mul(Xp_Y_XYZp, InverseM);
				return max(vRGB, 0);
			}
			v2f vert(appdata_full v) {
				v2f o;
				o.pos =  mul(UNITY_MATRIX_MVP, v.vertex);
				o.normal = v.normal;
				o.lightDir = ObjSpaceLightDir(v.vertex);
				o.viewDir = ObjSpaceViewDir(v.vertex);
				o.uv_MainTex = TRANSFORM_TEX(v.texcoord, _MainTex);
				return o;
			}

			float4 frag(v2f i) :COLOR
			{

				float3 mc00 = tex2D(_MainTex, i.uv_MainTex - fixed2(3, 3) / _inten).rgb;
				float3 mc10 = tex2D(_MainTex, i.uv_MainTex - fixed2(2, 3) / _inten).rgb;
				float3 mc20 = tex2D(_MainTex, i.uv_MainTex - fixed2(1, 3) / _inten).rgb;
				float3 mc30 = tex2D(_MainTex, i.uv_MainTex - fixed2(0, 3) / _inten).rgb;
				float3 mc40 = tex2D(_MainTex, i.uv_MainTex - fixed2(-1, 3) / _inten).rgb;
				float3 mc50 = tex2D(_MainTex, i.uv_MainTex - fixed2(-2, 3) / _inten).rgb;
				float3 mc60 = tex2D(_MainTex, i.uv_MainTex - fixed2(-3, 3) / _inten).rgb;

				float3 mc01 = tex2D(_MainTex, i.uv_MainTex - fixed2(3, 2) / _inten).rgb;
				float3 mc11 = tex2D(_MainTex, i.uv_MainTex - fixed2(2, 2) / _inten).rgb;
				float3 mc21 = tex2D(_MainTex, i.uv_MainTex - fixed2(1, 2) / _inten).rgb;
				float3 mc31 = tex2D(_MainTex, i.uv_MainTex - fixed2(0, 2) / _inten).rgb;
				float3 mc41 = tex2D(_MainTex, i.uv_MainTex - fixed2(-1, 2) / _inten).rgb;
				float3 mc51 = tex2D(_MainTex, i.uv_MainTex - fixed2(-2, 2) / _inten).rgb;
				float3 mc61 = tex2D(_MainTex, i.uv_MainTex - fixed2(-3, 2) / _inten).rgb;

				float3 mc02 = tex2D(_MainTex, i.uv_MainTex - fixed2(3, 1) / _inten).rgb;
				float3 mc12 = tex2D(_MainTex, i.uv_MainTex - fixed2(2, 1) / _inten).rgb;
				float3 mc22 = tex2D(_MainTex, i.uv_MainTex - fixed2(1, 1) / _inten).rgb;
				float3 mc32 = tex2D(_MainTex, i.uv_MainTex - fixed2(0, 1) / _inten).rgb;
				float3 mc42 = tex2D(_MainTex, i.uv_MainTex - fixed2(-1, 1) / _inten).rgb;
				float3 mc52 = tex2D(_MainTex, i.uv_MainTex - fixed2(-2, 1) / _inten).rgb;
				float3 mc62 = tex2D(_MainTex, i.uv_MainTex - fixed2(-3, 1) / _inten).rgb;

				float3 mc03 = tex2D(_MainTex, i.uv_MainTex - fixed2(3, 0) / _inten).rgb;
				float3 mc13 = tex2D(_MainTex, i.uv_MainTex - fixed2(2, 0) / _inten).rgb;
				float3 mc23 = tex2D(_MainTex, i.uv_MainTex - fixed2(1, 0) / _inten).rgb;
				float3 mc33mc = tex2D(_MainTex, i.uv_MainTex).rgb;
				float3 mc43 = tex2D(_MainTex, i.uv_MainTex - fixed2(-1, 0) / _inten).rgb;
				float3 mc53 = tex2D(_MainTex, i.uv_MainTex - fixed2(-2, 0) / _inten).rgb;
				float3 mc63 = tex2D(_MainTex, i.uv_MainTex - fixed2(-3, 0) / _inten).rgb;

				float3 mc04 = tex2D(_MainTex, i.uv_MainTex - fixed2(3, -1) / _inten).rgb;
				float3 mc14 = tex2D(_MainTex, i.uv_MainTex - fixed2(2, -1) / _inten).rgb;
				float3 mc24 = tex2D(_MainTex, i.uv_MainTex - fixed2(1, -1) / _inten).rgb;
				float3 mc34 = tex2D(_MainTex, i.uv_MainTex - fixed2(0, -1) / _inten).rgb;
				float3 mc44 = tex2D(_MainTex, i.uv_MainTex - fixed2(-1, -1) / _inten).rgb;
				float3 mc54 = tex2D(_MainTex, i.uv_MainTex - fixed2(-2, -1) / _inten).rgb;
				float3 mc64 = tex2D(_MainTex, i.uv_MainTex - fixed2(-3, -1) / _inten).rgb;

				float3 mc05 = tex2D(_MainTex, i.uv_MainTex - fixed2(3, -2) / _inten).rgb;
				float3 mc15 = tex2D(_MainTex, i.uv_MainTex - fixed2(2, -2) / _inten).rgb;
				float3 mc25 = tex2D(_MainTex, i.uv_MainTex - fixed2(1, -2) / _inten).rgb;
				float3 mc35 = tex2D(_MainTex, i.uv_MainTex - fixed2(0, -2) / _inten).rgb;
				float3 mc45 = tex2D(_MainTex, i.uv_MainTex - fixed2(-1, -2) / _inten).rgb;
				float3 mc55 = tex2D(_MainTex, i.uv_MainTex - fixed2(-2, -2) / _inten).rgb;
				float3 mc65 = tex2D(_MainTex, i.uv_MainTex - fixed2(-3, -2) / _inten).rgb;

				float3 mc06 = tex2D(_MainTex, i.uv_MainTex - fixed2(3, -3) / _inten).rgb;
				float3 mc16 = tex2D(_MainTex, i.uv_MainTex - fixed2(2, -3) / _inten).rgb;
				float3 mc26 = tex2D(_MainTex, i.uv_MainTex - fixed2(1, -3) / _inten).rgb;
				float3 mc36 = tex2D(_MainTex, i.uv_MainTex - fixed2(0, -3) / _inten).rgb;
				float3 mc46 = tex2D(_MainTex, i.uv_MainTex - fixed2(-1, -3) / _inten).rgb;
				float3 mc56 = tex2D(_MainTex, i.uv_MainTex - fixed2(-2, -3) / _inten).rgb;
				float3 mc66 = tex2D(_MainTex, i.uv_MainTex - fixed2(-3, -3) / _inten).rgb;
				float3 c = 0;
				// c+=(mc00+mc20+mc02+mc22);
				// c+=2*(mc10+mc01+mc21+mc12);
				// c+=4*mc11mc;
				// c/=16;
				///////////////////////////////////////////
				// c+=(mc00+mc40+mc04+mc44);//4
				// c+=2*(mc10+mc30+mc14+mc34+mc01+mc41+mc03+mc43);//16
				// c+=4*(mc20+mc24+mc02+mc42);//16
				// c+=8*(mc11+mc13+mc03+mc33);//32
				// c+=16*(mc21+mc23+mc12+mc32);//64
				// c+=32*mc22mc;//32
				// c/=164;
				c += (mc00 + mc60 + mc06 + mc66);//4
				c += 2 * (mc10 + mc50 + mc15 + mc56 + mc65 + mc01 + mc05 + mc16);//8
				c += 6 * (mc20 + mc11 + mc02 + mc40 + mc51 + mc62 + mc04 + mc15 + mc26 + mc64 + mc55 + mc46);//72
				c += 14 * (mc30 + mc03 + mc63 + mc36);//56
				c += 24 * (mc21 + mc12 + mc41 + mc52 + mc14 + mc25 + mc54 + mc45);//192
				c += 32 * (mc31 + mc13 + mc53 + mc35);//128
				c += 54 * (mc22 + mc42 + mc24 + mc44);//216
				c += 67 * (mc32 + mc23 + mc43 + mc34);//268
				c += 80 * mc33mc;//80
				c /= 1024;
				float lum = Luminance(c);


				c = mc33mc + c * (lum + 0.1) * _Lum;

				float y = dot(float4(0.3,0.59,0.11,1),c);
				float yd = _Exp * (_Exp / _BM + 1) / (_Exp + 1);
				//c2 *= c.r;
				float4 c2 = float4(c,1);
				return c2*yd;
			}
			ENDCG
		}//

		}
	}

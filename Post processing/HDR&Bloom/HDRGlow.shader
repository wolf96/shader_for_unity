Shader "Custom/HDRGlow" {
		Properties{
		_MainTex("base", 2D) = "white" {}
		_Exp("exposure", range(0, 4)) = 0.3
			_BM("bright Max", range(0, 4)) = 0.3
			_inten("intensity", range(4, 1024)) = 256//fuzzy level
			_Lum("Luminance", range(0, 4)) = 1
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
				//Bloom
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
				//HDR
				float y = dot(float4(0.3,0.59,0.11,1),c);
				float yd = _Exp * (_Exp / _BM + 1) / (_Exp + 1);
				float4 c2 = float4(c,1);
				return c2*yd;
			}
			ENDCG
		}//

		}
	}

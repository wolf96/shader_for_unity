/*
*Hi, I'm Lin Dong,
*this shader's algorithm is from ppsspp
*this is a shader about natural
*maybe something wrong, welcome to contect me
*if you want to get more detail please enter my blog http://blog.csdn.net/wolf96
*/
Shader "Custom/natural" {
		Properties{
		_MainTex("Main", 2D) = "white" {}
		_Size("Size", range(0.00005, 0.0008)) = 0.0001
		_Inten("Inten", range(0.5, 4)) = 2
	}
		SubShader{
			pass{
			Tags{ "LightMode" = "ForwardBase" }
			Cull off
				CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#include "UnityCG.cginc"
#include "MyFunc.cginc"

				float _Size;
			float _Inten;

				float4 _LightColor0;
			sampler2D _MainTex;
			float4 _MainTex_TexelSize;
			float4 _MainTex_ST;
			struct v2f {
				float4 pos : SV_POSITION;
				float2 uv_MainTex : TEXCOORD0;
				float4 vertex : TEXCOORD1;
			};

			v2f vert(appdata_full v) {
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv_MainTex = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.vertex = v.vertex;
				return o;
			}

			float4 frag(v2f i) :COLOR
			{
				float3 val00 = float3(1.2, 1.2, 1.2);
				float3x3 RGBtoYIQ = float3x3(0.299, 0.596, 0.212,
				0.587, -0.275, -0.523,
				0.114, -0.321, 0.311);

				float3x3 YIQtoRGB = float3x3(1.0, 1.0, 1.0,
					0.95568806036115671171, -0.27158179694405859326, -1.1081773266826619523,
					0.61985809445637075388, -0.64687381613840131330, 1.7050645599191817149);

				float4 c = tex2D(_MainTex, i.uv_MainTex);
				float3 c1 =mul( RGBtoYIQ,c.rgb);

				c1 = float3(pow(c1.x, val00.x), c1.yz*val00.yz);
				//转换到YIQ色彩空间再加强GB颜色1.2倍
				return float4(mul(YIQtoRGB,c1), 1);
			}
			ENDCG
		}//

		}
	}
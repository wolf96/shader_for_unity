/*
*Hi, I'm Lin Dong,
*this shader is about Depth Of Field in unity3d
*if you want to get more detail please enter my blog http://blog.csdn.net/wolf96
*/

Shader "Custom/DOF_P_P" {
	Properties{
	_MainTex("MainTex", 2D) = "white" {}
	_Radius("Radius", range(2, 8)) = 3
		_Pixel("_Pixel", range(0.0001, 0.01)) = 0.002
		_Depth("Depth", range(0, 1)) = 0
		_DepthClip("DepthClip", range(-1, 1)) = 0
		_Foward_back("Foward_back", range(0, 1)) = 1
}
	SubShader{
		pass{
		Tags{ "LightMode" = "ForwardBase" }
		Cull off
			CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#pragma target 4.0 
#include "UnityCG.cginc"

			sampler2D _CameraDepthTexture;
		fixed4 _CameraDepthTexture_ST;

		int _Foward_back;
		fixed _Depth;
		fixed _DepthClip;
		int _Radius;
		float _Pixel;
		sampler2D _MainTex;
		fixed4 _MainTex_ST;
#define PI 3.1415926535
		struct v2f {
			fixed4 pos : SV_POSITION;
			fixed2 uv_MainTex : TEXCOORD0;

		};

		v2f vert(appdata_full v) {
			v2f o;
			o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
			o.uv_MainTex = TRANSFORM_TEX(v.texcoord, _MainTex);
			return o;
		}
		inline fixed  GetDepth(fixed2 depth_uv)
		{
			fixed d = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, depth_uv)*0.8;
			return d;

		}
		fixed4 frag(v2f i) :COLOR
		{


			fixed2 uv = i.uv_MainTex;
			fixed depth = GetDepth(uv);
			fixed sigma = _Radius / 3.0;
			fixed sigma2 = 2.0 * sigma * sigma;
			fixed sigmap = sigma2 * PI;

			fixed4 cc = tex2D(_MainTex, i.uv_MainTex);

	//		fixed weight = 0;

			int times = 6;
			for (int n = 0, i = -times; i <= times; ++i)
			{
				int i2 = i * i;
				for (int j = -times; j <= times; ++j, ++n)
				{
		//			weight = exp(-(i2 + j * j) / sigma2) / sigmap;
					cc += (tex2D(_MainTex, uv + fixed2(i*0.5, j)*_Pixel));//* weight);
				}

			}
			cc /= 160;

			
			depth *=(saturate( ((depth-0.2)*2))+0.01);
				fixed4 c = tex2D(_MainTex,uv);

					if (_Foward_back == 0)
			{
						cc = lerp(c, cc,lerp(0,1, (depth + _DepthClip) * _Depth-0.2)*1.4);

			}
			else
			{
				cc = lerp(cc, c, lerp(0,1,(depth + _DepthClip) * _Depth-0.3)*1.4);

			}

			return cc;
		}
		ENDCG
	}//

	}
}

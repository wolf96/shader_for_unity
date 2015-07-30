/*
*Hi, I'm Lin Dong,
*this shader's algorithm is from ppsspp
*this is a shader about spline based resizers (spline36)
*maybe something wrong, welcome to contect me
*if you want to get more detail please enter my blog http://blog.csdn.net/wolf96
*/
Shader "Custom/upscale_spline36" {
		Properties{
		_MainTex("Main", 2D) = "white" {}
		_TexelDelta_X("Texel Size X", range(0, 1)) = 0.0002//0.1->0.04->0.01->0.005 缩小//0.0002->0.000000  放大
			_TexelDelta_Y("Texel Size Y", range(0, 100)) = 0.0002//0.1->0.04->0.01->0.005 缩小//0.0002->0.000000  放大
		HALF_PIXEL("HALF PIXEL", Vector) = (0.5, 0.5, 0.5, 0.5)
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
				float2 HALF_PIXEL;

			float _TexelDelta_X;
			float _TexelDelta_Y;
		//	float2 u_pixelDelta;
				float _Size;
	
				float4 _LightColor0;
			sampler2D _MainTex;
			float4 _MainTex_TexelSize;
			float4 _MainTex_ST;
			struct v2f {
				float4 pos : SV_POSITION;
				float2 uv_MainTex : TEXCOORD0;

			};

			v2f vert(appdata_full v) {
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv_MainTex = TRANSFORM_TEX(v.texcoord, _MainTex);
				return o;
			}
			float spline36_0_1(float x) {
				return ((13.0 / 11.0 * x - 453.0 / 209.0) * x - 3.0 / 209.0) * x + 1.0;
			}

			float spline36_1_2(float x) {
				return ((-6.0 / 11.0 * x + 612.0 / 209.0) * x - 1038.0 / 209.0) * x + 540.0 / 209.0;
			}

			float spline36_2_3(float x) {
				return ((1.0 / 11.0 * x - 159.0 / 209.0) * x + 434.0 / 209.0) * x - 384.0 / 209.0;
			}

			float4 rgb(int inputX, int inputY) {
			//	u_texelDelta = 1 / _Size;
				return tex2D(_MainTex, (float2(inputX, inputY) + HALF_PIXEL) *float2(_TexelDelta_X, _TexelDelta_Y));
			}

			float4 interpolateHorizontally(float2 inputPos, int2 inputPosFloor, int dy) {//水平插入/插值
				float sumOfWeights = 0.0;
				float4 sumOfWeightedPixel = 0;

				float x;
				float weight;

				x = inputPos.x - float(inputPosFloor.x - 2);
				weight = spline36_2_3(x);
				sumOfWeights += weight;
				sumOfWeightedPixel += weight * rgb(inputPosFloor.x - 2, inputPosFloor.y + dy);

				--x;
				weight = spline36_1_2(x);
				sumOfWeights += weight;
				sumOfWeightedPixel += weight * rgb(inputPosFloor.x - 1, inputPosFloor.y + dy);

				--x;
				weight = spline36_0_1(x);
				sumOfWeights += weight;
				sumOfWeightedPixel += weight * rgb(inputPosFloor.x + 0, inputPosFloor.y + dy);

				x = 1.0 - x;
				weight = spline36_0_1(x);
				sumOfWeights += weight;
				sumOfWeightedPixel += weight * rgb(inputPosFloor.x + 1, inputPosFloor.y + dy);

				++x;
				weight = spline36_1_2(x);
				sumOfWeights += weight;
				sumOfWeightedPixel += weight * rgb(inputPosFloor.x + 2, inputPosFloor.y + dy);

				++x;
				weight = spline36_2_3(x);
				sumOfWeights += weight;
				sumOfWeightedPixel += weight * rgb(inputPosFloor.x + 3, inputPosFloor.y + dy);

				return sumOfWeightedPixel / sumOfWeights;
			}

			float4 process(float2 outputPos) {
				float2 inputPos = outputPos / float2(_TexelDelta_X, _TexelDelta_Y);
				int2 inputPosFloor = int2(inputPos);

				// Vertical interporation
				float sumOfWeights = 0.0;
				float4 sumOfWeightedPixel = 0;

				float weight;
				float y;

				y = inputPos.y - float(inputPosFloor.y - 2);
				weight = spline36_2_3(y);
				sumOfWeights += weight;
				sumOfWeightedPixel += weight * interpolateHorizontally(inputPos, inputPosFloor, -2);

				--y;
				weight = spline36_1_2(y);
				sumOfWeights += weight;
				sumOfWeightedPixel += weight * interpolateHorizontally(inputPos, inputPosFloor, -1);

				--y;
				weight = spline36_0_1(y);
				sumOfWeights += weight;
				sumOfWeightedPixel += weight * interpolateHorizontally(inputPos, inputPosFloor, +0);

				y = 1.0 - y;
				weight = spline36_0_1(y);
				sumOfWeights += weight;
				sumOfWeightedPixel += weight * interpolateHorizontally(inputPos, inputPosFloor, +1);

				++y;
				weight = spline36_1_2(y);
				sumOfWeights += weight;
				sumOfWeightedPixel += weight * interpolateHorizontally(inputPos, inputPosFloor, +2);

				++y;
				weight = spline36_2_3(y);
				sumOfWeights += weight;
				sumOfWeightedPixel += weight * interpolateHorizontally(inputPos, inputPosFloor, +3);

				return float4((sumOfWeightedPixel / sumOfWeights).xyz, 1.0);
			}
			float4 frag(v2f i) :COLOR
			{
				return process(i.uv_MainTex); //v_position
			}
			ENDCG
		}//

		}
	}
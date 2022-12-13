 
/*
Reference:
Praun E, Hoppe H, Webb M, et al. Real-time hatching[C]
Proceedings of the 28th annual conference on Computer graphics and interactive techniques. ACM, 2001: 581.

L.L. Feng, Unity Shader Refined Introduction. Beijing, China: Posts & Telecom Press Co., Ltd. 2017.
*/

Shader "Luyao/Hatch_MyTAM_Pt&SpotLight"
{
    Properties
    {
        /*_MainTex ("Texture", 2D) = "white" {}*/

		// in inspector
        _Color("Color Tint", Color) = (1, 1, 1, 1)
        _TileFactor("Tile Factor", Float) = 1
		// textures
        _Hatch0("Hatch 0", 2D) = "white" {}
        _Hatch1("Hatch 1", 2D) = "white" {}
        _Hatch2("Hatch 2", 2D) = "white" {}
        _Hatch3("Hatch 3", 2D) = "white" {}
        _Hatch4("Hatch 4", 2D) = "white" {}
        _Hatch5("Hatch 5", 2D) = "white" {}
		_Hatch6("Hatch 6", 2D) = "white" {}
        _Hatch7("Hatch 7", 2D) = "white" {}
		_Hatch8("Hatch 8", 2D) = "white" {}
        _Hatch9("Hatch 9", 2D) = "white" {}
        _Hatch10("Hatch 10", 2D) = "white" {}
        _Hatch11("Hatch 11", 2D) = "white" {}
        _Hatch12("Hatch 12", 2D) = "white" {}
        _Hatch13("Hatch 13", 2D) = "white" {}
		_Hatch14("Hatch 14", 2D) = "white" {}
        _Hatch15("Hatch 15", 2D) = "white" {}
		
		// render outline
		_Outline ("Outline", Range(0, 1)) = 0.02

    }
    SubShader
    {
		// outliner pass
		Tags { "RenderType"="Opaque" "Queue"="Geometry"}
		
		Pass {
			NAME "OUTLINE"
			
			Cull Front
			
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			
			float _Outline;
			fixed4 _OutlineColor;
			
			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			}; 
			
			struct v2f {
			    float4 pos : SV_POSITION;
			};
			
			v2f vert (a2v v) {
				v2f o;
				
				float4 pos = mul(UNITY_MATRIX_MV, v.vertex); 
				float3 normal = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal);  
				normal.z = -0.5;
				pos = pos + float4(normalize(normal), 0) * _Outline;
				o.pos = mul(UNITY_MATRIX_P, pos);
				
				return o;
			}
			
			float4 frag(v2f i) : SV_Target { 
				return float4(_OutlineColor.rgb, 1);               
			}
			
			ENDCG
		}

		Pass {
			//Tags { "LightMode" = "ForwardAdd" }

			// Unity supplied blending multiple light effects (otherwise is overwrites)
			//Blend One One

			CGPROGRAM
			// Upgrade NOTE: excluded shader from DX11, OpenGL ES 2.0 because it uses unsized arrays
			//#pragma exclude_renderers d3d11 gles
			// ??? if excluded, then shader not working ???

			#pragma vertex vert
			#pragma fragment frag 

			//#pragma multi_compile_fwdadd

			#include "UnityCG.cginc"
			//#include "Lighting.cginc"
			//#include "AutoLight.cginc"  // Unity support shadow
			//#include "UnityShaderVariables.cginc"

			// ********* Variable passed in from C# script ********
			//float4 _spotLightPos;
			//float _sptIntensity;
			//fixed4 _sptColor;

			int _secLightNum;
			float4 _secLightsPos[2];  // has to know light number beforehand??
			//float4 _secLightsPos[_secLightNum];
			float _secLightsIntensity[2];
			fixed4 _secLightsColorVec[2];
			float4 _dLightDir;
			float _dLightIntensity;
			float4 _dLightColor;

			float _farDisArray[2];  // far distance of the lights
			float _nearDisArray[2];  // near distance of the lights

			float4 _cameraPos;  // camera/eye position

			fixed4 _Color;
			float _TileFactor;
			sampler2D _Hatch0;
			sampler2D _Hatch1;
			sampler2D _Hatch2;
			sampler2D _Hatch3;
			sampler2D _Hatch4;
			sampler2D _Hatch5;
			sampler2D _Hatch6;
			sampler2D _Hatch7;
			sampler2D _Hatch8;
			sampler2D _Hatch9;
			sampler2D _Hatch10;
			sampler2D _Hatch11;
			sampler2D _Hatch12;
			sampler2D _Hatch13;
			sampler2D _Hatch14;
			sampler2D _Hatch15;

			struct a2v {
				float4 vertex : POSITION;
				float4 tangent : TANGENT;
				float3 normal : NORMAL;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f {
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				//fixed3 hatchWeights0 : TEXCOORD1;
				//fixed3 hatchWeights1 : TEXCOORD2; // in total stores 6 weights

				fixed4 hatchWeights0 : TEXCOORD1;
				fixed4 hatchWeights1 : TEXCOORD2;
				fixed4 hatchWeights2 : TEXCOORD3;
				fixed4 hatchWeights3 : TEXCOORD4; // in total stores 16 weights

				float3 worldPos : TEXCOORD5;
				//SHADOW_COORDS(4)
			};


			// find the diffuse factor of a light source
			fixed DiffuseFactor(float worldLightDis, float farDistance, fixed3 worldLightDir, float3 worldNormal, float lStrength)
			{
				fixed diff = 0;

				if(worldLightDis <= farDistance)
				{
					diff = max(0, dot(worldLightDir, worldNormal)) * lStrength;
				}
				
				return diff;
			}

			// Find light strength based on light attenuation - quadraitc drop off from Professor Kelvin Sung
			float LightAttenuation(float worldLightDis, float farDistance, float nearDistance)
			{
				float strength = 0.0f;
				if(worldLightDis <= farDistance)
				{
					if(worldLightDis <= nearDistance)
					{
						strength = 1.0;  // no attenuation
					}
					else
					{
						// Reference: quadraitc drop off approach for light attenuation from Professor Kelvin Sung
						float n = worldLightDis - nearDistance;
						float d = farDistance - nearDistance;
						strength = smoothstep(0.0, 1.0, 1.0-(n*n)/(d*d));
					}
				}
				return strength;
			}


			v2f vert(a2v v) {
				v2f o;

				o.pos = UnityObjectToClipPos(v.vertex);

				o.uv = v.texcoord.xy * _TileFactor;

				// directional light
				//fixed3 worldLightDir = normalize(WorldSpaceLightDir(v.vertex)); // world space direction to light, given object space vertex position.
				//fixed3 worldNormal = UnityObjectToWorldNormal(v.normal); // world space normal direction
				//fixed diff = max(0, dot(worldLightDir, worldNormal)); // diffuse reflection number

				fixed3 worldNormal = UnityObjectToWorldNormal(v.normal); // world space normal direction
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz; // vertex's world position
				
				// ******** Unity supplied variable *********
				//fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz - o.worldPos.xyz);
				// ******** Use passed in light position *********
				fixed3 worldLightDir1 = normalize(_secLightsPos[0] - o.worldPos.xyz);
				fixed3 worldLightDir2 = normalize(_secLightsPos[1] - o.worldPos.xyz);


				float worldLightDis[2];
				worldLightDis[0] = length(_secLightsPos[0] - o.worldPos.xyz);
				worldLightDis[1] = length(_secLightsPos[1] - o.worldPos.xyz);


				// diffuse reflection number - but actually is the cos of the angle between WorldLightDir and WorldNormal
				//fixed diff = max(0, dot(worldLightDir1, worldNormal));
				//diff = max(diff, dot(worldLightDir2, worldNormal));

				// light attenuation
				float strengthArr[2];
				strengthArr[0] = 0.0f;
				strengthArr[1] = 0.0f;
				for(int k = 0; k < _secLightNum; ++k)
				{
					strengthArr[k] = LightAttenuation(worldLightDis[k], _farDisArray[k], _nearDisArray[k]);
				}

				fixed diff1 = DiffuseFactor(worldLightDis[0], _farDisArray[0], worldLightDir1, worldNormal, strengthArr[0]);
				fixed diff2 = DiffuseFactor(worldLightDis[1], _farDisArray[1], worldLightDir2, worldNormal, strengthArr[1]);
				float3 worldLightDir3 = - _dLightDir;
				float4 diffD = DiffuseFactor(0, 0, worldLightDir3, worldNormal, _dLightIntensity);
				fixed diff = diff1 + diff2 + diffD;

				// Phong illumination factor  // start adding the second light!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
				fixed3 viewDir = normalize(_cameraPos - o.worldPos.xyz);  // viewing direction
				fixed3 incidentVec1 = o.worldPos.xyz - _secLightsPos[0];
				fixed3 reflectionVec = reflect(incidentVec1, worldNormal);  // reflection vector
				fixed3 reflectionDir = normalize(reflectionVec);

				fixed spec = max(0, dot(reflectionDir, viewDir));

				//o.hatchWeights0 = fixed3(0, 0, 0);
				//o.hatchWeights1 = fixed3(0, 0, 0);

				o.hatchWeights0 = fixed4(0, 0, 0, 0);
				o.hatchWeights1 = fixed4(0, 0, 0, 0);
				o.hatchWeights2 = fixed4(0, 0, 0, 0);
				o.hatchWeights3 = fixed4(0, 0, 0, 0);

				//float hatchFactor = diff * 7.0;
				
				//if (hatchFactor > 6.0) {
				//	// Pure white, do nothing
				//}
				//else if (hatchFactor > 5.0) {
				//	o.hatchWeights0.x = hatchFactor - 5.0;
				//}
				//else if (hatchFactor > 4.0) {
				//	o.hatchWeights0.x = hatchFactor - 4.0;
				//	o.hatchWeights0.y = 1.0 - o.hatchWeights0.x;
				//}
				//else if (hatchFactor > 3.0) {
				//	o.hatchWeights0.y = hatchFactor - 3.0;
				//	o.hatchWeights0.z = 1.0 - o.hatchWeights0.y;
				//}
				//else if (hatchFactor > 2.0) {
				//	o.hatchWeights0.z = hatchFactor - 2.0;
				//	o.hatchWeights1.x = 1.0 - o.hatchWeights0.z;
				//}
				//else if (hatchFactor > 1.0) {
				//	o.hatchWeights1.x = hatchFactor - 1.0;
				//	o.hatchWeights1.y = 1.0 - o.hatchWeights1.x;
				//}
				//else {
				//	o.hatchWeights1.y = hatchFactor;
				//	o.hatchWeights1.z = 1.0 - o.hatchWeights1.y;
				//}

				// 8 textures
				float hatchFactor = diff * 17.0;
				//float hatchFactor = spec * 9.0;

				if (hatchFactor > 16.0) {
					// Only use White
				}
				else if (hatchFactor > 15.0) {  // hatchWeights0.x
					o.hatchWeights0.x = 1.0 - (hatchFactor - 15.0);
				}
				else if (hatchFactor > 14.0) {  // hatchWeights0.x & y
					o.hatchWeights0.x = hatchFactor - 14.0;
					o.hatchWeights0.y = 1.0 - o.hatchWeights0.x;
				}
				else if (hatchFactor > 13.0) {  // hatchWeights0.y & z
					o.hatchWeights0.y = hatchFactor - 13.0;
					o.hatchWeights0.z = 1.0 - o.hatchWeights0.y;
				}
				else if (hatchFactor > 12.0) {  // hatchWeights0.z & w
					o.hatchWeights0.z = hatchFactor - 12.0;
					o.hatchWeights0.w = 1.0 - o.hatchWeights0.z;
				}
				else if (hatchFactor > 11.0) { // hatchWeights0.w & hatchWeights1.x
					o.hatchWeights0.w = hatchFactor - 11.0;
					o.hatchWeights1.x = 1.0 - o.hatchWeights0.w;
				}
				else if (hatchFactor > 10.0) {  // hatchWeights1.x & y
					o.hatchWeights1.x = hatchFactor - 10.0;
					o.hatchWeights1.y = 1.0 - o.hatchWeights1.x;
				}
				else if (hatchFactor > 9.0) {  // hatchWeights1.y & z
					o.hatchWeights1.y = hatchFactor - 9.0;
					o.hatchWeights1.z = 1.0 - o.hatchWeights1.y;
				}
				else if (hatchFactor > 8.0) {  // hatchWeights1.z & w
					o.hatchWeights1.z = hatchFactor - 8.0;
					o.hatchWeights1.w = 1.0 - o.hatchWeights1.z;
				}
				else if (hatchFactor > 7.0) {  // hatchWeights1.w & hatchWeights2.x
					o.hatchWeights1.w = hatchFactor - 7.0;
					o.hatchWeights2.x = 1.0 - o.hatchWeights1.w;
				}
				else if (hatchFactor > 6.0) {  // hatchWeights2.x & y
					o.hatchWeights2.x = hatchFactor - 6.0;
					o.hatchWeights2.y = 1.0 - o.hatchWeights2.x;
				}
				else if (hatchFactor > 5.0) {  // hatchWeights2.y & z
					o.hatchWeights2.y = hatchFactor - 6.0;
					o.hatchWeights2.z = 1.0 - o.hatchWeights2.y;
				}
				else if (hatchFactor > 4.0) {  // hatchWeights2.z & w
					o.hatchWeights2.z = hatchFactor - 4.0;
					o.hatchWeights2.w = 1.0 - o.hatchWeights2.z;
				}
				else if (hatchFactor > 3.0) {  // hatchWeights2.w & hatchWeights3.x
					o.hatchWeights2.w = hatchFactor - 3.0;
					o.hatchWeights3.x = 1.0 - o.hatchWeights2.w;
				}
				else if (hatchFactor > 2.0) {  // hatchWeights3.x & y
					o.hatchWeights3.x = hatchFactor - 2.0;
					o.hatchWeights3.y = 1.0 - o.hatchWeights3.x;
				}
				else if (hatchFactor > 1.0) {  // hatchWeights3.y & z
					o.hatchWeights3.y = hatchFactor - 1.0;
					o.hatchWeights3.z = 1.0 - o.hatchWeights3.y;
				}
				else {  // hatchWeights3.z & w
					o.hatchWeights3.z = hatchFactor;
					o.hatchWeights3.w = 1.0 - o.hatchWeights3.z;
				}

				//o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

				//TRANSFER_SHADOW(o);

				return o;
			}

			fixed4 frag(v2f i) : SV_Target {
				fixed4 hatchTex0 = tex2D(_Hatch0, i.uv) * i.hatchWeights0.x;
				fixed4 hatchTex1 = tex2D(_Hatch1, i.uv) * i.hatchWeights0.y;
				fixed4 hatchTex2 = tex2D(_Hatch2, i.uv) * i.hatchWeights0.z;
				fixed4 hatchTex3 = tex2D(_Hatch3, i.uv) * i.hatchWeights0.w;
				fixed4 hatchTex4 = tex2D(_Hatch4, i.uv) * i.hatchWeights1.x;
				fixed4 hatchTex5 = tex2D(_Hatch5, i.uv) * i.hatchWeights1.y;
				fixed4 hatchTex6 = tex2D(_Hatch6, i.uv) * i.hatchWeights1.z;
				fixed4 hatchTex7 = tex2D(_Hatch7, i.uv) * i.hatchWeights1.w;

				fixed4 hatchTex8 = tex2D(_Hatch8, i.uv) * i.hatchWeights2.x;
				fixed4 hatchTex9 = tex2D(_Hatch9, i.uv) * i.hatchWeights2.y;
				fixed4 hatchTex10 = tex2D(_Hatch10, i.uv) * i.hatchWeights2.z;
				fixed4 hatchTex11 = tex2D(_Hatch11, i.uv) * i.hatchWeights2.w;
				fixed4 hatchTex12 = tex2D(_Hatch12, i.uv) * i.hatchWeights3.x;
				fixed4 hatchTex13 = tex2D(_Hatch13, i.uv) * i.hatchWeights3.y;
				fixed4 hatchTex14 = tex2D(_Hatch14, i.uv) * i.hatchWeights3.z;
				fixed4 hatchTex15 = tex2D(_Hatch15, i.uv) * i.hatchWeights3.w;

				fixed4 whiteColor = fixed4(1, 1, 1, 1) * (1 - i.hatchWeights0.x - i.hatchWeights0.y - i.hatchWeights0.z - i.hatchWeights0.w -
							i.hatchWeights1.x - i.hatchWeights1.y - i.hatchWeights1.z - i.hatchWeights1.w - 
							i.hatchWeights2.x - i.hatchWeights2.y - i.hatchWeights2.z - i.hatchWeights2.w -
							i.hatchWeights3.x - i.hatchWeights3.y - i.hatchWeights3.z - i.hatchWeights3.w); // consider white color
				//fixed4 whiteColor = fixed4(1, 0, 0, 0);
				fixed4 hatchColor = hatchTex0 + hatchTex1 + hatchTex2 + hatchTex3 + hatchTex4 + hatchTex5 + hatchTex6 + hatchTex7 +
									hatchTex8 + hatchTex9 + hatchTex10 + hatchTex11 + hatchTex12 + hatchTex13 + hatchTex14 + hatchTex15 + whiteColor;
				//fixed4 hatchColor = hatchTex0 + hatchTex1 + hatchTex2 + hatchTex3 + hatchTex4 + hatchTex5;

				// Unity support shadow
				//UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

				// *********** include light intensity (Unity supply): * _LightColor0.rgb = LightColor * LightIntensity *********
				//return fixed4(hatchColor.rgb * _LightColor0.rgb * _Color.rgb * atten, 1.0);
				// *********** use light position and light intensity passed in ***********
				//fixed4 _intensityColor = fixed4(1, 1, 1, 1) * _sptIntensity;
				//fixed4 _intensityColor = _sptColor * _sptIntensity;
				//fixed3 result = hatchColor.rgb * _Color.rgb * _sptIntensity;
				// Unity support shadow
				//return fixed4(hatchColor.rgb * _sptColor.rgb * _Color.rgb * atten * _sptIntensity, 1.0);
				
				//return fixed4(hatchColor.rgb * _sptColor.rgb * _Color.rgb * _sptIntensity, 1.0);

				//float4 _secLightsPos[2];  // has to know light number beforehand??
				//float4 _secLightsPos[_secLightNum];
				//float _secLightsIntensity[2];
				//fixed4 _secLightsColor[2];
				// !!!!!!!!!!!!!!!!!!!!!!!!!! Include normal of other lights !!!!!!!!!!!!!!!!!!!!!!!!!!!!
				// calculate multiple Lighting
				//fixed3 results[2];


				float worldLightDis[2];
				worldLightDis[0] = length(_secLightsPos[0] - i.worldPos.xyz);
				worldLightDis[1] = length(_secLightsPos[1] - i.worldPos.xyz);

				// light attenuation
				float strengthArr[2];
				strengthArr[0] = 0.0f;
				strengthArr[1] = 0.0f;
				for(int k = 0; k < _secLightNum; ++k)
				{
					strengthArr[k] = LightAttenuation(worldLightDis[k], _farDisArray[k], _nearDisArray[k]);
				}


				fixed3 results[2];
				for(int i = 0; i < _secLightNum; ++i)
				{
					results[i] = hatchColor.rgb * _secLightsColorVec[i] * _Color.rgb * _secLightsIntensity[i] * strengthArr[i];
				}
				fixed3 result;
				for(int j = 0; j < _secLightNum; ++j)
				{
					result += results[j];
				}

				fixed4 resultD = hatchColor * _dLightColor * _Color * _dLightIntensity;  // directional light

				result += resultD;
				return fixed4(result, 1.0);
			}

			ENDCG
		}
    }
	// Unity support shadow
	//FallBack "Diffuse"
}


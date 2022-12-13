/*
Reference:
Praun E, Hoppe H, Webb M, et al. Real-time hatching[C]
Proceedings of the 28th annual conference on Computer graphics and interactive techniques. ACM, 2001: 581.

L.L. Feng, Unity Shader Refined Introduction. Beijing, China: Posts & Telecom Press Co., Ltd. 2017.
*/

Shader "Luyao/MyTAM_illuminationLookUp"
{
    Properties
    {
		// in inspector
        _ObjectColor("ObjectColor Tint", Color) = (1, 1, 1, 1)  // Objet's color
		//_OutlineColor("Outline Color", Color) = (0.5, 0.5, 0.5, 0.5)  // Outline's color
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

		// test texture
		_TestTex("TestTex", 2D) = "white" {}
		
		// render outline
		_Outline ("Outline", Range(0, 1)) = 0.02

		// user control render method: 1. LookUpVal = diff+spec 2. 1. LookUpVal = diff/spec
		_HatchRenderMethod("HatchRenderMethod (1-diff+spec 0-diff/spec)", float) = 0
		_LookUpValMaxOrAdd("MaxOrAdd ForLookUpVal (1-Addition)", float) = 0  // user control under 1-diff+spec illumination model, whether to find max lookUpVal or do addition
		_HatchDiffOrSpec("HatchDiffOrSpec (1-Diff)", float) = 0  // user control render diffuse/specular hatch
		_HatchMaxDiff("HatchMaxDiff (1-WithHatch)", float) = 0  // user control render W/O hatch
		_ObjColorInLookUpVal("ObjColorInLookUpVal (1-ObjColor considered in lookUp)", float) = 0  // user control whether object color is considered into hatch lookUp (illumination)
		
		_ShowObjColor("Show/NotShow the Object Color (1-show)", float) = 0  // user control whether to show or not show object color

		_UnderlyingTexture("_UnderlyingTexture (1-Shows underlying texture on the object)", float) = 0  // user control whether object's underlying texture is shown or not
		_AmbIndex("AmbienIndex", float) = 0

		_Bg("Hatch Background Color", Color) = (1, 1, 1, 1)  // Hatch Background Color
		_Fg("Hatch forground Color", Color) = (0, 0, 0, 1)  // Hatch Background Color
    }

    SubShader
    {
		// outliner pass
		/*
		Reference:
		L.L. Feng, Unity Shader Refined Introduction. Beijing, China: Posts & Telecom Press Co., Ltd. 2017.
		*/
		Tags { "RenderType"="Opaque" "Queue"="Geometry"}
		
		Pass {
			NAME "OUTLINE"
			
			Cull Front
			
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag		

			#include "UnityCG.cginc"

			float _Outline;
			float4 _OutlineColor;
			
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
			CGPROGRAM

			// Upgrade NOTE: excluded shader from DX11, OpenGL ES 2.0 because it uses unsized arrays
			//#pragma exclude_renderers d3d11 gles

			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			#pragma enable_d3d11_debug_symbols

			// Variables passed in from C# script
			float _specIndex;

			int _secLightNum;
			float4 _secLightsPos[2];
			float _secLightsIntensity[2];
			float4 _secLightsColorVec[2];
			float4 _dLightDir;
			float _dLightIntensity;
			float4 _dLightColor;
			float _farDisArray[2];  // far distance of the lights
			float _nearDisArray[2];  // near distance of the lights

			float4 _cameraPos;  // camera/eye position

			float4 _ObjectColor;
			float _TileFactor;


			Texture2D _Hatch0;
			Texture2D _Hatch1;
			Texture2D _Hatch2;
			Texture2D _Hatch3;
			Texture2D _Hatch4;
			Texture2D _Hatch5;
			Texture2D _Hatch6;
			Texture2D _Hatch7;
			Texture2D _Hatch8;
			Texture2D _Hatch9;
			Texture2D _Hatch10;
			Texture2D _Hatch11;
			Texture2D _Hatch12;
			Texture2D _Hatch13;
			Texture2D _Hatch14;
			Texture2D _Hatch15;
			Texture2D _TestTex;
			SamplerState sampler_Hatch0;
			SamplerState sampler_Hatch1;
			SamplerState sampler_Hatch2;
			SamplerState sampler_Hatch3;
			SamplerState sampler_Hatch4;
			SamplerState sampler_Hatch5;
			SamplerState sampler_Hatch6;
			SamplerState sampler_Hatch7; 
			SamplerState sampler_Hatch8;
			SamplerState sampler_Hatch9;
			SamplerState sampler_Hatch10;
			SamplerState sampler_Hatch11;
			SamplerState sampler_Hatch12;
			SamplerState sampler_Hatch13;
			SamplerState sampler_Hatch14;
			SamplerState sampler_Hatch15;  // can only have maximum 16 samplers

			static const int kMaxHatchLevel = 16; // texture number

			float _HatchRenderMethod;
			float _LookUpValMaxOrAdd;
			float _HatchDiffOrSpec;
			float _HatchMaxDiff;
			float _ObjColorInLookUpVal;
			float _ShowObjColor;

			float _UnderlyingTexture;
			float _AmbIndex;

			float4 _Bg;
			float4 _Fg;


			struct a2v {
				float4 vertex : POSITION;
				float4 tangent : TANGENT;
				float3 normal : NORMAL;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f {
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;

				float3 worldPos : TEXCOORD1;
				
				float3 worldNormal : TEXCOORD2;  // pass normal to fragment shader
			};
			


			float ColortoFloat(float4 c)
			{
				float grayScaleVal = c.r * 0.299 + c.g * 0.587 + c.b * 0.114;
				return grayScaleVal;
			}

			// input a float, return a hatch color(texture)
			float4 HatchLookUp(float lookUpVal, float2 uv)
			{
				float hatchFactor = lookUpVal * (kMaxHatchLevel + 1);
				float w = hatchFactor - trunc(hatchFactor);
				
				float4 hatchColor = float4(1, 1, 1, 1);  // initially set to white

				if (hatchFactor > 16.0) {
					// Only use white
				}
				else if (hatchFactor > 15.0) {
					hatchColor = w * float4(1, 1, 1, 1) + (1-w) * _Hatch0.Sample(sampler_Hatch0, uv);  // w is on white
				}
				else if (hatchFactor > 14.0) {
					hatchColor = w * _Hatch0.Sample(sampler_Hatch0, uv) + (1-w) * _Hatch1.Sample(sampler_Hatch1, uv);
				}
				else if (hatchFactor > 13.0) {
					hatchColor = w * _Hatch1.Sample(sampler_Hatch1, uv) + (1-w) * _Hatch2.Sample(sampler_Hatch2, uv);
				}
				else if (hatchFactor > 12.0) {
					hatchColor = w * _Hatch2.Sample(sampler_Hatch2, uv) + (1-w) * _Hatch3.Sample(sampler_Hatch3, uv);
				}
				else if (hatchFactor > 11.0) {
					hatchColor = w * _Hatch3.Sample(sampler_Hatch3, uv) + (1-w) * _Hatch4.Sample(sampler_Hatch4, uv);
				}
				else if (hatchFactor > 10.0) {
					hatchColor = w * _Hatch4.Sample(sampler_Hatch4, uv) + (1-w) * _Hatch5.Sample(sampler_Hatch5, uv);
				}
				else if (hatchFactor > 9.0) {
					hatchColor = w * _Hatch5.Sample(sampler_Hatch5, uv) + (1-w) * _Hatch6.Sample(sampler_Hatch6, uv);
				}
				else if (hatchFactor > 8.0) {
					hatchColor = w * _Hatch6.Sample(sampler_Hatch6, uv) + (1-w) * _Hatch7.Sample(sampler_Hatch7, uv);
				}
				else if (hatchFactor > 7.0) {
					hatchColor = w * _Hatch7.Sample(sampler_Hatch7, uv) + (1-w) * _Hatch8.Sample(sampler_Hatch8, uv);
				}
				else if (hatchFactor > 6.0) {
					hatchColor = w * _Hatch8.Sample(sampler_Hatch8, uv) + (1-w) * _Hatch9.Sample(sampler_Hatch9, uv);
				}
				else if (hatchFactor > 5.0) {
					hatchColor = w * _Hatch9.Sample(sampler_Hatch9, uv) + (1-w) * _Hatch10.Sample(sampler_Hatch10, uv);
				}
				else if (hatchFactor > 4.0) {
					hatchColor = w * _Hatch10.Sample(sampler_Hatch10, uv) + (1-w) * _Hatch11.Sample(sampler_Hatch11, uv);
				}
				else if (hatchFactor > 3.0) {
					hatchColor = w * _Hatch11.Sample(sampler_Hatch11, uv) + (1-w) * _Hatch12.Sample(sampler_Hatch12, uv);
				}
				else if (hatchFactor > 2.0) {
					hatchColor = w * _Hatch12.Sample(sampler_Hatch12, uv) + (1-w) * _Hatch13.Sample(sampler_Hatch13, uv);
				}
				else if (hatchFactor > 1.0) {
					hatchColor = w * _Hatch13.Sample(sampler_Hatch13, uv) + (1-w) * _Hatch14.Sample(sampler_Hatch14, uv);
				}
				else {
					hatchColor = w * _Hatch14.Sample(sampler_Hatch14, uv) + (1-w) * _Hatch15.Sample(sampler_Hatch15, uv);
				}

				// Colored hatching: User chosen background color and forground color
				// !!!!!!!!!!!!!!!!!!!!!!!!
				return hatchColor.r * _Bg + (1 - hatchColor.r) * _Fg;
			}

			// find the diffuse factor (W/Ocolor) of a light source
			float4 DiffuseFactor(float worldLightDis, float farDistance, float3 worldLightDir, float3 worldNormal, float lStrength, float2 uv)
			{
				float4 diffColor = (0,0,0,0); // initially black when no light

				if(worldLightDis <= farDistance)
				{
					float diff = max(0, dot(worldLightDir, worldNormal)) * lStrength;
					if(_ObjColorInLookUpVal == 0)  // _ObjectColor does not affect hatch
					{
						diffColor = diff;  // float assigned to float4, rest 3 value same as first
					}
					else                           // _ObjectColor affects hatch based on illumination
					{
						//float4 cap = float4(2, 2, 2, 2); // cap can be applied to adjust the affect level of the object color
						diffColor = diff * _ObjectColor;
					}
				}
				
				float4 amb = float4(0.1, 0.1, 0.1, 0.1);
				diffColor += amb * _AmbIndex;

				return diffColor;
			}

			// find the specular factor (W/Ocolor) of a light source
			float4 SpecularFactor(float worldLightDis, float farDistance, float3 reflectionDir, float3 viewDir, float lStrength)
			{
				float4 specColor = (0,0,0,0); // initially black when no light

				if(worldLightDis <= farDistance)
				{
					float temp = max(0, dot(reflectionDir, viewDir));
					float spec = pow(temp, _specIndex);
					if(_ObjColorInLookUpVal == 0)  // _ObjectColor does not affects hatch
					{
						specColor = spec * lStrength;
					}
					else                           // _ObjectColor affects hatch based on illumination
					{
						specColor = spec * lStrength * _ObjectColor;
					}
				}

				float4 amb = float4(0.1, 0.1, 0.1, 0.1);
				specColor += amb * _AmbIndex;

				return specColor;
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

			// Render result of only diffuse or only specular
			float4 diffOrSpecRender(float4 diff1, float4 diff2, float4 diffD, float4 spec1, float4 spec2, float4 specD, float2 uv, float strengthArr[2])
			{
				float4 diff;
				float4 spec;
				if(_LookUpValMaxOrAdd == 1)
				{
					diff = diff1 + diff2 + diffD;
					spec = spec1 + spec2 + specD;
				}
				else
				{
					diff = max(diff1, diff2); 
					diff = max(diff, diffD);
					spec = max(spec1, spec2);
					spec = max(spec, specD);
				}

				float lookUpVal;

				if(_HatchDiffOrSpec == 1)  // rough material - only diffuse
				{
					if(_ObjColorInLookUpVal == 0)  // lookUpVal has no color component, only first value is valid
					{
						lookUpVal = diff.r;
						//lookUpVal = ColortoFloat(diff);
					}
					else                           // lookUpVal has color component, change float4 color into a float
					{
						lookUpVal = ColortoFloat(diff);
					}

				}
				else                       // smooth material - only spec
				{
					if(_ObjColorInLookUpVal == 0)
					{
						lookUpVal = spec.r;
					}
					else
					{
						lookUpVal = ColortoFloat(spec);
					}
				}
				
				float4 hatchColor = HatchLookUp(lookUpVal, uv);

				// additional underlying texture
				float4 hatchColorKd = (1,1,1,1);
				if(_UnderlyingTexture > 0)  // will show underlying texture
				{
					hatchColorKd = _TestTex.Sample(sampler_Hatch15, uv);  // Kd texture as is
					if(_UnderlyingTexture == 2)
					{
						// *** Attention: currently kd texture use the same hatchLookUp func ***
						// *** Which uses the same _Bg and _Fg as regular hatch. Which makes the multiplied result background & forground color two times darker***
						hatchColorKd = HatchLookUp(hatchColorKd, uv);  // underlaying texture mapped as hatch
					}
				}


				float4 result;
				for(int i = 0; i < _secLightNum; ++i)
				{
					if(_HatchMaxDiff == 0)  // render without hatch
					{
						if(_HatchDiffOrSpec == 1) // render with diffuse illumination
						{
							hatchColor = diff;
						}
						else  // render with specular illumination
						{
							hatchColor = spec;
						}
					}

					result += hatchColor * hatchColorKd * _secLightsColorVec[i] * _secLightsIntensity[i] * strengthArr[i];
				}

				result += hatchColor * hatchColorKd  * _dLightColor * _dLightIntensity;  // directional light

				if (_ShowObjColor > 0) { // check if need to show object color
					result *= _ObjectColor; // Multiply in each light computation or at the end are the same
				}
				return result;
			}

			// Render result of diffuse and specular
			float4 diffAndSpecRender(float4 diff1, float4 diff2, float4 diffD, float4 spec1, float4 spec2, float4 specD, float2 uv, float strengthArr[2])
			{

				float4 lightVal1 = diff1 + spec1;
				float4 lightVal2 = diff2 + spec2;
				float4 lightValD = diffD + specD;

				float lookUpVal;
				float4 lightVal;
				if(_LookUpValMaxOrAdd == 1)
				{
					lightVal = lightVal1 + lightVal2 + lightValD;

					if(_ObjColorInLookUpVal == 0)  // no color component
					{
						lookUpVal = lightVal.r;
						//lookUpVal = ColortoFloat(lightVal);
					}
					else                           // with color component
					{
						lookUpVal = ColortoFloat(lightVal);
					}
				}
				else
				{
					lightVal = max(lightVal1, lightVal2);
					lightVal = max(lightVal, lightValD);

					if(_ObjColorInLookUpVal == 0)  // no color component
					{
						lookUpVal = lightVal.r;
					}
					else                           // with color component
					{
						lookUpVal = ColortoFloat(lightVal);
					}
				}
				
				float4 hatchColor = HatchLookUp(lookUpVal, uv);

				// additional underlying texture
				float4 hatchColorKd = (1,1,1,1);
				if(_UnderlyingTexture > 0)  // will show underlying texture
				{
					hatchColorKd = _TestTex.Sample(sampler_Hatch15, uv);  // Kd texture as is
					if(_UnderlyingTexture == 2)
					{
						// *** Attention: currently kd texture use the same hatchLookUp func ***
						// *** Which uses the same _Bg and _Fg as regular hatch. Which makes the multiplied result background & forground color two times darker***
						hatchColorKd = HatchLookUp(hatchColorKd, uv);  // underlaying texture mapped as hatch
					}
				}

				float4 result = float4(0,0,0,0);
				for(int i = 0; i < _secLightNum; ++i)
				{
					if(_HatchMaxDiff == 0)  // render without hatch
					{
						hatchColor = lightVal;
					}
					result += hatchColor  * hatchColorKd * _secLightsColorVec[i] * _secLightsIntensity[i] * strengthArr[i];
				}
				result += hatchColor * hatchColorKd * _dLightColor * _dLightIntensity;  // directional light

				if (_ShowObjColor > 0) { // check if need to show object color
					result *= _ObjectColor;
				}
				return result;
			}



			v2f vert(a2v v) {
				v2f o;

				o.pos = UnityObjectToClipPos(v.vertex);

				o.uv = v.texcoord.xy * _TileFactor;
				
				o.worldNormal = UnityObjectToWorldNormal(v.normal);  // world space normal direction
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;  // vertex's world position
				
				return o;
			}

			float4 frag(v2f i) : SV_Target {

				float3 worldLightDir1 = normalize(_secLightsPos[0] - i.worldPos.xyz);
				float3 worldLightDir2 = normalize(_secLightsPos[1] - i.worldPos.xyz);

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

				float4 diff1 = DiffuseFactor(worldLightDis[0], _farDisArray[0], worldLightDir1, i.worldNormal, strengthArr[0], i.uv);
				float4 diff2 = DiffuseFactor(worldLightDis[1], _farDisArray[1], worldLightDir2, i.worldNormal, strengthArr[1], i.uv);
				float3 worldLightDir3 = - _dLightDir;

				float4 diffD = DiffuseFactor(0, 0, worldLightDir3, i.worldNormal, _dLightIntensity, i.uv);



				// specular value
				float3 viewDir = normalize(_cameraPos - i.worldPos.xyz);  // viewing direction
				float3 incidentVec1 = i.worldPos.xyz - _secLightsPos[0];
				float3 incidentVec2 = i.worldPos.xyz - _secLightsPos[1];
				float3 reflectionVec1 = reflect(incidentVec1, i.worldNormal);  // reflection vector
				float3 reflectionVec2 = reflect(incidentVec2, i.worldNormal);
				float3 reflectionDir1 = normalize(reflectionVec1);
				float3 reflectionDir2 = normalize(reflectionVec2);
				
				float4 spec1 = SpecularFactor(worldLightDis[0], _farDisArray[0], reflectionDir1, viewDir, strengthArr[0]);
				float4 spec2 = SpecularFactor(worldLightDis[1], _farDisArray[1], reflectionDir2, viewDir, strengthArr[1]);

				float3 reflectionVec3 = normalize(reflect(_dLightDir, i.worldNormal));
				float4 specD = SpecularFactor(0, 0, reflectionVec3, viewDir, _dLightIntensity);

				float4 result;
				
				if(_HatchRenderMethod == 0)  // method1 - lookUpVal = find max(diff/spec), all lights share one hatch
				{
					result = diffOrSpecRender(diff1, diff2, diffD, spec1, spec2, specD, i.uv, strengthArr);
				}
				else  // method2 - lookUpVal = diff + spec, all lights share one hatch
				{
					result = diffAndSpecRender(diff1, diff2, diffD, spec1, spec2, specD, i.uv, strengthArr);
				}

				return result;
			}

			ENDCG
		}
    }
	
}
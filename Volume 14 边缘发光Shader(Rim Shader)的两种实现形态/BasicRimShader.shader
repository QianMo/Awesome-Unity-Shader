

Shader "Learning Unity Shader/Lecture 14/Basic Rim Shader" 
{
	//-----------------------------------【属性 || Properties】------------------------------------------  
	Properties
	{
		//主颜色 || Main Color
		_MainColor("【主颜色】Main Color", Color) = (0.5,0.5,0.5,1)
		//漫反射纹理 || Diffuse Texture
		_TextureDiffuse("【漫反射纹理】Texture Diffuse", 2D) = "white" {}	
		//边缘发光颜色 || Rim Color
		_RimColor("【边缘发光颜色】Rim Color", Color) = (0.5,0.5,0.5,1)
		//边缘发光强度 ||Rim Power
		_RimPower("【边缘发光强度】Rim Power", Range(0.0, 36)) = 0.1
		//边缘发光强度系数 || Rim Intensity Factor
		_RimIntensity("【边缘发光强度系数】Rim Intensity", Range(0.0, 100)) = 3
	}

	//----------------------------------【子着色器 || SubShader】---------------------------------------  
	SubShader
	{
		//渲染类型为Opaque，不透明 || RenderType Opaque
		Tags
		{
			"RenderType" = "Opaque"
		}

		//---------------------------------------【唯一的通道 || Pass】------------------------------------
		Pass
		{
			//设定通道名称 || Set Pass Name
			Name "ForwardBase"

			//设置光照模式 || LightMode ForwardBase
			Tags
			{
				"LightMode" = "ForwardBase"
			}

			//-------------------------开启CG着色器编程语言段 || Begin CG Programming Part----------------------  
			CGPROGRAM

				//【1】指定顶点和片段着色函数名称 || Set the name of vertex and fragment shader function
				#pragma vertex vert
				#pragma fragment frag

				//【2】头文件包含 || include
				#include "UnityCG.cginc"
				#include "AutoLight.cginc"

				//【3】指定Shader Model 3.0 || Set Shader Model 3.0
				#pragma target 3.0

				//【4】变量声明 || Variable Declaration
				//系统光照颜色
				uniform float4 _LightColor0;
				//主颜色
				uniform float4 _MainColor;
				//漫反射纹理
				uniform sampler2D _TextureDiffuse; 
				//漫反射纹理_ST后缀版
				uniform float4 _TextureDiffuse_ST;
				//边缘光颜色
				uniform float4 _RimColor;
				//边缘光强度
				uniform float _RimPower;
				//边缘光强度系数
				uniform float _RimIntensity;

				//【5】顶点输入结构体 || Vertex Input Struct
				struct VertexInput 
				{
					//顶点位置 || Vertex position
					float4 vertex : POSITION;
					//法线向量坐标 || Normal vector coordinates
					float3 normal : NORMAL;
					//一级纹理坐标 || Primary texture coordinates
					float4 texcoord : TEXCOORD0;
				};

				//【6】顶点输出结构体 || Vertex Output Struct
				struct VertexOutput 
				{
					//像素位置 || Pixel position
					float4 pos : SV_POSITION;
					//一级纹理坐标 || Primary texture coordinates
					float4 texcoord : TEXCOORD0;
					//法线向量坐标 || Normal vector coordinates
					float3 normal : NORMAL;
					//世界空间中的坐标位置 || Coordinate position in world space
					float4 posWorld : TEXCOORD1;
					//创建光源坐标,用于内置的光照 || Function in AutoLight.cginc to create light coordinates
					LIGHTING_COORDS(3,4)
				};

				//【7】顶点着色函数 || Vertex Shader Function
				VertexOutput vert(VertexInput v) 
				{
					//【1】声明一个顶点输出结构对象 || Declares a vertex output structure object
					VertexOutput o;

					//【2】填充此输出结构 || Fill the output structure
					//将输入纹理坐标赋值给输出纹理坐标
					o.texcoord = v.texcoord;
					//获取顶点在世界空间中的法线向量坐标  
					o.normal = mul(float4(v.normal,0), _World2Object).xyz;
					//获得顶点在世界空间中的位置坐标  
					o.posWorld = mul(_Object2World, v.vertex);
					//获取像素位置
					o.pos = mul(UNITY_MATRIX_MVP, v.vertex);

					//【3】返回此输出结构对象  || Returns the output structure
					return o;
				}

				//【8】片段着色函数 || Fragment Shader Function
				fixed4 frag(VertexOutput i) : COLOR
				{
					//【8.1】方向参数准备 || Direction
					//视角方向
					float3 ViewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
					//法线方向
					float3 Normalection = normalize(i.normal);
					//光照方向
					float3 LightDirection = normalize(_WorldSpaceLightPos0.xyz);

					//【8.2】计算光照的衰减 || Lighting attenuation
					//衰减值
					float Attenuation = LIGHT_ATTENUATION(i);
					//衰减后颜色值
					float3 AttenColor = Attenuation * _LightColor0.xyz;

					//【8.3】计算漫反射 || Diffuse
					float NdotL = dot(Normalection, LightDirection);
					float3 Diffuse = max(0.0, NdotL) * AttenColor + UNITY_LIGHTMODEL_AMBIENT.xyz;

					//【8.4】准备自发光参数 || Emissive
					//计算边缘强度
					half Rim = 1.0 - max(0, dot(i.normal, ViewDirection));
					//计算出边缘自发光强度
					float3 Emissive = _RimColor.rgb * pow(Rim,_RimPower) *_RimIntensity;

					//【8.5】计在最终颜色中加入自发光颜色 || Calculate the final color
					//最终颜色 = （漫反射系数 x 纹理颜色 x rgb颜色）+自发光颜色 || Final Color=(Diffuse x Texture x rgbColor)+Emissive
					float3 finalColor = Diffuse * (tex2D(_TextureDiffuse,TRANSFORM_TEX(i.texcoord.rg, _TextureDiffuse)).rgb*_MainColor.rgb) + Emissive;
				
					//【8.6】返回最终颜色 || Return final color
					return fixed4(finalColor,1);
				}

			//-------------------结束CG着色器编程语言段 || End CG Programming Part------------------  
			ENDCG
		}
	}

	//后备着色器为普通漫反射 || Fallback use Diffuse
	FallBack "Diffuse"
}

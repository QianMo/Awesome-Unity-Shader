
Shader "浅墨Shader编程/Volume12/Diffuse(Lambert) Shader"
{
	//------------------------------------【属性值】------------------------------------
	Properties
	{
		//颜色值
		_Color("Main Color", Color) = (1, 1, 1, 1)

	}

	//------------------------------------【唯一的子着色器】------------------------------------
	SubShader
		{
			//渲染类型设置：不透明
			Tags{ "RenderType" = "Opaque" }
			//设置光照模式：ForwardBase
			Tags{ "LightingMode" = "ForwardBase" }
			//细节层次设为：200
			LOD 200

			//--------------------------------唯一的通道-------------------------------
			Pass
			{
				//===========开启CG着色器语言编写模块===========
				CGPROGRAM

				//编译指令:告知编译器顶点和片段着色函数的名称
				#pragma vertex vert
				#pragma fragment frag

				//包含头文件
				#include "UnityCG.cginc"

				//顶点着色器输入结构
				struct appdata
				{
					float4 vertex : POSITION;//顶点位置
					float3 normal : NORMAL;//法线向量坐标
				};

				//顶点着色器输出结构
				struct v2f
				{
					float4 position : SV_POSITION;//像素位置
					float3 normal : NORMAL;//法线向量坐标
				};

				//变量声明
				float4 _LightColor0;
				float4 _Color;

				//--------------------------------【顶点着色函数】-----------------------------
				// 输入：顶点输入结构体
				// 输出：顶点输出结构体
				//---------------------------------------------------------------------------------
				v2f vert(appdata input)
				{
					//【1】声明一个输出结构对象
					v2f output;

					//【2】填充此输出结构
					//输出的顶点位置为模型视图投影矩阵乘以顶点位置，也就是将三维空间中的坐标投影到了二维窗口
					output.position = mul(UNITY_MATRIX_MVP, input.vertex);
					//获取顶点在世界空间中的法线向量坐标
					output.normal = mul(float4(input.normal, 0.0), _World2Object).xyz;

					//【3】返回此输出结构对象
					return output;
				}


				//--------------------------------【片段着色函数】-----------------------------
				// 输入：顶点输出结构体
				// 输出：float4型的像素颜色值
				//---------------------------------------------------------------------------------
				fixed4 frag(v2f input) : COLOR
				{
					//【1】先准备好需要的参数
					//获取法线的方向
					float3 normalDirection = normalize(input.normal);
					//获取入射光线的值与方向
					float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);

					//【2】计算出漫反射颜色值  Diffuse=LightColor * MainColor * max(0,dot(N,L))
					float3 diffuse = _LightColor0.rgb * _Color.rgb * max(0.0, dot(normalDirection, lightDirection));

					//【3】合并漫反射颜色值与环境光颜色值
					float4 DiffuseAmbient = float4(diffuse, 1.0) + UNITY_LIGHTMODEL_AMBIENT;

					//【4】将漫反射-环境光颜色值乘上纹理颜色,并返回
					return DiffuseAmbient;
				}

				//===========结束CG着色器语言编写模块===========
				ENDCG

			}
		}
}

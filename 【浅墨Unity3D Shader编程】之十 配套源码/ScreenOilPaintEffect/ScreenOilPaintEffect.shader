//Reference:https://www.shadertoy.com/view/MsXSRN#

Shader "浅墨Shader编程/Volume10/ScreenOilPaintEffect" 
{
	//------------------------------------【属性值】------------------------------------
	Properties
	{
		_MainTex("Base (RGB)", 2D) = "white" {}
		_Distortion("_Distortion", Range(0.0, 1.0)) = 0.3
		_ScreenResolution("_ScreenResolution", Vector) = (0., 0., 0., 0.)
		_ResolutionValue("_ResolutionValue", Range(0.0, 5.0)) = 1.0
		_Radius("_Radius", Range(0.0, 5.0)) = 2.0
	}

	//------------------------------------【唯一的子着色器】------------------------------------
	SubShader
	{
		//--------------------------------唯一的通道-------------------------------
		Pass
		{
			//设置深度测试模式:渲染所有像素.等同于关闭透明度测试（AlphaTest Off）
			ZTest Always

			//===========开启CG着色器语言编写模块===========
			CGPROGRAM

			//编译指令: 指定着色器编译目标为Shader Model 3.0
			#pragma target 3.0

			//编译指令:告知编译器顶点和片段着色函数的名称
			#pragma vertex vert
			#pragma fragment frag

			//包含辅助CG头文件
			#include "UnityCG.cginc"

			//外部变量的声明
			uniform sampler2D _MainTex;
			uniform float _Distortion;
			uniform float4 _ScreenResolution;
			uniform float _ResolutionValue;
			uniform int  _Radius;

			//顶点输入结构
			struct vertexInput
			{
				float4 vertex : POSITION;//顶点位置
				float4 color : COLOR;//颜色值
				float2 texcoord : TEXCOORD0;//一级纹理坐标
			};

			//顶点输出结构
			struct vertexOutput
			{
				half2 texcoord : TEXCOORD0;//一级纹理坐标
				float4 vertex : SV_POSITION;//像素位置
				fixed4 color : COLOR;//颜色值
			};


			//--------------------------------【顶点着色函数】-----------------------------
			// 输入：顶点输入结构体
			// 输出：顶点输出结构体
			//---------------------------------------------------------------------------------
			vertexOutput vert(vertexInput Input)
			{
				//【1】声明一个输出结构对象
				vertexOutput Output;

				//【2】填充此输出结构
				//输出的顶点位置为模型视图投影矩阵乘以顶点位置，也就是将三维空间中的坐标投影到了二维窗口
				Output.vertex = mul(UNITY_MATRIX_MVP, Input.vertex);
				//输出的纹理坐标也就是输入的纹理坐标
				Output.texcoord = Input.texcoord;
				//输出的颜色值也就是输入的颜色值
				Output.color = Input.color;

				//【3】返回此输出结构对象
				return Output;
			}

			//--------------------------------【片段着色函数】-----------------------------
			// 输入：顶点输出结构体
			// 输出：float4型的颜色值
			//---------------------------------------------------------------------------------
			float4 frag(vertexOutput Input) : COLOR
			{
				//【1】根据设置的分辨率比值，计算图像尺寸
				float2 src_size = float2(_ResolutionValue / _ScreenResolution.x, _ResolutionValue / _ScreenResolution.y);
				
				//【2】获取坐标值
				float2 uv = Input.texcoord.xy;

				//【3】根据半径，计算出n的值
				float n = float((_Radius + 1) * (_Radius + 1));;

				//【4】定义一些参数
				float3 m0 = 0.0;  float3 m1 = 0.0;
				float3 s0 = 0.0;  float3 s1 = 0.0;
				float3 c;

				//【5】按半径Radius的值，迭代计算m0和s0的值
				for (int j = -_Radius; j <= 0; ++j)
				{
					for (int i = -_Radius; i <= 0; ++i)
					{
						c = tex2D(_MainTex, uv + float2(i, j) * src_size).rgb; 
						m0 += c; 
						s0 += c * c;
					}
				}

				//【6】按半径Radius的值，迭代计算m1和s1的值
				for (int j = 0; j <= _Radius; ++j)
				{
					for (int i = 0; i <= _Radius; ++i)
					{
						c = tex2D(_MainTex, uv + float2(i, j) * src_size).rgb; 
						m1 += c;
						s1 += c * c;
					}
				}

				//【7】定义参数，准备计算最终的颜色值
				float4 finalFragColor = 0.;
				float min_sigma2 = 1e+2;

				//【8】根据m0和s0，第一次计算finalFragColor的值
				m0 /= n;
				s0 = abs(s0 / n - m0 * m0);

				float sigma2 = s0.r + s0.g + s0.b;
				if (sigma2 < min_sigma2) 
				{
					min_sigma2 = sigma2;
					finalFragColor = float4(m0, 1.0);
				}

				//【9】根据m1和s1，第二次计算finalFragColor的值
				m1 /= n;
				s1 = abs(s1 / n - m1 * m1);

				sigma2 = s1.r + s1.g + s1.b;
				if (sigma2 < min_sigma2) 
				{
					min_sigma2 = sigma2;
					finalFragColor = float4(m1, 1.0);
				}

				//【10】返回最终的颜色值
				return finalFragColor;
			}

			ENDCG
		}

	}
}
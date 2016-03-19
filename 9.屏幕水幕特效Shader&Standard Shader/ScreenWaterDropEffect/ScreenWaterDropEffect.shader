//-----------------------------------------------【Shader脚本说明】---------------------------------------------------
//		 屏幕水幕特效的实现代码-Shader脚本部分
//      2015年10月  Created by  浅墨
//      更多内容或交流，请访问浅墨的博客：http://blog.csdn.net/poem_qianmo
//---------------------------------------------------------------------------------------------------------------------

Shader "浅墨Shader编程/Volume9/ScreenWaterDropEffect"
{
	//------------------------------------【属性值】------------------------------------
	Properties
	{
		//主纹理
		_MainTex ("Base (RGB)", 2D) = "white" {}
		//屏幕水滴的素材图
		_ScreenWaterDropTex ("Base (RGB)", 2D) = "white" {}
		//当前时间
		_CurTime ("Time", Range(0.0, 1.0)) = 1.0
		//X坐标上的水滴尺寸
		_SizeX ("SizeX", Range(0.0, 1.0)) = 1.0
		//Y坐标上的水滴尺寸
		_SizeY ("SizeY", Range(0.0, 1.0)) = 1.0
		//水滴的流动速度
		_DropSpeed ("Speed", Range(0.0, 10.0)) = 1.0
		//溶解度
		_Distortion ("_Distortion", Range(0.0, 1.0)) = 0.87
	}

	//------------------------------------【唯一的子着色器】------------------------------------
	SubShader
	{
		Pass
		{
			//设置深度测试模式:渲染所有像素.等同于关闭透明度测试（AlphaTest Off）
			ZTest Always
			
			//===========开启CG着色器语言编写模块===========
			CGPROGRAM

			//编译指令:告知编译器顶点和片段着色函数的名称
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			//编译指令: 指定着色器编译目标为Shader Model 3.0
			#pragma target 3.0

			//包含辅助CG头文件
			#include "UnityCG.cginc"

			//外部变量的声明
			uniform sampler2D _MainTex;
			uniform sampler2D _ScreenWaterDropTex;
			uniform float _CurTime;
			uniform float _DropSpeed;
			uniform float _SizeX;
			uniform float _SizeY;
			uniform float _Distortion;
			uniform float2 _MainTex_TexelSize;
			
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
			fixed4 frag(vertexOutput Input) : COLOR
			{
				//【1】获取顶点的坐标值
				float2 uv = Input.texcoord.xy;

				//【2】解决平台差异的问题。校正方向，若和规定方向相反，则将速度反向并加1
				#if UNITY_UV_STARTS_AT_TOP
				if (_MainTex_TexelSize.y < 0)
					_DropSpeed = 1 - _DropSpeed;
				#endif

				//【3】设置三层水流效果，按照一定的规律在水滴纹理上分别进行取样
				float3 rainTex1 = tex2D(_ScreenWaterDropTex, float2(uv.x * 1.15* _SizeX, (uv.y* _SizeY *1.1) + _CurTime* _DropSpeed *0.15)).rgb / _Distortion;
				float3 rainTex2 = tex2D(_ScreenWaterDropTex, float2(uv.x * 1.25* _SizeX - 0.1, (uv.y *_SizeY * 1.2) + _CurTime *_DropSpeed * 0.2)).rgb / _Distortion;
				float3 rainTex3 = tex2D(_ScreenWaterDropTex, float2(uv.x* _SizeX *0.9, (uv.y *_SizeY * 1.25) + _CurTime * _DropSpeed* 0.032)).rgb / _Distortion;

				//【4】整合三层水流效果的颜色信息，存于finalRainTex中
				float2 finalRainTex = uv.xy - (rainTex1.xy - rainTex2.xy - rainTex3.xy) / 3;

				//【5】按照finalRainTex的坐标信息，在主纹理上进行采样
				float3 finalColor = tex2D(_MainTex, float2(finalRainTex.x, finalRainTex.y)).rgb;

				//【6】返回加上alpha分量的最终颜色值
				return fixed4(finalColor, 1.0);


			}

			//===========结束CG着色器语言编写模块===========
			ENDCG
		}
	}
}


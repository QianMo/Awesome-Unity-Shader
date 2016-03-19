Shader "浅墨Shader编程/Volume11/PixelEffect"
{
	//------------------------------------【属性值】------------------------------------
	Properties
	{
		//主纹理
		_MainTex("Texture", 2D) = "white" {}
		//封装的变量值
		_Params("PixelNumPerRow (X) Ratio (Y)", Vector) = (80, 1, 1, 1.5)
	}

	//------------------------------------【唯一的子着色器】------------------------------------
	SubShader
	{
		//关闭剔除操作
		Cull Off
		//关闭深度写入模式
		ZWrite Off
		//设置深度测试模式:渲染所有像素.等同于关闭透明度测试（AlphaTest Off）
		ZTest Always

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
			struct vertexInput
			{
				float4 vertex : POSITION;//顶点位置
				float2 uv : TEXCOORD0;//一级纹理坐标
			};

			//顶点着色器输出结构
			struct vertexOutput
			{
				float4 vertex : SV_POSITION;//像素位置
				float2 uv : TEXCOORD0;//一级纹理坐标
			};

			//--------------------------------【顶点着色函数】-----------------------------
			// 输入：顶点输入结构体
			// 输出：顶点输出结构体
			//---------------------------------------------------------------------------------
			//顶点着色函数
			vertexOutput vert(vertexInput   v)
			{
				//【1】实例化一个输入结构体
				vertexOutput o;
				//【2】填充此输出结构
				//输出的顶点位置（像素位置）为模型视图投影矩阵乘以顶点位置，也就是将三维空间中的坐标投影到了二维窗口
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				//输入的UV纹理坐标为顶点输出的坐标
				o.uv = v.uv;

				//【3】返回此输出结构对象
				return o;
			}

			//变量的声明
			sampler2D _MainTex;
			half4 _Params;

			//进行像素化操作的自定义函数PixelateOperation
			half4 PixelateOperation(sampler2D tex, half2 uv, half scale, half ratio)
			{
				//【1】计算每个像素块的尺寸
				half PixelSize = 1.0 / scale;
				//【2】取整计算每个像素块的坐标值，ceil函数，对输入参数向上取整
				half coordX=PixelSize * ceil(uv.x / PixelSize);
				half coordY = (ratio * PixelSize)* ceil(uv.y / PixelSize / ratio);
				//【3】组合坐标值
				half2 coord = half2(coordX,coordY);
				//【4】返回坐标值
				return half4(tex2D(tex, coord).xyzw);
			}

			//--------------------------------【片段着色函数】-----------------------------
			// 输入：顶点输出结构体
			// 输出：float4型的像素颜色值
			//---------------------------------------------------------------------------------
			fixed4 frag(vertexOutput  Input) : COLOR
			{
				//使用自定义的PixelateOperation函数，计算每个像素经过取整后的颜色值
				return PixelateOperation(_MainTex, Input.uv, _Params.x, _Params.y);
			}

			//===========结束CG着色器语言编写模块===========
			ENDCG
		}
	}
}

//双面双色颜色可以调版透明Shader

Shader "浅墨Shader编程/Volume13/3.TwoSideColorChangeAlpha" 
{
	//------------------------------------【属性值】------------------------------------
	Properties
	{
		//正面颜色值
		_ColorWithAlpha_Front("ColorWithAlpha_Front", Color) = (0.9, 0.1, 0.1, 0.5)
		//背面颜色值
		_ColorWithAlpha_Back("ColorWithAlpha_Back", Color) = (0.1, 0.3, 0.9, 0.5)
	}

	//------------------------------------【唯一的子着色器】------------------------------------
	SubShader
	{
		//设置Queue为透明，在所有非透明几何体绘制之后再进行绘制
		Tags{ "Queue" = "Transparent" }

		//------------------------【通道1：渲染正面】-------------------------
		Pass
		{
			//剔除背面，渲染正面
			Cull Back
			//不写入深度缓冲,为了不遮挡住其他物体
			ZWrite Off 

			//选取Alpha混合方式
			Blend SrcAlpha OneMinusSrcAlpha
			//Blend  SrcAlpha SrcAlpha

			//===========开启CG着色器语言编写模块============
			CGPROGRAM

			//编译指令:告知编译器顶点和片段着色函数的名称
			#pragma vertex vert 
			#pragma fragment frag

			//变量声明
			uniform float4 _ColorWithAlpha_Front;

			//--------------------------------【顶点着色函数】-----------------------------
			// 输入：POSITION语义（坐标位置）
			// 输出：SV_POSITION语义（像素位置）
			//---------------------------------------------------------------------------------
			float4 vert(float4 vertexPos : POSITION) : SV_POSITION
			{
				//坐标系变换
				//输出的顶点位置（像素位置）为模型视图投影矩阵乘以顶点位置，也就是将三维空间中的坐标投影到了二维窗口
				return mul(UNITY_MATRIX_MVP, vertexPos);
			}

			//--------------------------------【片段着色函数】-----------------------------
			// 输入：无
			// 输出：COLOR语义（颜色值）
			//---------------------------------------------------------------------------------
			float4 frag(void) : COLOR
			{
				//返回自定义的RGBA颜色
				return _ColorWithAlpha_Front;
			}

			//===========结束CG着色器语言编写模块===========
			ENDCG
		}

		//------------------------【通道2：渲染背面】-------------------------
		Pass
		{
			//剔除正面，渲染背面
			Cull Front

			//不写入深度缓冲,为了不遮挡住其他物体
			ZWrite Off

			//选取Alpha混合方式
			Blend SrcAlpha OneMinusSrcAlpha
			//Blend  SrcAlpha SrcAlpha

			//===========开启CG着色器语言编写模块============
			CGPROGRAM

			//编译指令:告知编译器顶点和片段着色函数的名称
			#pragma vertex vert 
			#pragma fragment frag

			//变量声明
			uniform float4 _ColorWithAlpha_Back;

			//--------------------------------【顶点着色函数】-----------------------------
			// 输入：POSITION语义（坐标位置）
			// 输出：SV_POSITION语义（像素位置）
			//---------------------------------------------------------------------------------
			float4 vert(float4 vertexPos : POSITION) : SV_POSITION
			{
				//坐标系变换
				//输出的顶点位置（像素位置）为模型视图投影矩阵乘以顶点位置，也就是将三维空间中的坐标投影到了二维窗口
				return mul(UNITY_MATRIX_MVP, vertexPos);
			}

			//--------------------------------【片段着色函数】-----------------------------
			// 输入：无
			// 输出：COLOR语义（颜色值）
			//---------------------------------------------------------------------------------
			float4 frag(void) : COLOR
			{
				//返回自定义的RGBA颜色
				return _ColorWithAlpha_Back;
			}

			//===========结束CG着色器语言编写模块===========
			ENDCG
		}
	}
}
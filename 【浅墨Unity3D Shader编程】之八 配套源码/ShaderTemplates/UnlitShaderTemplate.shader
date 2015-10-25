
Shader "浅墨Shader编程/Volume8/无灯光着色器(Unlit Shader)模板"
{
	//------------------------------------【属性值】------------------------------------
	Properties
	{
		//主纹理
		_MainTex ("Texture", 2D) = "white" {}
	}

	//------------------------------------【唯一的子着色器】------------------------------------
	SubShader
	{
		//渲染类型设置：不透明
		Tags { "RenderType"="Opaque" }

		//细节层次设为：200
		LOD 100

		//--------------------------------唯一的通道-------------------------------
		Pass
		{
			//===========开启CG着色器语言编写模块===========
			CGPROGRAM

			//编译指令:告知编译器顶点和片段着色函数的名称
			#pragma vertex vert
			#pragma fragment frag

			// 着色器变体快捷编译指令：雾效。编译出几个不同的Shader变体来处理不同类型的雾效(关闭/线性/指数/二阶指数)
			#pragma multi_compile_fog

			//包含头文件
			#include "UnityCG.cginc"

			//顶点着色器输入结构
			struct appdata
			{
				float4 vertex : POSITION;//顶点位置
				float2 uv : TEXCOORD0;//纹理坐标
			};

			//顶点着色器输出结构
			struct v2f
			{
				float2 uv : TEXCOORD0;//纹理坐标
				UNITY_FOG_COORDS(1)//雾数据
				float4 vertex : SV_POSITION;//像素位置
			};

			//变量声明
			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			//--------------------------------【顶点着色函数】-----------------------------
			// 输入：顶点输入结构体
			// 输出：顶点输出结构体
			//---------------------------------------------------------------------------------
			v2f vert (appdata v)
			{
				//【1】实例化一个输入结构体
				v2f o;
				//【2】填充此输出结构
				//输出的顶点位置（像素位置）为模型视图投影矩阵乘以顶点位置，也就是将三维空间中的坐标投影到了二维窗口
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				//【3】用UnityCG.cginc头文件中内置定义的宏,根据uv坐标来计算真正的纹理上对应的位置（按比例进行二维变换）
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				//【4】用UnityCG.cginc头文件中内置定义的宏处理雾效，从顶点着色器中输出雾效数据
				UNITY_TRANSFER_FOG(o,o.vertex);

				//【5】返回此输出结构对象
				return o;
			}
			
			//--------------------------------【片段着色函数】-----------------------------
			// 输入：顶点输出结构体
			// 输出：float4型的像素颜色值
			//---------------------------------------------------------------------------------
			fixed4 frag (v2f i) : SV_Target
			{
				//【1】采样主纹理在对应坐标下的颜色值
				fixed4 col = tex2D(_MainTex, i.uv);

				//【2】用UnityCG.cginc头文件中内置定义的宏启用雾效
				UNITY_APPLY_FOG(i.fogCoord, col);		

				//【3】返回最终的颜色值
				return col;
			}

			//===========结束CG着色器语言编写模块===========
			ENDCG
		}
	}
}

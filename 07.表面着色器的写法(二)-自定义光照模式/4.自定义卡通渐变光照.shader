Shader "浅墨Shader编程/Volume7/37.自定义卡通渐变光照" 
{
	//--------------------------------【属性】----------------------------------------  
	Properties 
	{
		_MainTex ("【主纹理】Texture", 2D) = "white" {}
		_Ramp ("【渐变纹理】Shading Ramp", 2D) = "gray" {}
	}

	//--------------------------------【子着色器】----------------------------------
    SubShader 
	{
		//-----------子着色器标签----------  
		Tags { "RenderType" = "Opaque" }
		//-------------------开始CG着色器编程语言段-----------------  
		CGPROGRAM

		//【1】光照模式声明：使用自制的卡通渐变光照模式
		#pragma surface surf Ramp

		//变量声明
		sampler2D _Ramp;

		//【2】实现自制的卡通渐变光照模式
		half4 LightingRamp (SurfaceOutput s, half3 lightDir, half atten)
		{
			//点乘反射光线法线和光线方向
            half NdotL = dot (s.Normal, lightDir); 
			//增强光强
            half diff = NdotL * 0.5 + 0.5;
			//从纹理中定义渐变效果
			half3 ramp = tex2D (_Ramp, float2(diff,diff)).rgb;
			//计算出最终结果
            half4 color;
			color.rgb = s.Albedo * _LightColor0.rgb * ramp * (atten * 2);
			color.a = s.Alpha;

			return color;
		}

		//【3】输入结构  
		struct Input 
		{
			float2 uv_MainTex;
		};

		//变量声明
		sampler2D _MainTex;

		//【4】表面着色函数的编写
		void surf (Input IN, inout SurfaceOutput o) 
		{
			//从主纹理获取rgb颜色值 
			o.Albedo = tex2D (_MainTex, IN.uv_MainTex).rgb;
		}

		//-------------------结束CG着色器编程语言段------------------
		ENDCG

    }
    Fallback "Diffuse"
  }
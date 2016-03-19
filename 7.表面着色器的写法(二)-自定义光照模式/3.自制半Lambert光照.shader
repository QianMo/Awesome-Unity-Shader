  Shader "浅墨Shader编程/Volume7/36.自制简单的半Lambert光照" 
  {
		//--------------------------------【属性】----------------------------------------  
		Properties 
		{
			_MainTex ("【主纹理】Texture", 2D) = "white" {}
		}

		//--------------------------------【子着色器】----------------------------------  
		SubShader 
		{
			//-----------子着色器标签----------  
			Tags { "RenderType" = "Opaque" }
			//-------------------开始CG着色器编程语言段-----------------  
			CGPROGRAM

			//【1】光照模式声明：使用自制的半兰伯特光照模式
			#pragma surface surf QianMoHalfLambert

			//【2】实现自定义的半兰伯特光照模式
			half4 LightingQianMoHalfLambert (SurfaceOutput s, half3 lightDir, half atten) 
			{
				half NdotL =max(0, dot (s.Normal, lightDir));

				//在兰伯特光照的基础上加上这句，增加光强
				float hLambert = NdotL * 0.5 + 0.5;  
				half4 color;

				//修改这句中的相关参数
				color.rgb = s.Albedo * _LightColor0.rgb * (hLambert * atten * 2);
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
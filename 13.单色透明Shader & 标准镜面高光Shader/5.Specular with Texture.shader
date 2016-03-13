//支持纹理载入的specular shader 

Shader "浅墨Shader编程/Volume13/5.Specular with Shader"
{
	//------------------------------------【属性值】------------------------------------
	Properties
	{
		//主纹理
		_MainTex("Texture", 2D) = "white" {}
		//主颜色
		_Color("Main Color", Color) = (1, 1, 1, 1)
		//镜面反射颜色
		_SpecColor("Specular Color", Color) = (1, 1, 1, 1)
		//镜面反射光泽度
		_SpecShininess("Specular Shininess", Range(1.0, 100.0)) = 10.0
	}

	//------------------------------------【唯一的子着色器】------------------------------------
	SubShader
	{
		//渲染类型设置：不透明
		Tags{ "RenderType" = "Opaque" }

		//--------------------------------唯一的通道-------------------------------
		Pass
		{
			//光照模型ForwardBase
			Tags{ "LightMode" = "ForwardBase" }
			//===========开启CG着色器语言编写模块===========
			CGPROGRAM

			//编译指令:告知编译器顶点和片段着色函数的名称
			#pragma vertex vert
			#pragma fragment frag

			//顶点着色器输入结构
			struct appdata
			{
				float4 vertex : POSITION;//顶点位置
				float3 normal : NORMAL;//法线向量坐标
				float2 texcoord : TEXCOORD0;//一级纹理坐标
			};

			//顶点着色器输出结构
			struct v2f
			{
				float4 pos : SV_POSITION;//像素位置
				float3 normal : NORMAL;//法线向量坐标
				float2 texcoord : TEXCOORD0;//一级纹理坐标
				float4 posWorld : TEXCOORD1;//在世界空间中的坐标位置
			};

			//变量的声明
			float4 _LightColor0;
			float4 _Color;
			sampler2D _MainTex;
			float4 _SpecColor;
			float _SpecShininess;

			//--------------------------------【顶点着色函数】-----------------------------
			// 输入：顶点输入结构体
			// 输出：顶点输出结构体
			//---------------------------------------------------------------------------------
			//顶点着色函数
			v2f vert(appdata IN)
			{
				//【1】声明一个输出结构对象
				v2f OUT;

				//【2】填充此输出结构
				//输出的顶点位置为模型视图投影矩阵乘以顶点位置，也就是将三维空间中的坐标投影到了二维窗口
				OUT.pos = mul(UNITY_MATRIX_MVP, IN.vertex);
				//获得顶点在世界空间中的位置坐标
				OUT.posWorld = mul(_Object2World, IN.vertex);
				//获取顶点在世界空间中的法线向量坐标
				OUT.normal = mul(float4(IN.normal, 0.0), _World2Object).xyz;
				//输出的纹理坐标也就是输入的纹理坐标
				OUT.texcoord = IN.texcoord;

				//【3】返回此输出结构对象
				return OUT;
			}

			//--------------------------------【片段着色函数】-----------------------------
			// 输入：顶点输出结构体
			// 输出：float4型的像素颜色值
			//---------------------------------------------------------------------------------
			fixed4 frag(v2f IN) : COLOR
			{
				//【1】先准备好需要的参数
				//获取纹理颜色
				float4 texColor = tex2D(_MainTex, IN.texcoord);
				//获取法线的方向
				float3 normalDirection = normalize(IN.normal);
				//获取入射光线的方向
				float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
				//获取视角方向
				float3 viewDirection = normalize(_WorldSpaceCameraPos - IN.posWorld.xyz);

				//【2】计算出漫反射颜色值  Diffuse=LightColor * MainColor * max(0,dot(N,L))
				float3 diffuse = _LightColor0.rgb * _Color.rgb * max(0.0, dot(normalDirection, lightDirection));

				//【3】计算镜面反射颜色值 
				float3 specular;
				//若是法线方向和入射光方向大于180度，镜面反射值为0
				if (dot(normalDirection, lightDirection) < 0.0)
				{
					specular = float3(0.0, 0.0, 0.0);
				}
				//否则，根据公式进行计算 Specular =LightColor * SpecColor *pow(max(0,dot(R,V)),Shiness),R=reflect(-L,N)
				else
				{
					float3 reflectDirection = reflect(-lightDirection, normalDirection);
					specular = _LightColor0.rgb * _SpecColor.rgb * pow(max(0.0, dot(reflectDirection, viewDirection)), _SpecShininess);
				}

				//【4】合并漫反射、镜面反射、环境光的颜色值
				float4 diffuseSpecularAmbient = float4(diffuse, 1.0) + float4(specular, 1.0) + UNITY_LIGHTMODEL_AMBIENT;

				//【5】将漫反射-镜面反射-环境光的颜色值乘以纹理颜色值之后返回
				return diffuseSpecularAmbient * texColor;
			}

			//===========结束CG着色器语言编写模块===========
			ENDCG
		}
	}
}

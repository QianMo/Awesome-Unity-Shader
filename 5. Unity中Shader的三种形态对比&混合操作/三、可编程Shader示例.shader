Shader "浅墨Shader编程/Volume5/可编程Shader示例" 
{
	//-------------------------------【属性】--------------------------------------
	Properties 
	{
		_Color ("Color", Color) = (1.0,1.0,1.0,1.0)
		_SpecColor ("Specular Color", Color) = (1.0,1.0,1.0,1.0)
		_Shininess ("Shininess", Float) = 10
	}

	//--------------------------------【子着色器】--------------------------------
	SubShader 
	{
		//-----------子着色器标签----------
		Tags { "LightMode" = "ForwardBase" }

		//----------------通道---------------
		Pass 
		{
			//-------------------开始CG着色器编程语言段-----------------  
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			//---------------声明变量--------------
			uniform float4 _Color;
			uniform float4 _SpecColor;
			uniform float _Shininess;
			
			//--------------定义变量--------------
			uniform float4 _LightColor0;
			
			//--------------顶点输入结构体-------------
			struct vertexInput 
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			//--------------顶点输出结构体-------------
			struct vertexOutput 
			{
				float4 pos : SV_POSITION;
				float4 col : COLOR;
			};
			
			//--------------顶点函数--------------
			vertexOutput vert(vertexInput v)
			{
				vertexOutput o;
				
				//一些方向
				float3 normalDirection = normalize( mul( float4(v.normal, 0.0), _World2Object ).xyz );
				float3 viewDirection = normalize( float3( float4( _WorldSpaceCameraPos.xyz, 1.0) - mul(_Object2World, v.vertex).xyz ) );
				float3 lightDirection;
				float atten = 1.0;
				
				//光照
				lightDirection = normalize(_WorldSpaceLightPos0.xyz);
				float3 diffuseReflection = atten * _LightColor0.xyz * max( 0.0, dot( normalDirection, lightDirection ) );
				float3 specularReflection = atten * _LightColor0.xyz * _SpecColor.rgb * max( 0.0, dot( normalDirection, lightDirection ) ) * pow( max( 0.0, dot( reflect( -lightDirection, normalDirection ), viewDirection ) ), _Shininess );
				float3 lightFinal = diffuseReflection + specularReflection + UNITY_LIGHTMODEL_AMBIENT;
				
				//计算结果
				o.col = float4(lightFinal * _Color.rgb, 1.0);//颜色
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);//位置
				return o;
			}
			
			//--------------片段函数---------------
			float4 frag(vertexOutput i) : COLOR
			{
				return i.col;
			}

			//-------------------结束CG着色器编程语言段------------------
			ENDCG
		}
	}
	//备胎
	Fallback "Diffuse"
	
}
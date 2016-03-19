Shader "浅墨Shader编程/Volume5/20.基本blend使用+颜色可调" 
{
	//-------------------------------【属性】-----------------------------------------
    Properties 
	{
        _MainTex ("将混合的纹理", 2D) = "black" {}
		 _Color ("主颜色", Color) = (1,1,1,0)  
    }

	//--------------------------------【子着色器】--------------------------------
    SubShader 
	{
		//-----------子着色器标签----------
        Tags { "Queue" = "Transparent" } //子着色器的标签设为透明

		//----------------通道---------------
        Pass 
		{
			Blend One OneMinusDstColor          // 柔性相加
			SetTexture [_MainTex]
			{ 
				// 使颜色属性进入混合器  
				constantColor [_Color]  
				// 使用纹理的alpha通道插值混合顶点颜色  
				combine constant lerp(texture) previous  
			}
		}
    }
}


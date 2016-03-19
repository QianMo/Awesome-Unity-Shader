Shader "浅墨Shader编程/Volume5/21.基本blend使用+顶点光照" 
{
	//-------------------------------【属性】-----------------------------------------
    Properties 
	{
        _MainTex ("Texture to blend", 2D) = "black" {}
		_Color ("主颜色", Color) = (1,1,1,0)  
    }

	//--------------------------------【子着色器】--------------------------------
    SubShader 
	{
		//-----------子着色器标签----------
        Tags { "Queue" = "Transparent" }

		//----------------通道---------------
         Pass 
			{
				//【1】设置材质
				Material
				{
					Diffuse [_Color]  
					Ambient [_Color] 
				}

		        //【2】开启光照  
				Lighting On 
				Blend One OneMinusDstColor          // Soft Additive
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


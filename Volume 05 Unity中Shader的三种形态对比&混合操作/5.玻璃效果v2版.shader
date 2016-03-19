Shader "浅墨Shader编程/Volume5/22.玻璃效果v2" 
{
	//-------------------------------【属性】--------------------------------------
    Properties 
	{
        _Color ("Main Color", Color) = (1,1,1,1)
        _MainTex ("Base (RGB) Transparency (A)", 2D) = "white" {}
        _Reflections ("Base (RGB) Gloss (A)", Cube) = "skybox" { TexGen CubeReflect }
    }

	//--------------------------------【子着色器】--------------------------------
    SubShader 
	{
		//-----------子着色器标签----------
        Tags { "Queue" = "Transparent" }

		//----------------通道---------------
        Pass 
		{
			//进行纹理混合
			Blend One One

			//设置材质
            Material 
			{
                Diffuse [_Color]
            }

			//开光照
            Lighting On

			//和纹理相乘
            SetTexture [_Reflections] 
			{
                combine texture
                Matrix [_Reflection]
            }
        }
    }
} 



Shader "浅墨Shader编程/Volume3/8.纹理的Alpha通道与自发光相混合"
{
	//-------------------------------【属性】-----------------------------------------
    Properties
	{
		_MainTex ("基础纹理 (RGB)-自发光(A)", 2D) =  "red" { }
    }

	//--------------------------------【子着色器】----------------------------------
    SubShader 
	{
        Pass 
		{
			//【1】设置白色的顶点光照
            Material 
			{
                Diffuse (1,1,1,1)
                Ambient (1,1,1,1)
            }

			//【2】开光照
            Lighting On

			//【3】使用纹理的Alpha通道来插值混合颜色(1,1,1,1)
            SetTexture [_MainTex] 
			{
                constantColor (1,1,1,1)
                combine constant lerp(texture) previous
            }

			//【4】和纹理相乘
            SetTexture [_MainTex] 
			{
                combine previous * texture
            }
        }
    }
}

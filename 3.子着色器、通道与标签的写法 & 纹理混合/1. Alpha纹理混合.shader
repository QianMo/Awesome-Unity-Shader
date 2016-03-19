

Shader "浅墨Shader编程/Volume3/7.Alpha纹理混合"
{
	//-------------------------------【属性】-----------------------------------------
    Properties 
	{
        _MainTex ("基础纹理(RGB)", 2D) = "white" {}
        _BlendTex ("混合纹理(RGBA) ", 2D) = "white" {}
    }

	//--------------------------------【子着色器】--------------------------------
    SubShader 
	{
        Pass 
		{
			// 【1】应用主纹理
            SetTexture [_MainTex] {	combine texture }
			// 【2】使用相乘操作来进行Alpha纹理混合
            SetTexture [_BlendTex] {combine texture * previous}
        }
    }
}

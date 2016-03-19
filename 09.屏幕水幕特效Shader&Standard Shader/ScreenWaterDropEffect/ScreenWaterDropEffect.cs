//-----------------------------------------------【C#脚本说明】---------------------------------------------------
//		 屏幕水幕特效的实现代码-C#脚本部分
//      2015年10月  Created by  浅墨
//      更多内容或交流，请访问浅墨的博客：http://blog.csdn.net/poem_qianmo
//---------------------------------------------------------------------------------------------------------------------


using UnityEngine;
using System.Collections;

[ExecuteInEditMode]
[AddComponentMenu("浅墨Shader编程/Volume9/ScreenWaterDropEffect")]
public class ScreenWaterDropEffect : MonoBehaviour 
{
    //-------------------变量声明部分-------------------
    #region Variables

    //着色器和材质实例
    public Shader CurShader;//着色器实例
    private Material CurMaterial;//当前的材质

    //时间变量和素材图的定义
    private float TimeX = 1.0f;//时间变量
    private Texture2D ScreenWaterDropTex;//屏幕水滴的素材图

    //可以在编辑器中调整的参数值
    [Range(5, 64), Tooltip("溶解度")]
    public float Distortion = 8.0f;
    [Range(0, 7), Tooltip("水滴在X坐标上的尺寸")]
    public float SizeX = 1f;
    [Range(0, 7), Tooltip("水滴在Y坐标上的尺寸")]
    public float SizeY = 0.5f;
    [Range(0, 10), Tooltip("水滴的流动速度")]
    public float DropSpeed = 3.6f;

    //用于参数调节的中间变量
    public static float ChangeDistortion;
    public static float ChangeSizeX;
    public static float ChangeSizeY;
    public static float ChangeDropSpeed;
    #endregion


    //-------------------------材质的get&set----------------------------
    #region MaterialGetAndSet
    Material material
    {
        get
        {
            if (CurMaterial == null)
            {
                CurMaterial = new Material(CurShader);
                CurMaterial.hideFlags = HideFlags.HideAndDontSave;
            }
            return CurMaterial;
        }
    }
    #endregion


    //-----------------------------------------【Start()函数】---------------------------------------------  
    // 说明：此函数仅在Update函数第一次被调用前被调用
    //--------------------------------------------------------------------------------------------------------
    void Start()
    {
        //依次赋值
        ChangeDistortion = Distortion;
        ChangeSizeX = SizeX;
        ChangeSizeY = SizeY;
        ChangeDropSpeed = DropSpeed;

        //载入素材图
        ScreenWaterDropTex = Resources.Load("ScreenWaterDrop") as Texture2D;

        //找到当前的Shader文件
        CurShader = Shader.Find("浅墨Shader编程/Volume9/ScreenWaterDropEffect");

        //判断是否支持屏幕特效
        if (!SystemInfo.supportsImageEffects)
        {
            enabled = false;
            return;
        }
    }

    //-------------------------------------【OnRenderImage()函数】------------------------------------  
    // 说明：此函数在当完成所有渲染图片后被调用，用来渲染图片后期效果
    //--------------------------------------------------------------------------------------------------------
    void OnRenderImage(RenderTexture sourceTexture, RenderTexture destTexture)
    {
        //着色器实例不为空，就进行参数设置
        if (CurShader != null)
        {
            //时间的变化
            TimeX += Time.deltaTime;
            //时间大于100，便置0，保证可以循环
            if (TimeX > 100) TimeX = 0;

            //设置Shader中其他的外部变量
            material.SetFloat("_CurTime", TimeX);
            material.SetFloat("_Distortion", Distortion);
            material.SetFloat("_SizeX", SizeX);
            material.SetFloat("_SizeY", SizeY);
            material.SetFloat("_DropSpeed", DropSpeed);
            material.SetTexture("_ScreenWaterDropTex", ScreenWaterDropTex);

            //拷贝源纹理到目标渲染纹理，加上我们的材质效果
            Graphics.Blit(sourceTexture, destTexture, material);
        }
        //着色器实例为空，直接拷贝屏幕上的效果。此情况下是没有实现屏幕特效的
        else
        {
            //直接拷贝源纹理到目标渲染纹理
            Graphics.Blit(sourceTexture, destTexture);
        }


    }

    //-----------------------------------------【OnValidate()函数】--------------------------------------  
    // 说明：此函数在编辑器中该脚本的某个值发生了改变后被调用
    //--------------------------------------------------------------------------------------------------------
    void OnValidate()
    {
        ChangeDistortion = Distortion;
        ChangeSizeX = SizeX;
        ChangeSizeY = SizeY;
        ChangeDropSpeed = DropSpeed;
    }


    //-----------------------------------------【Update()函数】------------------------------------------  
    // 说明：此函数在每一帧中都会被调用
    //-------------------------------------------------------------------------------------------------------- 
    void Update()
    {
        //若程序在运行，进行赋值
        if (Application.isPlaying)
        {
            //赋值
            Distortion = ChangeDistortion;
            SizeX = ChangeSizeX;
            SizeY = ChangeSizeY;
            DropSpeed = ChangeDropSpeed;
        }
        //找到对应的Shader文件，和纹理素材
#if UNITY_EDITOR
        if (Application.isPlaying != true)
        {
            CurShader = Shader.Find("浅墨Shader编程/Volume9/ScreenWaterDropEffect");
            ScreenWaterDropTex = Resources.Load("ScreenWaterDrop") as Texture2D;

        }
#endif

    }

    //-----------------------------------------【OnDisable()函数】---------------------------------------  
    // 说明：当对象变为不可用或非激活状态时此函数便被调用  
    //--------------------------------------------------------------------------------------------------------
    void OnDisable()
    {
        if (CurMaterial)
        {
            //立即销毁材质实例
            DestroyImmediate(CurMaterial);
        }

    }
}


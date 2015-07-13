using UnityEngine;
using System.Collections;
[ExecuteInEditMode]
public class DOF_PP : MonoBehaviour
{
    #region Variables
    public Shader curShader;
    private Material curMaterial;
    public int _Radius = 3;
    public float _Pixel = 0.002f;
    public float _Depth = 0;
    public float _DepthClip = 0;
    public int _Foward_back = 1;

    public RenderTexture tempRtA = null;
    #endregion

    #region Properties
    Material material
    {
        get
        {
            if (curMaterial == null)
            {
                curMaterial = new Material(curShader);
                curMaterial.hideFlags = HideFlags.HideAndDontSave;
            }
            return curMaterial;
        }
    }
    #endregion

    void Start()
    {
        if (!SystemInfo.supportsImageEffects)
        {
            enabled = false;
            return;
        }

        if (!curShader && !curShader.isSupported)
        {
            enabled = false;
        }
    }

    void OnRenderImage(RenderTexture sourceTexture, RenderTexture destTexture)
    {
        if (curShader != null)
        {
            tempRtA = new RenderTexture(Screen.width / 4, Screen.height / 4, 0);
            tempRtA.hideFlags = HideFlags.DontSave;
            Graphics.Blit(sourceTexture, destTexture, material);
      //      Graphics.Blit(tempRtA, destTexture, material);//换 material
      //      Graphics.Blit(destTexture, tempRtA, material);//换 material
            //       Graphics.Blit(destTexture, material);
        }
        else
        {
            Graphics.Blit(sourceTexture, destTexture);
        }
    }
    void Update()
    {
        material.SetFloat("_Radius", _Radius);
        material.SetFloat("_Pixel", _Pixel);
        material.SetFloat("_Depth", _Depth);
        material.SetFloat("_DepthClip", _DepthClip);
        
        material.SetInt("_Foward_back", _Foward_back);

    }
    void OnDisable()
    {
        if (curMaterial)
        {
            DestroyImmediate(curMaterial);
        }
    }
}




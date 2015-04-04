using UnityEngine;
using System.Collections;
[ExecuteInEditMode]
public class ComputerFault : MonoBehaviour
{
    public Shader curShader;
    private Material curMaterial;
    public int Step = 50;
    public int Speed = 1;
    public int Black = 0;//0/1
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
            Graphics.Blit(sourceTexture, destTexture, material);
        }
        else
        {
            Graphics.Blit(sourceTexture, destTexture);
        }
    }
    void Update()
    {
        material.SetFloat("_Step", Step);
        material.SetFloat("_Speed", Speed);
        material.SetFloat("_Black", Black);
    }
    void OnDisable()
    {
        if (curMaterial)
        {
            DestroyImmediate(curMaterial);
        }
    }
}

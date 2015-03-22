/*Hi ,I'm Lin Dong
 *this is an effect about HDR & Bloom
 *if you want to have a good vision, you can turn Color Space to the linear space
 *then hdr can have perfect effect
 * this .cs is used in camera
 */


using UnityEngine;
using System.Collections;
[ExecuteInEditMode]
public class HDRGlow : MonoBehaviour {
    #region Variables
    public Shader curShader;
    private Material curMaterial;
    public float exp = 0.4f;
    public float bm = 0.4f;
    public int inten = 512;
    public float lum = 1f;
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
            material.SetFloat("_Exp", exp);
            material.SetFloat("_BM", bm);
            material.SetFloat("_Inten", inten);
            material.SetFloat("_Lum", lum);
            Graphics.Blit(sourceTexture, destTexture, material);
        }
        else
        {
            Graphics.Blit(sourceTexture, destTexture);
        }
    }
    void OnDisable()
    {
        if (curMaterial)
        {
            DestroyImmediate(curMaterial);
        }
    }
}




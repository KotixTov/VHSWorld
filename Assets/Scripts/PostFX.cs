using System;
using Unity.VisualScripting;
using UnityEngine;

public class PostFX : MonoBehaviour
{
    [SerializeField] private Material fXMaterial;

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (fXMaterial == null)
        {
            return;
        }
        
        Graphics.Blit(source, destination, fXMaterial);
    }
}

using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MaterialsSetup : MonoBehaviour
{
    [SerializeField] private Material[] materials;

    [ContextMenu("Set Materials")]
    public void SetMaterials()
    {
        SetChildrenMaterials(transform);
    }
    
    private void SetChildrenMaterials(Transform parent)
    {
        for (int i = 0; i < parent.childCount; i++)
        {
            if (parent.GetChild(i).TryGetComponent<Renderer>(out var childRenderer))
            {
                var replaceMaterials = new Material[childRenderer.materials.Length];
                
                for (var j = 0; j < childRenderer.materials.Length; j++)
                {
                    var material = childRenderer.sharedMaterials[j];
                    if (TryGetMaterialByName(material.name, out var outMaterial))
                    {
                        replaceMaterials[j] = outMaterial;
                    }
                }

                childRenderer.sharedMaterials = replaceMaterials;
            }

            SetChildrenMaterials(parent.GetChild(i));
        }
    }

    private bool TryGetMaterialByName(string name, out Material outMaterial)
    {
        name = name.Remove(name.IndexOf(" (Instance)"));
        foreach (var material in materials)
        {
            if (material.name == name)
            {
                outMaterial = material;
                return true;
            }
        }

        outMaterial = null;
        return false;
    }
}

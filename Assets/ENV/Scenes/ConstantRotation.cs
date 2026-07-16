using UnityEngine;
[ExecuteAlways]
public class ConstantRotation : MonoBehaviour
{
    public bool Active;
    public float Speed = 2;
    void Update()
    {
        if (Active)
        {
            transform.Rotate(Vector3.up * Speed * Time.deltaTime, Space.Self);
        }
      
    }
}

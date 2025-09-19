using UnityEngine;

namespace AlienExperiment
{
    /// <summary>
    /// Basic interactable resource that can be collected
    /// </summary>
    public class CollectableResource : MonoBehaviour, IInteractable
    {
        [Header("Resource Data")]
        [SerializeField] private ItemData resourceData;
        [SerializeField] private int quantity = 1;
        [SerializeField] private float respawnTime = 0f; // 0 = no respawn
        
        [Header("Visual Effects")]
        [SerializeField] private GameObject collectEffect;
        [SerializeField] private AudioClip collectSound;
        
        private bool isCollected = false;
        private float respawnTimer = 0f;
        
        public string GetInteractionText()
        {
            if (isCollected) return "";
            return $"Collect {resourceData.itemName}";
        }
        
        public void Interact(PlayerController player)
        {
            if (isCollected) return;
            
            var inventoryManager = FindObjectOfType<InventoryManager>();
            if (inventoryManager != null)
            {
                InventoryItem item = new InventoryItem(resourceData, quantity);
                
                if (inventoryManager.AddItem(item))
                {
                    CollectResource();
                }
                else
                {
                    Debug.Log("Inventory full!");
                }
            }
        }
        
        private void CollectResource()
        {
            isCollected = true;
            
            // Play effects
            if (collectEffect != null)
            {
                Instantiate(collectEffect, transform.position, Quaternion.identity);
            }
            
            if (collectSound != null)
            {
                AudioSource.PlayClipAtPoint(collectSound, transform.position);
            }
            
            // Hide the resource
            GetComponent<Renderer>().enabled = false;
            GetComponent<Collider>().enabled = false;
            
            // Set up respawn if applicable
            if (respawnTime > 0)
            {
                respawnTimer = respawnTime;
            }
            else
            {
                Destroy(gameObject);
            }
        }
        
        private void Update()
        {
            if (isCollected && respawnTime > 0)
            {
                respawnTimer -= Time.deltaTime;
                
                if (respawnTimer <= 0)
                {
                    RespawnResource();
                }
            }
        }
        
        private void RespawnResource()
        {
            isCollected = false;
            GetComponent<Renderer>().enabled = true;
            GetComponent<Collider>().enabled = true;
        }
    }
}
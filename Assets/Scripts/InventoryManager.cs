using UnityEngine;
using System.Collections.Generic;

namespace AlienExperiment
{
    /// <summary>
    /// Inventory system for survival game with crafting support
    /// </summary>
    public class InventoryManager : MonoBehaviour
    {
        [Header("Inventory Settings")]
        [SerializeField] private int maxSlots = 20;
        [SerializeField] private GameObject inventoryUI;
        [SerializeField] private KeyCode inventoryKey = KeyCode.I;
        
        private List<InventoryItem> items = new List<InventoryItem>();
        private bool isInventoryOpen = false;
        
        public static System.Action<List<InventoryItem>> OnInventoryChanged;
        public static System.Action<bool> OnInventoryToggle;
        
        private void Update()
        {
            if (Input.GetKeyDown(inventoryKey))
            {
                ToggleInventory();
            }
        }
        
        public bool AddItem(InventoryItem item)
        {
            // Check if we can stack with existing item
            for (int i = 0; i < items.Count; i++)
            {
                if (items[i].itemData.itemID == item.itemData.itemID && items[i].CanStack())
                {
                    items[i].quantity += item.quantity;
                    OnInventoryChanged?.Invoke(items);
                    return true;
                }
            }
            
            // Add as new item if we have space
            if (items.Count < maxSlots)
            {
                items.Add(item);
                OnInventoryChanged?.Invoke(items);
                return true;
            }
            
            return false; // Inventory full
        }
        
        public bool RemoveItem(string itemID, int quantity = 1)
        {
            for (int i = 0; i < items.Count; i++)
            {
                if (items[i].itemData.itemID == itemID)
                {
                    items[i].quantity -= quantity;
                    
                    if (items[i].quantity <= 0)
                    {
                        items.RemoveAt(i);
                    }
                    
                    OnInventoryChanged?.Invoke(items);
                    return true;
                }
            }
            
            return false;
        }
        
        public int GetItemCount(string itemID)
        {
            foreach (var item in items)
            {
                if (item.itemData.itemID == itemID)
                {
                    return item.quantity;
                }
            }
            return 0;
        }
        
        public bool HasItem(string itemID, int requiredQuantity = 1)
        {
            return GetItemCount(itemID) >= requiredQuantity;
        }
        
        public void ToggleInventory()
        {
            isInventoryOpen = !isInventoryOpen;
            
            if (inventoryUI != null)
            {
                inventoryUI.SetActive(isInventoryOpen);
            }
            
            // Toggle cursor
            if (isInventoryOpen)
            {
                Cursor.lockState = CursorLockMode.None;
                Cursor.visible = true;
            }
            else
            {
                Cursor.lockState = CursorLockMode.Locked;
                Cursor.visible = false;
            }
            
            OnInventoryToggle?.Invoke(isInventoryOpen);
        }
        
        public List<InventoryItem> GetItems()
        {
            return new List<InventoryItem>(items);
        }
        
        public void UseItem(string itemID)
        {
            foreach (var item in items)
            {
                if (item.itemData.itemID == itemID && item.itemData.isConsumable)
                {
                    item.itemData.Use();
                    RemoveItem(itemID, 1);
                    break;
                }
            }
        }
    }
    
    [System.Serializable]
    public class InventoryItem
    {
        public ItemData itemData;
        public int quantity;
        
        public InventoryItem(ItemData data, int qty = 1)
        {
            itemData = data;
            quantity = qty;
        }
        
        public bool CanStack()
        {
            return itemData.isStackable && quantity < itemData.maxStackSize;
        }
    }
    
    [CreateAssetMenu(fileName = "New Item", menuName = "Alien Experiment/Item Data")]
    public class ItemData : ScriptableObject
    {
        [Header("Basic Info")]
        public string itemID;
        public string itemName;
        public string description;
        public Sprite icon;
        
        [Header("Properties")]
        public ItemType itemType;
        public bool isStackable = true;
        public int maxStackSize = 10;
        public bool isConsumable = false;
        
        [Header("Survival Effects")]
        public float hungerRestore = 0f;
        public float thirstRestore = 0f;
        public float temperatureRestore = 0f;
        public float energyRestore = 0f;
        
        [Header("Crafting")]
        public bool isCraftable = false;
        public List<CraftingRecipe> craftingRecipes = new List<CraftingRecipe>();
        
        public void Use()
        {
            if (isConsumable)
            {
                SurvivalManager survivalManager = FindObjectOfType<SurvivalManager>();
                if (survivalManager != null)
                {
                    if (hungerRestore > 0)
                        survivalManager.ModifyStat(SurvivalManager.SurvivalStat.Hunger, hungerRestore);
                    if (thirstRestore > 0)
                        survivalManager.ModifyStat(SurvivalManager.SurvivalStat.Thirst, thirstRestore);
                    if (temperatureRestore > 0)
                        survivalManager.ModifyStat(SurvivalManager.SurvivalStat.Temperature, temperatureRestore);
                    if (energyRestore > 0)
                        survivalManager.ModifyStat(SurvivalManager.SurvivalStat.Energy, energyRestore);
                }
                
                Debug.Log($"Used {itemName}");
            }
        }
    }
    
    public enum ItemType
    {
        Food,
        Water,
        Tool,
        Material,
        Clothing,
        Fuel,
        Medicine,
        AlienArtifact
    }
    
    [System.Serializable]
    public class CraftingRecipe
    {
        public string recipeName;
        public List<CraftingIngredient> ingredients;
        public ItemData result;
        public int resultQuantity = 1;
        
        public bool CanCraft(InventoryManager inventory)
        {
            foreach (var ingredient in ingredients)
            {
                if (!inventory.HasItem(ingredient.itemID, ingredient.quantity))
                {
                    return false;
                }
            }
            return true;
        }
    }
    
    [System.Serializable]
    public class CraftingIngredient
    {
        public string itemID;
        public int quantity;
    }
}
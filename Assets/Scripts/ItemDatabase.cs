using UnityEngine;

namespace AlienExperiment
{
    /// <summary>
    /// Creates default item data for testing the survival game
    /// </summary>
    [CreateAssetMenu(fileName = "Item Database", menuName = "Alien Experiment/Item Database")]
    public class ItemDatabase : ScriptableObject
    {
        [Header("Food Items")]
        public ItemData berries;
        public ItemData mushrooms;
        public ItemData meat;
        
        [Header("Water Sources")]
        public ItemData freshWater;
        public ItemData dirtyWater;
        
        [Header("Tools")]
        public ItemData stick;
        public ItemData stone;
        public ItemData knife;
        
        [Header("Materials")]
        public ItemData wood;
        public ItemData fiber;
        public ItemData leaves;
        
        [Header("Alien Artifacts")]
        public ItemData alienDevice;
        public ItemData memoryFragment;
        public ItemData energyCrystal;
        
        private void OnEnable()
        {
            CreateDefaultItems();
        }
        
        private void CreateDefaultItems()
        {
            // This would typically be done in the Unity Inspector
            // but we can provide code examples for the items
        }
        
        public static ItemData CreateBerries()
        {
            var berries = CreateInstance<ItemData>();
            berries.itemID = "berries";
            berries.itemName = "Wild Berries";
            berries.description = "Sweet berries found growing on bushes. Provides sustenance but should be eaten in moderation.";
            berries.itemType = ItemType.Food;
            berries.isStackable = true;
            berries.maxStackSize = 10;
            berries.isConsumable = true;
            berries.hungerRestore = 20f;
            berries.thirstRestore = 5f;
            return berries;
        }
        
        public static ItemData CreateFreshWater()
        {
            var water = CreateInstance<ItemData>();
            water.itemID = "fresh_water";
            water.itemName = "Fresh Water";
            water.description = "Clean, drinkable water from a natural spring.";
            water.itemType = ItemType.Water;
            water.isStackable = true;
            water.maxStackSize = 5;
            water.isConsumable = true;
            water.thirstRestore = 30f;
            return water;
        }
        
        public static ItemData CreateStick()
        {
            var stick = CreateInstance<ItemData>();
            stick.itemID = "stick";
            stick.itemName = "Wooden Stick";
            stick.description = "A sturdy branch that could be useful for crafting.";
            stick.itemType = ItemType.Material;
            stick.isStackable = true;
            stick.maxStackSize = 20;
            stick.isConsumable = false;
            return stick;
        }
        
        public static ItemData CreateAlienDevice()
        {
            var device = CreateInstance<ItemData>();
            device.itemID = "alien_device";
            device.itemName = "Strange Device";
            device.description = "A mysterious technological device that seems out of place in this forest. It emits a faint humming sound.";
            device.itemType = ItemType.AlienArtifact;
            device.isStackable = false;
            device.maxStackSize = 1;
            device.isConsumable = false;
            return device;
        }
    }
}
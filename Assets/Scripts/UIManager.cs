using UnityEngine;
using UnityEngine.UI;
using System.Collections.Generic;

namespace AlienExperiment
{
    /// <summary>
    /// Main UI manager for the survival game
    /// </summary>
    public class UIManager : MonoBehaviour
    {
        [Header("Survival UI")]
        [SerializeField] private Slider hungerSlider;
        [SerializeField] private Slider thirstSlider;
        [SerializeField] private Slider temperatureSlider;
        [SerializeField] private Slider energySlider;
        [SerializeField] private Text timeText;
        [SerializeField] private Text interactionText;
        
        [Header("Narrative UI")]
        [SerializeField] private GameObject narrativePanel;
        [SerializeField] private Text narrativeTitle;
        [SerializeField] private Text narrativeDescription;
        [SerializeField] private GameObject notePanel;
        [SerializeField] private Text noteContent;
        
        [Header("Choice UI")]
        [SerializeField] private GameObject choicePanel;
        [SerializeField] private Button survivalChoiceButton;
        [SerializeField] private Button rebellionChoiceButton;
        [SerializeField] private Text choiceDescription;
        
        [Header("Inventory UI")]
        [SerializeField] private GameObject inventoryPanel;
        [SerializeField] private Transform inventoryGrid;
        [SerializeField] private GameObject inventorySlotPrefab;
        
        [Header("Status Effects")]
        [SerializeField] private GameObject warningPanel;
        [SerializeField] private Text warningText;
        [SerializeField] private Image screenOverlay;
        
        private List<InventorySlotUI> inventorySlots = new List<InventorySlotUI>();
        private DayNightCycle dayNightCycle;
        
        private void Start()
        {
            InitializeUI();
            SubscribeToEvents();
        }
        
        private void OnDestroy()
        {
            UnsubscribeFromEvents();
        }
        
        private void InitializeUI()
        {
            dayNightCycle = FindObjectOfType<DayNightCycle>();
            
            // Initialize survival sliders
            if (hungerSlider != null) hungerSlider.value = 1f;
            if (thirstSlider != null) thirstSlider.value = 1f;
            if (temperatureSlider != null) temperatureSlider.value = 1f;
            if (energySlider != null) energySlider.value = 1f;
            
            // Hide panels initially
            if (narrativePanel != null) narrativePanel.SetActive(false);
            if (notePanel != null) notePanel.SetActive(false);
            if (choicePanel != null) choicePanel.SetActive(false);
            if (inventoryPanel != null) inventoryPanel.SetActive(false);
            if (warningPanel != null) warningPanel.SetActive(false);
            
            // Initialize choice buttons
            if (survivalChoiceButton != null)
            {
                survivalChoiceButton.onClick.AddListener(() => MakeChoice(ChoiceManager.PlayerChoice.ContinueSurvival));
            }
            
            if (rebellionChoiceButton != null)
            {
                rebellionChoiceButton.onClick.AddListener(() => MakeChoice(ChoiceManager.PlayerChoice.StartRebellion));
            }
            
            // Initialize inventory
            CreateInventorySlots();
        }
        
        private void SubscribeToEvents()
        {
            SurvivalManager.OnStatChanged += UpdateSurvivalStat;
            SurvivalManager.OnStatCritical += ShowCriticalWarning;
            PlayerController.OnInteractableChanged += UpdateInteractionText;
            NarrativeManager.OnNoteDiscovered += ShowNote;
            NarrativeManager.OnNarrativeStageChanged += OnNarrativeStageChanged;
            InventoryManager.OnInventoryChanged += UpdateInventoryUI;
            InventoryManager.OnInventoryToggle += ToggleInventoryUI;
            ChoiceManager.OnChoiceMade += OnChoiceMade;
        }
        
        private void UnsubscribeFromEvents()
        {
            SurvivalManager.OnStatChanged -= UpdateSurvivalStat;
            SurvivalManager.OnStatCritical -= ShowCriticalWarning;
            PlayerController.OnInteractableChanged -= UpdateInteractionText;
            NarrativeManager.OnNoteDiscovered -= ShowNote;
            NarrativeManager.OnNarrativeStageChanged -= OnNarrativeStageChanged;
            InventoryManager.OnInventoryChanged -= UpdateInventoryUI;
            InventoryManager.OnInventoryToggle -= ToggleInventoryUI;
            ChoiceManager.OnChoiceMade -= OnChoiceMade;
        }
        
        private void Update()
        {
            UpdateTimeDisplay();
        }
        
        private void UpdateSurvivalStat(SurvivalManager.SurvivalStat stat, float percentage)
        {
            Slider targetSlider = null;
            
            switch (stat)
            {
                case SurvivalManager.SurvivalStat.Hunger:
                    targetSlider = hungerSlider;
                    break;
                case SurvivalManager.SurvivalStat.Thirst:
                    targetSlider = thirstSlider;
                    break;
                case SurvivalManager.SurvivalStat.Temperature:
                    targetSlider = temperatureSlider;
                    break;
                case SurvivalManager.SurvivalStat.Energy:
                    targetSlider = energySlider;
                    break;
            }
            
            if (targetSlider != null)
            {
                targetSlider.value = percentage;
                
                // Change color based on percentage
                Image fillImage = targetSlider.fillRect.GetComponent<Image>();
                if (fillImage != null)
                {
                    if (percentage < 0.2f)
                        fillImage.color = Color.red;
                    else if (percentage < 0.4f)
                        fillImage.color = Color.yellow;
                    else
                        fillImage.color = Color.green;
                }
            }
        }
        
        private void ShowCriticalWarning(SurvivalManager.SurvivalStat stat)
        {
            if (warningPanel != null && warningText != null)
            {
                warningPanel.SetActive(true);
                warningText.text = $"CRITICAL: {stat} is dangerously low!";
                
                // Auto-hide after 3 seconds
                Invoke(nameof(HideWarning), 3f);
            }
        }
        
        private void HideWarning()
        {
            if (warningPanel != null)
            {
                warningPanel.SetActive(false);
            }
        }
        
        private void UpdateInteractionText(IInteractable interactable)
        {
            if (interactionText != null)
            {
                if (interactable != null)
                {
                    interactionText.text = $"[E] {interactable.GetInteractionText()}";
                    interactionText.gameObject.SetActive(true);
                }
                else
                {
                    interactionText.gameObject.SetActive(false);
                }
            }
        }
        
        private void UpdateTimeDisplay()
        {
            if (timeText != null && dayNightCycle != null)
            {
                timeText.text = dayNightCycle.GetTimeString();
            }
        }
        
        private void ShowNote(string noteContent)
        {
            if (notePanel != null && this.noteContent != null)
            {
                this.noteContent.text = noteContent;
                notePanel.SetActive(true);
                
                // Auto-hide after 5 seconds or wait for input
                Invoke(nameof(HideNote), 5f);
            }
        }
        
        private void HideNote()
        {
            if (notePanel != null)
            {
                notePanel.SetActive(false);
            }
        }
        
        private void OnNarrativeStageChanged(int stage)
        {
            // Could show progression indicators or unlock new UI elements
            Debug.Log($"Narrative stage changed to: {stage}");
        }
        
        private void CreateInventorySlots()
        {
            if (inventoryGrid == null || inventorySlotPrefab == null) return;
            
            // Create 20 inventory slots
            for (int i = 0; i < 20; i++)
            {
                GameObject slotObject = Instantiate(inventorySlotPrefab, inventoryGrid);
                InventorySlotUI slotUI = slotObject.GetComponent<InventorySlotUI>();
                
                if (slotUI != null)
                {
                    inventorySlots.Add(slotUI);
                }
            }
        }
        
        private void UpdateInventoryUI(List<InventoryItem> items)
        {
            // Clear all slots
            foreach (var slot in inventorySlots)
            {
                slot.ClearSlot();
            }
            
            // Update slots with items
            for (int i = 0; i < items.Count && i < inventorySlots.Count; i++)
            {
                inventorySlots[i].SetItem(items[i]);
            }
        }
        
        private void ToggleInventoryUI(bool isOpen)
        {
            if (inventoryPanel != null)
            {
                inventoryPanel.SetActive(isOpen);
            }
        }
        
        public void ShowChoiceSystem()
        {
            if (choicePanel != null)
            {
                choicePanel.SetActive(true);
                
                if (choiceDescription != null)
                {
                    choiceDescription.text = "You've discovered the truth about your situation. What will you do?";
                }
            }
        }
        
        private void MakeChoice(ChoiceManager.PlayerChoice choice)
        {
            var choiceManager = FindObjectOfType<ChoiceManager>();
            if (choiceManager != null)
            {
                choiceManager.MakeChoice(choice);
            }
            
            if (choicePanel != null)
            {
                choicePanel.SetActive(false);
            }
        }
        
        private void OnChoiceMade(ChoiceManager.PlayerChoice choice)
        {
            Debug.Log($"UI: Player made choice: {choice}");
        }
        
        public void ShowNarrativeEvent(string title, string description)
        {
            if (narrativePanel != null && narrativeTitle != null && narrativeDescription != null)
            {
                narrativeTitle.text = title;
                narrativeDescription.text = description;
                narrativePanel.SetActive(true);
                
                // Auto-hide after 5 seconds
                Invoke(nameof(HideNarrativeEvent), 5f);
            }
        }
        
        private void HideNarrativeEvent()
        {
            if (narrativePanel != null)
            {
                narrativePanel.SetActive(false);
            }
        }
        
        public void ApplyScreenEffect(Color tint, float duration)
        {
            if (screenOverlay != null)
            {
                screenOverlay.color = tint;
                screenOverlay.gameObject.SetActive(true);
                
                Invoke(nameof(ClearScreenEffect), duration);
            }
        }
        
        private void ClearScreenEffect()
        {
            if (screenOverlay != null)
            {
                screenOverlay.gameObject.SetActive(false);
            }
        }
    }
    
    /// <summary>
    /// UI component for individual inventory slots
    /// </summary>
    public class InventorySlotUI : MonoBehaviour
    {
        [SerializeField] private Image itemIcon;
        [SerializeField] private Text quantityText;
        [SerializeField] private Button slotButton;
        
        private InventoryItem currentItem;
        
        private void Start()
        {
            if (slotButton != null)
            {
                slotButton.onClick.AddListener(OnSlotClicked);
            }
        }
        
        public void SetItem(InventoryItem item)
        {
            currentItem = item;
            
            if (item != null)
            {
                if (itemIcon != null)
                {
                    itemIcon.sprite = item.itemData.icon;
                    itemIcon.gameObject.SetActive(true);
                }
                
                if (quantityText != null)
                {
                    quantityText.text = item.quantity > 1 ? item.quantity.ToString() : "";
                    quantityText.gameObject.SetActive(item.quantity > 1);
                }
            }
            else
            {
                ClearSlot();
            }
        }
        
        public void ClearSlot()
        {
            currentItem = null;
            
            if (itemIcon != null)
            {
                itemIcon.gameObject.SetActive(false);
            }
            
            if (quantityText != null)
            {
                quantityText.gameObject.SetActive(false);
            }
        }
        
        private void OnSlotClicked()
        {
            if (currentItem != null && currentItem.itemData.isConsumable)
            {
                var inventoryManager = FindObjectOfType<InventoryManager>();
                if (inventoryManager != null)
                {
                    inventoryManager.UseItem(currentItem.itemData.itemID);
                }
            }
        }
    }
}
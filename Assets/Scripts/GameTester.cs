using UnityEngine;

namespace AlienExperiment
{
    /// <summary>
    /// Debug and testing utilities for the alien experiment game
    /// </summary>
    public class GameTester : MonoBehaviour
    {
        [Header("Testing Controls")]
        [SerializeField] private bool enableTestingMode = true;
        [SerializeField] private bool showDebugInfo = true;
        [SerializeField] private KeyCode fastForwardKey = KeyCode.F;
        [SerializeField] private KeyCode addResourcesKey = KeyCode.G;
        [SerializeField] private KeyCode triggerAnomalyKey = KeyCode.T;
        [SerializeField] private KeyCode revealExperimentKey = KeyCode.Y;
        
        [Header("Quick Test Values")]
        [SerializeField] private float timeSpeedMultiplier = 5f;
        [SerializeField] private float resourceAmount = 50f;
        
        private SurvivalManager survivalManager;
        private InventoryManager inventoryManager;
        private NarrativeManager narrativeManager;
        private DayNightCycle dayNightCycle;
        private ChoiceManager choiceManager;
        
        private bool fastForwardActive = false;
        private float originalTimeScale;
        
        private void Start()
        {
            if (!enableTestingMode) return;
            
            originalTimeScale = Time.timeScale;
            
            // Find all managers
            survivalManager = FindObjectOfType<SurvivalManager>();
            inventoryManager = FindObjectOfType<InventoryManager>();
            narrativeManager = FindObjectOfType<NarrativeManager>();
            dayNightCycle = FindObjectOfType<DayNightCycle>();
            choiceManager = FindObjectOfType<ChoiceManager>();
            
            Debug.Log("Game Tester initialized - Testing mode enabled");
            LogTestingControls();
        }
        
        private void Update()
        {
            if (!enableTestingMode) return;
            
            HandleTestingInput();
            
            if (showDebugInfo)
            {
                DisplayDebugInfo();
            }
        }
        
        private void HandleTestingInput()
        {
            // Fast forward time
            if (Input.GetKeyDown(fastForwardKey))
            {
                ToggleFastForward();
            }
            
            // Add resources to survive
            if (Input.GetKeyDown(addResourcesKey))
            {
                AddSurvivalResources();
            }
            
            // Trigger anomaly
            if (Input.GetKeyDown(triggerAnomalyKey))
            {
                TriggerAnomaly();
            }
            
            // Reveal experiment immediately
            if (Input.GetKeyDown(revealExperimentKey))
            {
                RevealExperiment();
            }
            
            // Number keys for quick narrative stages
            if (Input.GetKeyDown(KeyCode.Alpha1))
            {
                SetNarrativeStage(1);
            }
            else if (Input.GetKeyDown(KeyCode.Alpha2))
            {
                SetNarrativeStage(2);
            }
            else if (Input.GetKeyDown(KeyCode.Alpha3))
            {
                SetNarrativeStage(3);
            }
        }
        
        private void ToggleFastForward()
        {
            fastForwardActive = !fastForwardActive;
            
            if (fastForwardActive)
            {
                Time.timeScale = timeSpeedMultiplier;
                Debug.Log($"Fast forward enabled - {timeSpeedMultiplier}x speed");
            }
            else
            {
                Time.timeScale = originalTimeScale;
                Debug.Log("Fast forward disabled - normal speed");
            }
        }
        
        private void AddSurvivalResources()
        {
            if (survivalManager != null)
            {
                survivalManager.ModifyStat(SurvivalManager.SurvivalStat.Hunger, resourceAmount);
                survivalManager.ModifyStat(SurvivalManager.SurvivalStat.Thirst, resourceAmount);
                survivalManager.ModifyStat(SurvivalManager.SurvivalStat.Temperature, resourceAmount);
                survivalManager.ModifyStat(SurvivalManager.SurvivalStat.Energy, resourceAmount);
                
                Debug.Log($"Added {resourceAmount} to all survival stats");
            }
        }
        
        private void TriggerAnomaly()
        {
            if (dayNightCycle != null)
            {
                dayNightCycle.TriggerTestAnomaly();
                Debug.Log("Anomaly triggered manually");
            }
        }
        
        private void RevealExperiment()
        {
            if (choiceManager != null)
            {
                choiceManager.EnableChoiceSystem();
                Debug.Log("Experiment revealed - choice system enabled");
            }
        }
        
        private void SetNarrativeStage(int stage)
        {
            Debug.Log($"Manually set narrative stage to {stage}");
            // This would require modifying NarrativeManager to have a public method
            // For now, we'll just log the intent
        }
        
        private void DisplayDebugInfo()
        {
            if (survivalManager == null) return;
            
            // Display survival stats in top-left corner
            string debugText = "=== DEBUG INFO ===\n";
            debugText += $"Hunger: {survivalManager.CurrentHunger:F1}/100\n";
            debugText += $"Thirst: {survivalManager.CurrentThirst:F1}/100\n";
            debugText += $"Temperature: {survivalManager.CurrentTemperature:F1}/100\n";
            debugText += $"Energy: {survivalManager.CurrentEnergy:F1}/100\n";
            
            if (dayNightCycle != null)
            {
                debugText += $"Time: {dayNightCycle.GetTimeString()}\n";
                debugText += $"Day: {(dayNightCycle.IsDay ? "Yes" : "No")}\n";
            }
            
            if (narrativeManager != null)
            {
                debugText += $"Narrative Stage: {narrativeManager.GetCurrentNarrativeStage()}\n";
                debugText += $"Experiment Revealed: {narrativeManager.IsExperimentRevealed()}\n";
            }
            
            if (choiceManager != null)
            {
                debugText += $"Choice System: {(choiceManager.IsChoiceSystemEnabled() ? "Enabled" : "Disabled")}\n";
                debugText += $"Current Choice: {choiceManager.GetCurrentChoice()}\n";
            }
            
            debugText += $"Time Scale: {Time.timeScale:F1}x\n";
            
            // Display using Unity's GUI system (simple but effective for debugging)
            // This would be better implemented with proper UI, but for testing this works
        }
        
        private void OnGUI()
        {
            if (!enableTestingMode || !showDebugInfo) return;
            
            GUI.color = Color.white;
            GUI.backgroundColor = new Color(0, 0, 0, 0.5f);
            
            GUIStyle style = new GUIStyle(GUI.skin.box);
            style.alignment = TextAnchor.UpperLeft;
            style.fontSize = 12;
            
            string debugText = GetDebugText();
            GUI.Box(new Rect(10, 10, 250, 300), debugText, style);
        }
        
        private string GetDebugText()
        {
            string debugText = "=== DEBUG INFO ===\n";
            
            if (survivalManager != null)
            {
                debugText += $"Hunger: {survivalManager.CurrentHunger:F1}/100\n";
                debugText += $"Thirst: {survivalManager.CurrentThirst:F1}/100\n";
                debugText += $"Temperature: {survivalManager.CurrentTemperature:F1}/100\n";
                debugText += $"Energy: {survivalManager.CurrentEnergy:F1}/100\n\n";
            }
            
            if (dayNightCycle != null)
            {
                debugText += $"Time: {dayNightCycle.GetTimeString()}\n";
                debugText += $"Day: {(dayNightCycle.IsDay ? "Yes" : "No")}\n\n";
            }
            
            if (narrativeManager != null)
            {
                debugText += $"Narrative Stage: {narrativeManager.GetCurrentNarrativeStage()}\n";
                debugText += $"Experiment Revealed: {narrativeManager.IsExperimentRevealed()}\n\n";
            }
            
            if (choiceManager != null)
            {
                debugText += $"Choice System: {(choiceManager.IsChoiceSystemEnabled() ? "Enabled" : "Disabled")}\n";
                debugText += $"Current Choice: {choiceManager.GetCurrentChoice()}\n\n";
            }
            
            debugText += $"Time Scale: {Time.timeScale:F1}x\n\n";
            
            debugText += "=== CONTROLS ===\n";
            debugText += $"[{fastForwardKey}] Fast Forward\n";
            debugText += $"[{addResourcesKey}] Add Resources\n";
            debugText += $"[{triggerAnomalyKey}] Trigger Anomaly\n";
            debugText += $"[{revealExperimentKey}] Reveal Experiment\n";
            debugText += "[1-3] Narrative Stages\n";
            
            return debugText;
        }
        
        private void LogTestingControls()
        {
            Debug.Log("=== TESTING CONTROLS ===");
            Debug.Log($"[{fastForwardKey}] Toggle Fast Forward ({timeSpeedMultiplier}x speed)");
            Debug.Log($"[{addResourcesKey}] Add {resourceAmount} to all survival stats");
            Debug.Log($"[{triggerAnomalyKey}] Manually trigger anomaly");
            Debug.Log($"[{revealExperimentKey}] Reveal experiment and enable choices");
            Debug.Log("[1-3] Skip to narrative stages");
            Debug.Log("[Ctrl+R] Restart game");
            Debug.Log("[Ctrl+Q] Quit game");
        }
        
        private void OnApplicationPause(bool pauseStatus)
        {
            if (pauseStatus && fastForwardActive)
            {
                Time.timeScale = originalTimeScale;
            }
        }
    }
}
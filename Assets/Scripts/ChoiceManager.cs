using UnityEngine;
using System.Collections.Generic;

namespace AlienExperiment
{
    /// <summary>
    /// Manages the choice system between survival and rebellion paths
    /// </summary>
    public class ChoiceManager : MonoBehaviour
    {
        [Header("Choice System")]
        [SerializeField] private GameObject choiceUI;
        [SerializeField] private bool choiceSystemEnabled = false;
        
        [Header("Ending Scenarios")]
        [SerializeField] private GameObject survivalEndingPrefab;
        [SerializeField] private GameObject rebellionSuccessPrefab;
        [SerializeField] private GameObject rebellionFailurePrefab;
        
        private PlayerChoice currentChoice = PlayerChoice.None;
        private bool choiceMade = false;
        private float rebellionProgress = 0f;
        
        public enum PlayerChoice
        {
            None,
            ContinueSurvival,
            StartRebellion
        }
        
        public static System.Action<PlayerChoice> OnChoiceMade;
        public static System.Action<float> OnRebellionProgressChanged;
        public static System.Action<EndingType> OnGameEnding;
        
        public enum EndingType
        {
            SurvivalSuccess,
            SurvivalFailure,
            RebellionSuccess,
            RebellionFailure
        }
        
        private void Start()
        {
            if (choiceUI != null)
            {
                choiceUI.SetActive(false);
            }
        }
        
        private void Update()
        {
            if (choiceSystemEnabled && !choiceMade)
            {
                HandleChoiceInput();
            }
            
            if (currentChoice == PlayerChoice.StartRebellion)
            {
                UpdateRebellionProgress();
            }
        }
        
        public void EnableChoiceSystem()
        {
            choiceSystemEnabled = true;
            
            if (choiceUI != null)
            {
                choiceUI.SetActive(true);
                
                // Enable cursor for UI interaction
                Cursor.lockState = CursorLockMode.None;
                Cursor.visible = true;
            }
            
            Debug.Log("Choice system enabled - You must choose your path!");
        }
        
        private void HandleChoiceInput()
        {
            // For testing purposes, use keyboard input
            if (Input.GetKeyDown(KeyCode.Alpha1))
            {
                MakeChoice(PlayerChoice.ContinueSurvival);
            }
            else if (Input.GetKeyDown(KeyCode.Alpha2))
            {
                MakeChoice(PlayerChoice.StartRebellion);
            }
        }
        
        public void MakeChoice(PlayerChoice choice)
        {
            if (choiceMade) return;
            
            currentChoice = choice;
            choiceMade = true;
            
            if (choiceUI != null)
            {
                choiceUI.SetActive(false);
            }
            
            // Return cursor control to player
            Cursor.lockState = CursorLockMode.Locked;
            Cursor.visible = false;
            
            OnChoiceMade?.Invoke(choice);
            
            switch (choice)
            {
                case PlayerChoice.ContinueSurvival:
                    StartSurvivalPath();
                    break;
                case PlayerChoice.StartRebellion:
                    StartRebellionPath();
                    break;
            }
            
            Debug.Log($"Player chose: {choice}");
        }
        
        private void StartSurvivalPath()
        {
            // Continue the survival simulation
            // Player needs to maintain stats for a certain period to "graduate"
            StartCoroutine(MonitorSurvivalSuccess());
        }
        
        private void StartRebellionPath()
        {
            // Player must sabotage the experiment and wake other subjects
            SpawnRebellionObjectives();
            
            // Add new UI elements for rebellion progress
            Debug.Log("Rebellion path started - Find and wake other test subjects!");
        }
        
        private System.Collections.IEnumerator MonitorSurvivalSuccess()
        {
            float survivalTimeNeeded = 300f; // 5 minutes of continued survival
            float startTime = Time.time;
            
            SurvivalManager survivalManager = FindObjectOfType<SurvivalManager>();
            
            while (Time.time - startTime < survivalTimeNeeded)
            {
                if (survivalManager != null)
                {
                    // Check if player is maintaining good stats
                    bool isHealthy = !survivalManager.IsStatCritical(SurvivalManager.SurvivalStat.Hunger) &&
                                   !survivalManager.IsStatCritical(SurvivalManager.SurvivalStat.Thirst) &&
                                   !survivalManager.IsStatCritical(SurvivalManager.SurvivalStat.Temperature) &&
                                   !survivalManager.IsStatCritical(SurvivalManager.SurvivalStat.Energy);
                    
                    if (!isHealthy)
                    {
                        // Failed survival path
                        TriggerEnding(EndingType.SurvivalFailure);
                        yield break;
                    }
                }
                
                yield return new WaitForSeconds(1f);
            }
            
            // Successfully survived
            TriggerEnding(EndingType.SurvivalSuccess);
        }
        
        private void SpawnRebellionObjectives()
        {
            // Spawn stasis pods with other test subjects
            GameObject[] stasisPods = GameObject.FindGameObjectsWithTag("StasisPod");
            
            foreach (var pod in stasisPods)
            {
                pod.SetActive(true);
                var podComponent = pod.GetComponent<StasisPod>();
                if (podComponent != null)
                {
                    podComponent.EnableInteraction();
                }
            }
            
            // Spawn control terminals
            GameObject[] controlTerminals = GameObject.FindGameObjectsWithTag("ControlTerminal");
            
            foreach (var terminal in controlTerminals)
            {
                terminal.SetActive(true);
            }
        }
        
        private void UpdateRebellionProgress()
        {
            // Calculate rebellion progress based on objectives completed
            int totalObjectives = GetTotalRebellionObjectives();
            int completedObjectives = GetCompletedRebellionObjectives();
            
            float newProgress = (float)completedObjectives / totalObjectives;
            
            if (newProgress != rebellionProgress)
            {
                rebellionProgress = newProgress;
                OnRebellionProgressChanged?.Invoke(rebellionProgress);
                
                if (rebellionProgress >= 1f)
                {
                    // All objectives completed
                    TriggerEnding(EndingType.RebellionSuccess);
                }
            }
        }
        
        private int GetTotalRebellionObjectives()
        {
            int total = 0;
            total += GameObject.FindGameObjectsWithTag("StasisPod").Length;
            total += GameObject.FindGameObjectsWithTag("ControlTerminal").Length;
            return total;
        }
        
        private int GetCompletedRebellionObjectives()
        {
            int completed = 0;
            
            // Count awakened subjects
            GameObject[] stasisPods = GameObject.FindGameObjectsWithTag("StasisPod");
            foreach (var pod in stasisPods)
            {
                var podComponent = pod.GetComponent<StasisPod>();
                if (podComponent != null && podComponent.IsAwakened())
                {
                    completed++;
                }
            }
            
            // Count sabotaged terminals
            GameObject[] terminals = GameObject.FindGameObjectsWithTag("ControlTerminal");
            foreach (var terminal in terminals)
            {
                var terminalComponent = terminal.GetComponent<ControlTerminal>();
                if (terminalComponent != null && terminalComponent.IsSabotaged())
                {
                    completed++;
                }
            }
            
            return completed;
        }
        
        public void TriggerEnding(EndingType endingType)
        {
            OnGameEnding?.Invoke(endingType);
            
            // Load appropriate ending scene or display ending UI
            switch (endingType)
            {
                case EndingType.SurvivalSuccess:
                    ShowSurvivalSuccessEnding();
                    break;
                case EndingType.SurvivalFailure:
                    ShowSurvivalFailureEnding();
                    break;
                case EndingType.RebellionSuccess:
                    ShowRebellionSuccessEnding();
                    break;
                case EndingType.RebellionFailure:
                    ShowRebellionFailureEnding();
                    break;
            }
        }
        
        private void ShowSurvivalSuccessEnding()
        {
            Debug.Log("ENDING: Survival Success - You've graduated from the experiment!");
            // Show ending cutscene or UI
        }
        
        private void ShowSurvivalFailureEnding()
        {
            Debug.Log("ENDING: Survival Failure - The experiment claims another failure...");
            // Show ending cutscene or UI
        }
        
        private void ShowRebellionSuccessEnding()
        {
            Debug.Log("ENDING: Rebellion Success - You've freed yourself and the other subjects!");
            // Show ending cutscene or UI
        }
        
        private void ShowRebellionFailureEnding()
        {
            Debug.Log("ENDING: Rebellion Failure - The simulation resets, but you retain fragments of memory...");
            // Show ending cutscene or UI
        }
        
        public PlayerChoice GetCurrentChoice()
        {
            return currentChoice;
        }
        
        public float GetRebellionProgress()
        {
            return rebellionProgress;
        }
        
        public bool IsChoiceSystemEnabled()
        {
            return choiceSystemEnabled;
        }
    }
    
    /// <summary>
    /// Stasis pod that can be interacted with during rebellion path
    /// </summary>
    public class StasisPod : MonoBehaviour, IInteractable
    {
        [SerializeField] private bool isAwakened = false;
        [SerializeField] private bool canInteract = false;
        [SerializeField] private GameObject subjectPrefab;
        
        public string GetInteractionText()
        {
            if (!canInteract) return "";
            return isAwakened ? "Subject Awakened" : "Wake Test Subject";
        }
        
        public void Interact(PlayerController player)
        {
            if (canInteract && !isAwakened)
            {
                AwakenSubject();
            }
        }
        
        public void EnableInteraction()
        {
            canInteract = true;
        }
        
        private void AwakenSubject()
        {
            isAwakened = true;
            
            if (subjectPrefab != null)
            {
                Instantiate(subjectPrefab, transform.position + Vector3.forward, Quaternion.identity);
            }
            
            // Visual feedback
            var renderer = GetComponent<Renderer>();
            if (renderer != null)
            {
                renderer.material.color = Color.green;
            }
            
            Debug.Log("Test subject awakened!");
        }
        
        public bool IsAwakened()
        {
            return isAwakened;
        }
    }
    
    /// <summary>
    /// Control terminal for sabotage during rebellion path
    /// </summary>
    public class ControlTerminal : MonoBehaviour, IInteractable
    {
        [SerializeField] private bool isSabotaged = false;
        [SerializeField] private bool canInteract = false;
        
        public string GetInteractionText()
        {
            if (!canInteract) return "";
            return isSabotaged ? "Terminal Sabotaged" : "Sabotage Terminal";
        }
        
        public void Interact(PlayerController player)
        {
            if (canInteract && !isSabotaged)
            {
                SabotageTerminal();
            }
        }
        
        public void EnableInteraction()
        {
            canInteract = true;
        }
        
        private void SabotageTerminal()
        {
            isSabotaged = true;
            
            // Visual feedback
            var renderer = GetComponent<Renderer>();
            if (renderer != null)
            {
                renderer.material.color = Color.red;
            }
            
            Debug.Log("Control terminal sabotaged!");
        }
        
        public bool IsSabotaged()
        {
            return isSabotaged;
        }
    }
}
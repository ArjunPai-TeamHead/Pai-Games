using UnityEngine;
using System.Collections.Generic;
using System.Collections;

namespace AlienExperiment
{
    /// <summary>
    /// Manages the progressive narrative discovery and alien experiment revelation
    /// </summary>
    public class NarrativeManager : MonoBehaviour
    {
        [Header("Narrative Triggers")]
        [SerializeField] private float survivalTimeThreshold1 = 300f; // 5 minutes for first hint
        [SerializeField] private float survivalTimeThreshold2 = 900f; // 15 minutes for major revelation
        [SerializeField] private float survivalTimeThreshold3 = 1800f; // 30 minutes for full truth
        
        [Header("Discovery System")]
        [SerializeField] private List<NarrativeEvent> narrativeEvents;
        [SerializeField] private GameObject notesPrefab;
        [SerializeField] private Transform[] noteSpawnPoints;
        
        [Header("Glitch Effects")]
        [SerializeField] private Material glitchMaterial;
        [SerializeField] private float glitchIntensity = 0.1f;
        [SerializeField] private AudioSource glitchAudioSource;
        
        private float gameStartTime;
        private int currentNarrativeStage = 0;
        private List<string> discoveredNotes = new List<string>();
        private bool experimentRevealed = false;
        
        public static System.Action<string> OnNoteDiscovered;
        public static System.Action<int> OnNarrativeStageChanged;
        public static System.Action OnExperimentRevealed;
        
        private void Start()
        {
            gameStartTime = Time.time;
            InitializeNarrativeEvents();
        }
        
        private void Update()
        {
            CheckNarrativeProgression();
        }
        
        private void InitializeNarrativeEvents()
        {
            if (narrativeEvents == null)
            {
                narrativeEvents = new List<NarrativeEvent>
                {
                    new NarrativeEvent
                    {
                        eventID = "first_anomaly",
                        triggerTime = survivalTimeThreshold1,
                        title = "Strange Observations",
                        description = "The trees... they seem too perfect. Too symmetrical. And the wildlife moves in patterns that feel almost... programmed.",
                        isTriggered = false
                    },
                    new NarrativeEvent
                    {
                        eventID = "electronic_interference",
                        triggerTime = survivalTimeThreshold2,
                        title = "Electronic Disturbance",
                        description = "A strange humming fills the air. Looking up, you notice what looks like a bird, but its movement is too mechanical, too precise.",
                        isTriggered = false
                    },
                    new NarrativeEvent
                    {
                        eventID = "barrier_discovery",
                        triggerTime = survivalTimeThreshold3,
                        title = "The Truth Revealed",
                        description = "Walking toward the forest edge, your hand touches something invisible but solid. A shimmer in the air reveals a dome-like barrier. This isn't a forest. This is a cage.",
                        isTriggered = false
                    }
                };
            }
        }
        
        private void CheckNarrativeProgression()
        {
            float survivalTime = Time.time - gameStartTime;
            
            foreach (var narrativeEvent in narrativeEvents)
            {
                if (!narrativeEvent.isTriggered && survivalTime >= narrativeEvent.triggerTime)
                {
                    TriggerNarrativeEvent(narrativeEvent);
                }
            }
        }
        
        private void TriggerNarrativeEvent(NarrativeEvent narrativeEvent)
        {
            narrativeEvent.isTriggered = true;
            currentNarrativeStage++;
            
            Debug.Log($"Narrative Event Triggered: {narrativeEvent.title}");
            
            // Show narrative event to player
            StartCoroutine(DisplayNarrativeEvent(narrativeEvent));
            
            // Spawn related environmental clues
            SpawnEnvironmentalClue(narrativeEvent);
            
            // Update game environment based on stage
            UpdateEnvironmentForStage(currentNarrativeStage);
            
            OnNarrativeStageChanged?.Invoke(currentNarrativeStage);
            
            if (narrativeEvent.eventID == "barrier_discovery")
            {
                RevealExperiment();
            }
        }
        
        private IEnumerator DisplayNarrativeEvent(NarrativeEvent narrativeEvent)
        {
            // TODO: Display UI for narrative event
            // For now, we'll use debug logs and could trigger screen effects
            
            yield return StartCoroutine(CreateGlitchEffect());
            
            // This would show a UI panel with the narrative text
            Debug.Log($"NARRATIVE: {narrativeEvent.description}");
            
            yield return new WaitForSeconds(3f);
        }
        
        private IEnumerator CreateGlitchEffect()
        {
            // Visual glitch effect
            if (Camera.main != null)
            {
                GameObject glitchObject = new GameObject("GlitchEffect");
                var glitchRenderer = glitchObject.AddComponent<Renderer>();
                
                if (glitchMaterial != null)
                {
                    glitchRenderer.material = glitchMaterial;
                }
                
                // Audio glitch
                if (glitchAudioSource != null)
                {
                    glitchAudioSource.Play();
                }
                
                yield return new WaitForSeconds(2f);
                
                Destroy(glitchObject);
            }
        }
        
        private void SpawnEnvironmentalClue(NarrativeEvent narrativeEvent)
        {
            if (notesPrefab != null && noteSpawnPoints.Length > 0)
            {
                // Choose a random spawn point
                int spawnIndex = Random.Range(0, noteSpawnPoints.Length);
                Transform spawnPoint = noteSpawnPoints[spawnIndex];
                
                // Spawn note with narrative content
                GameObject note = Instantiate(notesPrefab, spawnPoint.position, spawnPoint.rotation);
                var noteComponent = note.GetComponent<EnvironmentalNote>();
                
                if (noteComponent != null)
                {
                    noteComponent.SetNoteContent(narrativeEvent.title, narrativeEvent.description);
                }
            }
        }
        
        private void UpdateEnvironmentForStage(int stage)
        {
            switch (stage)
            {
                case 1:
                    // Increase environmental anomalies
                    var dayNightCycle = FindObjectOfType<DayNightCycle>();
                    if (dayNightCycle != null)
                    {
                        // Increase anomaly frequency
                    }
                    break;
                    
                case 2:
                    // Start showing more obvious artificial elements
                    ActivateArtificialElements();
                    break;
                    
                case 3:
                    // Full experiment mode - barriers visible, drones revealed
                    RevealAllAlienTechnology();
                    break;
            }
        }
        
        private void ActivateArtificialElements()
        {
            // Find and activate hidden technological elements
            GameObject[] hiddenTech = GameObject.FindGameObjectsWithTag("HiddenTechnology");
            foreach (var tech in hiddenTech)
            {
                tech.SetActive(true);
            }
        }
        
        private void RevealAllAlienTechnology()
        {
            // Make all alien technology visible
            GameObject[] alienTech = GameObject.FindGameObjectsWithTag("AlienTechnology");
            foreach (var tech in alienTech)
            {
                var renderer = tech.GetComponent<Renderer>();
                if (renderer != null)
                {
                    renderer.enabled = true;
                }
            }
        }
        
        private void RevealExperiment()
        {
            experimentRevealed = true;
            OnExperimentRevealed?.Invoke();
            
            // Enable choice system
            var choiceManager = FindObjectOfType<ChoiceManager>();
            if (choiceManager != null)
            {
                choiceManager.EnableChoiceSystem();
            }
        }
        
        public void DiscoverNote(string noteID, string noteContent)
        {
            if (!discoveredNotes.Contains(noteID))
            {
                discoveredNotes.Add(noteID);
                OnNoteDiscovered?.Invoke(noteContent);
                
                Debug.Log($"Note Discovered: {noteID}");
            }
        }
        
        public int GetCurrentNarrativeStage()
        {
            return currentNarrativeStage;
        }
        
        public bool IsExperimentRevealed()
        {
            return experimentRevealed;
        }
        
        public List<string> GetDiscoveredNotes()
        {
            return new List<string>(discoveredNotes);
        }
        
        [System.Serializable]
        public class NarrativeEvent
        {
            public string eventID;
            public float triggerTime;
            public string title;
            public string description;
            public bool isTriggered;
        }
    }
    
    /// <summary>
    /// Component for environmental notes that can be discovered
    /// </summary>
    public class EnvironmentalNote : MonoBehaviour, IInteractable
    {
        [Header("Note Content")]
        [SerializeField] private string noteTitle;
        [SerializeField] private string noteContent;
        [SerializeField] private bool isDiscovered = false;
        
        private NarrativeManager narrativeManager;
        
        private void Start()
        {
            narrativeManager = FindObjectOfType<NarrativeManager>();
        }
        
        public string GetInteractionText()
        {
            return isDiscovered ? "Read Note (Already Read)" : "Read Note";
        }
        
        public void Interact(PlayerController player)
        {
            if (!isDiscovered)
            {
                isDiscovered = true;
                
                if (narrativeManager != null)
                {
                    narrativeManager.DiscoverNote(noteTitle, noteContent);
                }
                
                // Visual feedback
                var renderer = GetComponent<Renderer>();
                if (renderer != null)
                {
                    renderer.material.color = Color.gray; // Mark as read
                }
            }
        }
        
        public void SetNoteContent(string title, string content)
        {
            noteTitle = title;
            noteContent = content;
        }
    }
}
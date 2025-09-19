using UnityEngine;
using UnityEngine.SceneManagement;

namespace AlienExperiment
{
    /// <summary>
    /// Main game manager that coordinates all systems
    /// </summary>
    public class GameManager : MonoBehaviour
    {
        [Header("Game State")]
        [SerializeField] private bool gameStarted = false;
        [SerializeField] private bool gamePaused = false;
        [SerializeField] private bool gameEnded = false;
        
        [Header("Managers")]
        [SerializeField] private SurvivalManager survivalManager;
        [SerializeField] private PlayerController playerController;
        [SerializeField] private DayNightCycle dayNightCycle;
        [SerializeField] private InventoryManager inventoryManager;
        [SerializeField] private NarrativeManager narrativeManager;
        [SerializeField] private ChoiceManager choiceManager;
        [SerializeField] private UIManager uiManager;
        
        [Header("Game Settings")]
        [SerializeField] private float gameStartDelay = 2f;
        [SerializeField] private string gameTitle = "Alien Experiment: Survival & Discovery";
        [SerializeField] private string gameVersion = "0.1.0";
        
        // Singleton pattern
        public static GameManager Instance { get; private set; }
        
        // Events
        public static System.Action OnGameStarted;
        public static System.Action OnGamePaused;
        public static System.Action OnGameResumed;
        public static System.Action OnGameEnded;
        
        private void Awake()
        {
            // Singleton pattern
            if (Instance == null)
            {
                Instance = this;
                DontDestroyOnLoad(gameObject);
            }
            else
            {
                Destroy(gameObject);
                return;
            }
            
            InitializeGame();
        }
        
        private void Start()
        {
            StartGame();
        }
        
        private void Update()
        {
            HandleInput();
        }
        
        private void InitializeGame()
        {
            // Find all managers if not assigned
            if (survivalManager == null)
                survivalManager = FindObjectOfType<SurvivalManager>();
                
            if (playerController == null)
                playerController = FindObjectOfType<PlayerController>();
                
            if (dayNightCycle == null)
                dayNightCycle = FindObjectOfType<DayNightCycle>();
                
            if (inventoryManager == null)
                inventoryManager = FindObjectOfType<InventoryManager>();
                
            if (narrativeManager == null)
                narrativeManager = FindObjectOfType<NarrativeManager>();
                
            if (choiceManager == null)
                choiceManager = FindObjectOfType<ChoiceManager>();
                
            if (uiManager == null)
                uiManager = FindObjectOfType<UIManager>();
            
            // Subscribe to important events
            SubscribeToEvents();
            
            Debug.Log($"{gameTitle} v{gameVersion} - Initialized");
        }
        
        private void SubscribeToEvents()
        {
            if (survivalManager != null)
            {
                SurvivalManager.OnPlayerDied += OnPlayerDied;
            }
            
            if (choiceManager != null)
            {
                ChoiceManager.OnGameEnding += OnGameEndingTriggered;
            }
            
            if (narrativeManager != null)
            {
                NarrativeManager.OnExperimentRevealed += OnExperimentRevealed;
            }
        }
        
        private void StartGame()
        {
            if (gameStarted) return;
            
            // Start the game after a brief delay
            Invoke(nameof(DelayedGameStart), gameStartDelay);
        }
        
        private void DelayedGameStart()
        {
            gameStarted = true;
            OnGameStarted?.Invoke();
            
            Debug.Log("Game Started - Survival begins...");
        }
        
        private void HandleInput()
        {
            if (!gameStarted || gameEnded) return;
            
            // Pause/Resume game
            if (Input.GetKeyDown(KeyCode.Escape))
            {
                if (gamePaused)
                    ResumeGame();
                else
                    PauseGame();
            }
            
            // Quick restart (for testing)
            if (Input.GetKeyDown(KeyCode.R) && Input.GetKey(KeyCode.LeftControl))
            {
                RestartGame();
            }
            
            // Quick quit
            if (Input.GetKeyDown(KeyCode.Q) && Input.GetKey(KeyCode.LeftControl))
            {
                QuitGame();
            }
        }
        
        public void PauseGame()
        {
            if (gamePaused || gameEnded) return;
            
            gamePaused = true;
            Time.timeScale = 0f;
            
            // Show cursor
            Cursor.lockState = CursorLockMode.None;
            Cursor.visible = true;
            
            OnGamePaused?.Invoke();
            Debug.Log("Game Paused");
        }
        
        public void ResumeGame()
        {
            if (!gamePaused || gameEnded) return;
            
            gamePaused = false;
            Time.timeScale = 1f;
            
            // Hide cursor
            Cursor.lockState = CursorLockMode.Locked;
            Cursor.visible = false;
            
            OnGameResumed?.Invoke();
            Debug.Log("Game Resumed");
        }
        
        public void RestartGame()
        {
            Time.timeScale = 1f;
            SceneManager.LoadScene(SceneManager.GetActiveScene().name);
        }
        
        public void QuitGame()
        {
            Debug.Log("Quitting Game");
            
            #if UNITY_EDITOR
            UnityEditor.EditorApplication.isPlaying = false;
            #else
            Application.Quit();
            #endif
        }
        
        private void OnPlayerDied()
        {
            Debug.Log("Player died - Game Over");
            EndGame(ChoiceManager.EndingType.SurvivalFailure);
        }
        
        private void OnExperimentRevealed()
        {
            Debug.Log("Alien experiment revealed - Choice system activated");
            
            if (uiManager != null)
            {
                uiManager.ShowChoiceSystem();
            }
        }
        
        private void OnGameEndingTriggered(ChoiceManager.EndingType endingType)
        {
            EndGame(endingType);
        }
        
        private void EndGame(ChoiceManager.EndingType endingType)
        {
            if (gameEnded) return;
            
            gameEnded = true;
            OnGameEnded?.Invoke();
            
            Debug.Log($"Game Ended: {endingType}");
            
            // Show ending screen after delay
            Invoke(nameof(ShowGameOverScreen), 3f);
        }
        
        private void ShowGameOverScreen()
        {
            // This would show the game over UI
            // For now, we'll just enable cursor and offer restart
            Cursor.lockState = CursorLockMode.None;
            Cursor.visible = true;
            
            Debug.Log("Press R to restart or Q to quit");
        }
        
        // Public getters for game state
        public bool IsGameStarted() => gameStarted;
        public bool IsGamePaused() => gamePaused;
        public bool IsGameEnded() => gameEnded;
        
        // Getter methods for managers (for other scripts to access)
        public SurvivalManager GetSurvivalManager() => survivalManager;
        public PlayerController GetPlayerController() => playerController;
        public DayNightCycle GetDayNightCycle() => dayNightCycle;
        public InventoryManager GetInventoryManager() => inventoryManager;
        public NarrativeManager GetNarrativeManager() => narrativeManager;
        public ChoiceManager GetChoiceManager() => choiceManager;
        public UIManager GetUIManager() => uiManager;
        
        private void OnDestroy()
        {
            // Unsubscribe from events
            if (survivalManager != null)
            {
                SurvivalManager.OnPlayerDied -= OnPlayerDied;
            }
            
            if (choiceManager != null)
            {
                ChoiceManager.OnGameEnding -= OnGameEndingTriggered;
            }
            
            if (narrativeManager != null)
            {
                NarrativeManager.OnExperimentRevealed -= OnExperimentRevealed;
            }
        }
    }
}
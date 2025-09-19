using UnityEngine;

namespace AlienExperiment
{
    /// <summary>
    /// Audio manager for ambient sounds and alien experiment audio cues
    /// </summary>
    public class AudioManager : MonoBehaviour
    {
        [Header("Ambient Audio")]
        [SerializeField] private AudioSource forestAmbientSource;
        [SerializeField] private AudioSource alienUndertoneSource;
        [SerializeField] private AudioClip[] forestSounds;
        [SerializeField] private AudioClip[] alienSounds;
        
        [Header("Effect Audio")]
        [SerializeField] private AudioSource effectsSource;
        [SerializeField] private AudioClip glitchSound;
        [SerializeField] private AudioClip anomalySound;
        [SerializeField] private AudioClip choiceSound;
        
        [Header("Settings")]
        [SerializeField] private float forestVolume = 0.5f;
        [SerializeField] private float alienVolumeMax = 0.3f;
        [SerializeField] private float fadeSpeed = 1f;
        
        private float currentAlienVolume = 0f;
        private int narrativeStage = 0;
        private bool isAnomalyActive = false;
        
        private void Start()
        {
            InitializeAudio();
            SubscribeToEvents();
        }
        
        private void OnDestroy()
        {
            UnsubscribeFromEvents();
        }
        
        private void InitializeAudio()
        {
            // Set up forest ambient
            if (forestAmbientSource != null && forestSounds.Length > 0)
            {
                forestAmbientSource.clip = forestSounds[0];
                forestAmbientSource.volume = forestVolume;
                forestAmbientSource.loop = true;
                forestAmbientSource.Play();
            }
            
            // Set up alien undertones (start silent)
            if (alienUndertoneSource != null && alienSounds.Length > 0)
            {
                alienUndertoneSource.clip = alienSounds[0];
                alienUndertoneSource.volume = 0f;
                alienUndertoneSource.loop = true;
                alienUndertoneSource.Play();
            }
        }
        
        private void SubscribeToEvents()
        {
            NarrativeManager.OnNarrativeStageChanged += OnNarrativeStageChanged;
            DayNightCycle.OnAnomalyDetected += OnAnomalyDetected;
            ChoiceManager.OnChoiceMade += OnChoiceMade;
        }
        
        private void UnsubscribeFromEvents()
        {
            NarrativeManager.OnNarrativeStageChanged -= OnNarrativeStageChanged;
            DayNightCycle.OnAnomalyDetected -= OnAnomalyDetected;
            ChoiceManager.OnChoiceMade -= OnChoiceMade;
        }
        
        private void Update()
        {
            UpdateAlienUndertones();
        }
        
        private void UpdateAlienUndertones()
        {
            if (alienUndertoneSource == null) return;
            
            // Gradually increase alien undertones based on narrative stage
            float targetVolume = (narrativeStage / 3f) * alienVolumeMax;
            
            if (isAnomalyActive)
            {
                targetVolume = alienVolumeMax; // Full volume during anomalies
            }
            
            currentAlienVolume = Mathf.MoveTowards(currentAlienVolume, targetVolume, fadeSpeed * Time.deltaTime);
            alienUndertoneSource.volume = currentAlienVolume;
        }
        
        private void OnNarrativeStageChanged(int stage)
        {
            narrativeStage = stage;
            
            // Change alien sound based on stage
            if (alienUndertoneSource != null && alienSounds.Length > stage)
            {
                alienUndertoneSource.clip = alienSounds[Mathf.Min(stage, alienSounds.Length - 1)];
                alienUndertoneSource.Play();
            }
        }
        
        private void OnAnomalyDetected()
        {
            isAnomalyActive = true;
            
            // Play anomaly sound effect
            if (effectsSource != null && anomalySound != null)
            {
                effectsSource.PlayOneShot(anomalySound);
            }
            
            // Stop anomaly state after duration
            Invoke(nameof(StopAnomaly), 5f);
        }
        
        private void StopAnomaly()
        {
            isAnomalyActive = false;
        }
        
        private void OnChoiceMade(ChoiceManager.PlayerChoice choice)
        {
            if (effectsSource != null && choiceSound != null)
            {
                effectsSource.PlayOneShot(choiceSound);
            }
        }
        
        public void PlayGlitchEffect()
        {
            if (effectsSource != null && glitchSound != null)
            {
                effectsSource.PlayOneShot(glitchSound);
            }
        }
        
        public void SetForestVolume(float volume)
        {
            forestVolume = Mathf.Clamp01(volume);
            if (forestAmbientSource != null)
            {
                forestAmbientSource.volume = forestVolume;
            }
        }
        
        public void SetAlienVolumeMax(float volume)
        {
            alienVolumeMax = Mathf.Clamp01(volume);
        }
    }
}
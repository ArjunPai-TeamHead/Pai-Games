using UnityEngine;
using System.Collections;

namespace AlienExperiment
{
    /// <summary>
    /// Core survival mechanics manager - handles hunger, thirst, temperature, and energy
    /// </summary>
    public class SurvivalManager : MonoBehaviour
    {
        [Header("Survival Stats")]
        [SerializeField] private float maxHunger = 100f;
        [SerializeField] private float maxThirst = 100f;
        [SerializeField] private float maxTemperature = 100f;
        [SerializeField] private float maxEnergy = 100f;
        
        [Header("Decay Rates (per hour)")]
        [SerializeField] private float hungerDecayRate = 5f;
        [SerializeField] private float thirstDecayRate = 8f;
        [SerializeField] private float temperatureDecayRate = 3f;
        [SerializeField] private float energyDecayRate = 6f;
        
        [Header("Critical Thresholds")]
        [SerializeField] private float criticalThreshold = 20f;
        [SerializeField] private float dangerThreshold = 40f;
        
        // Current stats
        public float CurrentHunger { get; private set; }
        public float CurrentThirst { get; private set; }
        public float CurrentTemperature { get; private set; }
        public float CurrentEnergy { get; private set; }
        
        // Events
        public static System.Action<SurvivalStat, float> OnStatChanged;
        public static System.Action<SurvivalStat> OnStatCritical;
        public static System.Action OnPlayerDied;
        
        private bool isInitialized = false;
        
        public enum SurvivalStat
        {
            Hunger,
            Thirst,
            Temperature,
            Energy
        }
        
        private void Start()
        {
            InitializeStats();
            StartCoroutine(SurvivalDecay());
        }
        
        private void InitializeStats()
        {
            CurrentHunger = maxHunger;
            CurrentThirst = maxThirst;
            CurrentTemperature = maxTemperature;
            CurrentEnergy = maxEnergy;
            isInitialized = true;
            
            // Notify UI of initial values
            OnStatChanged?.Invoke(SurvivalStat.Hunger, GetStatPercentage(SurvivalStat.Hunger));
            OnStatChanged?.Invoke(SurvivalStat.Thirst, GetStatPercentage(SurvivalStat.Thirst));
            OnStatChanged?.Invoke(SurvivalStat.Temperature, GetStatPercentage(SurvivalStat.Temperature));
            OnStatChanged?.Invoke(SurvivalStat.Energy, GetStatPercentage(SurvivalStat.Energy));
        }
        
        private IEnumerator SurvivalDecay()
        {
            while (isInitialized)
            {
                yield return new WaitForSeconds(3.6f); // 1/1000th of an hour for faster testing
                
                // Apply decay
                CurrentHunger = Mathf.Max(0, CurrentHunger - (hungerDecayRate / 1000f));
                CurrentThirst = Mathf.Max(0, CurrentThirst - (thirstDecayRate / 1000f));
                CurrentTemperature = Mathf.Max(0, CurrentTemperature - (temperatureDecayRate / 1000f));
                CurrentEnergy = Mathf.Max(0, CurrentEnergy - (energyDecayRate / 1000f));
                
                // Update UI
                OnStatChanged?.Invoke(SurvivalStat.Hunger, GetStatPercentage(SurvivalStat.Hunger));
                OnStatChanged?.Invoke(SurvivalStat.Thirst, GetStatPercentage(SurvivalStat.Thirst));
                OnStatChanged?.Invoke(SurvivalStat.Temperature, GetStatPercentage(SurvivalStat.Temperature));
                OnStatChanged?.Invoke(SurvivalStat.Energy, GetStatPercentage(SurvivalStat.Energy));
                
                // Check for critical states
                CheckCriticalStates();
                
                // Check for death
                if (IsPlayerDead())
                {
                    OnPlayerDied?.Invoke();
                    break;
                }
            }
        }
        
        private void CheckCriticalStates()
        {
            if (CurrentHunger <= criticalThreshold)
                OnStatCritical?.Invoke(SurvivalStat.Hunger);
            if (CurrentThirst <= criticalThreshold)
                OnStatCritical?.Invoke(SurvivalStat.Thirst);
            if (CurrentTemperature <= criticalThreshold)
                OnStatCritical?.Invoke(SurvivalStat.Temperature);
            if (CurrentEnergy <= criticalThreshold)
                OnStatCritical?.Invoke(SurvivalStat.Energy);
        }
        
        private bool IsPlayerDead()
        {
            return CurrentHunger <= 0 || CurrentThirst <= 0 || CurrentTemperature <= 0 || CurrentEnergy <= 0;
        }
        
        public float GetStatPercentage(SurvivalStat stat)
        {
            switch (stat)
            {
                case SurvivalStat.Hunger:
                    return CurrentHunger / maxHunger;
                case SurvivalStat.Thirst:
                    return CurrentThirst / maxThirst;
                case SurvivalStat.Temperature:
                    return CurrentTemperature / maxTemperature;
                case SurvivalStat.Energy:
                    return CurrentEnergy / maxEnergy;
                default:
                    return 0f;
            }
        }
        
        public void ModifyStat(SurvivalStat stat, float amount)
        {
            switch (stat)
            {
                case SurvivalStat.Hunger:
                    CurrentHunger = Mathf.Clamp(CurrentHunger + amount, 0, maxHunger);
                    break;
                case SurvivalStat.Thirst:
                    CurrentThirst = Mathf.Clamp(CurrentThirst + amount, 0, maxThirst);
                    break;
                case SurvivalStat.Temperature:
                    CurrentTemperature = Mathf.Clamp(CurrentTemperature + amount, 0, maxTemperature);
                    break;
                case SurvivalStat.Energy:
                    CurrentEnergy = Mathf.Clamp(CurrentEnergy + amount, 0, maxEnergy);
                    break;
            }
            
            OnStatChanged?.Invoke(stat, GetStatPercentage(stat));
        }
        
        public bool IsStatCritical(SurvivalStat stat)
        {
            return GetStatPercentage(stat) * 100f <= criticalThreshold;
        }
        
        public bool IsStatDangerous(SurvivalStat stat)
        {
            return GetStatPercentage(stat) * 100f <= dangerThreshold;
        }
    }
}
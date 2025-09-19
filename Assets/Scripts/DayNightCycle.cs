using UnityEngine;
using System.Collections;

namespace AlienExperiment
{
    /// <summary>
    /// Manages day/night cycle with environmental effects and alien experiment hints
    /// </summary>
    public class DayNightCycle : MonoBehaviour
    {
        [Header("Time Settings")]
        [SerializeField] private float dayDurationMinutes = 10f; // Real-time minutes for one day
        [SerializeField] private Light sunLight;
        [SerializeField] private Light moonLight;
        
        [Header("Sky Colors")]
        [SerializeField] private Gradient skyGradient;
        [SerializeField] private Gradient fogGradient;
        [SerializeField] private AnimationCurve lightIntensityCurve;
        
        [Header("Temperature Effects")]
        [SerializeField] private float dayTemperatureBonus = 10f;
        [SerializeField] private float nightTemperaturePenalty = -15f;
        
        [Header("Alien Experiment Hints")]
        [SerializeField] private float anomalyChance = 0.1f; // Chance per cycle for anomaly
        [SerializeField] private Color alienTintColor = Color.green;
        [SerializeField] private float anomalyDuration = 5f;
        
        private float currentTimeOfDay = 0.5f; // 0 = midnight, 0.5 = noon, 1 = midnight
        private float daySpeed;
        private bool isAnomalyActive = false;
        private SurvivalManager survivalManager;
        
        public float TimeOfDay => currentTimeOfDay;
        public bool IsDay => currentTimeOfDay > 0.25f && currentTimeOfDay < 0.75f;
        public bool IsNight => !IsDay;
        
        public static System.Action<bool> OnDayNightChange;
        public static System.Action OnAnomalyDetected;
        
        private void Start()
        {
            daySpeed = 1f / (dayDurationMinutes * 60f);
            survivalManager = FindObjectOfType<SurvivalManager>();
            
            if (sunLight == null)
                sunLight = FindObjectOfType<Light>();
                
            UpdateLighting();
        }
        
        private void Update()
        {
            UpdateTimeOfDay();
            UpdateLighting();
            UpdateEnvironmentalEffects();
            CheckForAnomalies();
        }
        
        private void UpdateTimeOfDay()
        {
            float previousTime = currentTimeOfDay;
            currentTimeOfDay += daySpeed * Time.deltaTime;
            
            if (currentTimeOfDay >= 1f)
            {
                currentTimeOfDay = 0f;
                OnNewDay();
            }
            
            // Check for day/night transitions
            bool wasDay = previousTime > 0.25f && previousTime < 0.75f;
            bool isNowDay = currentTimeOfDay > 0.25f && currentTimeOfDay < 0.75f;
            
            if (wasDay != isNowDay)
            {
                OnDayNightChange?.Invoke(isNowDay);
            }
        }
        
        private void UpdateLighting()
        {
            if (sunLight != null)
            {
                // Calculate sun angle (0-360 degrees)
                float sunAngle = (currentTimeOfDay - 0.25f) * 360f;
                sunLight.transform.rotation = Quaternion.Euler(sunAngle, 30f, 0f);
                
                // Update intensity based on time
                float intensity = lightIntensityCurve.Evaluate(currentTimeOfDay);
                sunLight.intensity = intensity;
                
                // Update colors
                if (!isAnomalyActive)
                {
                    sunLight.color = Color.white;
                    RenderSettings.skybox.SetColor("_Tint", skyGradient.Evaluate(currentTimeOfDay));
                    RenderSettings.fogColor = fogGradient.Evaluate(currentTimeOfDay);
                }
            }
            
            if (moonLight != null)
            {
                moonLight.intensity = IsNight ? 0.3f : 0f;
            }
        }
        
        private void UpdateEnvironmentalEffects()
        {
            if (survivalManager != null)
            {
                // Apply temperature effects based on time of day
                float temperatureEffect = 0f;
                
                if (IsDay)
                {
                    temperatureEffect = dayTemperatureBonus * Time.deltaTime / 60f; // Per minute
                }
                else
                {
                    temperatureEffect = nightTemperaturePenalty * Time.deltaTime / 60f; // Per minute
                }
                
                survivalManager.ModifyStat(SurvivalManager.SurvivalStat.Temperature, temperatureEffect);
            }
        }
        
        private void CheckForAnomalies()
        {
            if (!isAnomalyActive && Random.value < anomalyChance * Time.deltaTime)
            {
                StartCoroutine(TriggerAnomaly());
            }
        }
        
        private IEnumerator TriggerAnomaly()
        {
            isAnomalyActive = true;
            OnAnomalyDetected?.Invoke();
            
            // Visual anomaly - tint the lighting
            if (sunLight != null)
            {
                Color originalColor = sunLight.color;
                sunLight.color = alienTintColor;
                
                // Flicker effect
                for (int i = 0; i < 10; i++)
                {
                    sunLight.intensity *= Random.Range(0.5f, 1.5f);
                    yield return new WaitForSeconds(0.1f);
                }
                
                yield return new WaitForSeconds(anomalyDuration - 1f);
                
                // Restore original lighting
                sunLight.color = originalColor;
                UpdateLighting(); // Reset intensity
            }
            
            isAnomalyActive = false;
        }
        
        private void OnNewDay()
        {
            Debug.Log("New day started - Day " + GetCurrentDay());
            
            // Increase anomaly chance slightly each day
            anomalyChance = Mathf.Min(anomalyChance * 1.05f, 0.5f);
        }
        
        public int GetCurrentDay()
        {
            return Mathf.FloorToInt(Time.timeSinceStartup / (dayDurationMinutes * 60f)) + 1;
        }
        
        public string GetTimeString()
        {
            int hours = Mathf.FloorToInt(currentTimeOfDay * 24f);
            int minutes = Mathf.FloorToInt((currentTimeOfDay * 24f - hours) * 60f);
            return string.Format("Day {0} - {1:D2}:{2:D2}", GetCurrentDay(), hours, minutes);
        }
        
        public void SetTimeOfDay(float time)
        {
            currentTimeOfDay = Mathf.Clamp01(time);
            UpdateLighting();
        }
        
        // Method to trigger anomaly for testing
        [ContextMenu("Trigger Anomaly")]
        public void TriggerTestAnomaly()
        {
            if (!isAnomalyActive)
            {
                StartCoroutine(TriggerAnomaly());
            }
        }
    }
}
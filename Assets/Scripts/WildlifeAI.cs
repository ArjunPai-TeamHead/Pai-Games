using UnityEngine;
using System.Collections;

namespace AlienExperiment
{
    /// <summary>
    /// AI controller for forest wildlife with algorithmic behavior patterns (alien hint)
    /// </summary>
    public class WildlifeAI : MonoBehaviour
    {
        [Header("Movement")]
        [SerializeField] private float moveSpeed = 2f;
        [SerializeField] private float rotationSpeed = 90f;
        [SerializeField] private float wanderRadius = 10f;
        [SerializeField] private float wanderTimer = 0f;
        
        [Header("Behavior")]
        [SerializeField] private AnimalType animalType;
        [SerializeField] private float detectionRange = 5f;
        [SerializeField] private float fleeDistance = 8f;
        [SerializeField] private bool isNocturnal = false;
        
        [Header("Alien Hints")]
        [SerializeField] private bool useAlgorithmicMovement = true;
        [SerializeField] private float algorithmicPrecision = 0.1f;
        [SerializeField] private bool perfectPatterns = false;
        
        private Vector3 homePosition;
        private Vector3 targetPosition;
        private AnimalState currentState;
        private Transform playerTransform;
        private DayNightCycle dayNightCycle;
        private Rigidbody rigidBody;
        
        // Algorithmic movement variables
        private float movementPhase = 0f;
        private Vector3 lastCalculatedPosition;
        
        public enum AnimalType
        {
            Rabbit,
            Deer,
            Bird,
            Squirrel,
            Fox
        }
        
        public enum AnimalState
        {
            Wandering,
            Fleeing,
            Resting,
            Feeding,
            PatrollingPattern
        }
        
        private void Start()
        {
            homePosition = transform.position;
            targetPosition = GetRandomWanderTarget();
            currentState = AnimalState.Wandering;
            
            rigidBody = GetComponent<Rigidbody>();
            if (rigidBody == null)
            {
                rigidBody = gameObject.AddComponent<Rigidbody>();
                rigidBody.freezeRotation = true;
            }
            
            // Find player and day/night cycle
            GameObject player = GameObject.FindGameObjectWithTag("Player");
            if (player != null)
            {
                playerTransform = player.transform;
            }
            
            dayNightCycle = FindObjectOfType<DayNightCycle>();
            
            // Start behavior coroutine
            StartCoroutine(AnimalBehaviorLoop());
        }
        
        private void Update()
        {
            HandleMovement();
            CheckPlayerProximity();
            UpdateAlgorithmicBehavior();
        }
        
        private IEnumerator AnimalBehaviorLoop()
        {
            while (true)
            {
                switch (currentState)
                {
                    case AnimalState.Wandering:
                        yield return StartCoroutine(WanderBehavior());
                        break;
                    case AnimalState.Fleeing:
                        yield return StartCoroutine(FleeBehavior());
                        break;
                    case AnimalState.Resting:
                        yield return StartCoroutine(RestBehavior());
                        break;
                    case AnimalState.Feeding:
                        yield return StartCoroutine(FeedBehavior());
                        break;
                    case AnimalState.PatrollingPattern:
                        yield return StartCoroutine(PatrolBehavior());
                        break;
                }
                
                yield return new WaitForSeconds(0.1f);
            }
        }
        
        private void HandleMovement()
        {
            if (currentState == AnimalState.Resting) return;
            
            Vector3 direction = (targetPosition - transform.position).normalized;
            
            if (useAlgorithmicMovement)
            {
                // Perfect algorithmic movement (alien hint)
                direction = CalculateAlgorithmicDirection();
            }
            
            // Move towards target
            if (direction.magnitude > 0.1f)
            {
                transform.position += direction * moveSpeed * Time.deltaTime;
                
                // Rotate towards movement direction
                Quaternion targetRotation = Quaternion.LookRotation(direction);
                transform.rotation = Quaternion.RotateTowards(transform.rotation, targetRotation, rotationSpeed * Time.deltaTime);
            }
        }
        
        private Vector3 CalculateAlgorithmicDirection()
        {
            movementPhase += Time.deltaTime;
            
            if (perfectPatterns)
            {
                // Create unnaturally perfect movement patterns
                float x = Mathf.Sin(movementPhase * 2f) * algorithmicPrecision;
                float z = Mathf.Cos(movementPhase * 1.5f) * algorithmicPrecision;
                
                Vector3 perfectDirection = new Vector3(x, 0, z);
                Vector3 naturalDirection = (targetPosition - transform.position).normalized;
                
                return Vector3.Lerp(naturalDirection, perfectDirection, 0.3f);
            }
            else
            {
                // Slightly too precise movement
                Vector3 direction = (targetPosition - transform.position).normalized;
                
                // Round to algorithmic precision (unnaturally precise)
                direction.x = Mathf.Round(direction.x / algorithmicPrecision) * algorithmicPrecision;
                direction.z = Mathf.Round(direction.z / algorithmicPrecision) * algorithmicPrecision;
                
                return direction;
            }
        }
        
        private void CheckPlayerProximity()
        {
            if (playerTransform == null) return;
            
            float distanceToPlayer = Vector3.Distance(transform.position, playerTransform.position);
            
            if (distanceToPlayer < detectionRange && currentState != AnimalState.Fleeing)
            {
                currentState = AnimalState.Fleeing;
                targetPosition = GetFleeTarget();
            }
            else if (distanceToPlayer > fleeDistance && currentState == AnimalState.Fleeing)
            {
                currentState = AnimalState.Wandering;
                targetPosition = GetRandomWanderTarget();
            }
        }
        
        private void UpdateAlgorithmicBehavior()
        {
            // Occasionally switch to perfect pattern movement (alien hint)
            if (Random.value < 0.001f) // Very rare
            {
                perfectPatterns = !perfectPatterns;
                
                if (perfectPatterns)
                {
                    currentState = AnimalState.PatrollingPattern;
                }
            }
        }
        
        private IEnumerator WanderBehavior()
        {
            // Check if should be active based on day/night cycle
            if (ShouldBeActive())
            {
                if (Vector3.Distance(transform.position, targetPosition) < 1f)
                {
                    targetPosition = GetRandomWanderTarget();
                }
                
                // Occasionally switch to feeding
                if (Random.value < 0.02f)
                {
                    currentState = AnimalState.Feeding;
                }
            }
            else
            {
                currentState = AnimalState.Resting;
            }
            
            yield return new WaitForSeconds(Random.Range(2f, 5f));
        }
        
        private IEnumerator FleeBehavior()
        {
            // Keep fleeing until player is far enough
            if (playerTransform != null)
            {
                float distanceToPlayer = Vector3.Distance(transform.position, playerTransform.position);
                
                if (distanceToPlayer < fleeDistance)
                {
                    targetPosition = GetFleeTarget();
                }
                else
                {
                    currentState = AnimalState.Wandering;
                    targetPosition = GetRandomWanderTarget();
                }
            }
            
            yield return new WaitForSeconds(0.5f);
        }
        
        private IEnumerator RestBehavior()
        {
            // Stop moving while resting
            targetPosition = transform.position;
            
            yield return new WaitForSeconds(Random.Range(3f, 8f));
            
            if (ShouldBeActive())
            {
                currentState = AnimalState.Wandering;
                targetPosition = GetRandomWanderTarget();
            }
        }
        
        private IEnumerator FeedBehavior()
        {
            // Stop and "feed"
            targetPosition = transform.position;
            
            yield return new WaitForSeconds(Random.Range(5f, 10f));
            
            currentState = AnimalState.Wandering;
            targetPosition = GetRandomWanderTarget();
        }
        
        private IEnumerator PatrolBehavior()
        {
            // Create a perfect geometric patrol pattern (alien hint)
            Vector3[] patrolPoints = CreateGeometricPattern();
            int currentPoint = 0;
            
            while (perfectPatterns && currentPoint < patrolPoints.Length)
            {
                targetPosition = patrolPoints[currentPoint];
                
                while (Vector3.Distance(transform.position, targetPosition) > 0.5f)
                {
                    yield return new WaitForSeconds(0.1f);
                }
                
                currentPoint++;
                yield return new WaitForSeconds(1f);
            }
            
            currentState = AnimalState.Wandering;
            perfectPatterns = false;
        }
        
        private Vector3[] CreateGeometricPattern()
        {
            // Create a perfect circle pattern
            Vector3[] points = new Vector3[8];
            Vector3 center = transform.position;
            float radius = 5f;
            
            for (int i = 0; i < points.Length; i++)
            {
                float angle = (float)i / points.Length * 360f * Mathf.Deg2Rad;
                points[i] = center + new Vector3(Mathf.Cos(angle) * radius, 0, Mathf.Sin(angle) * radius);
            }
            
            return points;
        }
        
        private bool ShouldBeActive()
        {
            if (dayNightCycle == null) return true;
            
            bool isDayTime = dayNightCycle.IsDay;
            
            return isNocturnal ? !isDayTime : isDayTime;
        }
        
        private Vector3 GetRandomWanderTarget()
        {
            Vector3 randomDirection = Random.insideUnitSphere * wanderRadius;
            randomDirection += homePosition;
            randomDirection.y = homePosition.y; // Keep on ground level
            
            return randomDirection;
        }
        
        private Vector3 GetFleeTarget()
        {
            if (playerTransform == null) return GetRandomWanderTarget();
            
            Vector3 fleeDirection = (transform.position - playerTransform.position).normalized;
            Vector3 fleeTarget = transform.position + fleeDirection * fleeDistance;
            fleeTarget.y = transform.position.y;
            
            return fleeTarget;
        }
        
        public AnimalType GetAnimalType()
        {
            return animalType;
        }
        
        public AnimalState GetCurrentState()
        {
            return currentState;
        }
        
        // Method to force algorithmic behavior (for testing)
        [ContextMenu("Toggle Algorithmic Behavior")]
        public void ToggleAlgorithmicBehavior()
        {
            perfectPatterns = !perfectPatterns;
            if (perfectPatterns)
            {
                currentState = AnimalState.PatrollingPattern;
            }
        }
    }
}
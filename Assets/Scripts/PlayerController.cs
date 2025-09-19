using UnityEngine;

namespace AlienExperiment
{
    /// <summary>
    /// First-person player controller with survival game features
    /// </summary>
    [RequireComponent(typeof(CharacterController))]
    public class PlayerController : MonoBehaviour
    {
        [Header("Movement")]
        [SerializeField] private float walkSpeed = 5f;
        [SerializeField] private float runSpeed = 8f;
        [SerializeField] private float jumpHeight = 2f;
        [SerializeField] private float gravity = -9.81f;
        
        [Header("Camera")]
        [SerializeField] private Camera playerCamera;
        [SerializeField] private float mouseSensitivity = 2f;
        [SerializeField] private float lookUpLimit = 90f;
        [SerializeField] private float lookDownLimit = -90f;
        
        [Header("Interaction")]
        [SerializeField] private float interactionRange = 3f;
        [SerializeField] private LayerMask interactableLayerMask = -1;
        
        private CharacterController characterController;
        private Vector3 velocity;
        private bool isGrounded;
        private float xRotation = 0f;
        
        // Input variables
        private Vector2 moveInput;
        private Vector2 lookInput;
        private bool jumpInput;
        private bool runInput;
        private bool interactInput;
        
        // Current interactable
        private IInteractable currentInteractable;
        
        public static System.Action<IInteractable> OnInteractableChanged;
        
        private void Start()
        {
            characterController = GetComponent<CharacterController>();
            
            if (playerCamera == null)
                playerCamera = Camera.main;
                
            // Lock cursor to center of screen
            Cursor.lockState = CursorLockMode.Locked;
            Cursor.visible = false;
        }
        
        private void Update()
        {
            HandleInput();
            HandleMovement();
            HandleLook();
            HandleInteraction();
        }
        
        private void HandleInput()
        {
            // Movement input
            moveInput = new Vector2(Input.GetAxis("Horizontal"), Input.GetAxis("Vertical"));
            
            // Look input
            lookInput = new Vector2(Input.GetAxis("Mouse X"), Input.GetAxis("Mouse Y"));
            
            // Action inputs
            jumpInput = Input.GetButtonDown("Jump");
            runInput = Input.GetKey(KeyCode.LeftShift);
            interactInput = Input.GetKeyDown(KeyCode.E);
            
            // Menu inputs
            if (Input.GetKeyDown(KeyCode.Escape))
            {
                ToggleCursor();
            }
        }
        
        private void HandleMovement()
        {
            // Check if grounded
            isGrounded = characterController.isGrounded;
            
            if (isGrounded && velocity.y < 0)
            {
                velocity.y = -2f;
            }
            
            // Calculate movement direction
            Vector3 moveDirection = transform.right * moveInput.x + transform.forward * moveInput.y;
            
            // Apply speed
            float currentSpeed = runInput ? runSpeed : walkSpeed;
            characterController.Move(moveDirection * currentSpeed * Time.deltaTime);
            
            // Jumping
            if (jumpInput && isGrounded)
            {
                velocity.y = Mathf.Sqrt(jumpHeight * -2f * gravity);
            }
            
            // Apply gravity
            velocity.y += gravity * Time.deltaTime;
            characterController.Move(velocity * Time.deltaTime);
            
            // Apply energy cost for running
            if (runInput && moveInput.magnitude > 0.1f)
            {
                SurvivalManager survivalManager = FindObjectOfType<SurvivalManager>();
                if (survivalManager != null)
                {
                    survivalManager.ModifyStat(SurvivalManager.SurvivalStat.Energy, -2f * Time.deltaTime);
                }
            }
        }
        
        private void HandleLook()
        {
            if (Cursor.lockState == CursorLockMode.Locked)
            {
                // Horizontal rotation (Y-axis)
                transform.Rotate(Vector3.up * lookInput.x * mouseSensitivity);
                
                // Vertical rotation (X-axis) - applied to camera
                xRotation -= lookInput.y * mouseSensitivity;
                xRotation = Mathf.Clamp(xRotation, lookDownLimit, lookUpLimit);
                playerCamera.transform.localRotation = Quaternion.Euler(xRotation, 0f, 0f);
            }
        }
        
        private void HandleInteraction()
        {
            // Raycast for interactables
            Ray ray = playerCamera.ScreenPointToRay(new Vector3(Screen.width / 2, Screen.height / 2));
            RaycastHit hit;
            
            IInteractable newInteractable = null;
            
            if (Physics.Raycast(ray, out hit, interactionRange, interactableLayerMask))
            {
                newInteractable = hit.collider.GetComponent<IInteractable>();
            }
            
            // Update current interactable
            if (newInteractable != currentInteractable)
            {
                currentInteractable = newInteractable;
                OnInteractableChanged?.Invoke(currentInteractable);
            }
            
            // Handle interaction input
            if (interactInput && currentInteractable != null)
            {
                currentInteractable.Interact(this);
            }
        }
        
        private void ToggleCursor()
        {
            if (Cursor.lockState == CursorLockMode.Locked)
            {
                Cursor.lockState = CursorLockMode.None;
                Cursor.visible = true;
            }
            else
            {
                Cursor.lockState = CursorLockMode.Locked;
                Cursor.visible = false;
            }
        }
        
        public Vector3 GetPosition()
        {
            return transform.position;
        }
        
        public Vector3 GetForward()
        {
            return transform.forward;
        }
        
        public Camera GetCamera()
        {
            return playerCamera;
        }
    }
    
    /// <summary>
    /// Interface for interactable objects
    /// </summary>
    public interface IInteractable
    {
        string GetInteractionText();
        void Interact(PlayerController player);
    }
}
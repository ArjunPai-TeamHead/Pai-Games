using UnityEngine;
using System.Collections.Generic;

namespace AlienExperiment
{
    /// <summary>
    /// Procedural forest generator with alien experiment hints
    /// </summary>
    public class ForestGenerator : MonoBehaviour
    {
        [Header("Forest Generation")]
        [SerializeField] private GameObject[] treePrefabs;
        [SerializeField] private GameObject[] bushPrefabs;
        [SerializeField] private GameObject[] rockPrefabs;
        [SerializeField] private GameObject[] grassPrefabs;
        
        [Header("Generation Settings")]
        [SerializeField] private int forestSize = 100;
        [SerializeField] private float treeSpacing = 5f;
        [SerializeField] private float treeDensity = 0.3f;
        [SerializeField] private float bushDensity = 0.1f;
        [SerializeField] private float rockDensity = 0.05f;
        
        [Header("Alien Elements")]
        [SerializeField] private GameObject[] alienTechPrefabs;
        [SerializeField] private float alienTechChance = 0.02f;
        [SerializeField] private float geometricClearingChance = 0.1f;
        
        [Header("Terrain")]
        [SerializeField] private Terrain terrain;
        [SerializeField] private float terrainHeight = 10f;
        
        private List<Vector3> treePositions = new List<Vector3>();
        private List<Vector3> clearingCenters = new List<Vector3>();
        
        private void Start()
        {
            GenerateForest();
        }
        
        public void GenerateForest()
        {
            ClearExistingForest();
            GenerateTerrain();
            GenerateTrees();
            GenerateVegetation();
            GenerateAlienElements();
            CreateInvisibleBarriers();
        }
        
        private void ClearExistingForest()
        {
            // Clear existing generated objects
            Transform[] children = new Transform[transform.childCount];
            for (int i = 0; i < transform.childCount; i++)
            {
                children[i] = transform.GetChild(i);
            }
            
            foreach (var child in children)
            {
                if (Application.isPlaying)
                    Destroy(child.gameObject);
                else
                    DestroyImmediate(child.gameObject);
            }
            
            treePositions.Clear();
            clearingCenters.Clear();
        }
        
        private void GenerateTerrain()
        {
            if (terrain == null) return;
            
            TerrainData terrainData = terrain.terrainData;
            int width = terrainData.heightmapResolution;
            int height = terrainData.heightmapResolution;
            
            float[,] heights = new float[width, height];
            
            for (int x = 0; x < width; x++)
            {
                for (int y = 0; y < height; y++)
                {
                    // Generate subtle height variations
                    float xCoord = (float)x / width * 5f;
                    float yCoord = (float)y / height * 5f;
                    
                    heights[x, y] = Mathf.PerlinNoise(xCoord, yCoord) * 0.1f;
                }
            }
            
            terrainData.SetHeights(0, 0, heights);
        }
        
        private void GenerateTrees()
        {
            if (treePrefabs == null || treePrefabs.Length == 0) return;
            
            for (int x = -forestSize / 2; x < forestSize / 2; x += (int)treeSpacing)
            {
                for (int z = -forestSize / 2; z < forestSize / 2; z += (int)treeSpacing)
                {
                    if (Random.value < treeDensity)
                    {
                        Vector3 position = new Vector3(
                            x + Random.Range(-treeSpacing * 0.4f, treeSpacing * 0.4f),
                            0f,
                            z + Random.Range(-treeSpacing * 0.4f, treeSpacing * 0.4f)
                        );
                        
                        // Check if position is in a clearing
                        if (IsInClearing(position)) continue;
                        
                        // Create geometric patterns (alien hint)
                        if (ShouldCreateGeometricPattern(position))
                        {
                            CreateGeometricTreePattern(position);
                        }
                        else
                        {
                            SpawnTree(position);
                        }
                    }
                }
            }
        }
        
        private void SpawnTree(Vector3 position)
        {
            GameObject treePrefab = treePrefabs[Random.Range(0, treePrefabs.Length)];
            GameObject tree = Instantiate(treePrefab, position, Quaternion.Euler(0, Random.Range(0, 360), 0), transform);
            
            // Add slight alien modifications occasionally
            if (Random.value < 0.1f)
            {
                AddAlienTreeModification(tree);
            }
            
            treePositions.Add(position);
        }
        
        private bool ShouldCreateGeometricPattern(Vector3 position)
        {
            return Random.value < geometricClearingChance;
        }
        
        private void CreateGeometricTreePattern(Vector3 center)
        {
            // Create a perfect circle of trees (alien hint)
            float radius = Random.Range(8f, 15f);
            int treeCount = Random.Range(8, 16);
            
            for (int i = 0; i < treeCount; i++)
            {
                float angle = (float)i / treeCount * 360f * Mathf.Deg2Rad;
                Vector3 position = center + new Vector3(
                    Mathf.Cos(angle) * radius,
                    0f,
                    Mathf.Sin(angle) * radius
                );
                
                SpawnTree(position);
            }
            
            clearingCenters.Add(center);
        }
        
        private bool IsInClearing(Vector3 position)
        {
            foreach (var clearingCenter in clearingCenters)
            {
                if (Vector3.Distance(position, clearingCenter) < 12f)
                {
                    return true;
                }
            }
            return false;
        }
        
        private void GenerateVegetation()
        {
            // Generate bushes
            if (bushPrefabs != null && bushPrefabs.Length > 0)
            {
                for (int i = 0; i < forestSize * forestSize * bushDensity; i++)
                {
                    Vector3 position = new Vector3(
                        Random.Range(-forestSize / 2, forestSize / 2),
                        0f,
                        Random.Range(-forestSize / 2, forestSize / 2)
                    );
                    
                    if (!IsNearTree(position, 3f) && !IsInClearing(position))
                    {
                        GameObject bushPrefab = bushPrefabs[Random.Range(0, bushPrefabs.Length)];
                        Instantiate(bushPrefab, position, Quaternion.Euler(0, Random.Range(0, 360), 0), transform);
                    }
                }
            }
            
            // Generate rocks
            if (rockPrefabs != null && rockPrefabs.Length > 0)
            {
                for (int i = 0; i < forestSize * forestSize * rockDensity; i++)
                {
                    Vector3 position = new Vector3(
                        Random.Range(-forestSize / 2, forestSize / 2),
                        0f,
                        Random.Range(-forestSize / 2, forestSize / 2)
                    );
                    
                    if (!IsNearTree(position, 2f))
                    {
                        GameObject rockPrefab = rockPrefabs[Random.Range(0, rockPrefabs.Length)];
                        Instantiate(rockPrefab, position, Quaternion.Euler(0, Random.Range(0, 360), 0), transform);
                    }
                }
            }
        }
        
        private bool IsNearTree(Vector3 position, float minDistance)
        {
            foreach (var treePos in treePositions)
            {
                if (Vector3.Distance(position, treePos) < minDistance)
                {
                    return true;
                }
            }
            return false;
        }
        
        private void GenerateAlienElements()
        {
            if (alienTechPrefabs == null || alienTechPrefabs.Length == 0) return;
            
            // Spawn hidden alien technology
            for (int i = 0; i < forestSize * forestSize * alienTechChance; i++)
            {
                Vector3 position = new Vector3(
                    Random.Range(-forestSize / 2, forestSize / 2),
                    0f,
                    Random.Range(-forestSize / 2, forestSize / 2)
                );
                
                if (!IsNearTree(position, 5f))
                {
                    GameObject techPrefab = alienTechPrefabs[Random.Range(0, alienTechPrefabs.Length)];
                    GameObject tech = Instantiate(techPrefab, position, Quaternion.identity, transform);
                    
                    // Start hidden, will be revealed through narrative progression
                    tech.SetActive(false);
                    tech.tag = "AlienTechnology";
                }
            }
        }
        
        private void AddAlienTreeModification(GameObject tree)
        {
            // Add subtle alien modifications to trees
            var renderer = tree.GetComponent<Renderer>();
            if (renderer != null)
            {
                // Slightly different color tint
                renderer.material.color = Color.Lerp(Color.white, Color.cyan, 0.1f);
            }
            
            // Slightly too perfect scaling
            tree.transform.localScale = Vector3.one * 1.1f;
        }
        
        private void CreateInvisibleBarriers()
        {
            // Create invisible barriers at the forest edge (experiment boundary)
            float barrierHeight = 20f;
            float barrierThickness = 1f;
            
            // North barrier
            CreateBarrier(new Vector3(0, barrierHeight / 2, forestSize / 2), 
                         new Vector3(forestSize, barrierHeight, barrierThickness));
            
            // South barrier
            CreateBarrier(new Vector3(0, barrierHeight / 2, -forestSize / 2), 
                         new Vector3(forestSize, barrierHeight, barrierThickness));
            
            // East barrier
            CreateBarrier(new Vector3(forestSize / 2, barrierHeight / 2, 0), 
                         new Vector3(barrierThickness, barrierHeight, forestSize));
            
            // West barrier
            CreateBarrier(new Vector3(-forestSize / 2, barrierHeight / 2, 0), 
                         new Vector3(barrierThickness, barrierHeight, forestSize));
        }
        
        private void CreateBarrier(Vector3 position, Vector3 size)
        {
            GameObject barrier = new GameObject("InvisibleBarrier");
            barrier.transform.position = position;
            barrier.transform.parent = transform;
            
            BoxCollider collider = barrier.AddComponent<BoxCollider>();
            collider.size = size;
            
            // Make it invisible initially
            var renderer = barrier.AddComponent<MeshRenderer>();
            renderer.enabled = false;
            
            barrier.tag = "Barrier";
        }
        
        [ContextMenu("Regenerate Forest")]
        public void RegenerateForest()
        {
            GenerateForest();
        }
    }
}
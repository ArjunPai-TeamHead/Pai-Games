# Alien Experiment: Survival & Discovery - Development Guide

## Quick Start for Developers

### Project Setup
1. **Unity Version**: 2022.3 LTS or later
2. **Clone the repository**: `git clone https://github.com/ArjunPai-TeamHead/Pai-Games.git`
3. **Open in Unity Hub**: Add project and open
4. **Load Main Scene**: `Assets/Scenes/MainScene.unity`
5. **Press Play**: The game should start immediately

### Core Systems Overview

#### 1. Survival System (`SurvivalManager.cs`)
- **Purpose**: Manages player's vital stats (hunger, thirst, temperature, energy)
- **Key Features**:
  - Real-time decay of survival stats
  - Critical state warnings
  - Death conditions
  - UI integration
- **Testing**: Stats decay every 3.6 seconds for quick testing

#### 2. Player Controller (`PlayerController.cs`)
- **Purpose**: First-person movement and interaction system
- **Controls**:
  - WASD: Movement
  - Mouse: Look around
  - Shift: Run (costs energy)
  - E: Interact with objects
  - I: Open inventory
  - Esc: Toggle cursor/pause

#### 3. Day/Night Cycle (`DayNightCycle.cs`)
- **Purpose**: Environmental time system with alien anomalies
- **Features**:
  - 10-minute day cycle (configurable)
  - Temperature effects (day warmth, night cold)
  - Random anomalies with visual glitches
  - Lighting changes

#### 4. Narrative System (`NarrativeManager.cs`)
- **Purpose**: Progressive story revelation
- **Timeline**:
  - 5 minutes: First anomaly hints
  - 15 minutes: Electronic disturbances
  - 30 minutes: Full experiment revelation
- **Elements**: Environmental notes, glitch effects, triggered events

#### 5. Choice System (`ChoiceManager.cs`)
- **Purpose**: Major decision point and ending system
- **Choices**:
  - Continue Survival: Follow experiment protocol
  - Start Rebellion: Wake other subjects and escape
- **Endings**: 4 different scenarios based on choices and performance

### Game Flow

```
Start → Forest Spawn → Survival Phase → Anomaly Discovery → 
Choice Point → Ending (Survival Success/Failure OR Rebellion Success/Failure)
```

### Testing Features

#### Debug Commands
- **R + Ctrl**: Restart game
- **Q + Ctrl**: Quit game
- **Context Menu** on `DayNightCycle`: "Trigger Anomaly"
- **Context Menu** on `WildlifeAI`: "Toggle Algorithmic Behavior"

#### Survival Stat Testing
Stats decay quickly for testing (3.6 seconds = 1/1000th hour). Modify `SurvivalManager` decay rates for different testing speeds.

#### Narrative Testing
Change the threshold times in `NarrativeManager` to trigger story events faster:
```csharp
[SerializeField] private float survivalTimeThreshold1 = 30f;  // 30 seconds instead of 5 minutes
[SerializeField] private float survivalTimeThreshold2 = 60f;  // 1 minute instead of 15 minutes
[SerializeField] private float survivalTimeThreshold3 = 120f; // 2 minutes instead of 30 minutes
```

### Architecture

#### Event System
The game uses a decoupled event system for communication between components:
- `SurvivalManager.OnStatChanged` → Updates UI
- `PlayerController.OnInteractableChanged` → Shows interaction prompts
- `NarrativeManager.OnExperimentRevealed` → Enables choice system
- `ChoiceManager.OnGameEnding` → Triggers ending sequences

#### ScriptableObject System
Items use ScriptableObjects for data-driven design:
- `ItemData.cs`: Base item properties
- `ItemDatabase.cs`: Creates sample items
- Easy to add new items without code changes

### Adding Content

#### New Items
1. Create new `ItemData` ScriptableObject
2. Configure properties (name, type, effects)
3. Add to inventory through `CollectableResource` components

#### New Anomalies
1. Add new `NarrativeEvent` to `NarrativeManager`
2. Set trigger conditions
3. Implement visual/audio effects in `UpdateEnvironmentForStage()`

#### New Endings
1. Add new `EndingType` enum value in `ChoiceManager`
2. Implement ending logic in `TriggerEnding()`
3. Create ending scene or UI

### Performance Notes

#### Procedural Generation
- `ForestGenerator` creates environment on start
- Use "Regenerate Forest" context menu for testing
- Adjust forest size and density for performance

#### AI Systems
- `WildlifeAI` uses coroutines for behavior
- Multiple animals can be expensive
- Consider object pooling for larger scenes

### Known Limitations

1. **No 3D Models**: Current implementation uses primitive shapes
2. **Basic Audio**: No sound effects or music implemented
3. **Simple UI**: Functional but not polished
4. **No Persistence**: No save game system yet

### Future Enhancements

1. **Art Assets**: Replace primitives with proper 3D models
2. **Audio System**: Add atmospheric sounds and music
3. **Advanced AI**: More complex wildlife behaviors
4. **Multiplayer**: Co-op survival experience
5. **Mod Support**: Allow community content

### Troubleshooting

#### Common Issues
- **Missing references**: Assign components in Unity Inspector
- **No movement**: Check if cursor is locked (press Esc)
- **No anomalies**: Wait for timer or use debug command
- **UI not showing**: Ensure UI components are assigned in `UIManager`

#### Performance Issues
- Reduce forest size in `ForestGenerator`
- Lower animal count
- Disable unnecessary visual effects

### Contributing

1. Fork the repository
2. Create feature branch
3. Test thoroughly
4. Submit pull request with description

The game is designed to be modular and expandable, making it easy to add new features and content.
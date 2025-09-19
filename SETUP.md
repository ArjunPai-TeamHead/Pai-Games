# Mars Survival Roblox Game - Setup Instructions

## Quick Setup for Roblox Studio

This guide will help you set up the Mars Survival game in Roblox Studio.

### Prerequisites
- Roblox Studio installed
- Basic knowledge of Roblox Studio interface

### Step-by-Step Setup

#### 1. Create New Place
1. Open Roblox Studio
2. Create a new Baseplate experience
3. Save your place with a descriptive name like "Mars Survival Game"

#### 2. Set up Folder Structure
Create the following folder structure in your game:

```
ReplicatedStorage/
├── GameConfig (ModuleScript)
└── RemoteEvents (Folder) [This will be auto-created by scripts]

ServerScriptService/
├── GameManager (Script)
├── WorldGenerator (Script)
├── ProgressionSystem (Script)
└── HostileMobSystem (Script)

StarterPlayerScripts/
├── PlayerController (LocalScript)
└── UIManager (LocalScript)
```

#### 3. Import Scripts

**Step 3a: ReplicatedStorage Scripts**
1. In ReplicatedStorage, create a ModuleScript named "GameConfig"
2. Copy the contents of `src/ReplicatedStorage/GameConfig.lua` into this script

**Step 3b: ServerScriptService Scripts**
1. In ServerScriptService, create a Script named "GameManager"
2. Copy the contents of `src/ServerScriptService/GameManager.lua` into this script
3. Repeat for "WorldGenerator", "ProgressionSystem", and "HostileMobSystem"

**Step 3c: StarterPlayerScripts Scripts**
1. In StarterPlayer > StarterPlayerScripts, create a LocalScript named "PlayerController"
2. Copy the contents of `src/StarterPlayerScripts/PlayerController.lua` into this script
3. Repeat for "UIManager"

#### 4. Configure Game Settings

**Lighting Setup:**
- Set Lighting.Technology to "Future"
- Set Lighting.Ambient to Color3.new(0.4, 0.2, 0.1) for Mars atmosphere

**Spawn Location:**
- Place spawn location at coordinates (0, 5, 0)
- This will be near the central trading post

#### 5. Test the Game

1. Click "Play" in Roblox Studio
2. Your character should spawn with:
   - Mars gravity (higher jumps, faster movement)
   - Helmet visual effect
   - Survival UI showing Oxygen, Energy, Warmth, and Hunger
   - Day/night cycle information

#### 6. Verify Core Systems

**Test Mining:**
- Press "1" to select drill tool
- Click on generated mineral deposits to mine resources
- Check inventory with "I" key

**Test Trading:**
- Walk to the central trading post (large black building)
- Press "E" to interact or "T" to open trading interface
- Buy and sell resources

**Test Building:**
- Press "2" to select building tool
- Press "B" to open building menu
- Try building basic structures

**Test Jobs:**
- Find the job board near the trading post
- Press "J" to open job panel
- Take available jobs for credits and experience

### Advanced Configuration

#### Customizing Game Balance
Edit values in the GameConfig script to adjust:
- Survival decay rates
- Resource spawn rates  
- Building costs
- Job payouts
- Experience requirements

#### Adding Custom Content
- Modify WorldGenerator to add new structures or terrain features
- Add new resource types in GameConfig
- Create new building types with custom costs
- Add new job types with unique requirements

### Troubleshooting

**Common Issues:**

1. **Scripts not running:**
   - Ensure scripts are in the correct service folders
   - Check Output window for error messages
   - Verify all script names match exactly

2. **UI not appearing:**
   - Make sure UIManager LocalScript is in StarterPlayerScripts
   - Check that PlayerController is also present
   - Verify ReplicatedStorage has GameConfig

3. **No world generation:**
   - Ensure WorldGenerator script is in ServerScriptService
   - Check that the script isn't disabled
   - Look for terrain generation in the workspace

4. **Remote events not working:**
   - Scripts auto-create remote events in ReplicatedStorage
   - If issues persist, manually create a "RemoteEvents" folder in ReplicatedStorage

### Performance Tips

- For better performance on lower-end devices:
  - Reduce DEPOSIT_COUNT in WorldGenerator
  - Decrease MAX_MOBS in HostileMobSystem
  - Lower update frequencies in survival decay

### Publishing Your Game

1. File > Publish to Roblox As...
2. Choose appropriate settings:
   - Set to Public if you want others to play
   - Add proper description and thumbnail
   - Set appropriate genre (Adventure/Roleplay)

### Next Steps

Once the basic game is working:
1. Add custom 3D models to replace primitive shapes
2. Implement sound effects and music
3. Add more complex building mechanics
4. Create multiplayer features
5. Add seasonal events and updates

---

## Support

If you encounter issues:
1. Check the Output window in Roblox Studio for error messages
2. Review this setup guide to ensure all steps were followed
3. Verify script contents match the source files exactly

The game includes comprehensive debugging output in the console to help identify issues.

## Features Overview

Your Mars Survival game includes:
- ✅ Complete survival system (4 vital stats)
- ✅ Mining and resource collection (5 resource types)
- ✅ Trading economy with dynamic pricing
- ✅ Building system (6+ structure types)
- ✅ Job system (5 different jobs)
- ✅ Day/night cycle with hostile mobs
- ✅ Progression system with ranks and skills
- ✅ Rocket building endgame content
- ✅ Planet creation ultimate goal
- ✅ Comprehensive UI for all systems
- ✅ Achievement and experience systems

Start your Mars colonization adventure today!
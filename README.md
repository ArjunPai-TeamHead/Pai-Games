# Mars Survival

An immersive open-world Roblox survival game set on the harsh Martian surface. Begin your journey with a basic shelter and work your way towards building your own rocket or even creating your own planet!

## Game Overview

Mars Survival is a comprehensive survival experience where players must overcome the challenges of living on Mars while progressing through an extensive technological tree that leads to space exploration and planetary creation.

### 🎮 Core Gameplay Features

#### Day Cycle Activities
- **Resource Collection**: Mine different minerals with varying rarity and value (Iron, Copper, Titanium, Rare Earth Elements, Ice)
- **Trading Economy**: Sell your resources at designated trading posts with fluctuating market prices
- **Progression System**: Earn XP, level up skills, and unlock new abilities across 5 skill trees
- **Job System**: Take on various roles (Miner, Engineer, Scientist, Security, Trader) to earn additional income

#### Night Cycle Challenges
- **Security Management**: Defend your base from hostile mobs (Dust Devils, Mars Spiders, Sand Crawlers)
- **Player Interactions**: Protect your resources from potential raiders
- **Strategic Defense**: Invest in security systems to safeguard your hard-earned materials

#### Advanced Progression
- **Rocket Science**: Research and construct your own spacecraft from scratch with 5 major components
- **Planetary Development**: Design and build your own customized planet with multiple biomes
- **Rank System**: Climb the hierarchy from Settler → Engineer → Scientist → Commander → Pioneer

### 🛠️ Technical Features

- **Procedurally Generated Environment**: Mars surface with mineral deposits, craters, and atmospheric effects
- **Dynamic Day/Night Cycle**: 8-minute cycles affecting gameplay mechanics and survival rates
- **Player-Driven Economy**: Fluctuating market prices and resource-based trading system
- **Robust Base Building**: Multiple structure types with different functions and defense capabilities
- **Survival Mechanics**: Manage Oxygen, Energy, Warmth, and Hunger in the harsh Martian environment
- **PvP and PvE Elements**: Night-time hostile creatures and potential player conflicts

### 🚀 Game Progression Path

1. **Survival Phase**: Learn basic survival on Mars, manage your life support systems
2. **Resource Gathering**: Begin mining operations and establish your first income streams
3. **Base Building**: Construct shelters, defense systems, and resource processing facilities
4. **Skill Development**: Level up in Mining, Engineering, Survival, Combat, and Science
5. **Advanced Technology**: Start rocket construction projects requiring rare materials
6. **Space Exploration**: Launch rockets and unlock planetary creation capabilities
7. **World Building**: Create and customize your own planets with unique biomes and features

## Project Structure

```
src/
├── ReplicatedStorage/
│   └── GameConfig.lua          # Central game configuration and balancing
├── ServerScriptService/
│   ├── GameManager.lua         # Main server-side game controller
│   ├── WorldGenerator.lua      # Mars environment and structure generation
│   └── ProgressionSystem.lua   # Player advancement and endgame content
├── StarterPlayerScripts/
│   └── PlayerController.lua    # Client-side player controls and UI
└── Workspace/                  # Generated world content
```

## Getting Started

### For Players
1. Join the Roblox game (when published)
2. Start with basic survival - manage your life support systems
3. Use the mining drill (key 1) to collect resources from mineral deposits
4. Trade resources at trading posts for credits
5. Build structures to improve your survival chances
6. Progress through jobs and skill levels
7. Eventually build rockets and create planets!

### For Developers
1. Clone this repository
2. Import the scripts into Roblox Studio
3. Set up the folder structure as shown above
4. Place scripts in their respective service folders
5. Test in Roblox Studio

### Controls
- **WASD**: Movement (enhanced for Mars gravity)
- **Mouse**: Look around
- **1**: Select Mining Drill
- **2**: Select Building Tool  
- **3**: Select Trading Interface
- **E**: Interact with objects
- **I**: Toggle Inventory (planned)
- **J**: Toggle Job Panel (planned)

## Game Systems

### Survival System
Four critical life support stats that decay over time:
- **Oxygen**: Essential for breathing, decays faster at night
- **Energy**: Required for activities, restored by rest
- **Warmth**: Critical during cold Martian nights
- **Hunger**: Managed through food resources and greenhouse production

### Mining and Resources
- **Iron**: Common building material, foundation of most structures
- **Copper**: Used in electronics and advanced systems
- **Titanium**: High-strength material for rockets and advanced buildings
- **Rare Earth Elements**: Critical for advanced technology and planet creation
- **Ice**: Essential for life support, oxygen, and water production

### Building System
- **Basic Shelter**: Provides protection and reduces survival decay
- **Advanced Shelter**: Better protection with enhanced life support
- **Mining Drill**: Automated resource collection
- **Defense Turret**: Protection against hostile creatures
- **Solar Panel**: Power generation for advanced systems
- **Greenhouse**: Food production facility

### Progression Features
- **5 Skill Trees**: Mining, Engineering, Survival, Combat, Science
- **Rank Advancement**: 5 ranks from Settler to Pioneer
- **Achievement System**: Major milestones with experience rewards
- **Job System**: 5 different jobs with unique pay rates and skill bonuses

### Endgame Content
- **Rocket Building**: 5-component spacecraft construction
- **Planetary Creation**: 4-component planet building system
- **Multiple Biomes**: Desert, Forest, Ocean, and Mixed planetary environments
- **Victory Conditions**: Complete technological mastery and world creation

## Development Status

✅ **Completed Features**:
- Core survival mechanics with 4-stat system
- Day/night cycle with visual and gameplay effects
- Mining system with 5 resource types
- Trading economy with dynamic pricing
- Basic building and defense systems
- Skill progression and experience system
- Job system with 5 different roles
- Rocket building progression
- Planet creation system
- Achievement and ranking systems
- Mars environment generation
- Atmospheric effects (dust storms)

🚧 **In Progress**:
- Enhanced UI for inventory management
- Advanced crafting system
- Multiplayer interaction systems
- Save/load player progress

🔄 **Planned Features**:
- Mobile device support
- Enhanced visual effects
- Music and sound design
- Community features and leaderboards
- Seasonal events and updates

## Technical Implementation

### Architecture
- **Event-Driven Design**: Server-client communication through RemoteEvents
- **Modular Systems**: Each major system is self-contained and extensible
- **Data-Driven Configuration**: Centralized balancing through GameConfig
- **Scalable Progression**: Easy to add new content and features

### Performance Considerations
- **Efficient Update Loops**: Heartbeat-based systems for smooth performance
- **Procedural Generation**: Reduces memory usage through algorithmic content creation
- **Client-Server Balance**: Appropriate distribution of processing load

## Contributing

This is an open-source project welcoming contributions:

1. **Bug Reports**: Use GitHub issues to report problems
2. **Feature Requests**: Suggest new gameplay features or improvements
3. **Code Contributions**: Fork, improve, and submit pull requests
4. **Testing**: Help test new features and provide feedback

### Development Guidelines
- Follow Roblox Lua coding standards
- Maintain modular, documented code
- Test all changes thoroughly
- Consider game balance in modifications

## License

This project is licensed under the Creative Commons License - see the LICENSE file for details.

## Roadmap

### Version 1.1 (Upcoming)
- Enhanced UI and inventory management
- Advanced crafting recipes
- Player-to-player trading
- Guild/colony systems

### Version 1.2 (Future)
- Multiple planets to explore
- Advanced terraforming mechanics
- Interplanetary travel system
- Competitive elements and leaderboards

### Version 2.0 (Long Term)
- Mobile platform support
- Advanced graphics and effects
- Community-generated content tools
- Seasonal events and storylines

---

**Start your journey on Mars today - from humble settler to master of worlds!**
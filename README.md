Simplified Flight Sim - Extended Edition
A lightweight flight simulation framework based on Godot 4.x, supporting aircraft, helicopters and spacecraft.
Project Origin
This project is a secondary development based on the open-source repository:
https://github.com/fbcosentino/godot-simplified-flightsim
Original Author: fbcosentino
Original License: MIT License
This extended project continues to use the MIT open-source license.
Features
Retained Original Features
Complete flight physics: lift, drag, aerodynamic heating and gravity simulation
Modular architecture for quickly creating various aircraft
Energy system: fuel tanks, battery and energy distribution logic
Dual world modes: linear world / spherical planetary world
Standard aircraft modules: engine, steering, flaps, landing gear and instruments
New Extended Features (Added by Me)
Static ground target system (drone targets for attack practice)
Forward automatic target locking system (RayCast detection)
Homing missile system: launch, automatic tracking, hit and destroy logic
Complete collision judgment and exception protection, stable operation
Runtime Environment
Game Engine: Godot Engine 4.6 or above
Programming Language: GDScript
License: MIT License
How to Run
Clone or download this project locally.
Open Godot Engine, import project.godot in the root directory.
Open the example scene and press F5 to start the game.
Controls
Basic Flight Controls
Pitch Up - W: Nose climb
Pitch Down - S: Nose dive
Roll Left - A: Bank left
Roll Right - D: Bank right
Yaw Left - Q: Rudder left
Yaw Right - E: Rudder right
Afterburner - Shift: Boost engine thrust
Aircraft Equipment
Start Engine - P: Turn on the engine
Stop Engine - O: Turn off the engine
Throttle Up - F: Increase engine power
Throttle Down - V: Decrease engine power
Flaps Up - G: For high-speed flight
Flaps Down - B: For takeoff, landing and low speed
Landing Gear Up - J: Retract landing gear
Landing Gear Down - M: Deploy landing gear
New Combat System
Switch Weapon - Z: Toggle between air-to-air missile and air-to-ground missile
Look Behind - X: Switch to rear view, press again to revert
Fire Homing Missile - Right Mouse Button: Auto lock forward target and launch missile
Project Structure

## 📁 Project Structure

```
├── addons/
│   └── simplified_flightsim/     # Core flight simulation addon
│       ├── Aircraft/             # Main aircraft node
│       └── aircraft_modules/     # All module implementations
│           ├── Engine/
│           ├── Steering/
│           ├── Flaps/
│           ├── LandingGear/
│           ├── EnergyContainer/
│           └── Instruments/
├── example/                      # Example game with combat system
│   ├── Example1_Simple.gd        # Main game scene (air combat demo)
│   ├── scenes/
│   │   ├── Airplane/            # Aircraft models (Airplan1, Airplan2)
│   │   ├── AirEnemy/            # Enemy AI fighters
│   │   ├── GroundEnemy/         # Ground targets
│   │   ├── Missile/             # Missile types (AAM, AGM)
│   │   ├── CombatHUD/           # Combat interface
│   │   └── LockUI/              # Target locking system
│   ├── sfx/                     # Sound effects (CC0 licensed)
│   └── textures/                # Art assets (CC0 licensed)
├── docs/                        # Documentation images
├── LICENSE                      # MIT License
└── README.md                    # This file
```

## 🛠️ Usage Guide

### Basic Setup - Creating Your Own Aircraft

1. Add an `Aircraft` node to your scene
2. Add a `CollisionShape3D` as child (primitive shape recommended)
3. Add desired modules as children:
   ```
   Aircraft (RigidBody3D)
   ├── CollisionShape3D          # Required - primitive shape
   ├── CollisionShape3D          # For landing gear
   ├── Engine                    # Propulsion
   ├── Steering                  # Control surfaces
   ├── Flaps                     # Lift enhancement
   ├── LandingGear               # Gear system
   └── EnergyContainer           # Fuel tank
   ```

4. Configure parameters in the Inspector panel
5. Connect module signals to your UI nodes

### Module Configuration

Each module has these common properties:
- **Module Type**: String identifier (e.g., "engine", "steering")
- **Module Tags**: Array of strings for filtering (e.g., "left", "right")
- **Receive Input**: Enable if module processes player input
- **Process Physics**: Enable if module runs physics code
- **Uses Energy**: Enable if module consumes fuel/power

### Customizing Aircraft Models

The example includes two CSG-based aircraft models:
- **Airplan1** (`airplan1_model.gd`) - Stealth fighter style
- **Airplan2** (`airplan2_model.gd`) - Compact fighter style

Both are generated entirely in code using CSG nodes - no external 3D models required! You can modify them or create your own by editing the GDScript files.

## 📚 Documentation

- **Full API Reference**: See the inline documentation in `addons/simplified_flightsim/Aircraft/Aircraft.gd`
- **Module System**: Each module has detailed comments explaining parameters
- **Examples**: 4 complete examples demonstrating different use cases:
  1. Simple airplane with basic instruments
  2. Complex multi-engine plane with full systems
  3. Helicopter/quadcopter simulation
  4. Spaceship with spherical planetary physics

## 🔧 Technical Details

### Physics Implementation
- **Lift Equation**: Based on NASA's lift formula with configurable lift factor
- **Drag Equation**: 3-axis drag with separate coefficients per direction
- **Temperature Model**: Stagnation heating + radiation cooling (Stefan-Boltzmann law)
- **Mach Number**: Configurable scaling for small maps
- **Gravity**: Normalized to Earth (1.0 = Earth gravity)

### Performance Optimized
- All physics run in `_physics_process()` at fixed timestep
- Modules only process when enabled
- Optional temperature calculations (disable if not needed)
- Efficient energy budgeting system

## 🎨 Assets & Licensing

This project uses only open-source assets:

### Code & Design
- **Flight Sim Library**: MIT License - Copyright (c) 2022 fbcosentino
- **Example Game Code**: MIT License

### Art Assets (All CC0/Public Domain)
- **Textures**: Kenney Prototype Textures (CC0) - [kenney.nl](https://www.kenney.nl)
- **Sound Effects**: From OpenGameArt (various CC0 licenses)
  - Engine sounds, explosion, flaps, landing gear
- **Fonts**: Pixel font (included)
- **Aircraft Models**: Generated in-code (CSG), no external files needed

See individual license files in `example/sfx/` and `example/textures/` directories.

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

1. **Report Bugs**: Open an issue describing the problem
2. **Suggest Features**: Open an issue with your idea
3. **Submit Pull Requests**:
   - Fork the repository
   - Create a feature branch
   - Make your changes
   - Test thoroughly in Godot
   - Submit PR with clear description

### Development Guidelines
- Follow Godot's coding style (GDScript)
- Comment complex physics calculations
- Keep modules modular and reusable
- Test on both linear and spherical world modes
- Update documentation for new features

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2022 fbcosentino

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
```

## 🙏 Acknowledgments

- **Fernando Cosentino (fbcosentino)** - Original flight simulation library author
- **Kenney** - Excellent CC0 game assets
- **OpenGameArt Community** - Sound effects and resources
- **Godot Engine Team** - Amazing open-source game engine

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/wquu351/godot-combat-flightsim/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/flight-sim/discussions)
- **Godot Forums**: Search for "simplified flightsim"

---

**Happy Flying!** ✈️🎮

*Built with ❤️ using Godot Engine*

# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Prat is a World of Warcraft 1.12.1 (Vanilla/Classic WoW) addon that provides a modular framework for chat customization. It's built on the Ace2 library framework and uses a plugin-based architecture where individual modules handle specific chat features.

## Architecture

### Core Structure
- **Prat.lua**: Main addon file that initializes the Ace2 framework and provides the core addon structure
- **Prat.toc**: WoW Table of Contents file defining addon metadata, dependencies, and file load order
- **modules/**: Individual feature modules that extend chat functionality
- **libs/**: Ace2 library dependencies (AceAddon-2.0, AceConsole-2.0, AceDB-2.0, etc.)
- **frames/**: XML UI frame definitions (popup.xml, who.xml)
- **font/**: Custom font files for Unicode support

### Module System
Each module in the `modules/` directory is a self-contained feature that follows the Ace2 module pattern:
- Uses AceLibrary for localization and core functionality
- Registers with the main Prat addon via AceModuleCore-2.0
- Provides configuration options through the Waterfall-1.0 GUI system
- Can hook into WoW chat events and modify chat behavior

### Key Modules
- **LFGAlerts.lua**: Most recently modified module for raid group finding alerts
- **PlayerNames.lua**: Handles player name formatting and class coloring
- **Timestamps.lua**: Adds timestamp functionality to chat messages
- **ChannelColorMemory.lua**: Manages channel color persistence
- **PopupMessage.lua**: Creates popup notifications for specific chat events

## Development Commands

This is a WoW addon project with no traditional build system. Development workflow:

### Testing
- Install addon in WoW Interface/Addons directory
- Test in-game using `/prat` (GUI) or `/pratcl` (console commands)
- Reload UI in-game with `/reload` after code changes

### Version Management  
- Update version in `Prat.toc` file (currently v1.0.11)
- Version follows semantic versioning pattern

## File Modification Guidelines

### Adding New Modules
1. Create new .lua file in `modules/` directory
2. Follow existing module pattern with AceLibrary localization
3. Add module file path to `Prat.toc` in the modules section
4. Implement standard Ace2 module structure with OnEnable/OnDisable methods

### Modifying Existing Modules
- Preserve existing localization structure (enUS, ruRU, zhCN, koKR)
- Maintain backward compatibility with saved variables
- Follow existing coding patterns for consistency

### TOC File Updates
When adding new files, update `Prat.toc` in the appropriate section:
- Libraries load first
- Core Prat.lua loads next  
- Modules load after core
- Frame XML files load last

## Localization
The addon supports multiple languages through AceLocale-2.2:
- English (enUS) - base language
- Russian (ruRU) 
- Chinese Simplified (zhCN)
- Korean (koKR)

All user-facing strings should be localized in module files using the L["string"] pattern.
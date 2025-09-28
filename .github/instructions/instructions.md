---
applyTo: '**'
---
# Project Overview
This project is a collection of quest file in lua and perl for the EQEMU Everquest Server Emulator. It uses the Spire quest API.


## Folder Structure
- `quests/@docs`: Contains multiple files and folders that contain the functions and methods that the Spire quest API uses.
- `quests/@docs/constants`: Contains multiple files with information about the API constants.
- `quests/@docs/events`: Contains multiple files with information about EVENTS
- `quests/@docs/methods`: Contains multiple files with information about METHODS. 
- `quests/@tools`: Contains tooling for working with quest file.s
- `quests/global`: Contains quest scripts that are global to any npcs. 
- `quests/plugins`: Contains quest plugins. These are modules that can be referenced and used in any other script. 

## Important Context Files
- `quests/@docs/quest-loading.md` describes how the quest files are loaded in the EQEMU server.

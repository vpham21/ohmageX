# ohmage MWF vDW - Dragon Well (龍井) 

[ohmage](http://ohmage.org/) is an open-source, mobile to web platform that records, analyzes, and visualizes data from both prompted experience samples entered by the user, as well as continuous streams of data passively collected from sensors or applications onboard the mobile device. 

**ohmage MWF version DW** is a revamped version of ohmage MWF, which aims to deliver a single-source and platform-independent mobile application integrated with the Ohmage API. It includes enhancements such as a modular event-driven architecture with [Backbone](http://backbonejs.org/) + [Marionette](http://marionettejs.com/), automated development workflow enhancements, and extensive use of preprocessors (e.g. [Coffeescript](http://coffeescript.org/) and [SASS](http://sass-lang.com/)).

## Installation and Setup

- [Installation Instructions (wiki)](https://github.com/ucla/ohmage-mwf-dw/wiki/Installation-Instructions)
- [Build Dependencies (wiki)](https://github.com/ucla/ohmage-mwf-dw/wiki/Build-Dependencies)
  - [Versions, IDs and Naming (wiki)](https://github.com/ucla/ohmage-mwf-dw/wiki/Versions,-IDs-and-Naming)

## Development using **ohmage-mwf-DW**

- [Development Workflow (wiki)](https://github.com/ucla/ohmage-mwf-dw/wiki/Development-Workflow)

## Version Notes

> The name "Dragon Well" comes from a variety of Chinese green tea (龍井茶).

#### 0.1.0 - First Release

Includes the following functionality:

- Header
  - Header navigation list
  - Slot for dynamic header navigation button

- Footer
  - Simple footer template

- Login Page
  - Login / password form
  - Save auth via hashed password
  - Switch servers
  - Show login failure error messages

- Campaign List
  - Multiple Campaign status
  - Sync campaigns from server
  - Filter Campaigns by saved / unsaved
  - Campaign search box with fuzzy filtering

- Save and Unsave Campaigns
  - Save campaigns to localstorage
  - Remove campaigns and associated surveys on remove
  - store campaign XML on save

- Saved Surveys List
  - List all surveys
  - Filter surveys dropdown
  - running and "ghosted" survey states based on parent campaign

- Survey Taking
  - Parse survey XML into survey flow
  - Render All Prompts in sequence
  - Prompt validation rules from XML, with basic error alert
  - Previous, Skip and Next buttons
  - Survey intro, before Submit and After Submit steps
  - Conditional parser (based on old parser)
  - Confirmation warning on survey exit

- Survey Upload
  - Upload responses with timestamp and geolocation
  - Upload images object hash with UUIDs

- Logout
  - Clear hashed password
  - Confirmation warning on logout

#### 0.0.1 - Initial Setup

- Set up Phonegap, Backbone + Marionette, and vendor libraries

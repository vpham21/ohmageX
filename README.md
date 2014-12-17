# ohmage MWF vDW - Dragon Well (龍井) 

[ohmage](http://ohmage.org/) is an open-source, mobile to web platform that records, analyzes, and visualizes data from both prompted experience samples entered by the user, as well as continuous streams of data passively collected from sensors or applications onboard the mobile device. 

**ohmage MWF version DW** is a revamped version of ohmage MWF, which aims to deliver a single-source and platform-independent mobile application integrated with the Ohmage API. It includes enhancements such as a modular event-driven architecture with [Backbone](http://backbonejs.org/) + [Marionette](http://marionettejs.com/), automated development workflow enhancements, and extensive use of preprocessors (e.g. [Coffeescript](http://coffeescript.org/) and [SASS](http://sass-lang.com/)).

## Installation and Setup

#### Prerequisites

* Ruby 2.1+
* Node.js 0.10+
* Java JDK 1.6+


#### Build Web Assets

Install dependencies for local build:

```
bundle
npm install
```

Compile assets with WebBlocks:

```
node_modules/grunt-cli/bin/grunt exec:blocks_build
```

Compile assets with Grunt:

```
node_modules/grunt-cli/bin/grunt dev
```

If files in `/blocks` weren't updated, you may skip the WebBlocks build.


#### Build Cordova for iOS

The following task prepares the app for mobile builds, and is required before the first mobile build:

```
grunt mobile_firstrun
```

After this, the mobile app can be built at any time with the following:

```
grunt mobile_www_build
```

Note that `mobile_www_build` creates a build with updated contents of the `www` folder. If other assets need to be updated in the build, check the **Cordova Build Process Notes** section.

##### Troubleshooting

During the first time that `mobile_www_build` is executed, Grunt may stop it with an error. The error resolves if the `mobile_www_build` task is repeated again.


##### Cordova Build Process Details

`grunt mobile_firstrun` does the following:

- cleans any mobile build folders, if they exist
- creates a cordova project in a build folder
- creates a hybrid_build folder containing only core assets, that are copied to the build folder
- overwrites the base config.xml with a custom config.xml
- replaces default icon and splash screens with custom icons
- adds cordova target platforms (defined in Gruntfile)
- adds plugins (defined in Gruntfile)

This task may be run again at any time if major changes to any of these assets are made.

There are also individual Grunt tasks, defined in the Gruntfile, for each of these actions, if needed to be performed separately.

##### Note on Using `cordovacli` tasks

If you need to execute a Grunt `cordovacli` task, you must navigate to the Cordova project build folder first. `cordovacli` tasks will **only** execute in the current directory that the `grunt` command is executed in, regardless of `options.path` settings in the `Gruntfile`. This is an open issue on the Github page for `cordovacli` [https://github.com/csantanapr/grunt-cordovacli/issues/12](https://github.com/csantanapr/grunt-cordovacli/issues/12). 

The `mobile_firstrun` task executes in the root folder without issues, and avoids this problem by executing a custom `grunt-exec` task with a forced `cwd` context from the shell.


## Development using **ohmage-mwf-DW**

- [Development Workflow (wiki)](https://github.com/ucla/ohmage-mwf-dw/wiki/Development-Workflow)

## Version Notes

> The name "Dragon Well" comes from a variety of Chinese green tea (龍井茶).

#### 0.2.0 - GUI Release

- Build updates
  - Standardized build process

- GUI now integrated
  - Webblocks CSS and UI Components
  - Hamburger Menu
  - Progress Bar
  - Notice Regions on select pages
  - Custom Choice
  - Basic Profile Page placeholder

- Storage
  - Custom Choices now saved
  - Custom choices can be individually deleted
  - User data deleted on logout

- PhoneGap optimizations
  - status bar overlay
  - Device Detection
  - Touch event optimization

- Error handling
  - Unsupported prompt types
  - Survey Upload errors

- Login Flow
  - Multi-modal menu, shows Logged-In and Not Logged-In items
  - Redirect when not logged in


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

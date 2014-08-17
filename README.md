MissionPossible - ribot Challenge
=================================

Test project for the folks over at Ribot


I chose to develop an application that’s a bit more fun than just a simple data viewing app.
The app includes a game that the user must participate in in order to view details about the ribot team.

The game is a simple form of the popular game “Space Invaders”


Build Instructions.

- Open the Xcode project.
- Press run - that’s it.

Linked against the following Apple Frameworks:

Foundation
UIKit
SpriteKit
CoreGraphics



Limitations and Future Improvements:

- Work out a better way to control the players character. 
- Fade between different studio images that were downloaded from the API
- Implement proper caching of all ribot data to allow for offline use
- Implement a proper network queue mechanism.
- Improve graphics
- Improve sounds
- Fix bugs - there are several known bugs such as one that causes particles and projectile to be spawned at the side of the screen.
- Fix major bug that causes crash when resuming from background.
- Find a better way of getting images that aren’t returned by the API. At the moment if the image can’t be downloaded from the API then we attempt to find it on the website at a hardcoded path.


Screenshots
===========


![Home View](/Screenshots/Home.png?raw=true “Home”)
![Team Locked](/Screenshots/RibotTeam0.png?raw=true “Team Locked”)
![Team Unlocked](/Screenshots/RibotTeam1.png?raw=true “Team Unlocked”)
![Staff member](/Screenshots/ribotMember.png?raw=true “Individual staff member”)
![Game screen](/Screenshots/Game01.png?raw=true “Game screen”)
![Game screen](/Screenshots/Game02.png?raw=true “Game screen”)



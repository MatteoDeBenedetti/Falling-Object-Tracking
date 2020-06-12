# FALLING OBJECT TRACKING 

---
#### Computer Vision algorithm in Matlab to detect and save the trajectory of a falling object.
The object considered is an ellipse with 2 different black circles to be able to find the orientation as well.
4 circles at the corners give a reference and also 2 circles on the inclined plane give its position,

---

The input is a video coming from a GoPro hero 4.
The object is falling between 2 sheets of plexiglass.
Behind the plexiglass is a cartesian robot that makes it possible to automate the whole processo of dropping the object, recovering it, bringing it to a desired position, dropping it and so on.

---

This work is part of a bigger project for the Robots Mechanics exam, using the setup to estimate the physical and inertial properties of an object from its falling trajectory. 

### Scripts:

*gopro_calib.m*: The video needs to be corrected to consider the distorsion of the lens. This script estimates the distorsion parameters and saves them

*VidProcess.m*: Reads and corrects the video, detects the falling object and saves its coordinates in a file:

*FinalVideo.m*: Creates a video containing the raw input video of the falling object and an overlay of the detected object and a tray of its estimated Center of mass

---
### Example of the Final Video
For a short example of the final video (~3 sec) click on the image  
[![VIDEO](https://img.youtube.com/vi/L29NLL4a18c/0.jpg)](https://www.youtube.com/watch?v=L29NLL4a18c&feature=youtu.be)


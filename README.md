DNV is a dynamic network visualizer written in Processing. 

This visualizer handles static and mobile nodes. Static nodes are also called anchor nodes and are visualized in pink. The value of each node is visualized using a moving dot that circles around the node's unique ID. The dot moves every second, making a full revolution every 60 seconds (like the hand of a clock).
Mobile nodes are visualized in blue and does not show their value. The position of these node is inferred using the amount of data they exchange with the static nodes (the position of static nodes can be specified in a file or by drag and dropping the nodes)

The visualizer comes with some demo logs. To load the node positions press 'L' (load). To start and stop the visualization press 'P' (pause). If you want to save the position of anchor nodes (after dragging them to a new position) press 'S' (save).

NOTE: you need to copy the library "Common.jar" in a folder named 'libraries' inside the 'sketchbook' folder. For more information on how to install a library for processing go to this link: https://github.com/processing/processing/wiki/How-to-Install-a-Contributed-Library

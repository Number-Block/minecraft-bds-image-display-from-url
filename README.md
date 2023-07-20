# minecraft-bds-image-display-from-url
http server, resource pack, behavior pack that can display images from URLs that can be used with BDS

I disclaim any copyrights that I own.
The manufacturer is not responsible for any problems.

This behavior pack has been verified to work with 1.20.0.24.
This behavior pack uses the beta api.
See here for details.
https://learn.microsoft.com/en-us/minecraft/creator/documents/scriptingservers

The behavior pack is the behavior_pack/display folder inside the behavior_pack folder.
The resource pack is the resource_pack/display folder inside the resource_pack folder.

display_server/bin/display_server.exe is the http server.
Behavior packs and resource packs must be running in order for them to work.
This server uses port 8080.
The http server port can be set with the environment variable MINECRAFT_DISPLAY_PORT
If you change the port, const displayServerUrl = "http://localhost:8080/minecraft/display" in behavior_pack/display/scripts/main.js;
Also change the port of

Only players with the "display" tag can use the display function in Minecraft.
Run the command in chat as follows.

!display (width size) (image format) (image URL)

example:
!display 80 png https://images.com/minecraft/image.png

Supported image formats are png, jpg, and jpeg.


This program and others are not optimized.
It may be vulnerable, so it is recommended not to let untrusted players operate it.

Dynamic Mapvote-Map



Modify the File to add/delete maps:
/scripts/maps/store/mapvote_maps.txt

The first line should contains the Timelimit in seconds.
Example: "Time: 30"

The other Lines should contains the map-data.
Example: "Half-Life Campaign|hl_c00"

The Character '|' splits the Text.
The Text infront of the Pipe-Character it the Title that appears on the Vote-Screen.
The Text after the Pipe-Character is the name of the map.

You can also add a Breakline in the Title by adding "\n".
Example: "Half-Life\nCampaign|hl_c00"

It is possible to add a second map to the map-data.
Example: "Half-Life Campaign|hl_c00|hl_c02_a1"

If people decided to vote that Campaign,
a Vote-Window will appear that allows the people to skip the intro (goto 2nd map).

If you wanna add a Pipe-Character to the Title, then use "\|".

Vote-Screen doesn't support Unicode-Characters.



A picture is worth a thousand words.
Add a path to a Sprite to the Line like this:
"sprites/dynamic_mapvote/half-life.spr|Half-Life Campaign|hl_c00"
Then this sprite will appear on the Votescreen.

Be sure that everybody see the sprite
(Add sprite-path into dynamic_mapvote.res is it is a custom sprite).

Be sure that the resolution of the sprite is 352x160
or else it wont fit into the Vote-Screen.



The Map will be build automatically using the Text-File.
If the Text-File is missing or contains invalid Data,
then the Error will be shown as Title on the Vote-Screen and
Half-Life Campaign will be started after the Vote.

If an invalid Map gets voted,
an Error-Message appears on your Screen and the Vote-Timer will reset,
so the people can vote for a differend map.



Credits:
Map by CubeMath

Known Bugs:
Possible Softlock: If people vote for an invalid map, then people will be stuck on this map!
Bug: Disappearing Map-Parts, because there are too many Entities on the map.
  (Keep in Mind, that each Character on the Vote-Screen is an Entity)
Minor Bug: Repeating Player-Sprays

Contact:
http://steamcommunity.com/id/CubeMath/
https://discord.gg/4aYW2wx

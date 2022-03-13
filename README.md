# you-has-me

## Models
### Campaign
The highest level of organization. Consists of a collection of meta levels.  E.g. If you are familiar with classic Doom, this would be a Doom WAD.
Each metalevel can be created by a different creator. And a campaign can be composed of any collection of these metalevels.

### MetaLevel
A collection of levels. The idea is that a metalevel is also represented visually as a level, but is not really "playable", in that the metalevel does not make use of complicated update logic etc. Level select involves the player walking around a metalevel. In some RPG games like Final Fantasy, there is a "macro-scale" map where the player travels from city to city. This is a similar idea.

Think of this as a map-pack for a particular game.
In DOOM, this would be an episode, e.g. Knee Deep in the Dead.

### Outlet
An outlet are places on the boundary of a metalevel where you can travel to a connector.

### Condition
A condition determines whether an outlet is open. For example, a condition might be that your total score must be greater than a certain amount.

### Connector
A connector connects 2 metalevels, think of this as a bridge from one map-pack to another.

### Level
A level is the same concept as that in Baba is You. A level is actually playable and has complicated logic like update logic etc.

A level is a rectangular grid, possibly with layers (as with Wayne's suggestion). The idea is that we can stack layers one upon another.

The bidirectional array facilitates this. Instead of using a doubly linked list, a bidirectional array where the even indices store the non-negative integers, and the odd indices store the negative integers. So the base level layer would be 0, and if you want to add a layer below, then this layer would be of layer -1. If you want to add a layer above, this layer would be layer 1.


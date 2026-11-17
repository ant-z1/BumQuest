-> start

// outline
// The story is refactored into a conversation with an NPC guide.
// The knight goes through different choices, boss fights, and reset mechanics.

VAR name = ""

// knot 1, start: The Keeper's Greeting
=== start ===
"Ah, traveler... step forward into the light," an old man in grey robes rasps, leaning heavily on his wooden staff. "A silver knight stands before me, yet my eyes grow dim. Tell me, what name do you carry?"

+ ["I am Arthur."]
    ~ name = "Arthur"
    "Ah, Sir Arthur," the old man nods slowly. "A noble name."
+ ["Call me Lancelot."]
    ~ name = "Lancelot"
    "Sir Lancelot," the old man murmurs. "Bold and fierce."
+ ["My name is Galahad."]
    ~ name = "Galahad"
    "Sir Galahad," the old man smiles softly. "A seeker of truth."

- "Welcome, Sir {name}," the guide says, gesturing toward a swirling vortex behind him. "Your fate beckons beyond this doorway. Will you step through?"

+ ["I am ready. Send me to the first realm."]
    "Brave words, Sir {name}," the old man says, ushering you into the portal. "May light guide your blade!"
    -> forest
+ ["No... this is too much. I'm staying here."]
    The old man sighs, shaking his head. "A heavy heart makes a slow sword, traveler."
    -> short_ending


// knot 2, the forest: The Tutorial Encounter
=== forest ===
You materialize in a misty wood. The old guide's spirit hovers beside you as a glowing wisp. 

"Look closely," the wisp whispers. "A screeching goblin bars the road. Show me how you handle a blade, Sir {name}!"

+ ["Draw your sword and attack!"]
    With a single clean strike, you slay the creature. 
    "Well struck!" the wisp chuckles. "A fine warm-up. Onward to the fortress!"
    -> castle
+ ["Turn around and sprint back to the portal."]
    "Wait! Sir {name}, come back!" the guide calls out, but you flee into the mist.
    -> short_ending


// knot 3, the castle: The Boss Encounter
=== castle ===
The wisp takes human form once more at the gates of an obsidian citadel. 

"Inside sits the Overlord," the guide warns quietly. "He has brought down a hundred heroes before you. How do you intend to strike, {name}?"

+ ["I will breach the front gates and fight him head-on!"]
    "A valiant charge!" the guide shouts. 
    You kick down the doors and battle heroically, but the Overlord's raw power overwhelms you. As your vision fades, the old man kneels by your side with sorrow in his eyes.
    -> full_ending_one
+ ["Let us look for a hidden way around."]
    "Wise choice," the old man whispers, leading you to a forgotten side tunnel. 
    Deep within, you discover an ancient relic: the Amulet of Weakness.
    -> loop_ending


// knot 4: Endings & Resets
=== short_ending ===
"You turned back before your story even began," the old man says softly, turning his back on you.

End of story: The Bum
-> END

=== full_ending_one ===
"You fought like a legend, Sir {name}," the guide whispers as darkness takes you. "Yet bravery alone could not shatter his defense."

End of story: Fallen Hero. You completed the journey, but fell at the final hurdle.
-> END

=== loop_ending ===
"Fascinating!" the old man exclaims, examining the glowing amulet in your hands. "This magic exposes the Overlord's single vulnerability! With this, history can be rewritten. What will you do, Sir {name}?"

+ ["Send me back to the beginning. I'll face him again with this knowledge!"]
    "Then step back through the stream of time!" the guide chants, raising his staff.
    -> start
+ ["I have proven my craft. I accept this triumph."]
    "Then rest now, champion," the old man bows deeply. "Your legend will be sung for generations."
    
    End of story: The Master Knight. You conquered the entire journey using your newfound knowledge!
    -> END
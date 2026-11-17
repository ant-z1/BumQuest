-> start

// outline
// the story is about a knight who goes through different worlds 
// and has to conquer their leader. it starts with a small foe 
// (combat tutorial) leading to a short ending.
// the story progresses through boss fights, leading to ultimate decisions,
// to decide your ending. 
// there is a reset mechanic  that lets the user reach a new ending.


VAR name = ""

// knot 1, start
=== start ===
Once upon a time there was a silver knight.
That knight was you.
What is your name?
+ [My name is Arthur]
    ~ name = "Arthur"
+ [My name is Lancelot]
    ~ name = "Lancelot"
+ [My name is Galahad]
    ~ name = "Galahad"

- Welcome {name}! Your destiny awaits you!
Now, {name}, please enter the portal.

+ [Go to first world]
    Brave choice, Sir {name}. Let your journey begin!
    -> forest
+ [No, I want to stay home]
    // ENDING 1: The short ending (gives up immediately)
    You decide it's too dangerous and stay home.
    -> short_ending

// knot 2, the forest
=== forest ===
// First player choice, to give them a "tutorial"
You step into a dark forest. A small goblin blocks your path!
+ [Fight the goblin]
    You easily defeat the goblin in a quick tutorial battle!
    -> castle
+ [Flee back home]
    // the quick ending
    Overwhelmed by the creepy woods, you run back home and lock the door.
    -> short_ending

// knot 3, the castle
=== castle ===
// the first "real" fight
You arrive at the dark fortress doors. The final boss awaits inside.
+ [Charge in blindly]
    // full ending 1. 
    You charge in, fight bravely, but are defeated by the final boss's overwhelming power. 
    -> full_ending_one
+ [Search for a secret entrance]
    // loop back mechanic
    You discover a hidden side passage and find a magical amulet of weakness!
    -> loop_ending

// knot 4. endings and resets
=== short_ending ===
// short ending
End of story: The bum
-> END

=== full_ending_one ===
// full story ending.
End of story: Fallen Hero. You completed the whole journey, but fell at the final hurdle.
-> END

=== loop_ending ===
//loop back mechanic with new info
With the magical amulet in hand, you return to the start with new knowledge of the boss's weakness! 
+ [Restart the journey with your new knowledge]
    -> start
+ [Accept this victory]
    // last ending, with new information.
    End of story: The Master Knight. You conquered the entire story using your newfound knowledge!
    -> END
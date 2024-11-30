# Task 1: Illustrating Decidability of a Computational Problem
For this task I have chosen to illustrate the decidability of 
$A_{DFA} = \{ \langle B,w \rangle\ | B \text{ is a DFA that accepts string } w\}$.


## String Representation
For this problem I have decided to represent $\langle B,w \rangle = x$
in JSON with the following format:

```
{
    states: string[] 
    alphabet: char[]
    transitions: tuple<string, string, string>[]
    start_state: string
    accept_states: string[]
    word: string
}
```

`states` is an array of states in the DFA

`alphabet` is an array of characters in the DFA's alphabet 

`transitions` is an array of 3-tuples defining
the DFA's transition function where the first string is the
current state, the second string is the character being read,
and the third string is the output state.

`start_state` is the start state of the DFA 

`accept_states` is an array representing the set of acceptance states in the DFA

`word` is $w$, the string whose membership in $L(B)$ is being tested

## Parsing and Computation
The input string $x$ is parsed by first reading the JSON string into
a dictionary that is then destructured so each key has its own variable.

Then the program ensures that $x$ accurately represents $\langle B, w \rangle$
by making sure the `start_state` is a valid state in `states`,
`accept_states` is a subset of `states`, `word` only contains characters
from `alphabet`, and `transitions` defines the proper 
transitions such that all states have *exactly one* transition defined for every
member of the alphabet and the output of the
transition function is always a valid state, aka $\delta: Q \times \Sigma \to Q$.

After the input string is validated, the arrays are transformed to sets
and the transition function is represented as a adjacency-list like dictionary.

If any errors are thrown in the parsing and validation of $x$ the program halts
and returns `false`.

If the input $x$ is valid, the program then simulates the computation of $B$ 
on $w$ and if the computation ends in an accept state the program returns
`true`, otherwise it returns `false`.

## Example Strings
For both of the following examples, the input string represents the following
DFA from example 1.9 in the textbook where \
$L(B) = \{w | w \text{ is the empty string or ends in 0}\}$. $B$ has
the following state diagram:

![Textbook Example 1.9](textbook-1-9.png)

### Accepted String
For an accepted string let $x = \langle B, w\$ where $B$ is the 
DFA shown above and $w = 100$. Here is $x$:

```
{
    "states": ["q1", "q2"],
    "alphabet": ["0", "1"],
    "transitions": [
        ["q1", "0", "q1"],
        ["q1", "1", "q2"],
        ["q2", "1", "q2"],
        ["q2", "0", "q1"]
    ],
    "start_state": "q1",
    "accept_states": ["q1"],
    "word": "100"
}
```

This string is in the set because it properly encodes $\langle B, w \rangle$.
Additionally `word` / $w$ is in the language $L(B)$ because $100$ ends
in 0. The computation of $B$ on $w$ has the following state transitions:
$q1 \to q2 \to q1 \to q1$ and since $q1$ is an accept state the
program returns true and accepts $x$.

When running the program on this input $x$, we see the program correctly returns `true`.
Note that instead of typing the long JSON string manually, I have it saved to a file and am 
passing it in as a command line arg with `cat`.

![Running the program on example 1](part-1-example-1.png)

### Rejected String
For a rejected string let $x = \langle B, w\$ where $B$ is the 
DFA shown above and $w = 00001$. Here is $x$:

```
{
    "states": ["q1", "q2"],
    "alphabet": ["0", "1"],
    "transitions": [
        ["q1", "0", "q1"],
        ["q1", "1", "q2"],
        ["q2", "1", "q2"],
        ["q2", "0", "q1"]
    ],
    "start_state": "q1",
    "accept_states": ["q1"],
    "word": "00001"
}
```

This string is not in the set because although it properly encodes 
$\langle B, w \rangle$, $w \notin L(B)$  because it ends in a 1.
The computation of $B$ on $w$ has the following state transitions:
$q1 \to q1 \to q1 \to q1 \to q1 \to q2$ and since $q2$ is not an
accepting state, the program returns false and rejects $x$.

When running the program on this input $x$, we see the program correctly returns `false`.
Note that instead of typing the long JSON string manually, I have it saved to a file and am 
passing it in as a command line arg with `cat`.

![Running the program on example 2](part-1-example-2.png)

## Video Explanation

## Code
```elixir
```

# Task 2: Illustrating a Mapping Reduction
For this task I have chosen to illustrate the mapping reduction 
$A_{TM} \leq_m HALT_{TM}$ where $A_{TM} = \{\langle M, w \rangle | M \text{ is a Turing machine, } w \text{ is a string, and } w \in L(M)\}$ and 
$HALT_{TM} = \{\langle M, w \rangle | M \text{ is a Turing machine, } w \text{ is a string, and } M \text{ halts on } w\}$.

As defined in lecture both $A_{TM}$ and $HALT_{TM}$ are undecidable and
$A_{TM} \leq_m HALT_{TM}$ can be done with the function $F: \Sigma^* \to \Sigma^*$ 
defined as follows

$$
F = 
\begin{cases}  
const_{out} & \text{if } x \ne \langle M, w \rangle \text{ for any Turing machine } M \text{ and string } w \text{ over the alphabet of } M \\
\langle M', w \rangle & \text{if } x = \langle M, w \rangle \text{ for some Turing machine } M \text{ and string } w \text{ over the alphabet of } M \\
\end{cases}
$$

where $const_{out}$ is some constant $\langle M, w \rangle \notin HALT_{TM}$
and $M'$ is a Turing machine that computes like $M$ except if the computation
of $M$ were ever to go to a reject state, $M'$ loops instead.

## String Representation 
Similar to task 1, $\langle M, w \rangle$ is encoded as a JSON string with
the following format:

```
{
  states: string[] 
  input_alphabet: char[]
  tape_alphabet: char[]
  transitions: tuple<string, string, string, string, string>[]
  start_state: string
  accept_state: string
  reject_state: string
  word: string
}
```

`states` is an array of states in the Turing machine

`input_alphabet` is the array of characters in the Turing machine's input
alphabet

`tape_alphabet` is the array of characters in the Turing machine's tape
alphabet.

`transitions` is an array of 5 tuples specifying the Turing machine's
transition function where the first string is the input state,
the second string is the character being read, the third string is
the character to write, the fourth string is the direction to move
the tape head (either 'R' or 'L'), and the fifth string is the output state.

`start_state` is the Turing machine's starting state.

`accept_state` is the Turing machine's accept state.

`reject_state` is the Turing machine's reject state.

`word` is the input $w$, a string over the `input_alphabet`

## Parsing
Given the input string $x = \langle M, w \rangle$, the string
is first parsed as JSON into a dictionary that is then destructured
so each key has its own variable. 

The program then checks that $x = \langle M, w \rangle$ by making sure
`start_state` is a member of `states`, `input_alphabet` is a subset
of `tape_alphabet`, `accept_state` is a member of `states, `reject_state`
is a member of `states`, `word` is the string $w$ which is over
`input_alphabet` and transitions properly defines the transition
function such that all states have *exactly one* transition defined for every 
member of `tape_alphabet` and the transition is valid such that the
character being read/written is in the tape alphabet, the 
tape head is being moved either right or left, and the output state is a
member of `states`.

After the input string $x$ is validated, the arrays are transformed to sets
and the transition function is represented as a adjacency-list like dictionary.

If any errors are thrown in the parsing and validation of $x$ the program halts
and returns $const_{out}$.

## Mapping
Assuming parsing went well, the input is then mapped from $\langle M, w \rangle \in A_{TM}$
to $\langle M', w \rangle \in HALT_{TM}$ using the method described
at the start / in lecture.

A new state `loop_state` is added to the states and transition function
such that on `loop_state` the computation will loop forever because 
no matter what symbol is read, the transition function will leave the
tape unchanged, move the tape head right and stay on `loop_state`.

Then, for every transition in the transition function that goes
to `reject_state`, the transition is changed to go to `loop_state` instead.

This process then produces $M'$ from $M$ so the program then
serializes $\langle M', w \rangle$ into the same JSON format as the input
and then outputs that string.

## Examples
For both examples I'll use the following Turing machine $M$ from
the textbook figure 3.8.

![Textbook Figure 3.8](textbook-3-8.png)

This Turing machine $M$ decides $A = \{0^{2^n} | n \geq 0 \}$.

### Positive Instance
For a positive instance of a string $x = \langle M, w \rangle$ where
$M$ is a Turing machine and $w$ is a string over the Turing machine's
input alphabet, let's use the Turing machine defined above.

This Turing machine $M$ decides $A = \{0^{2^n} | n \geq 0 \}$
and the string $w$ I have chosen is $w = 0000 = 0^{2^2}$
such that $\langle M, w \rangle \in A_{TM}$ because $w \in L(A)$.
To show $w \in L(A)$, the computation of $w$ on $M$ goes as follows (read pointer is 0 indexed):

Tape: $0000\textunderscore \textunderscore \textunderscore $, State: $q1$, Read pointer in position 0 

Tape: $\textunderscore 000\textunderscore \textunderscore \textunderscore $, State: $q2$, Read pointer in position 1 

Tape: $\textunderscore x00\textunderscore \textunderscore \textunderscore $, State: $q3$, Read pointer in position 2

Tape: $\textunderscore x00\textunderscore \textunderscore \textunderscore $, State: $q4$, Read pointer in position 3

Tape: $\textunderscore x0x\textunderscore \textunderscore \textunderscore $, State: $q3$, Read pointer in position 4

Tape: $\textunderscore x0x\textunderscore \textunderscore \textunderscore $, State: $q5$, Read pointer in position 3

Tape: $\textunderscore x0x\textunderscore \textunderscore \textunderscore $, State: $q5$, Read pointer in position 2

Tape: $\textunderscore x0x\textunderscore \textunderscore \textunderscore $, State: $q5$, Read pointer in position 1

Tape: $\textunderscore x0x\textunderscore \textunderscore \textunderscore $, State: $q5$, Read pointer in position 0

Tape: $\textunderscore x0x\textunderscore \textunderscore \textunderscore $, State: $q2$, Read pointer in position 1

Tape: $\textunderscore x0x\textunderscore \textunderscore \textunderscore $, State: $q2$, Read pointer in position 2

Tape: $\textunderscore xxx\textunderscore \textunderscore \textunderscore $, State: $q3$, Read pointer in position 3

Tape: $\textunderscore xxx\textunderscore \textunderscore \textunderscore $, State: $q3$, Read pointer in position 4

Tape: $\textunderscore xxx\textunderscore \textunderscore \textunderscore $, State: $q5$, Read pointer in position 3

Tape: $\textunderscore xxx\textunderscore \textunderscore \textunderscore $, State: $q5$, Read pointer in position 2

Tape: $\textunderscore xxx\textunderscore \textunderscore \textunderscore $, State: $q5$, Read pointer in position 1

Tape: $\textunderscore xxx\textunderscore \textunderscore \textunderscore $, State: $q5$, Read pointer in position 0

Tape: $\textunderscore xxx\textunderscore \textunderscore \textunderscore $, State: $q2$, Read pointer in position 1

Tape: $\textunderscore xxx\textunderscore \textunderscore \textunderscore $, State: $q2$, Read pointer in position 2

Tape: $\textunderscore xxx\textunderscore \textunderscore \textunderscore $, State: $q2$, Read pointer in position 3

Tape: $\textunderscore xxx\textunderscore \textunderscore \textunderscore $, State: $q2$, Read pointer in position 4

Tape: $\textunderscore xxx\textunderscore \textunderscore \textunderscore $, State: $q_{accept}$, Read pointer in position 5

The computation halts in $q_{accept}$, therefore $w \in L(M)$ and 
$\langle M, w \rangle \in A_{TM}$.

Given this $\langle M, w \rangle$, $x$ is the following JSON string:

```
{
    "states": ["q1", "q2", "q3", "q4", "q5", "q_accept", "q_reject"],
    "input_alphabet": ["0"],
    "tape_alphabet": ["0", "x", "_"],
    "transitions": [
        ["q1", "_", "_", "R", "q_reject"],
        ["q1", "x", "x", "R", "q_reject"],
        ["q1", "0", "_", "R", "q2"],

        ["q2", "_", "_", "R", "q_accept"],
        ["q2", "x", "x", "R", "q2"],
        ["q2", "0", "x", "R", "q3"],

        ["q3", "_", "_", "L", "q5"],
        ["q3", "x", "x", "R", "q3"],
        ["q3", "0", "0", "R", "q4"],

        ["q4", "_", "_", "R", "q_reject"],
        ["q4", "x", "x", "R", "q4"],
        ["q4", "0", "x", "R", "q3"],

        ["q5", "_", "_", "R", "q2"],
        ["q5", "x", "x", "L", "q5"],
        ["q5", "0", "0", "L", "q5"],

        ["q_accept", "_", "_", "R", "q_accept"],
        ["q_accept", "x", "x", "R", "q_accept"],
        ["q_accept", "0", "0", "R", "q_accept"],

        ["q_reject", "_", "_", "R", "q_reject"],
        ["q_reject", "x", "x", "R", "q_reject"],
        ["q_reject", "0", "0", "R", "q_reject"]
    ],
    "start_state": "q1",
    "accept_state": "q_accept",
    "reject_state": "q_reject",
    "word": "0000"
}
```

This is a positive input to the mapping reduction function because
$x = \langle M, w \rangle$ where $M$ is a well-defined Turing machine
and $w$ is a string over $M$'s input alphabet and $\langle M, w \rangle \in A_{TM}$.
Therefore this should
result in the JSON string $\langle M', w \rangle \in HALT_{TM}$ where $w$ is unchanged
from the input and $M'$ is a Turing machine that computes like $M$ except if the computation
of $M$ were ever to go to a reject state, $M'$ loops instead. $M'$ 
should have the following state diagram: 

![M' state diagram](textbook-3-8-mapped.png)

$\langle M', w \rangle \in HALT_{TM}$ because running the computation of $M'$
on $w$ results in the following computations:

Tape: $0000 \textunderscore \textunderscore \textunderscore$, State: $q1$, Read pointer in position 0 

Tape: $\textunderscore 000\textunderscore \textunderscore \textunderscore$, State: $q2$, Read pointer in position 1 

Tape: $\textunderscore x00\textunderscore \textunderscore \textunderscore $, State: $q3$, Read pointer in position 2

Tape: $\textunderscore x00\textunderscore \textunderscore \textunderscore $, State: $q4$, Read pointer in position 3

Tape: $\textunderscore x0x\textunderscore \textunderscore \textunderscore $, State: $q3$, Read pointer in position 4

Tape: $\textunderscore x0x\textunderscore \textunderscore \textunderscore $, State: $q5$, Read pointer in position 3

Tape: $\textunderscore x0x\textunderscore \textunderscore \textunderscore $, State: $q5$, Read pointer in position 2

Tape: $\textunderscore x0x\textunderscore \textunderscore \textunderscore $, State: $q5$, Read pointer in position 1

Tape: $\textunderscore x0x\textunderscore \textunderscore \textunderscore $, State: $q5$, Read pointer in position 0

Tape: $\textunderscore x0x\textunderscore \textunderscore \textunderscore $, State: $q2$, Read pointer in position 1

Tape: $\textunderscore x0x\textunderscore \textunderscore \textunderscore $, State: $q2$, Read pointer in position 2

Tape: $\textunderscore xxx\textunderscore \textunderscore \textunderscore $, State: $q3$, Read pointer in position 3

Tape: $\textunderscore xxx\textunderscore \textunderscore \textunderscore $, State: $q3$, Read pointer in position 4

Tape: $\textunderscore xxx\textunderscore \textunderscore \textunderscore $, State: $q5$, Read pointer in position 3

Tape: $\textunderscore xxx\textunderscore \textunderscore \textunderscore $, State: $q5$, Read pointer in position 2

Tape: $\textunderscore xxx\textunderscore \textunderscore \textunderscore $, State: $q5$, Read pointer in position 1

Tape: $\textunderscore xxx\textunderscore \textunderscore \textunderscore $, State: $q5$, Read pointer in position 0

Tape: $\textunderscore xxx\textunderscore \textunderscore \textunderscore $, State: $q2$, Read pointer in position 1

Tape: $\textunderscore xxx\textunderscore \textunderscore \textunderscore $, State: $q2$, Read pointer in position 2

Tape: $\textunderscore xxx\textunderscore \textunderscore \textunderscore $, State: $q2$, Read pointer in position 3

Tape: $\textunderscore xxx\textunderscore \textunderscore \textunderscore $, State: $q2$, Read pointer in position 4

Tape: $\textunderscore xxx\textunderscore \textunderscore \textunderscore $, State: $q_{accept}$, Read pointer in position 5

The computation of $w$ on $M'$ halts at $q_{accept}$, therefore 
$\langle M', w \rangle \in HALT_{TM}$

Upon running the code on this JSON input, we get the following JSON output: 

![Running the code on example 1](part-2-example-1.png)

Note again how we use `cat` to avoid having to type the entire JSON input string and are able to read it from a file.

Here is the formatted output so it is easier to read:

```
{
   "accept_state":"q_accept",
   "input_alphabet":[
      "0"
   ],
   "reject_state":"q_reject",
   "start_state":"q1",
   "states":[
      "q1", "q2", "q3", "q4", "q5", "q_accept", "q_loop_grgat", "q_reject"
   ],
   "tape_alphabet":["0", "_", "x"],
   "transitions":[
      ["q1", "0", "_", "R", "q2"],
      ["q1", "_", "_", "R", "q_loop_grgat"],
      ["q1", "x", "x", "R", "q_loop_grgat"],
      ["q2", "0", "x", "R", "q3"],
      ["q2", "_", "_", "R", "q_accept"],
      ["q2", "x", "x", "R", "q2"],
      ["q3", "0", "0", "R", "q4"],
      ["q3", "_", "_", "L", "q5"],
      ["q3", "x", "x", "R", "q3"],
      ["q4", "0", "x", "R", "q3"],
      ["q4", "_", "_", "R", "q_loop_grgat"],
      ["q4", "x", "x", "R", "q4"],
      ["q5", "0", "0", "L", "q5"],
      ["q5", "_", "_", "R", "q2"],
      ["q5", "x", "x", "L", "q5"],
      ["q_accept", "0", "0", "R", "q_accept"],
      ["q_accept", "_", "_", "R", "q_accept"],
      ["q_accept", "x", "x", "R", "q_accept"],
      ["q_loop_grgat", "0", "0", "R", "q_loop_grgat"],
      ["q_loop_grgat", "_", "_", "R", "q_loop_grgat"],
      ["q_loop_grgat", "x", "x", "R", "q_loop_grgat"],
      ["q_reject", "0", "0", "R", "q_loop_grgat"],
      ["q_reject", "_", "_", "R", "q_loop_grgat"],
      ["q_reject", "x", "x", "R", "q_loop_grgat"]
   ],
   "word":"0000"
}
```

As you can see this JSON output correctly represents the mapped string $\langle M', w \rangle$
with the outputted $M'$ having the same specifications and state diagram as drawn above. Therefore
the program has correctly mapped this example $\langle M, w \rangle$ 
because $\langle M, w \rangle \in A_{TM} \iff \langle M', w \rangle \in HALT_{TM}$
since $\langle M, w \rangle \in A_{TM}$, the program has correctly outputted $F(\langle M, w \rangle) = \langle M', w \rangle \in HALT_{TM}$.

Note that `loop_state` / $q_{loop}$ is `q_loop_grgat` because a random length-5 string
is appended to `q_loop_` just incase `q_loop` is already a state in $M$.

### Negative Instance
For a negative instance of a string $x = \langle M, w \rangle \notin A_{TM}$ where
$M$ is a Turing machine and $w$ is a string over the Turing machine's
input alphabet, take figure 3.8 from the textbook with the input string $w = \epsilon$.

$\langle M, w \rangle \notin A_{TM}$ because the computation of $M$ on
$w$ halts in $q_{reject}$ through the following steps:

Tape: $\textunderscore \textunderscore \textunderscore $, State: $q1$, Read pointer in position 0 

Tape: $\textunderscore \textunderscore \textunderscore $, State: $q_{reject}$, Read pointer in position 1 

Given this $\langle M, w \rangle$, $x$ is the following JSON string:

```
{
    "states": ["q1", "q2", "q3", "q4", "q5", "q_accept", "q_reject"],
    "input_alphabet": ["0"],
    "tape_alphabet": ["0", "x", "_"],
    "transitions": [
        ["q1", "_", "_", "R", "q_reject"],
        ["q1", "x", "x", "R", "q_reject"],
        ["q1", "0", "_", "R", "q2"],

        ["q2", "_", "_", "R", "q_accept"],
        ["q2", "x", "x", "R", "q2"],
        ["q2", "0", "x", "R", "q3"],

        ["q3", "_", "_", "L", "q5"],
        ["q3", "x", "x", "R", "q3"],
        ["q3", "0", "0", "R", "q4"],

        ["q4", "_", "_", "R", "q_reject"],
        ["q4", "x", "x", "R", "q4"],
        ["q4", "0", "x", "R", "q3"],

        ["q5", "_", "_", "R", "q2"],
        ["q5", "x", "x", "L", "q5"],
        ["q5", "0", "0", "L", "q5"],

        ["q_accept", "_", "_", "R", "q_accept"],
        ["q_accept", "x", "x", "R", "q_accept"],
        ["q_accept", "0", "0", "R", "q_accept"],

        ["q_reject", "_", "_", "R", "q_reject"],
        ["q_reject", "x", "x", "R", "q_reject"],
        ["q_reject", "0", "0", "R", "q_reject"]
    ],
    "start_state": "q1",
    "accept_state": "q_accept",
    "reject_state": "q_reject",
    "word": ""
}
```

Same as the positive example, $M'$ should have the following state diagram 
when mapped with the program: 

![M' state diagram](textbook-3-8-mapped.png)

$w$ should still be unchanged so we would get $\langle M', w \rangle$ which is not in $HALT_{TM}$ because
the computation of $M'$ on $w$ goes as follows:

Tape: $\textunderscore \textunderscore \textunderscore $, State: $q1$, Read pointer in position 0 

Tape: $\textunderscore \textunderscore \textunderscore $, State: $q_{loop}$, Read pointer in position 1 

Tape: $\textunderscore \textunderscore \textunderscore $, State: $q_{loop}$, Read pointer in position 2

Tape: $\textunderscore \textunderscore \textunderscore $, State: $q_{loop}$, Read pointer in position 3

This cycle would then continue on $q_{loop}$ forever and $M'$ would never halt on $w$, therefore making $\langle M', w \rangle \notin HALT_{TM}$.


Upon running the code on this JSON input, we get the following JSON output: 

![Running the code on example 1](part-2-example-2.png)

Note again how we use `cat` to avoid having to type the entire JSON input string and are able to read it from a file.

Here is the formatted JSON for easier reading:

```
{
   "accept_state":"q_accept",
   "input_alphabet":[
      "0"
   ],
   "reject_state":"q_reject",
   "start_state":"q1",
   "states":["q1", "q2", "q3", "q4", "q5", "q_accept", "q_loop_xgujl", "q_reject"],
   "tape_alphabet":["0", "_", "x"],
   "transitions":[
      ["q1", "0", "_", "R", "q2"],
      ["q1", "_", "_", "R", "q_loop_xgujl"],
      ["q1", "x", "x", "R", "q_loop_xgujl"],
      ["q2", "0", "x", "R", "q3"],
      ["q2", "_", "_", "R", "q_accept"],
      ["q2", "x", "x", "R", "q2"],
      ["q3", "0", "0", "R", "q4"],
      ["q3", "_", "_", "L", "q5"],
      ["q3", "x", "x", "R", "q3"],
      ["q4", "0", "x", "R", "q3"],
      ["q4", "_", "_", "R", "q_loop_xgujl"],
      ["q4", "x", "x", "R", "q4"],
      ["q5", "0", "0", "L", "q5"],
      ["q5", "_", "_", "R", "q2"],
      ["q5", "x", "x", "L", "q5"],
      ["q_accept", "0", "0", "R", "q_accept"],
      ["q_accept", "_", "_", "R", "q_accept"],
      ["q_accept", "x", "x", "R", "q_accept"],
      ["q_loop_xgujl", "0", "0", "R", "q_loop_xgujl"],
      ["q_loop_xgujl", "_", "_", "R", "q_loop_xgujl"],
      ["q_loop_xgujl", "x", "x", "R", "q_loop_xgujl"],
      ["q_reject", "0", "0", "R", "q_loop_xgujl"],
      ["q_reject", "_", "_", "R", "q_loop_xgujl"],
      ["q_reject", "x", "x", "R", "q_loop_xgujl"]
   ],
   "word":""
}
```

As you can see this JSON output correctly represents the mapped string $\langle M', w \rangle$
with the outputted $M'$ having the same specifications and state diagram as drawn above. Therefore
the program has correctly mapped this example $\langle M, w \rangle$ 
because $\langle M, w \rangle \in A_{TM} \iff \langle M', w \rangle \in HALT_{TM}$ and
since $\langle M, w \rangle \notin A_{TM}$, the program has correctly outputted $F(\langle M, w \rangle) = \langle M', w \rangle \notin HALT_{TM}$.

Note that `loop_state` / $q_{loop}$ is `q_loop_xgujl` because a random length-5 string
is appended to `q_loop_` just incase `q_loop` is already a state in $M$.

## Video Explanation

## Code
```elixir

```


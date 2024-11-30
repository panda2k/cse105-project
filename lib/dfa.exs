defmodule Project.DFA do
  @doc"""
  Parses a DFA json string to get the formal definition of states,
  alphabet, transition function, start state, and accept states

  ## JSON DFA Format 
  {
    states: string[] 
    alphabet: char[]
    transitions: tuple<string, string, string>[]
    start_state: string
    accept_states: string[]
    word: string
  }
  states is an array of states in the DFA
  alphabet is an array of characters in the DFA's alphabet 
  transitions is an array of 3-tuples defining
  the DFA's transition function where the first string is the
  starting state, the second string is the character being read,
  and the third string is the destination state
  start_state is the start state of the DFA 
  accept_states is an array representing the set of acceptance states in the DFA
  
  ## Examples
  For an example, view `dfa_specs/ends_in_zero.json` which represents
  the finite automaton in example 1.9, or `dfa_specs/start_and_end_same.json`
  which represents the finite automaton in example 1.11
  """
  def parse_dfa(input) do
    %{ 
      "states" => states,
      "alphabet" => alphabet,
      "transitions" => transitions,
      "start_state" => start_state,
      "accept_states" => accept_states,
      "word" => word 
    } = :json.decode(input)

    states = MapSet.new(states)
    alphabet = MapSet.new(alphabet)
    accept_states = MapSet.new(accept_states)
    # map the transition 3 tuples into an adjacency list
    transitions = Enum.reduce(transitions, %{}, fn [start, label, dest], acc -> 
      Map.update(acc, start, %{label => dest}, fn existing -> Map.put(existing, label, dest) end) 
    end) 

    # assert that all accept states are members of states, aka accept_states subseteq states
    if not MapSet.subset?(accept_states, states) do
      raise "All accept states must be members of the states array"
    end

    # assert that the start start is a member of states
    if not MapSet.member?(states, start_state) do
      raise "The start state must be a member of the state array"
    end

    # assert that every state has transition rules
    if not MapSet.equal?(states, transitions |> Map.keys |> MapSet.new) do
      raise "Every state must have transitions defined"
    end
    # assert that every state has a transition for every member of the alphabet and said transition maps to a valid state
    transitions 
      |> Map.values
      |> Enum.each(fn rules -> 
        # assert that the state's rules has a rule for each alphabet character
        if not MapSet.equal?(alphabet, rules |> Map.keys |> MapSet.new) do
          raise "There must be a transition defined for every alphabet character"
        end
        # assert that every destination in the rules is a valid state

        if not MapSet.subset?(rules |> Map.values |> MapSet.new, states) do
          raise "Every destination state must be a member of the state array"
        end
      end)

    # now the DFA input is guaranteed to be valid so assert that the input string
    # is valid
    word = String.graphemes(word)
    # assert that the input string only contains characters in the alphabet
    if not MapSet.subset?(word |> MapSet.new, alphabet) do
      raise "word must only contain characters defined in the alphabet list"
    end
    {states, alphabet, transitions, start_state, accept_states, word}
  end
  
  @doc"""
  Given the path to a DFA json file and an input string, decides whether
  the input string is in the language accepted by the DFA.

  Assuming the input string is valid, the computation of it goes as follows:
  Start with the current state at start_state. Then, read the string right to left.
  For every character, modify the current state to be the result of the transition
  function with the current state and current character being read.
  After the string is processed, check if the current state is an accept state. If
  it is, accept, otherwise, reject.
  """
  def test_decidable(input) do 
    {_, _, transitions, start_state, accept_states, word} = parse_dfa(input) 
    
    # process input string
    end_state = Enum.reduce(word, start_state, fn character, state -> 
        Map.get(transitions, state) |> Map.get(character)
      end)
    MapSet.member?(accept_states, end_state)
  end

  def call do
    # if an error is thrown during the testing, return false (failed the typecheck)
    try do 
      test_decidable(System.argv() |> Enum.at(0, ""))
    rescue 
      _ -> false
    end
  end 
end

Project.DFA.call() |> IO.puts

defmodule Project.MapReduce do
  def parse_tm(input) do 
    %{
      "states" => states,
      "input_alphabet" => input_alphabet,
      "tape_alphabet" => tape_alphabet,
      "transitions" => transitions,
      "start_state" => start_state,
      "accept_state" => accept_state,
      "reject_state" => reject_state,
      "word" => word 
    } = :json.decode(input)

    states = MapSet.new(states)
    input_alphabet = MapSet.new(input_alphabet)
    tape_alphabet = MapSet.new(tape_alphabet)
    head_directions = MapSet.new(["L", "R"])

    # map the transition [start state, read character, write character, tape direction, end state]
    transitions = Enum.reduce(transitions, %{}, fn [start, read, write, dir, dest], acc -> 
      Map.update(acc, start, %{ read => {write, dir, dest} }, fn existing -> Map.put(existing, read, {write, dir, dest}) end)
    end)

    # assert that the accept state is in the states
    if not MapSet.member?(states, accept_state) do
      raise "The accept state must be a member of the states array"
    end
    # assert that the reject state is in the states
    if not MapSet.member?(states, reject_state) do
      raise "The reject state must be a member of the states array"
    end
    # assert that the start state is in the states
    if not MapSet.member?(states, start_state) do
      raise "The start state must be a member of the states array"
    end
    # assert that every state has transition rules
    if not MapSet.equal?(states, transitions |> Map.keys |> MapSet.new) do
      raise "Every state must have transitions defined"
    end
    # assert that every state has a transition for every member of the tape alphabet
    transitions 
      |> Map.values
      |> Enum.each(fn rules ->
        # assert that the state's rules has a rule for each tape character
        if not MapSet.equal?(tape_alphabet, rules |> Map.keys |> MapSet.new) do
          raise "Each state must have a transition defined for each member of the tape alphabet" 
        end
        # assert that every destination in the rules is a valid state
        if not MapSet.subset?(rules |> Map.values |> Enum.map(fn { _, _, dest } -> dest end) |> MapSet.new, states) do
          raise "The destination of a state transition must be a valid state in the state array"
        end
        # assert that every write character is valid in tape alphabet
        if not MapSet.subset?(rules |> Map.values |> Enum.map(fn { write, _, _} -> write end) |> MapSet.new, tape_alphabet) do
          raise "The character being written to tape must be a member of the tape alphabet"
        end
        # assert that every tape direction is either L or R
        if not MapSet.subset?(rules |> Map.values |> Enum.map(fn { _, dir, _} -> dir end) |> MapSet.new, head_directions) do
          raise "The tape head direction must be either 'R' or 'L'"
        end
      end)
    
    # now that tm is valid, assert that the input string only contains char from input alphabet
    word = String.graphemes(word)
    if not MapSet.subset?(word |> MapSet.new, input_alphabet) do
      raise "The word must only contain characters form the input alphabet"
    end

    {states, input_alphabet, tape_alphabet, transitions, start_state, accept_state, reject_state, word}
  end

  def serialize_tm({ states, input_alphabet, tape_alphabet, transitions, start_state, accept_state, reject_state, word }) do 
    %{
      "states" => states |> MapSet.to_list,
      "input_alphabet" => input_alphabet |> MapSet.to_list,
      "tape_alphabet" => tape_alphabet |> MapSet.to_list,
      "transitions" => transitions 
        |> Enum.flat_map(fn {start, rules} -> 
          Enum.map(rules, fn { read, { write, dir, dest } } -> 
            [start, read, write, dir, dest]
          end)
        end),
      "start_state" => start_state,
      "accept_state" => accept_state,
      "reject_state" => reject_state,
      "word" => word |> Enum.join
    } |> :json.encode
  end

  def new_state(states, prefix) do
    random_state = for _ <- 1..5, into: "#{prefix}_", do: <<Enum.random(?a..?z)>>
    if MapSet.member?(states, random_state) do
      new_state(states, prefix)
    else
      random_state 
    end
  end

  @doc"""
  Maps the Turing machine acceptance problem to the halting problem
  Given the input <M,w>, maps to <M', w> with the technique discussed in 
  class where if a computation were ever to go to the reject state,
  it would loop instead.
  """
  def map_reduce(input) do
    {
      states, 
      input_alphabet,
      tape_alphabet,
      transitions,
      start_state,
      accept_state,
      reject_state,
      word,
    } = parse_tm(input)
    # make a new loop state 
    loop_state = new_state(states, "q_loop")
    states = MapSet.put(states, loop_state)
    
    # for every edge that goes to the reject state, go to a new loop state
    transitions = Enum.reduce(transitions, %{}, fn {start, rules}, acc -> 
        rules = Enum.reduce(rules, %{}, fn { read, { write, dir, dest } }, acc -> 
          if dest == reject_state do
            # if going to reject state, redirect to loop state
            Map.put(acc, read, {write, dir, loop_state})
          else
            # if not going to reject state, leave it unchanged
            Map.put(acc, read, {write, dir, dest }) 
          end
        end)
        Map.put(acc, start, rules)
      end)

    # output the formatted new turing machine
    serialize_tm({states, input_alphabet, tape_alphabet, transitions, start_state, accept_state, reject_state, word})
  end

  def call do 
    try do
      map_reduce(System.argv() |> Enum.at(0, ""))
    rescue
      _ -> {
        # if an error is thrown during the map reduction that means parsing failed
        # so lets return a constant which is not in halt_tm. we will use a TM
        # that loops on the start state forever
        MapSet.new(["q_start", "q_acc", "q_rej"]),
        MapSet.new(["0"]),
        MapSet.new(["0", "_"]),
        %{
          "q_start" => %{
            "0" => { "0", "R", "q_start" },
            "_" => { "_", "R", "q_start" }
          },
          "q_acc" => %{
            "0" => { "0", "R", "q_acc" },
            "_" => { "_", "R", "q_acc" }
          },
          "q_rej" => %{
            "0" => { "0", "R", "q_rej" },
            "_" => { "_", "R", "q_rej" }
          }
        },
        "q_start",
        "q_acc",
        "q_rej",
        "",
      } |> serialize_tm()
    end
  end
end

Project.MapReduce.call |> IO.puts

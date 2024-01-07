Empty ← @-
Player ← @O
Cpu ← @X

InitField ← ↯3_3Empty
InitCursor ← 0_0

# field --
ShowField ← &pf ⊐/⊂≡(⊂:"\r\n")

# field -- ?
RowsAndCols ← >0+ ∩(>0/+/×) ⍉.
# field -- ?
Diags ← >0+ ∩(≤/+♭ ×⊞=.⇡,:⧻.) ⇌.
# char field -- ?
Won ← >0+ ⊃Diags RowsAndCols =
# field -- ?
Full ← /×≠Empty♭

Clear ← &pf "\x1b[2J"
Home ← &pf "\x1b[2H"
ResetScreen ← Home Clear

Left ← "\x1b[D"
Right ← "\x1b[C"
Up ← "\x1b[A"
Down ← "\x1b[B"
ArrowKeys ← {Left Right Up Down}

# keys string -- ?mask
Find ← ∵(>0/+⌕∩°□)⊙□
# acc -- c⊂acc
Collect ← ⊂:&rs1 0
# keys -- acc
GetKeyInput ← ; ⍢⊙Collect(=0/+ Find) :""

&raw 1

# State machine
⍢(
  ⊢⊚⌕□: {"start" "cpu_move" "player_start" "player_move" "player_win" "cpu_win" "draw"}
  (
    # start
    ResetScreen
    &pf "Hello! Let's Play Tic Tac Toe\r\n"
    &sl 1
    &pf "I'll start\r\n"
    "cpu_move"
  | # cpu_move
    ResetScreen
    &pf "Here's my move\r\n"
    ∵(⌊×⚂)△.  # choose a random position
    =Empty⊡,, # check if position is empty
    (
      # invalid position
      "cpu_move";
    |          # valid position
      ⍜⊡(Cpu;) # set position to cpu
      ShowField.
      &sl 1.5
      Won Cpu . # check cpu won
      (
        # no win
        Full . # check if field is full
        (
          # not full
          : # put cursor on top on top
          "player_start"
            | "draw"
        )
        | # cpu win
        "cpu_win"
      )
    )
  | # player_start
    ResetScreen
    &pf "It's your move now\r\n"
    &sl 0.2
    &pf "Move the cursor with the arrow keys\r\n"
    &pf "and confirm with space\r\n"
    &sl 0.2
    "player_move"
  | # player_move
    ResetScreen
    &pf "It's your move now\r\n"
    &pf "Move the cursor with the arrow keys\r\n"
    &pf "and confirm with space\r\n"
    ShowField ⍜⊡(@¤;),,                  # show field with cursor
    ⊢⊚Find: GetKeyInput. ⊂ ArrowKeys " " # get input
    ≥⧻ArrowKeys.                         # check what type of input
    (
      # arrow
      +⊏: [0_¯1 0_1 ¯1_0 1_0] # select direction and update cursor
      ◿⧻,                     # wrap cursor if needed
      "player_move"
    |           # space
      ;         # drop input from the stack
      =Empty⊡,, # check if position is empty
      (
        # invalid position
        "player_move"
        |           # valid position
        ,:          # copy cursor under field
        ⍜⊡(Player;) # set position to player
        ResetScreen
        ShowField.
        &sl 1
        Won Player . # check player won
        (
          # no win
          Full . # check if field is full
          (
            # not full
            "cpu_move"
                | "draw"
          )
            | # player win
          "player_win"
        )
      )
    )
  | # player_win
    &pf "Congrats! You won\r\n"
    &sl 1
    "done"
  | # cpu_win
    &pf "Too bad! You lose\r\n"
    &sl 1
    "done"
  | # draw
    &pf "It's a draw!\r\n"
    &sl 1
    "done"
  )
)(¬≍"done") "start" InitField InitCursor

&raw 0

;;; # drop state, field and cursor of the stack
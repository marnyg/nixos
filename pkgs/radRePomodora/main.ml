(* effort_reward.ml *)

open Random
open Unix

(* Configuration *)
let min_time = 5    (* Minimum time unit in seconds *)
let max_time = 20   (* Maximum time unit in seconds *)
let min_ratio = 3   (* Minimum number of cycles before reward *)
let max_ratio = 7   (* Maximum number of cycles before reward *)
let jackpot_prob = 15  (* Jackpot probability in percentage *)

(* Rewards and Denials *)
let rewards = [
  "Take a quick stretch";
  "Grab a small snack";
  "Watch a 1-minute funny clip";
  "Do 10 jumping jacks"
]

let denials = [
  "Keep pushing!";
  "Not this time!";
  "Stay focused!";
  "Almost there!"
]

let jackpots = [
  "Take a 10-minute break";
  "Indulge in your favorite treat";
  "Watch a short motivational video"
]

(* Cross-platform notification *)
let send_notification title message =
  let os = Sys.os_type in
  if os = "Unix" then
    let cmd = Printf.sprintf "notify-send '%s' '%s'" title message in
    ignore (system cmd)
  else if os = "Win32" then
    let cmd = Printf.sprintf "msg * \"%s: %s\"" title message in
    ignore (system cmd)
  else
    Printf.printf "[%s]: %s\n" title message

(* Random sleep within interval *)
let random_sleep () =
  let sleep_time = min_time + (Random.int (max_time - min_time + 1)) in
  Printf.printf "Focus for %d seconds...\n" sleep_time;
  sleep sleep_time

(* Main loop *)
let rec main_loop work_count ratio_threshold =
  random_sleep ();

  let work_count = work_count + 1 in

  if work_count >= ratio_threshold then
    let is_jackpot = (Random.int 100) < jackpot_prob in
    if is_jackpot then
      let jackpot = List.nth jackpots (Random.int (List.length jackpots)) in
      send_notification "💥 JACKPOT REWARD!" jackpot;
      Printf.printf "Jackpot reward: %s\n" jackpot
    else
      let reward = List.nth rewards (Random.int (List.length rewards)) in
      send_notification "🎉 Reward Time!" reward;
      Printf.printf "Reward given: %s\n" reward;
    main_loop 0 (min_ratio + Random.int (max_ratio - min_ratio + 1))
  else
    let denial = List.nth denials (Random.int (List.length denials)) in
    send_notification "❌ No Reward" denial;
    Printf.printf "No reward: %s\n" denial;
    main_loop work_count ratio_threshold

(* Entry point *)
let () =
  Random.self_init ();
  try
    main_loop 0 (min_ratio + Random.int (max_ratio - min_ratio + 1))
  with
    | Sys.Break -> Printf.printf "\nExiting... Stay productive!\n"

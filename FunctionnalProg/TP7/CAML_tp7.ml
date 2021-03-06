(* #require "graphics";; *)

open Graphics;;
open Float;;

(* Type for the representation of functional images. *)
type picture = int * int -> color

(* Dimensions of the graphical window. *)
let w = 512

and h = 512

(* render f : draw the image `f` on the graphical window. *)
let render (f : picture) =
  open_graph (Printf.sprintf " %dx%d" w h);
  auto_synchronize false;
  for x = 0 to w - 1 do
    for y = 0 to h - 1 do
      set_color (f (x, y));
      plot x y
    done;
    set_color background
  done;
  synchronize ();
  wait_next_event [ Button_down; Key_pressed ] |> ignore;
  close_graph ()

let black_on_black : picture = fun _ -> black

let half_plane color : picture =
  fun (x, y) -> if x < w / 2 then color else background

let diagonal color : picture = fun (x, y) -> if x = y then color else background

let square size color : picture =
  fun (x, y) ->
  let half = size / 2 in
  if x > -half && x <= half && y > -half && y <= half then color else background

let rectangle width height color : picture =
  fun (x, y) ->
  let halfX = width / 2 and halfY = height / 2 in
  if x > -halfX && x <= halfX && y > -halfY && y <= halfY then color
  else background

let disk radius color : picture =
  fun (x, y) ->
  let hypotP2 = (x * x) + (y * y) in
  if hypotP2 <= radius * radius then color else background

let circle radius color : picture =
  fun (x, y) ->
  let hypotP2 = (x * x) + (y * y) in
  if hypotP2 > (radius - 3) * (radius - 1) && hypotP2 <= radius * radius then
    color
  else background

let move pic offset : picture =
  fun (x, y) ->
  let offX, offY = offset in
  pic (x + offX, y + offY)

let vertical_symmetry pic : picture = fun (x, y) -> pic (x, -y)

let horizontal_symmetry pic : picture = fun (x, y) -> pic (-x, y)

let v_lines n : picture =
  fun (x, _) -> if x mod n = 0 then black else background

let v_stripes n : picture =
  fun (x, _) -> if x mod ((n * 2) + 1) < n then black else background

let chessboard color n : picture =
  fun (x, y) ->
  if
    (x mod ((n * 2) + 1) < n && y mod ((n * 2) + 1) >= n)
    || (x mod ((n * 2) + 1) >= n && y mod ((n * 2) + 1) < n)
  then color
  else background

let concentric color n : picture =
  fun (x, y) ->
  let h = int_of_float (hypot (float_of_int x) (float_of_int y)) in
  if h mod ((n * 2) + 1) < n then color else background

let compose_two pic1 pic2 : picture =
  fun (x, y) -> if pic2 (x, y) != background then pic2 (x, y) else pic1 (x, y)

let compose pics : picture =
  let rec aux pics res =
    match pics with
    | [] -> res
    | head :: tail -> aux tail (compose_two res head)
  in
  aux pics (fun _ -> background)

let rotate pic theta : picture =
  fun (x, y) ->
  let xf = float_of_int x and yf = float_of_int y in
  let c = cos theta and s = sin theta in
  pic
    ( int_of_float ((xf *. c) -. (yf *. s)),
      int_of_float ((yf *. c) -. (xf *. s)) )

let sun color : picture =
  let beam = move (rectangle 3 30 color) (1, -50) and body = disk 30 color in
  compose
    [
      beam;
      rotate beam (pi /. 2.);
      rotate beam pi;
      rotate beam (pi /. 2. *. 3.);
      body;
    ]

let compose_xor_two pic1 pic2 : picture =
  fun (x, y) ->
  if pic1 (x, y) != background && pic2 (x, y) != background then background
  else if pic1 (x, y) != background then pic1 (x, y)
  else if pic2 (x, y) != background then pic2 (x, y)
  else background

let double_concentric width : picture =
  let c = concentric black width in
  compose_xor_two (move c (50, 0)) (move c (-50, 0))

let rosace : picture =
  let d = double_concentric 30 in
  compose_xor_two d (rotate d (pi /. 2.))

(*
render black_on_black;;
render (half_plane red);;
render (diagonal red);;
render (square 60 red);;
render (rectangle 50 90 red);;
render (disk 50 red);;
render (circle 200 red);;
*)

let r = move (rectangle 128 64 green) (-64, 32)

let ad = vertical_symmetry (diagonal green)

;;
render (vertical_symmetry r)

;;
render (move ad (0, -h))

(*
render (v_lines 5);;
render (v_stripes 64);;
render (chessboard red 64);;
render (concentric red 64);;
*)

;;
render (compose_two (chessboard red 64) (concentric blue 64))

let s_mickey =
  let ear = disk 25 black and head = disk 50 black in
  let leftEar = move ear (-((w / 2) - 45), -((h / 2) + 60))
  and rightEar = move ear (-((w / 2) + 45), -((h / 2) + 60)) in
  compose [ leftEar; rightEar; move head (-(w / 2), -(h / 2)) ]

;;
render s_mickey

let mickey =
  let ear = move (disk 25 black) (-45, -60)
  and headBorder = circle 50 black
  and head = disk 50 (rgb 128 128 128)
  and eye = move (disk 5 black) (-20, -20)
  and nose = disk 10 black in
  let half = compose [ ear; headBorder; eye; nose ] in
  let full = compose [ head; half; horizontal_symmetry half ] in
  move (rotate full (pi /. 2.)) (-(w / 2), -(h / 2))

;;
render mickey

;;
render (move (sun yellow) (-(w / 2), -(h / 2)))

;;
render (move (double_concentric 20) (-(w / 2), -(h / 2)))

;;
render (move rosace (-(w / 2), -(h / 2)))

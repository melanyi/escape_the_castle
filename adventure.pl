/* Museum Heist, by Daphne Chiu and Melody Lan. */

:- dynamic i_am_at/1, at/2, holding/1, on/1, off/1, unlocked/1, locked/1, conscious/1, unconscious/1,  time/1. 
:- retractall(at(_, _)), retractall(i_am_at(_)), retractall(alive(_)). 

i_am_at(control_room).
time(20). 

/* These rules describe the path between locations */ 
path(control_room, f, main_gallery).
path(main_gallery, b, control_room).
path(main_gallery, f, lobby).
path(lobby, f, restroom). 
path(lobby, b, main_gallery).
path(lobby, l, storage).
path(lobby, r, special_gallery). 
path(restroom, b, lobby).
path(storage, b, lobby).
path(special_gallery, l, lobby). 
path(special_gallery, f, daVinci_gallery). 
path(daVinci_gallery, b, special_gallery). 
path(special_gallery, b, outside). 

/* These rules describe how time counts down in the game */
count_time(X, Y) :-
    time(X),
    Y is X-1,
    Y is 1, 
    write('You have 1 minute left.'), nl.

count_time(X, Y) :-
    time(X),
    Y is X-1,
    write('You have '), write(Y), write(' minutes left.'), nl.

/* These rules describe the state of the objets in the game */ 
on(security_camera).
off(sink). 
conscious(guard). 
unlocked(restroom_door).

/* These rules describe where objects are located */

at(crowbar, storage). 
at(mop, storage). 
at(bucket, storage). 
at(tape, storage). 
at(paintbrush, storage). 
at(tarp, special_gallery). 
at(painting, daVinci_gallery). 

/* These rules describe how to pick up an object. */

take(X) :-
        holding(X),
        write('You''re already holding it!'),
        !, nl.

take(X) :-
        i_am_at(Place),
        at(X, Place),
        retract(at(X, Place)),
        assert(holding(X)),
        write('OK.'),
        !, nl.

take(_) :-
        write('I don''t see it here.'),
        nl.


/* These rules describe how to put down an object. */

drop(X) :-
        holding(X),
        i_am_at(Place),
        retract(holding(X)),
        assert(at(X, Place)),
        write('OK.'), 
        !, nl.

drop(_) :-
        write('You aren''t holding it!'),
        nl.

/* These rules describe other actions */ 

turn_on(sink) :-
        off(sink),
        retract(off(sink)),
        assert(on(sink)),
        write('OK. the sink is turned on.'), nl, 
        write('The sink is overflowing, better get the other guard!'),nl,
        write('Press b to go back to the lobby.'),
        !, nl.

turn_on(X) :-
        off(X),
        retract(off(X)),
        assert(on(X)),
        write('OK.'), write(X), write(' is turned on.'),
        !, nl.

turn_on(_) :- write('You can''t do that!'), !, nl.  

turn_off(security_camera) :-
        on(security_camera),
        i_am_at(control_room), 
        retract(on(security_camera)),
        assert(off(secruity_camera)),
        write('OK. security camera is turned off.'),
        !, nl.

turn_off(X) :-
        on(X),
        retract(on(X)),
        assert(off(X)),
        write('OK.'), write(X), write(' is turned off.'),
        !, nl.

turn_off(_) :- write('You can''t do that!'), nl. 

lock(restroom_door) :-
        unlocked(restroom_door),
        retract(unlocked(restroom_door)),
        assert(locked(restroom_door)),
        write('The restroom door is locked. Continue with the heist!'),nl,
        write('press b to go to the main gallery'),nl, 
        write('press l to go in the storage closet'),nl,
        write('press r to go down the lobby'), 
        !, nl.

lock(_) :-
        write('Go to the lobby to lock the restroom door'),nl. 

hit :-
        i_am_at(special_gallery), 
        holding(crowbar), 
        conscious(guard),
        retract(conscious(guard)),
        assert(unconscious(guard)),
        write('The guard has been knocked out. Continue with the heist!'),
        !, nl.

hit :-
        i_am_at(special_gallery), 
        conscious(guard),
        holding(mop), 
        retract(conscious(guard)),
        assert(unconscious(guard)),
        write('The guard has been knocked out. Continue with the heist!'),
        !, nl.

hit :-
        i_am_at(special_gallery), 
        holding(_), 
        write('That was not effective! You''ve be caught!'),
        !, nl.

hit :-
        write('That was not effective!'),
        !, nl.

/* These rules define the direction letters as calls to go/1. */

f :- go(f).

b :- go(b).

l :- go(l).

r :- go(r).


/* This rule tells how to move in a given direction. */

go(_) :-
        time(0), 
        die, !. 

go(Direction) :-
        i_am_at(Here),
        path(Here, Direction, There),
        retract(i_am_at(Here)),
        assert(i_am_at(There)),
        time(X),
        count_time(X, Y),
        retract((time(X))),
        assert(time(Y)),
        !, look.

go(_) :-
        write('You can''t go that way.').


/* This rule tells how to look about you. */

look :-
        i_am_at(Place),
        describe(Place),
        nl,
        notice_objects_at(Place),
        nl.


/* These rules set up a loop to mention all the objects
   in your vicinity. */

notice_objects_at(Place) :-
        at(X, Place),
        write('There is a '), write(X), write(' here.'), nl,
        fail.

notice_objects_at(_).


/* This rule tells how to die. */

die :-
        finish.

/* This rule tells how to win. */

win :-
        finish.


/* Under UNIX, the "halt." command quits Prolog but does not
   remove the output window. On a PC, however, the window
   disappears before the final output can be seen. Hence this
   routine requests the user to perform the final "halt." */

finish :-
        nl,
        write('The game is over. Please enter the "halt." command.'),
        nl.


/* This rule just writes out game instructions. */

instructions :-
        nl,
        write('Enter commands using standard Prolog syntax.'), nl,
        write('Available commands are:'), nl,
        write('start.              -- to start the game.'), nl,
        write('f.  b.  l.  r.      -- to go in that direction.'), nl,
        write('take(Object).       -- to pick up an object.'), nl,
        write('drop(Object).       -- to put down an object.'), nl,
        write('turn_on(Object).    -- to turn on an object'), nl, 
        write('turn_off(Object).   -- to turn off an object'), nl,
        write('hit                 -- to hit the guard'),nl,
        write('lock(restroom_door) -- to lock the restroom door'),nl,
        write('look.               -- to look around you again.'), nl,
        write('instructions.       -- to see this message again.'), nl,
        write('halt.               -- to end the game and quit.'), nl,
        nl.


/* This rule prints out instructions and tells where you are. */

start :-
        instructions,
        write('You are a guard at an art museum.'), nl, 
        write('You plan to steal the most expensive painting at midnight.'), nl,
        write('You can turn off the security camera for 20 minutes.'), nl,
        write('There are two other guards on night shift with you'), nl,
        write('be sure to distract them before you act.'), nl, 
        write('Good luck.'), nl, nl, nl,
        look.


/* These rules describe the various rooms.  Depending on
   circumstances, a room may have more than one description. */

describe(control_room) :- on(security_camera), 
write('You are at the control room.'), nl, 
write('Remember to turn off the security camera to begin your heist!'), nl, nl,
write('press f to go forward to the main gallery').

describe(main_gallery) :- locked(restroom_door), 
write('The guard is locked in the restroom. You are in the main gallery. Press f to go back to the lobby and continue with your heist!'), !. 

describe(main_gallery) :- on(sink), 
write('The guard rushes over to the restroom. Now is the chance to lock him in. Use command lock(restroom_door).'),nl,nl,
write('After you lock the restroom door, you can press f to go to the lobby.'),!.

describe(main_gallery) :- off(sink), 
write('There''s guard here on night shift, you briefly greet him.'), nl,
write('In order for the heist to go smoothly, maybe you should distract him? (hint hint)'), nl,
write('The restroom sink is breaking down lately, use that fact if you want.'), nl,
write('press f to go forward to the lobby'),nl,
write('press b to go back to the control room'), nl, !.

describe(lobby) :- write('This is the lobby. There''s nothing of use here.'),nl,
write('press f to go forward to the restroom with the broken sink'),nl,
write('press b to go back to the main gallery where there''s another guard on duty.'),nl,
write('press l to go in the storage closet where there are useful items.'),nl,
write('press r to go down the lobby'). 

describe(storage) :- write('This is the storage closet of the museum'),nl, 
write('There are some items that could be helpful for your heist. Choose wisely.'),nl,
write('press b to go to the lobby'). 

describe(restroom) :- locked(restroom_door), on(sink), 
write('You have locked the guard in. You are in the lobby. Press f to continue on with your heist.'),nl, #????
write('Don''t forget to take useful items from the storage closet.'), nl,
write('Press b to go to the lobby.'), !.

describe(restroom) :- off(sink), 
write('This is one of the restrooms in the museum. The sinks are broken.'),nl,
write('Turn on the sink to flood this restroom'),nl,
write('press b to go back to the lobby'), !. 


describe(special_gallery) :- conscious(guard), holding(painting), 
write('You''ve been caught by the guard on duty!'), nl, die, !.  

describe(special_gallery) :- conscious(guard), 
write('You are at the special exhibit gallery. There''s a guard on duty.'),nl,
write('You need to take the tarp in this room to wrap the painting, but you cannot act with the guard watching.'), nl,
write('Figure out a plan and remember you took some items from the storage closet.'), nl, 
write('press f to go forward to the da Vinci gallery where the expensive painting is kept'), nl, 
write('press b to go back to the lobby'), nl, !. 

describe(special_gallery) :- unconscious(guard), holding(mop), 
write('The guard woke up, you''ve been caught!'), nl, die, !.

describe(special_gallery) :- unconscious(guard), unlocked(restroom_door), 
write('The main gallery guard was suspicious of the lack of response from the special gallery'), nl,  
write('and he comes to inspect the special gallery. You''ve been caught!'), nl, die, !.

describe(special_gallery) :- unconscious(guard), locked(restroom_door),
write('press b to leave through the back door now!'), !. 

describe(daVinci_gallery) :- write('You are now in the daVinci gallery. Steal the painting now.'),nl,
write('press b to go back to the special gallery.'), !. 

describe(outside) :- holding(painting), holding(tarp), off(security_camera), 
write('You escaped with the painting! You won !!!!!!'), nl, win, !. 

describe(outside) :- holding(painting), holding(tarp), on(security_camera), 
write('You stole the painting but the security camera was on the whole time. You''ve been caught!'), nl, die, !. 

describe(outside) :- holding(painting), on(security_camera),
write('You didn''t wrap the painting and passerbys saw you steal a painting!. You''ve been caught!'), nl, die, !. 

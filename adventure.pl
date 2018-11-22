/* Museum Heist, by Daphne Chiu and Melody Lan. */

:- dynamic i_am_at/1, at/2, holding/1.
:- retractall(at(_, _)), retractall(i_am_at(_)), retractall(alive(_)).

i_am_at(control_room).

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

/* These rules describe the state of the objets in the game */ 
off(sink). 
plugged(sink).
flows_into(sink,floor) :- plugged(sink).
wet(X) :- flow(X).
unconscious(Y) :- hit(crowbar, Y).
unconscious(Y) :- hit(mop, Y).

/* These rules describe where objects are located */

at(crowbar, storage). 
at(mop, storage). 
at(bucket, storage). 
at(first_aid, storage). 
at(tarp, special_gallery). 
at(suitcase, director_office). 
at(fake_footage, control_room). 

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
hit(X,Y) :- 
		conscious(Y),
		holding(X),
		write("You hit the other guard with a"),
		write(X).



/* These rules define the direction letters as calls to go/1. */

f :- go(f).

b :- go(b).

l :- go(l).

r :- go(r).


/* This rule tells how to move in a given direction. */

go(Direction) :-
        i_am_at(Here),
        path(Here, Direction, There),
        retract(i_am_at(Here)),
        assert(i_am_at(There)),
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
        write('start.             -- to start the game.'), nl,
        write('f.  b.  l.  r.     -- to go in that direction.'), nl,
        write('take(Object).      -- to pick up an object.'), nl,
        write('drop(Object).      -- to put down an object.'), nl,
        write('look.              -- to look around you again.'), nl,
        write('instructions.      -- to see this message again.'), nl,
        write('halt.              -- to end the game and quit.'), nl,
        nl.


/* This rule prints out instructions and tells where you are. */

start :-
        instructions,
        write('You are a guard at an art museum.'), nl, 
        write('You plan to steal the most expensive painting at midnight.'), nl,
        write('You can turn off the security camera for an hour before the emergency alarm'), nl,
        write('goes off, and must return to the control room to upload a fake footage to frame'),nl,
        write('your fellow guard and escape.'), nl,
        write('Good luck.'), nl, nl, nl,
        look.


/* These rules describe the various rooms.  Depending on
   circumstances, a room may have more than one description. */

describe(control_room) :- write('You are at the control room.'), nl, 
write('Turn off the security camera to begin your heist.'), nl, 
write('Attention: Don''take the fake footage right now!!!'), nl.

describe(control_room) :- write('press f to go forward to the main gallery'), nl, nl.  

describe(main_gallery) :- write('There''s guard here on night shift, you briefly greet him.'), nl,
write('In order for the heist to go smoothly, maybe you should distract him?'), nl,
write('The restroom sink needs repairing lately, use that fact if you want.'),nl,
write('press f to go forward to the lobby'),nl,
write('press b to go back to the control room.'), nl, nl. 

describe(main_gallery) :- wet(floor), write('The guard rushes over to the restroom. Now it''s the chance to lock him in.').

describe(lobby) :- write('This is the lobby. There''s nothing of use here.'),nl,
write('press f to go forward to the restroom with the broken sink'),nl,
write('press b to go back to the main gallery.'),nl,
write('press l to go in the storage closet'),nl,
write('press r to go down the lobby'). 

describe(storage) :- write('This is the storage closet of the museum'),nl, 
write('There are some items that could be helpful for your heist. Choose wisely.'). 

describe(restroom) :- write('This is one of the restrooms in the museum. The sinks are broken.'),nl,
write('Turn on the taps to flood this restroom (and maybe other areas too?)').

describe(restroom) :- on(sink), plugged(sink), wet(floor), write('The sinks are overflowing! Better get the other guard').
 
describe(special_gallery) :- write('You are at the special exhibit gallery. There''s a guard on duty.'),nl,
write('You need to take the tarp in this room to wrap the painting.'). 


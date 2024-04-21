;********************************************
;Digital Mobility Model (DMM)
;Author: Na Jiang (Richard), Fiammetta Brandajs, Andrew Crooks
;********************************************
;********************************************
;**********************
; -1, Declare Variable Names
;**********************
globals[
  digital-mobility-index

  png0
  png1
  png2

  pnd0
  pnd1
  pnd2

  tng0
  tng1
  tng2

  tnd0
  tnd1
  tnd2
]

;Place Agent Attributes
patches-own  [
  id
  ptype
  p-evolve-type ;capture each time step change type, at the beginigng of each time this will be reset for verification useage
]

;Dynamic Agent Attributes
turtles-own [
  ttype
  previous-id
  back-loc ; 0; 1;
  a-evolve-type ;capture each time step change type, at the beginigng of each time this will be reset
  px
  py
]
;**********************
;********************************************

;********************************************
;**********************
; 0, Initialization
;**********************
to setup
  ;1
  clear-all
  reset-ticks

  ;2, initilize global
  set digital-mobility-index 0

  ;3, set patch
  ask patches[set ptype 0]

  ;4, create turtles
  ask n-of (Per-Patches * count patches) patches [sprout 1 set p-evolve-type 0]

  ;5, set up turtles
  ask turtles [
    set shape "circle"
    set ttype 0
    set px [pxcor] of patch-here ;remeber the patch x y
    set py [pycor] of patch-here ;remeber the patch x y
    set a-evolve-type 0
   ]

  ;6, give the model some dynamics to start
  ;learning-society
  agents-natural-growth
  patches-natural-growth
  update-color
end
;**********************
;********************************************

;********************************************
;**********************
; 1, Go Function
;**********************
 to go
  show ticks
  update-et

  ;========Main Interaction========
  ;Hierarchical Evolution = learning-society + learn-by-moving
  learning-society
  learn-by-moving
  ;================================

  update-color
  update-dmi
  tick
end
;**********************
;********************************************

;********************************************
;**********************
; 2, Dynamic Agent Functions
;**********************
to learn-by-moving
  print["------------------learning-by-moving------------------"]
  move
  gain-skill
end

to move
  print["+++++++++moving+++++++++"]
  ask turtles[
    ;remember location before moving
    set px [pxcor] of patch-here
    set py [pycor] of patch-here
    ;then move
    move-to one-of patches
  ]
end

to gain-skill
  print["+++++++++gain-skill+++++++++"]

  if A-Growth = False
  [
    print["No Agent-natural growth"]
    set tng0 round (Growth-Rate-TType-0-1 * count turtles with [ttype = 0])
    show tng0
    ;agent natural growth 0 ->1
    let tcount0 0
    while [tcount0 < tng0]
    [
      ask one-of turtles with[ttype = 0]
      [
        ;print["agent natural growth 0->1"]
        set ttype 1
        set a-evolve-type 01
      ]
      set tcount0 tcount0 + 1
    ]
  ]

  ask turtles[
    if ttype = 0[if ttype != [ptype] of patch-here [back-to-last-loc]]
    if ttype = 1[
      ifelse ttype = [ptype] of patch-here
      [
        ;print["evolve--ttype from 1->2"]
        set ttype 2
        set back-loc 0
        set a-evolve-type 112
      ]
      [
        ifelse ttype > [ptype] of patch-here
        [
          ;print["greater"]
          move-to patch-here
        ]
        [back-to-last-loc]
      ]
    ]

    if ttype = 2[
      ifelse ttype = [ptype] of patch-here
      [
        ;print["evolve--ttype from 1->2"]
        set ttype 3
        set back-loc 0
        set a-evolve-type 123
      ]
      [
        ifelse ttype > [ptype] of patch-here
        [
          ;print["greater"]
          move-to patch-here
        ]
        [back-to-last-loc]
      ]
    ]
  ]
end

to back-to-last-loc
  print["back-to-last-loc->move back"]
  setxy px py    ;go back to previous position
  set back-loc 1 ;1 means agent goes back to previous loc, 0 means not
end
;**********************
;********************************************

;********************************************
; 3, Learning Society Functions
;********************************************
;**********************
; 3.0, Learning Society
;**********************
to learning-society
  print["------------------learning-society-places------------------"]
  print["+++++++++learning-society-Decline+++++++++"]
  ifelse A-Decline = True [agents-natural-decline]  [print["learning-society-agent decline not called"]]
  ifelse P-Decline = True [patches-natural-decline] [print["learning-society-places decline not called"]]

  print["+++++++++learning-society-Growth+++++++++"]
  ifelse P-Growth =  True [patches-natural-growth]  [print["learning-society-places growth not called"]]
  ifelse A-Growth =  True [agents-natural-growth]   [print["learning-society-agent growth not called"]]






end
;**********************
; 3.1, Impacts on Dynamic Agents
;**********************
;agent growth
to agents-natural-growth
  print["dynmic-agent-natural-growth"]
  set tng0 round (Growth-Rate-TType-0-1 * count turtles with [ttype = 0])
  set tng1 round (Growth-Rate-TType-1-2 * count turtles with [ttype = 1])
  set tng2 round (Growth-Rate-TType-2-3 * count turtles with [ttype = 2])

  show tng0
  show tng1
  show tng2

  ;agent natural growth 0 ->1
  let tcount0 0
  ;show tng0
  while [tcount0 < tng0]
  [
    ask one-of turtles with[ttype = 0 and a-evolve-type = 0]
    [
      ;print["agent natural growth 0->1"]
      set ttype 1
      set a-evolve-type 01
      set back-loc 0
    ]
    set tcount0 tcount0 + 1
    ;print["tcount0"]
    ;show tcount0
  ]

  ;agent natural growth 1 ->2
  let tcount1 0
  while [tcount1 < tng1]
  [
    ask one-of turtles with[ttype = 1 and a-evolve-type = 0]
    [
      ;print["agent natural growth 1->2"]
      set ttype 2
      set a-evolve-type 12
      set back-loc 0
    ]
    set tcount1 tcount1 + 1
    ;print["tcount1"]
    ;show tcount1
  ]

  ;agent natural growth 2 ->3
  let tcount2 0
  while [tcount2 < tng2]
  [
    ask one-of turtles with[ttype = 2 and a-evolve-type = 0]
    [
      ;print["agent natural growth 2->3"]
      set ttype 3
      set a-evolve-type 23
      set back-loc 0
    ]
    set tcount2 tcount2 + 1
  ]
end

;agent decline
to agents-natural-decline
  print["dynmic-agent-natural-decline"]
  set tnd0 round (Decline-Rate-TType-1-0 * count turtles with [ttype = 1])
  set tnd1 round (Decline-Rate-TType-2-1 * count turtles with [ttype = 2])
  set tnd2 round (Decline-Rate-TType-3-2 * count turtles with [ttype = 3])

  show tnd0
  show tnd1
  show tnd2

  let tcount0 0
  while [tcount0 < tnd0]
  [
    ask one-of turtles with[ttype = 1 and a-evolve-type = 0]
    [
      ;print["agent natural decline 1->0"]
      set ttype 0
      set a-evolve-type 10
    ]
    set tcount0 tcount0 + 1
  ]

  let tcount1 0
  while [tcount1 < tnd1]
  [
    ask one-of turtles with[ttype = 2 and a-evolve-type = 0]
    [
      ;print["agent natural decline 2->1"]
      set ttype 1
      set a-evolve-type 21
    ]
    set tcount1 tcount1 + 1
  ]

  let tcount2 0
  while [tcount2 < tnd2]
  [
    ask one-of turtles with[ttype = 3 and a-evolve-type = 0]
    [
      ;print["agent natural decline 3->2"]
      set ttype 2
      set a-evolve-type 32
    ]
    set tcount2 tcount2 + 1
  ]
end
;**********************

;**********************
; 3.2, Impacts on Place Agents
;**********************
;Place Agents Growth
to patches-natural-growth
  print["places-natural-growth"]
  set png0 round (Growth-Rate-PType-0-1 * count patches with [ptype = 0])
  set png1 round (Growth-Rate-PType-1-2 * count patches with [ptype = 1])
  set png2 round (Growth-Rate-PType-2-3 * count patches with [ptype = 2])

  show png0
  show png1
  show png2
  ;natural growth 0 ->1
  let pcount0 0
  while [pcount0 < png0]
  [
    ask one-of patches with[ptype = 0]
    [
      ;print["patches-natural-growth 0->1"]
      set ptype 1
      set p-evolve-type 01
    ]
    set pcount0 pcount0 + 1
  ]

  ;natural growth 1 ->2
  let pcount1 0
  while [pcount1 < png1]
  [
    ask one-of patches with[ptype = 1 and p-evolve-type = 0]
    [
      ;print["patches-natural-growth 1->2"]
      set ptype 2
      set p-evolve-type 12
    ]
    set pcount1 pcount1 + 1
  ]

  ;natural growth 1 ->2
  let pcount2 0
  while [pcount2 < png2]
  [
    ask one-of patches with[ptype = 2 and p-evolve-type = 0]
    [
      ;print["patches-natural-growth 2->3"]
      set ptype 3
      set p-evolve-type 23
    ]
    set pcount2 pcount2 + 1
  ]
end

;Place Agents Decline
to patches-natural-decline
  print["places-natural-decline"]
  set pnd0 round (Decline-Rate-PType-1-0 * count patches with [ptype = 1])
  set pnd1 round (Decline-Rate-PType-2-1 * count patches with [ptype = 2])
  set pnd2 round (Decline-Rate-PType-3-2 * count patches with [ptype = 3])
  show pnd0
  show pnd1
  show pnd2
  if pnd0 > 0[
    ;natural decline 1 ->0
    let pcount0 0
    while [pcount0 < pnd0]
    [
      ;show pnd0
      ask one-of patches with[ptype = 1 and p-evolve-type = 0]
      [
        ;print["patches-natural-decline 1->0"]
        set ptype 0
        set p-evolve-type 10
      ]
      set pcount0 pcount0 + 1
    ]
  ]

  if pnd1 > 0[
    ;natural decline 2 ->1
    let pcount1 0
    while [pcount1 < pnd1]
    [
      ask one-of patches with[ptype = 2 and p-evolve-type = 0]
      [
        ;print["patches-natural-decline 2->1"]
        set ptype 1
        set p-evolve-type 21
      ]
      set pcount1 pcount1 + 1
    ]
  ]

  if pnd2 > 0[
    ;natural decline 3 ->2
    let pcount2 0
    while [pcount2 < pnd2]
    [
      ask one-of patches with[ptype = 3 and p-evolve-type = 0]
      [
        ;print["patches-natural-decline 3->2"]
        set ptype 2
        set p-evolve-type 32
      ]
      set pcount2 pcount2 + 1
    ]
  ]
end
;**********************
;********************************************

;********************************************
; 4, Update Global Var Functions
;********************************************
to update-et
  ask patches with [p-evolve-type != 0]
  [set p-evolve-type 0]

  ask turtles with [a-evolve-type != 0]
  [set a-evolve-type 0]

end

to update-color
  ;change turtle color
  ask turtles[
    ;if ttype = 0 [set color 8 set  size 1.3]
    ;if ttype = 1 [set color 14 set size 1.2]
    ;if ttype = 2 [set color 44 set size 1]
    ;if ttype = 3 [set color 64 set size 0.8]
    if ttype = 0 [set color 8  set size 0.5 set shape "face sad"]
    if ttype = 1 [set color 14 set size 1   set shape "face neutral" ]
    if ttype = 2 [set color 44 set size 1.5 set shape "face neutral"]
    if ttype = 3 [set color 64 set size 2   set shape "face happy"]
  ]

  ;change patch color
  ask patches [
    if ptype = 0 [set pcolor white]
    if ptype = 1 [set pcolor 15]
    if ptype = 2 [set pcolor 46]
    if ptype = 3 [set pcolor 66]
  ]
end

to update-dmi
    set digital-mobility-index (count turtles with [back-loc = 0]) / (count turtles)
end
;**********************
;********************************************

;********************************************
; 5, Verification Functions
;********************************************
;***************************
; 5.1, Verification Setups
;***************************
to setup-ver-p-growth
  clear-all
  reset-ticks
  ask patches[set ptype 0]
  update-color
end

to setup-ver-p-decline
  clear-all
  reset-ticks
  ask patches[set ptype 3]
  update-color
end

to setup-ver-a-growth
  clear-all
  reset-ticks
  while [count turtles < 100] [
    ask one-of patches [
      if not any? turtles in-radius 2 [sprout 1]
    ]
  ]
  ask turtles [
    set shape "circle"
    set ttype 0
    ;remeber the patch x y
    set px [pxcor] of patch-here
    set py [pycor] of patch-here
   ]
  update-color
end

to setup-ver-a-decline
  clear-all
  reset-ticks
  ;ask patches [sprout 1]

  while [count turtles < 100] [
    ask one-of patches [
      if not any? turtles in-radius 2 [sprout 1]
    ]
  ]

  ask turtles [
    set shape "circle"
    set ttype 3
    ;remeber the patch x y
    set px [pxcor] of patch-here
    set py [pycor] of patch-here
   ]
  update-color
end

to setup-ver-a-moveback
  clear-all
  reset-ticks
  ;ask patches [sprout 1]

  while [count turtles < 100] [
    ask one-of patches [
      if not any? turtles in-radius 2 [sprout 1]
    ]
  ]

  ask patches[set ptype 3]

  ask turtles [
    set shape "circle"
    set ttype 0
    ;remeber the patch x y
    set px [pxcor] of patch-here
    set py [pycor] of patch-here
   ]
  update-color
end

to setup-ver-a-gain
  clear-all
  reset-ticks
  ;ask patches [sprout 1]

  while [count turtles < 100] [
    ask one-of patches [
      if not any? turtles in-radius 2 [sprout 1]
    ]
  ]

  ask patch 0 0 [set ptype 1]
  ask patch 10 10 [set ptype 2]
  ask patch -10 -10 [set ptype 3]

  ask turtles [
    set shape "circle"
    set ttype 1
    ;remeber the patch x y
    set px [pxcor] of patch-here
    set py [pycor] of patch-here
   ]
  update-color
end

;***************************
; 5.2, Verification Model Function
;***************************
to ver-p-growth
  update-et
  patches-natural-growth
  update-color
  ;tick
end

to ver-p-decline
  update-et
  patches-natural-decline
  update-color
end

to ver-a-growth
  update-et
  agents-natural-growth
  update-color
end

to ver-a-decline
  update-et
  agents-natural-decline
  update-color
end

to ver-a-move-back
  learn-by-moving
  update-color
end

to ver-a-gain
  ask turtles
  [
    if ttype = 1[setxy 0 0]
    if ttype = 2 [setxy 10 10]
    if ttype = 3 [setxy -10 -10]
  ]
  gain-skill
  update-color
end
;**********************
;********************************************
@#$#@#$#@
GRAPHICS-WINDOW
386
17
851
483
-1
-1
11.15
1
10
1
1
1
0
1
1
1
-20
20
-20
20
0
0
1
ticks
30.0

BUTTON
22
17
85
50
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
22
52
234
85
Per-Patches
Per-Patches
0
1
0.1
0.01
1
NIL
HORIZONTAL

BUTTON
87
17
161
50
NIL
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
162
17
234
50
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
19
175
195
208
Growth-Rate-PType-0-1
Growth-Rate-PType-0-1
0
1
0.05
0.01
1
NIL
HORIZONTAL

SLIDER
19
210
195
243
Growth-Rate-PType-1-2
Growth-Rate-PType-1-2
0
1
0.2
0.01
1
NIL
HORIZONTAL

MONITOR
1358
257
1494
302
Leaning Society 0 to 1
count patches with [p-evolve-type = 01]
0
1
11

MONITOR
1358
305
1495
350
Leaning Society 1 to 2
count patches with [p-evolve-type = 12]
0
1
11

SLIDER
18
245
194
278
Growth-Rate-PType-2-3
Growth-Rate-PType-2-3
0
1
0.2
0.01
1
NIL
HORIZONTAL

MONITOR
1358
352
1495
397
Leaning Society 2 to 3
count patches with [p-evolve-type = 23]
0
1
11

SLIDER
18
359
196
392
Growth-Rate-TType-0-1
Growth-Rate-TType-0-1
0
1
0.05
0.01
1
NIL
HORIZONTAL

SLIDER
18
395
196
428
Growth-Rate-TType-1-2
Growth-Rate-TType-1-2
0
1
0.2
0.01
1
NIL
HORIZONTAL

SLIDER
18
429
196
462
Growth-Rate-TType-2-3
Growth-Rate-TType-2-3
0
1
0.2
0.01
1
NIL
HORIZONTAL

PLOT
857
21
1182
216
Number of Agent with Differnt Skill Level
Time
Amount
1.0
100.0
1.0
200.0
false
true
"" ""
PENS
"Level 0" 1.0 0 -5987164 true "" "plot count turtles with [ttype = 0]"
"Level 1" 1.0 0 -2674135 true "" "plot count turtles with [ttype = 1]"
"Level 2" 1.0 0 -1184463 true "" "plot count turtles with [ttype = 2]"
"Level 3" 1.0 0 -14439633 true "" "plot count turtles with [ttype = 3]"

PLOT
1356
19
1701
214
Places with Different Digitalization Level
NIL
NIL
1.0
100.0
1.0
1600.0
false
true
"" ""
PENS
"Level 0" 1.0 0 -3026479 true "" "plot count patches with [ptype = 0]"
"Level 1" 1.0 0 -2139308 true "" "plot count patches with [ptype = 1]"
"Level 2" 1.0 0 -987046 true "" "plot count patches with [ptype = 2]"
"Level 3" 1.0 0 -11085214 true "" "plot count patches with [ptype = 3]"

SLIDER
199
246
385
279
Decline-Rate-PType-3-2
Decline-Rate-PType-3-2
0
1
0.2
0.01
1
NIL
HORIZONTAL

SLIDER
199
210
385
243
Decline-Rate-PType-2-1
Decline-Rate-PType-2-1
0
1
0.2
0.01
1
NIL
HORIZONTAL

SLIDER
199
174
386
207
Decline-Rate-PType-1-0
Decline-Rate-PType-1-0
0
1
0.1
0.01
1
NIL
HORIZONTAL

SLIDER
201
429
384
462
Decline-Rate-TType-3-2
Decline-Rate-TType-3-2
0
1
0.3
0.01
1
NIL
HORIZONTAL

SLIDER
201
395
385
428
Decline-Rate-TType-2-1
Decline-Rate-TType-2-1
0
1
0.3
0.01
1
NIL
HORIZONTAL

SLIDER
200
359
383
392
Decline-Rate-TType-1-0
Decline-Rate-TType-1-0
0
1
0.2
0.01
1
NIL
HORIZONTAL

PLOT
858
408
1193
649
Agents Moving Back
NIL
NIL
1.0
100.0
1.0
100.0
false
true
"" ""
PENS
"Level 0" 1.0 0 -3026479 true "" "plot count turtles with [ttype = 0 and back-loc = 1]"
"Level 1" 1.0 0 -2674135 true "" "plot count turtles with [ttype = 1 and back-loc = 1]"
"Level 2" 1.0 0 -4079321 true "" "plot count turtles with [ttype = 2 and back-loc = 1]"
"Level 3" 1.0 0 -14439633 true "" "plot count turtles with [ttype = 3 and back-loc = 1]"

SWITCH
243
113
344
146
P-Decline
P-Decline
0
1
-1000

SWITCH
256
304
365
337
A-Decline
A-Decline
0
1
-1000

TEXTBOX
20
157
218
187
Places Growth and Decline Rate
12
0.0
1

TEXTBOX
24
343
316
371
Dynamic Agents Growth and Decline Rate
11
0.0
1

TEXTBOX
195
108
248
150
Places\nNatrual\nDecline?
11
0.0
1

PLOT
1202
407
1726
647
Digital Mobility Index
NIL
NIL
1.0
100.0
0.0
1.0
false
false
"" ""
PENS
"pen-1" 1.0 0 -7500403 true "" "plot digital-mobility-index"

MONITOR
1201
653
1343
698
Digital Mobility Index
(count turtles with [ back-loc = 1 ]) / (count turtles)
3
1
11

TEXTBOX
203
307
252
342
Natural \nDecline?
11
0.0
1

SWITCH
78
113
182
146
P-Growth
P-Growth
0
1
-1000

SWITCH
71
304
180
337
A-Growth
A-Growth
0
1
-1000

MONITOR
1185
24
1325
69
Level 0 Dynamic Agent
count turtles with [ttype = 0]
17
1
11

MONITOR
1186
72
1325
117
Level 1 Dynamic Agent
count turtles with [ttype = 1]
17
1
11

MONITOR
1187
120
1326
165
Level 2 Dynamic Agent
count turtles with [ttype = 2]
17
1
11

MONITOR
1187
168
1327
213
Level 3 Dynamic Agent
count turtles with [ttype = 3]
17
1
11

MONITOR
858
652
1193
697
Dynamic Agent Goes Back to Previous Place
count turtles with [back-loc = 1]
17
1
11

MONITOR
857
256
1049
301
Leaning by Moving Agent 0 to 1
count turtles with [a-evolve-type = 101]
17
1
11

MONITOR
858
306
1049
351
Leaning by Moving Agent 1 to 2
count turtles with [a-evolve-type = 112]
17
1
11

MONITOR
859
358
1049
403
Leaning by Moving Agent 2 to 3
count turtles with [a-evolve-type = 123]
17
1
11

MONITOR
1054
257
1190
302
Leaning Society 0 to 1
count turtles with [a-evolve-type = 01]
17
1
11

MONITOR
1055
306
1191
351
Leaning Society 1 to 2
count turtles with [a-evolve-type = 12]
17
1
11

MONITOR
1057
359
1193
404
Leaning Society 2 to 3
count turtles with [a-evolve-type = 23]
17
1
11

TEXTBOX
858
225
1098
267
Dynamic Agent Gain Skills (Each Tick)\nMoving\n
11
0.0
1

TEXTBOX
1057
239
1207
257
Natural Growth
11
0.0
1

TEXTBOX
1194
224
1435
252
Agent Lose Skills (Each Ticks)\nNatural Decline\n
11
0.0
1

MONITOR
1193
257
1330
302
Leaning Society 1 to 0
count turtles with [a-evolve-type = 10]
17
1
11

MONITOR
1195
305
1328
350
Leaning Society 2 to 1
count turtles with [a-evolve-type = 21]
17
1
11

MONITOR
1196
358
1327
403
Leaning Society 3 to 2
count turtles with [a-evolve-type = 32]
17
1
11

TEXTBOX
1360
225
1685
267
Places with Change Digitlization Level (Each Tick)\nNatrual Growth\n
11
0.0
1

TEXTBOX
1502
243
1652
261
Natrual Decline
11
0.0
1

MONITOR
1498
258
1636
303
Leaning Society 1 to 0
count patches with [p-evolve-type = 10]
17
1
11

MONITOR
1499
307
1636
352
Leaning Society 2 to 1
count patches with [p-evolve-type = 21]
17
1
11

MONITOR
1500
353
1637
398
Leaning Society 3 to 2
count patches with [p-evolve-type = 32]
17
1
11

MONITOR
1347
653
1495
698
Total Dynamic Agents
count turtles
17
1
11

TEXTBOX
26
88
176
106
Places Paramter
12
0.0
1

TEXTBOX
26
106
73
148
Places\nNatural \nGrowth?
11
0.0
1

TEXTBOX
21
280
171
298
Dynamic Agent Paramter
12
0.0
1

TEXTBOX
22
306
71
334
Natural \nGrowth?
11
0.0
1

BUTTON
22
538
120
571
V-PGrowth
setup-ver-p-growth
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
23
507
173
525
Verification Fuctions\n
11
0.0
1

BUTTON
121
538
185
571
V1
ver-p-growth
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
22
577
120
610
V-PDecline
setup-ver-p-decline\n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
197
538
298
571
V-AGrowth
setup-ver-a-growth\n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
299
538
361
571
V3
ver-a-growth
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
299
576
362
609
V4
ver-a-decline
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
197
576
298
609
V-ADecline
setup-ver-a-decline
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
122
577
185
610
V2
ver-p-decline
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
23
522
173
540
Places\n
11
0.0
1

TEXTBOX
200
522
350
540
Agents
11
0.0
1

TEXTBOX
27
615
177
633
Movment Verification\n
11
0.0
1

BUTTON
23
631
116
664
V-AMoveBack
setup-ver-a-moveback
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
117
631
184
664
V5
ver-a-move-back
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
198
631
296
664
V-A-Gain
setup-ver-a-gain
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
297
631
360
664
V6
ver-a-gain
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.4.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="S1" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="100"/>
    <metric>digital-mobility-index</metric>
    <enumeratedValueSet variable="Per-Patches">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="P-Growth">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="P-Decline">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="A-Growth">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="A-Decline">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Growth-Rate-PType-0-1">
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Growth-Rate-PType-1-2">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Growth-Rate-PType-2-3">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Decline-Rate-PType-1-0">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Decline-Rate-PType-2-1">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Decline-Rate-PType-3-2">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Growth-Rate-TType-0-1">
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Growth-Rate-TType-1-2">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Growth-Rate-TType-2-3">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Decline-Rate-TType-1-0">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Decline-Rate-TType-2-1">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Decline-Rate-TType-3-2">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="S2" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="100"/>
    <metric>digital-mobility-index</metric>
    <enumeratedValueSet variable="Per-Patches">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="P-Growth">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="P-Decline">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="A-Growth">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="A-Decline">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Growth-Rate-PType-0-1">
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Growth-Rate-PType-1-2">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Growth-Rate-PType-2-3">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Decline-Rate-PType-1-0">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Decline-Rate-PType-2-1">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Decline-Rate-PType-3-2">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Growth-Rate-TType-0-1">
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Growth-Rate-TType-1-2">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Growth-Rate-TType-2-3">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Decline-Rate-TType-1-0">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Decline-Rate-TType-2-1">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Decline-Rate-TType-3-2">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="S3" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="100"/>
    <metric>digital-mobility-index</metric>
    <enumeratedValueSet variable="Per-Patches">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="P-Growth">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="P-Decline">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="A-Growth">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="A-Decline">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Growth-Rate-PType-0-1">
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Growth-Rate-PType-1-2">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Growth-Rate-PType-2-3">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Decline-Rate-PType-1-0">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Decline-Rate-PType-2-1">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Decline-Rate-PType-3-2">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Growth-Rate-TType-0-1">
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Growth-Rate-TType-1-2">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Growth-Rate-TType-2-3">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Decline-Rate-TType-1-0">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Decline-Rate-TType-2-1">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Decline-Rate-TType-3-2">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="S4" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="100"/>
    <metric>digital-mobility-index</metric>
    <enumeratedValueSet variable="Per-Patches">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="P-Growth">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="P-Decline">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="A-Growth">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="A-Decline">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Growth-Rate-PType-0-1">
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Growth-Rate-PType-1-2">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Growth-Rate-PType-2-3">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Decline-Rate-PType-1-0">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Decline-Rate-PType-2-1">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Decline-Rate-PType-3-2">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Growth-Rate-TType-0-1">
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Growth-Rate-TType-1-2">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Growth-Rate-TType-2-3">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Decline-Rate-TType-1-0">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Decline-Rate-TType-2-1">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Decline-Rate-TType-3-2">
      <value value="0.3"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@

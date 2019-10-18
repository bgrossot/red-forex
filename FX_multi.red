Red [needs: view]

system/view/debug?: no

PPAIRE: 1
PPIVOT: 2
TTENDANCE: 3
UURLPAIRE: 4

makefxurl: function [ paire ] [
    fxurl: copy "https://rates.fxcm.com/ShowAllCharts?s="
    append fxurl paire
    append fxurl "&period=short"
    to-url fxurl
]

filesav: %cross-multi.txt
cross: read/lines filesav
nbp: (length? cross) / 3
paires: make block! 0; contient les paires
clear paires
cpt: 0
loop nbp [
    unepaire: make block! 4; contient une paire : paire pivot tendance url
    append unepaire cross/(cpt + 1) ; paire
    append unepaire cross/(cpt + 2) ; pivot
    append unepaire cross/(cpt + 3) ; tendance : "buy" ou "sell"
    append unepaire makefxurl unepaire/1
    cpt: cpt + 3
    append/only paires unepaire
]

repeat i nbp
[
    print paires/(i)
]

;-- prompt-popup displays a message, a field for single-line input, and 
;--    'OK' and 'Cancel' buttons. Normally it returns a string, though it returns
;--    false if 'Cancel' is clicked, and none if the window is closed with 'X'.

prompt-popup: func [ msg ] [
    result: "" ;-- in case user closes window with 'X'
    view/flags [
        msg-text: text msg center return
        in-field: field focus
        on-enter [result: in-field/text unview]
        return
        yes-btn: button "OK" [result: in-field/text unview]
        no-btn: button "Cancel" [result: "" unview]
        ;do [
        ;    gap: 10 ;--between OK and Cancel
        ;    ;-- enlarge text if small
        ;    unless msg-text/size/x > (yes-btn/size/x + no-btn/size/x + gap) [
        ;        msg-text/size/x: yes-btn/size/x + no-btn/size/x + gap
        ;    ]

        ;    win-centre: (2 * msg-text/offset/x + msg-text/size/x) / 2 ;-- centre buttons
        ;    yes-btn/offset/x: win-centre - yes-btn/size/x - (gap / 2)
        ;    no-btn/offset/x: win-centre + (gap / 2)
        ;    in-field/size/x: 150
        ;    in-field/offset/x: win-centre - (in-field/size/x / 2)
        ;]
    ] [modal popup]
    result
]

popup-menu: func [ titre ] [
    result: "Aucun" ;-- in case user closes window with 'X'
    view/flags [
        title titre
        drop-list font-name "arial" font-size 22 bold center data [
        "AUDCAD" "AUDCHF" "AUDJPY" "AUDNZD" "AUDUSD"
        "CADCHF" "CADJPY" "CHFJPY"
        "EURAUD" "EURCAD" "EURCHF" "EURGBP" "EURJPY" "EURNZD" "EURUSD"
        "GBPAUD" "GBPCAD" "GBPCHF" "GBPJPY" "GBPNZD" "GBPUSD"
        "NZDCAD" "NZDCHF" "NZDJPY" "NZDUSD"
        "USDCAD" "USDCHF" "USDJPY"
    ] [result: pick face/data face/selected unview]
    ] [modal popup]
    result
]

val_fx: func [ url ] [
    flux: read url
    found: find flux "Rate: "
    refound: find found "<b>"
	sprefound: second split refound ">"
    return first split sprefound " "
]

setvaltend: function [ data [block!] ] [ ; "url gfx_paire gfx_pivot tendance" ; être dans un block permet le passage par référence
    strurl: reduce data/1
    objpaire: reduce data/2
    objpivot: reduce data/3
    strtendance: reduce data/4
    print "-----"
    print strurl
    print "-----"
    print objpaire/text
    print "-----"
    print objpivot/text
    print "-----"
    print strtendance
    print "-----"

    valf: val_fx strurl
    objpaire/text: valf
    either strtendance == "buy"
    [either (to-float valf) < (to-float objpivot/text) [objpaire/font/color: 128.0.0] [objpaire/font/color: 0.128.0]]
    [either (to-float valf) > (to-float objpivot/text) [objpaire/font/color: 128.0.0] [objpaire/font/color: 0.128.0]]
]

make-fx-paire: func [ ii [integer!]] [
    opivotname: to-word rejoin ["opivot" to-string ii]
    opairename: to-word rejoin ["opaire" to-string ii]
    resname1: to-word rejoin ["res1" to-string ii]
    resname2: to-word rejoin ["res2" to-string ii]

    pairepivot: to-path compose [paires (ii) (:PPIVOT)]
    probe pairepivot

    ; si tu veux rester une solution en ligne de commande, attention il y a un piège
    ; tout est fait au sein d'un "compose" !

    compose/deep [
        (to-set-word opivotname) text (paires/:ii/:PPIVOT) font-name "arial" font-size 22 bold
        on-down [(to-set-word resname1) prompt-popup "Entrez le pivot" "Pivot ?" if not empty? (resname1) [
                                                                                 (to-set-path pairepivot) copy (resname1)
                                                                                 obj: (opivotname)
                                                                                 obj/text: (pairepivot) ; (opivotname)/text ne fontionne pas
                                                                                 ;print type? obj
                                                                                 ;print type? obj/text
                                                                                 ; devrait fonctionner, ya un truc qui m'échappe
                                                                                 ;(to-set-path rejoin [(opivotname) "/text"]) "ppp"
        ] ]

        ; en attente de résulution du cas "ii"
        ;on-alt-down [
        ;            obj: (opivotname)           ; ya un truc qui m'échappe, cf. plus haut
        ;            either obj/font/color == blue [paires/:ii/:TTENDANCE: "sell" obj/font/color: red] [paires/:ii/:TTENDANCE: "buy" obj/font/color: blue
        ;] ]

        ;(to-set-word opairename) text "1.2345" font-name "arial" font-color black font-size 22 bold
        ;rate 0:0:10
        ;on-created [ setvaltend [ paires/:ii/:UURLPAIRE (opairename) (opivotname) paires/:ii/:TTENDANCE ]
        ;             obj: (opivotname)          ; ya un truc qui m'échappe, cf. plus haut
        ;             obj/font/color: to-tuple either paires/:ii/:TTENDANCE == "buy" [blue] [red] ]
    ]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;    opivot1: text pivot1 font-name "arial" font-size 22 bold
;;    on-down [res1: prompt-popup "Entrez le pivot" "Pivot1 ?" if not empty? res1 [pivot1: res1 opivot1/text: res1] ] 
;;    on-alt-down [either opivot1/font/color == blue [tendance1: "sell" opivot1/font/color: red] [tendance1: "buy" opivot1/font/color: blue] ]

;;;;;;;;;;;    opaire1: text "1.2345" font-name "arial" font-color black font-size 22 bold
;;;;;;;;;;;    rate 0:0:10
;;;;;;;;;;;    on-created [ setvaltend [ paire1url opaire1 opivot1 tendance1 ]
;;;;;;;;;;;                 opivot1/font/color: to-tuple either tendance1 == "buy" [blue] [red] ]
;;;;;;;;;;;    on-time [ setvaltend [ paire1url opaire1 opivot1 tendance1 ] ]

;;;;;;;;;;;    with [menu: ["Sauvegarde" change]]
;;;;;;;;;;;    on-menu [
;;;;;;;;;;;       if event/picked = 'change [
;;;;;;;;;;;            write/lines filesav reduce [paire1 pivot1 tendance1]
;;;;;;;;;;;       ]
;;;;;;;;;;;    ]
;;;;;;;;;;;    on-down [res2: popup-menu "Choix d'une paire" paire1: res2 paire1url: makefxurl res2]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
]

the-head: [
    across
    origin 0x0
    ]

thewindow: append [] the-head

cpt: 1
repeat i nbp [
    paire: copy paires/:i/:PPAIRE
    pivot: copy paires/:i/:PPIVOT
    tendance: copy paires/:i/:TTENDANCE
    urlpaire: copy paires/:i/:UURLPAIRE
    print paire
    print pivot
    print tendance
    print urlpaire
    ;append thewindow make-fx-paire urlpaire pivot tendance cpt
    append thewindow make-fx-paire i
]

;print thewindow

view layout thewindow 

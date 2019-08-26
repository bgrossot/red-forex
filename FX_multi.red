Red [needs: view]

system/view/debug?: no

makefxurl: function [ paire ] [
    fxurl: copy "https://rates.fxcm.com/ShowAllCharts?s="
    append fxurl paire
    append fxurl "&period=short"
    to-url fxurl
]

filesav: %cross-multi.txt
cross: read/lines filesav
nbp: (length? cross) / 3
paires: copy [] ; contient les paires : paire pivot tendance
cpt: 0
loop nbp [
    paire: cross/(cpt + 1)
    append paires paire ; paire
    append paires cross/(cpt + 2) ; pivot
    append paires cross/(cpt + 3) ; tendance : "buy" ou "sell"
    append paires makefxurl paire
    cpt: cpt + 3
]
print paires

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

val_fx: func [] [
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

    valf: val_fx strurl objpaire/text: valf
    either strtendance == "buy"
    [either (to-float valf) < (to-float objpivot/text) [objpaire/font/color: 128.0.0] [objpaire/font/color: 0.128.0]]
    [either (to-float valf) > (to-float objpivot/text) [objpaire/font/color: 128.0.0] [objpaire/font/color: 0.128.0]]
]

make-fx-paire: func [ paire [url!] pivot [string!] tendance [tuple!] cpt [integer!]] [
    opivotname: to-word rejoin ["opivot" to-string cpt]
    compose/deep [
    (to-set-word opivotname) text (pivot) font-name "arial" font-color (tendance) font-size 22 bold
    ;on-alt-down [either (to-set-path [(opivotname) font color]) == blue [opivot/font/color: red] [opivot/font/color: blue] ]
    on-alt-down [if [ to-path compose [(to-word opivotname) font color] == blue ] [ print to-path compose [(to-word opivotname) font color]  ] ]

    opaire1: text "1.2345" font-name "arial" font-color black font-size 22 bold
    rate 0:0:10
    on-time [valf1: val_fx paire1 opaire1/text: valf1
             either  opivot1/font/color == blue
             [either (to-float valf1) < (to-float opivot1/text) [opaire1/font/color: 128.0.0] [opaire1/font/color: 0.128.0]]
             [either (to-float valf1) > (to-float opivot1/text) [opaire1/font/color: 128.0.0] [opaire1/font/color: 0.128.0]]
            ]
    on-down [res2: prompt-popup "Paire1 ?" paire1: makefxurl res2]
    ]
]

make-head: func [] [
    compose [
    across
    origin 0x0
    ]
]

thewindow: append [] make-head

cpt: 0
loop nbp [
    paire: copy paires/(cpt + 1)
    pivot: copy paires/(cpt + 2)
    tendance: copy paires/(cpt + 3)
    urlpaire: copy paires/(cpt + 4)
    print paire
    print pivot
    print tendance
    print urlpaire
    append thewindow make-fx-paire urlpaire pivot to-tuple tendance cpt
    cpt: cpt + 4
]

view thewindow 
; layout [
;    across
;    origin 0x0

;make-test
;cpt: 0
;loop nbp [
;paire: copy paires/(cpt + 1)
;    pivot: copy paires/(cpt + 2)
;    tendance: copy paires/(cpt + 3)
;    cpt: cpt + 3

    ;ftarg: text target font-name "arial" font-color trend font-size 22 bold
    ;on-down [res1: prompt-popup "target" if not empty? res1 [ftarg/text: res1] ] 
    ;on-alt-down [either ftarg/font/color == blue [ftarg/font/color: red] [ftarg/font/color: blue] ]

    ;t: text "1.2345" font-name "arial" font-color black font-size 22 bold
    ;rate 0:0:15
    ;on-time [t/text: val_fx]
    ;on-down [res2: prompt-popup "paire" makefxurl res2]
;]

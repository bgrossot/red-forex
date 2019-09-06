Red [needs: view]

system/view/debug?: no

makefxurl: function [ paire ] [
    fxurl: copy "https://rates.fxcm.com/ShowAllCharts?s="
    append fxurl paire
    append fxurl "&period=short"
    to-url fxurl
]

filesav: %cross-2.txt
cross: read/lines filesav
paire1: cross/1
pivot1: cross/2
tendance1: cross/3 ; "buy" ou "sell"
paire1url: makefxurl paire1
paire2: cross/4
pivot2: cross/5
tendance2: cross/6 ; "buy" ou "sell"
paire2url: makefxurl paire2

;-- prompt-popup displays a message, a field for single-line input, and 
;--    'OK' and 'Cancel' buttons. Normally it returns a string, though it returns
;--    false if 'Cancel' is clicked, and none if the window is closed with 'X'.

prompt-popup: func [ msg ] [
    result: none ;-- in case user closes window with 'X'
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

    valf: val_fx strurl objpaire/text: valf
    either strtendance == "buy"
    [either (to-float valf) < (to-float objpivot/text) [objpaire/font/color: 128.0.0] [objpaire/font/color: 0.128.0]]
    [either (to-float valf) > (to-float objpivot/text) [objpaire/font/color: 128.0.0] [objpaire/font/color: 0.128.0]]
]

coltend1: to-tuple either tendance1 == "buy" [blue] [red]
coltend2: to-tuple either tendance2 == "buy" [blue] [red]

view layout [
    title "Surveillance FX"
    across
    origin 0x0

    opivot1: text pivot1 font-name "arial" font-color coltend1 font-size 22 bold
    on-down [res1: prompt-popup "Entrez le pivot" "Pivot1 ?" if not empty? res1 [pivot1: res1 opivot1/text: res1] ] 
    on-alt-down [either opivot1/font/color == blue [tendance1: "sell" opivot1/font/color: red] [tendance1: "buy" opivot1/font/color: blue] ]

    opaire1: text "1.2345" font-name "arial" font-color black font-size 22 bold
    rate 0:0:10
    on-created [ setvaltend [ paire1url opaire1 opivot1 tendance1 ] ]
    on-time [ setvaltend [ paire1url opaire1 opivot1 tendance1 ] ]
    on-down [res3: popup-menu "Choix d'une paire" paire1: res3 paire1url: makefxurl res3]

    opivot2: text pivot2 font-name "arial" font-color coltend2 font-size 22 bold
    on-down [res2: prompt-popup "Entrez le pivot" "Pivot2 ?" if not empty? res2 [pivot2: res2 opivot2/text: res2] ] 
    on-alt-down [either opivot2/font/color == blue [tendance2: "sell" opivot2/font/color: red] [tendance2: "buy" opivot2/font/color: blue] ]

    opaire2: text "1.2345" font-name "arial" font-color black font-size 22 bold
    rate 0:0:10
    on-created [ setvaltend [ paire2url opaire2 opivot2 tendance2 ] ]
    on-time [ setvaltend [ paire2url opaire2 opivot2 tendance2 ] ]
    on-down [res4: popup-menu "Choix d'une paire" paire1: res4 paire1url: makefxurl res4]

    with [menu: ["Sauvegarde" change]]
    on-menu [
       if event/picked = 'change [
            write/lines filesav reduce [paire1 pivot1 tendance1]
            write/lines filesav reduce [paire2 pivot2 tendance2]
       ]
    ]
]

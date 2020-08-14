#NoEnv
#Warn
SendMode Input
SetWorkingDir %A_ScriptDir%

ObjIndexOf(obj, item, case_sensitive := false) {
	for i, val in obj {
		if (case_sensitive ? (val == item) : (val = item))
			return i
	}
}

Scale(xy) {
    if A_ScreenHeight = 1080
         return xy
    if A_ScreenHeight = 1440
        if xy is integer
           return Floor(xy * (4/3))
        else
           return [Floor(xy[1] * (4/3)), Floor(xy[2] * (4/3))]
    else
        MsgBox Unsupported resolution
        ExitApp
}

global char_xy        := Scale([1000, 1060])
global dealers_xy     := Scale([1120, 1060])
global flea_market_xy := Scale([1220, 1060])

global dealer_nav_sell_xy := Scale([250, 45])

global dealers_grid_xy := Scale([625, 330])
global dealers_grid_card_dimensions := Scale([160, 205])
global dealers_grid_gutter_size := Scale(10)

global deal_btn_xy := Scale([850, 165])
global flea_market_search_box_xy := Scale([270, 120])
global flea_market_add_offer_xy := Scale([1300, 80])
global flea_market_refresh_xy := Scale([1835, 115])
global flea_market_gear_xy := Scale([480, 85])
global flea_market_filters_remove_bartering_offers_xy := Scale([513, 278])
global flea_market_filters_ok_xy := Scale([610, 430])
global flea_market_filters_currency_xy := Scale([655, 120])
global flea_market_filters_currency_rub_xy := Scale([655, 177])

global dealers := ["prapor", "therapist", "fence", "skier", "peacekeeper", "mechanic", "ragman", "jaeger"]
global dealers_per_row = 4

LeftClick(xy) {
    MouseClick, left, xy[1], xy[2], 1, 0
}

GetDealerCoords(index) {
    row_index := Mod(index, dealers_per_row)
    row := Floor(index / dealers_per_row)
    x := dealers_grid_xy[1] + (row_index * (dealers_grid_card_dimensions[1] + dealers_grid_gutter_size)) + 10
    y := dealers_grid_xy[2] + (row * (dealers_grid_card_dimensions[2] + dealers_grid_gutter_size)) + 10
    return [x, y]
}

GotoDealer(dealer_name) {
    index := ObjIndexOf(dealers, dealer_name) - 1
    coords := GetDealerCoords(index)
    x := coords[1], y := coords[2]
    MouseGetPos, start_x, start_y
    LeftClick(dealers_xy)
    Sleep 100
    LeftClick([x, y])
    Sleep 500
    ; Loading Fence's view appears to take longer
    if (dealer_name == "fence") {
        Sleep 500
    }
    if (dealer_name == "mechanic") {
        Sleep 500
    }
    LeftClick(dealer_nav_sell_xy)
    Sleep 200
    MouseMove, %start_x%, %start_y%, 0
}

GotoCharacter() {
    MouseGetPos, start_x, start_y
    LeftClick(char_xy)
    Sleep 30
    MouseMove, %start_x%, %start_y%, 0
}

GotoFleaMarket() {
    MouseGetPos, start_x, start_y
    LeftClick(flea_market_xy)
    Sleep 100
    LeftClick(flea_market_search_box_xy)
    Sleep 30
    MouseMove, %start_x%, %start_y%, 0
}

; This does not work reliably because position of "Filter by item" in the
; context menu varies
FilterByItem() {
    MouseGetPos, start_x, start_y
    MouseClick, right, , , 1, 0
    Sleep 25
    MouseClick, left, 10, -70, 1, 0,, R
    Sleep 40
    MouseMove, %start_x%, %start_y%, 0
}

Sell() {
    FilterByItem()
    Sleep 100
    MouseGetPos, start_x, start_y
    LeftClick(flea_market_add_offer_xy)
    Sleep 100
    MouseMove, 1200, 155, 0
    Sleep 150
    Click, Down
    Sleep, 50
    MouseMove, -300, 0, 0, R
    Sleep, 50
    Click, Up
    MouseMove, %start_x%, %start_y%, 0
}

RefreshFleaMarket() {
    MouseGetPos, start_x, start_y
    LeftClick(flea_market_refresh_xy)
    Sleep, 20
    MouseMove, %start_x%, %start_y%, 0
}

Deal() {
    MouseGetPos, start_x, start_y
    LeftClick(deal_btn_xy)
    Sleep, 50
    MouseMove, %start_x%, %start_y%, 0
}

LeftClickAll(xys, delay) {
    For index, xy in xys {
        LeftClick(xy)
        Sleep, 50
    }
}

RemoveBarteringOffers() {
    MouseGetPos, start_x, start_y
    LeftClickAll([
(Join,
    flea_market_gear_xy,
    flea_market_filters_remove_bartering_offers_xy,
    flea_market_filters_currency_xy,
    flea_market_filters_currency_rub_xy,
    flea_market_filters_ok_xy
)], 50)
    MouseMove, %start_x%, %start_y%, 0
}

#IfWinActive, EscapeFromTarkov

!^c::GotoCharacter()

!^1::GotoDealer("prapor")
!^2::GotoDealer("therapist")
!^3::GotoDealer("fence")
!^4::GotoDealer("skier")
!^q::GotoDealer("peacekeeper")
!^w::GotoDealer("mechanic")
!^e::GotoDealer("ragman")
!^r::GotoDealer("jaeger")
!^f::FilterByItem()
!^v::Sell()
!^d::Deal()
!^b::RemoveBarteringOffers()
!^t::GotoFleaMarket()

; For scrolling the stash faster
!^WheelUp::Send, {WheelUp 5}
!^WheelDown::Send, {WheelDown 5}

#IfWinActive, ahk_exe Code.exe

~^s:: 
    Sleep, 300
    Reload
return

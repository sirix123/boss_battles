"use strict";

// events
GameEvents.Subscribe( "picking_done", OnPickingDone );
GameEvents.Subscribe( "player_reconnect", OnPickingDone );
GameEvents.Subscribe( "send_product_list", OnPickingDone );
GameEvents.Subscribe( "open_shop_external", OnServerSendOpenShop );
GameEvents.Subscribe( "update_shop_product_list", OnServerUpdatePlayerShop );


/* Event Handlers
=========================================================================*/
/* After picking is done spawn the shop button */
const product_list = [];
function OnPickingDone( data ) {

    var rootPanel = $("#ShopButtonPanel");
	rootPanel.RemoveClass("hidden");

    $('#ShopButtonPanel').style.visibility = 'visible';

    for (let i = 1; data[i] !== undefined; i++) {
    	let products = [];
        for(let j = 1; data[i]["products"][j] !== undefined; j++)
        {
			products.push(data[i]["products"][j]);
        }
        let heroProductMap = { 
        	hero: data[i]["hero"],
        	products: products
         };
     	product_list.push(heroProductMap);
    }

    $.Msg("product_list, ",product_list)

}

/* When player presses the buy button server returns a url with their steamid */
function OnServerSendOpenShop( data ) {

    let end_url = "";
    for (let i = 1; data[i] !== undefined; i++) {
        end_url = data[i]; 
    }

    var start_url = "https://";
    $.DispatchEvent("ExternalBrowserGoToURL",  start_url.concat(end_url) ); 
}

/* when the server sends an updated shop list based on purchases change buttons from buy to equip if they have purchased */
const player_purchase_list = [];
function OnServerUpdatePlayerShop( data ) {
    //$.Msg("OnServerUpdatePlayerShop data ",data)
    //OnServerUpdatePlayerShop data {"1":{"steam_id":"76561197972850274","purchased_list":{"product_1":1,"product_2":1,"product_3":1}}}

    for (let i = 1; data[i] !== undefined; i++) {
        player_purchase_list.push(data[i]); 
    }

    $.Msg("player_purchase_list ",player_purchase_list)
}

/* Button Event Handlers
=========================================================================*/
function OnShopButtonPressed(){

    var rootPanelMainShop = $("#ParentShopPanel");
    rootPanelMainShop.RemoveClass("hidden");

	let productListContainer = $("#ProductListContainer");

	//for (let i=0; i < product_list.length; i++){
    for (const [key, value] of Object.entries(product_list)) {
        //$.Msg("property ", key); property 0
        //$.Msg("product_list ", value); product_list {"hero":"npc_dota_hero_juggernaut","products":["698c6222-4043-4dd0-8c2e-1b1c8c4c65cb"]}
        //for (let j=0; j < product_list[j]["products"].length; j++){
        $.Msg("value[products].length ",value["products"].length)
        for (let i = 0; i < value["products"].length; i++) {

            $.Msg("value[products][i] ", value["products"][i]);

            /*
             product_list[j][products] ead33daf-8779-4b26-9a61-4841a7587302
                product_list[j][products] 39607c1c-7ed0-4377-a1f8-0d7d5ca980cf
                product_list[j][products] 
                product_list[j][products] */

            let productPanel = $.CreatePanel("Panel", productListContainer, value["products"][i]);
            productPanel.BLoadLayoutSnippet("ProductList");

            let buyButton = productPanel.FindChildInLayoutFile("ProductPurchaseButton");

            let playerId = Players.GetLocalPlayer()
            let player_hero = Players.GetPlayerSelectedHero( playerId )

            // player purchase list is an object.. below code doesnt work

            // check the product list against the player purcahse list whenever the shop is loaded, 
            /*for (let k=0; k < player_purchase_list.length; k++){
                if(value["products"][i] == player_purchase_list[k])
                {
                    // show the equip button if theyre the correct hero
                    if( player_hero == product_list[i] )
                    {
                        let buyButtonTxt = productPanel.FindChildInLayoutFile("ProductPurchaseButtonTxt");
                        buyButton.RemoveClass( "disabled" );
                        buyButtonTxt.text = "Equip";
                        buyButton.SetPanelEvent( 'onactivate', function () {
                            OnEquipButtonPressed( buyButton );
                        });

                        $.Msg("setting button to equip enabled")
                    }
                    // disable if not the correct hero
                    else
                    {
                        let buyButtonTxt = productPanel.FindChildInLayoutFile("ProductPurchaseButtonTxt");
                        buyButton.AddClass( "disabled" );
                        buyButtonTxt.text = "Equip";
                        buyButton.ClearPanelEvent( 'onactivate' )

                        $.Msg("setting button to equip disabled")
                    }
    
                }
                //else show the buy button
                else
                {
                    let buyButtonTxt = productPanel.FindChildInLayoutFile("ProductPurchaseButtonTxt");
                    buyButtonTxt.text = "Buy now!";
                    buyButton.SetPanelEvent( 'onactivate', function () {
                        OnBuyButtonPressed( buyButton, buyButtonTxt );
                    });

                    $.Msg("setting button to buy now enabled")
                }
            }*/
        }
	}
}

function OnBuyButtonPressed( buyButton, buyButtonTxt ){

    // disable the button to show something is happening...
    buyButton.AddClass( "disabled" );
    buyButtonTxt.text = "Processing...";
    buyButtonTxt.AddClass( "disabled" );
    buyButton.ClearPanelEvent( 'onactivate' )

    GameEvents.SendCustomGameEventToServer( "player_pressed_buy_button", { } );

}

function OnEquipButtonPressed(  ){
    GameEvents.SendCustomGameEventToServer( "player_pressed_equip_button", { } );
}

function OnShopCloseButtonPressed(){

    var rootPanelMainShop = $("#ParentShopPanel");
	rootPanelMainShop.SetHasClass("hidden", true);
}

/* runs when client loads files
=========================================================================*/
(function () {
	var rootPanel = $("#ShopButtonPanel");
	rootPanel.SetHasClass("hidden", true);

    var rootPanelMainShop = $("#ParentShopPanel");
	rootPanelMainShop.SetHasClass("hidden", true);
})();


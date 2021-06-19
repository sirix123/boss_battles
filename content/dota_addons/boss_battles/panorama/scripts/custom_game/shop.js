"use strict";

// events
GameEvents.Subscribe( "picking_done", OnPickingDone );
GameEvents.Subscribe( "player_reconnect", OnPickingDone );
GameEvents.Subscribe( "send_product_list", OnPickingDone );
GameEvents.Subscribe( "open_shop_external", OnServerSendOpenShop );
GameEvents.Subscribe( "update_shop_product_list", OnServerUpdatePlayerShop );
GameEvents.Subscribe( "shop_status", OnServerShopStatus );

/* Event Handlers
=========================================================================*/
/* After picking is done spawn the shop button */
const product_list = [];
function OnPickingDone( data ) {

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

    //$.Msg("product_list, ",product_list)

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
let player_purchase_list = [];
function OnServerUpdatePlayerShop( data ) {

    for (let i = 1; data[i] !== undefined; i++) {
    	let products_purchased = [];
        for(let j = 1; data[i][j] !== undefined; j++)
        {
			products_purchased.push(data[i][j]);
        }
        let heroProductMap = {
        	products_purchased: products_purchased
         };
     	player_purchase_list.push(heroProductMap);
    }

    //$.Msg("player_purchase_list ",player_purchase_list)
}

/* if the shop server is down disable the buttona nd close the shop if its open*/
function OnServerShopStatus( data ) {

    if ( data.shop_status == 0 )
    {
        let shopButtonContainer = $("#ShopButtonPanel");
        shopButtonContainer.style.visibility = 'visible';
        shopButtonContainer.RemoveClass("hidden");
        shopButtonContainer.AddClass( "disabled" );
        shopButtonContainer.ClearPanelEvent( 'onactivate' )

        let shopButton = shopButtonContainer.FindChildInLayoutFile("ShopButton");
        shopButton.AddClass( "disabled" );
        shopButton.ClearPanelEvent( 'onactivate' )
    
        let productListContainer = $("#ProductListContainer");
        for (let i = 0; i < productListContainer.GetChildCount(); i++  )
        {
            var child = productListContainer.GetChild(i)
            child.DeleteAsync(0);
        }
        var rootPanelMainShop = $("#ParentShopPanel");
        rootPanelMainShop.SetHasClass("hidden", true);
    }

    if( data.shop_status ==  1)
    {
        let shopButtonContainer = $("#ShopButtonPanel");
        shopButtonContainer.style.visibility = 'visible';
        shopButtonContainer.RemoveClass("hidden");

        let shopButton = shopButtonContainer.FindChildInLayoutFile("ShopButton");
        let shopButtonTxt = shopButtonContainer.FindChildInLayoutFile("ShopButtonLabel");
        shopButtonTxt.RemoveClass( "disabled" );
        shopButton.RemoveClass( "disabled" );

        shopButton.SetPanelEvent( 'onactivate', function () {
            OnShopButtonPressed();
        });
    }
}

/* Button Event Handlers
=========================================================================*/
function OnShopButtonPressed(){

    var rootPanelMainShop = $("#ParentShopPanel");
    rootPanelMainShop.RemoveClass("hidden");

	let productListContainer = $("#ProductListContainer");

    for (let [key, value] of Object.entries(product_list)) {
        for (let i = 0; i < value["products"].length; i++) {

            let productPanel = $.CreatePanel("Panel", productListContainer, value["products"][i]);
            productPanel.BLoadLayoutSnippet("ProductList");

            let buyButton = productPanel.FindChildInLayoutFile("ProductPurchaseButton");

            // get appropriate image for the product id provided
            let image_name = GetProductImage(value["products"][i]);
            let heroImage = productPanel.FindChildInLayoutFile('HeroImage');


            var new_portrait = '<MoviePanel id="portrait_'+image_name+'" class="ProductDisplayPictureContainer" src="file://{resources}/videos/heroes/'+image_name+'.webm" repeat="true" autoplay="onload"/>'
            productPanel.BCreateChildren(new_portrait) 

            //file://{resources}/videos/heroes/npc_dota_hero_sven.webm
            //heroImage.src('file://{images}/heroes/selection/' + image_name + '.webm');

            /*if( image_name ){
                heroImage.SetImage('file://{images}/heroes/selection/' + image_name + '.png');
                heroImage.style.backgroundImage = 'url("file://{images}/heroes/' + image_name + '.png")';
                heroImage.style.backgroundSize = "100% 100%";
            }*/
           
            let playerId = Players.GetLocalPlayer()
            let player_hero = Players.GetPlayerSelectedHero( playerId )

            // check the product list against the player purcahse list whenever the shop is loaded, 
            for (let [key2, value2] of Object.entries(player_purchase_list)) {
                for (let j = 0; j < value2["products_purchased"].length; j++) {
                    if(value2["products_purchased"][j] == value["products"][i])
                    {
                        // show the equip button if theyre the correct hero
                        if( player_hero == value["hero"])
                        {
                            let buyButtonTxt = productPanel.FindChildInLayoutFile("ProductPurchaseButtonTxt");
                            buyButton.RemoveClass( "disabled" );
                            buyButtonTxt.text = "Equip";
                            buyButton.product = value2["products_purchased"][j];
                            buyButton.SetPanelEvent( 'onactivate', function () {
                                OnEquipButtonPressed( buyButton.product );
                            });

                            //$.Msg("setting button to equip enabled")
                            break;
                        }
                        // disable if not the correct hero
                        else
                        {
                            let buyButtonTxt = productPanel.FindChildInLayoutFile("ProductPurchaseButtonTxt");
                            buyButton.AddClass( "disabled" );
                            buyButtonTxt.text = "Incorrect hero";
                            buyButton.ClearPanelEvent( 'onactivate' )

                            //$.Msg("setting button to equip disabled")
                            break;
                        }
        
                    }
                    //else show the buy button
                    else
                    {
                        let buyButtonTxt = productPanel.FindChildInLayoutFile("ProductPurchaseButtonTxt");
                        buyButton.RemoveClass( "disabled" );
                        buyButtonTxt.text = "Buy now!";
                        buyButton.SetPanelEvent( 'onactivate', function () {
                            OnBuyButtonPressed( buyButton, buyButtonTxt );
                        });

                        //$.Msg("setting button to buy now enabled")
                    }
                }
            }
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

function OnEquipButtonPressed( product_id ){

    let playerId = Players.GetLocalPlayer()
    let player_hero = Players.GetPlayerSelectedHero( playerId )
    GameEvents.SendCustomGameEventToServer( "player_pressed_equip_button", { player_hero, product_id } );
}

function OnShopCloseButtonPressed(){

    let productListContainer = $("#ProductListContainer");

    for (let i = 0; i < productListContainer.GetChildCount(); i++  )
	{
		var child = productListContainer.GetChild(i)
		child.DeleteAsync(0);
	}

    var rootPanelMainShop = $("#ParentShopPanel");
	rootPanelMainShop.SetHasClass("hidden", true);
}

/*
=========================================================================*/
function GetProductImage( product_id ){
    if( product_id == "ed05d5ae-8383-47e1-9723-a8daa17c8695"){
        return "npc_dota_hero_crystal_maiden_alt1";
    }

    if( product_id == "1111111-4043-4dd0-8c2e-1b1c8c4c65cb"){
        return "npc_dota_hero_queenofpain_alt1";
    }
}

/* runs when client loads files
=========================================================================*/
(function () {
	var rootPanel = $("#ShopButtonPanel");
	rootPanel.SetHasClass("hidden", true);

    var rootPanelMainShop = $("#ParentShopPanel");
	rootPanelMainShop.SetHasClass("hidden", true);
})();

